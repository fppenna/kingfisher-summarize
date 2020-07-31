import csv
import json
import logging
import logging.config
import os.path
import re
from contextlib import contextmanager
from datetime import datetime

import click
from psycopg2 import sql
from psycopg2.extras import execute_values

from ocdskingfisherviews import (do_correct_user_permissions, do_field_counts, do_refresh_views, get_schemas,
                                 read_sql_files)
from ocdskingfisherviews.db import commit, get_connection, get_cursor, pluck, schema_exists, set_search_path

logger = logging.getLogger('foo')
logger.info('bar')


@contextmanager
def log_exception():
    """
    Logs and re-raises any exceptions in the block.
    """
    logger = logging.getLogger('ocdskingfisher.views.cli')

    try:
        yield
    except Exception as e:
        logger.exception(e)
        raise


def validate_collections(ctx, param, value):
    """
    Returns a list of collection IDs. Raises an error if an ID isn't in the collection table.
    """
    try:
        ids = tuple(int(_id) for _id in value.split(','))
    except ValueError:
        raise click.BadParameter(f'Collection IDs must be integers')

    difference = set(ids) - set(pluck('SELECT id FROM collection WHERE id IN %(ids)s', {'ids': ids}))
    if difference:
        raise click.BadParameter(f'Collection IDs {difference} not found')

    return ids


def validate_name(ctx, param, value):
    """
    Returns a schema name. Raises an error if the schema isn't in the database.
    """
    schema = f'view_data_{value}'

    if not schema_exists(schema):
        raise click.BadParameter(f'SQL schema "{schema}" not found')

    return schema


@click.group()
@click.pass_context
def cli(ctx):
    path = os.path.expanduser('~/.config/ocdskingfisher-views/logging.json')
    if os.path.isfile(path):
        with open(path) as f:
            logging.config.dictConfig(json.load(f))
    else:
        logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

    logger = logging.getLogger('ocdskingfisher.views.cli')
    logger.info(f'Running {ctx.invoked_subcommand}')

    global connection
    connection = get_connection()

    global cursor
    cursor = get_cursor()


@click.command()
@click.argument('collections', callback=validate_collections)
@click.argument('note')
@click.option('--name', help='A custom name for the SQL schema ("view_data_" will be prepended).')
@click.option('--dontbuild', is_flag=True, help="Don't run the refresh-views, field-counts and "
                                                "correct-user-permissions commands.")
@click.option('--tables-only', is_flag=True, help='Create SQL tables instead of SQL views.')
@click.option('--threads', type=int, default=1, help='The number of threads for the field-counts command to use '
                                                     '(up to the number of collections).')
def add_view(collections, note, name, dontbuild, tables_only, threads):
    """
    Creates a schema containing summary tables about one or more collections.

    \b
    COLLECTIONS is one or more comma-separated collection IDs
    NOTE is your name and a description of your purpose
    """
    logger = logging.getLogger('ocdskingfisher.views.add-view')

    if not name:
        if len(collections) > 5:
            raise click.UsageError('--name is required for more than 5 collections')
        name = f"collection_{'_'.join(str(_id) for _id in sorted(collections))}"

    schema = f'view_data_{name}'
    cursor.execute(sql.SQL('CREATE SCHEMA {schema}').format(schema=sql.Identifier(schema)))
    set_search_path([schema])

    cursor.execute('CREATE TABLE selected_collections(id INTEGER PRIMARY KEY)')
    execute_values(cursor, 'INSERT INTO selected_collections (id) VALUES %s', [(_id,) for _id in collections])

    cursor.execute('CREATE TABLE note(id SERIAL, note TEXT NOT NULL, created_at TIMESTAMP WITHOUT TIME ZONE)')
    cursor.execute(sql.SQL('INSERT INTO note (note, created_at) VALUES (%(note)s, %(at)s)'),
                   {'note': note, 'at': datetime.utcnow()})

    cursor.execute('ANALYZE selected_collections')
    commit()

    logger.info(f'Added {name}')

    if not dontbuild:
        message = [f'Running refresh-views {name}']
        if tables_only:
            message.append(' --tables-only')
        logger.info(''.join(message))
        do_refresh_views(cursor, schema, tables_only=tables_only)

        message = [f'Running field-counts {name}']
        if threads != 1:
            message.append(f' --threads {threads}')
        logger.info(''.join(message))
        do_field_counts(cursor, schema, threads=threads)

        logger.info('Running correct-user-permissions')
        do_correct_user_permissions(cursor)


@click.command()
@click.argument('name', callback=validate_name)
def delete_view(name):
    """
    Drops a schema.

    NAME is the last part of a schema's name after "view_data_".
    """
    logger = logging.getLogger('ocdskingfisher.views.cli.delete-view')

    # `CASCADE` drops all objects (tables, functions, etc.) in the schema.
    statement = sql.SQL('DROP SCHEMA {schema} CASCADE').format(schema=sql.Identifier(name))
    cursor.execute(statement)
    commit()

    logger.info(statement.as_string(connection))


@click.command()
def list_views():
    """
    Lists the schemas, with collection IDs and creator's notes.
    """
    for schema in get_schemas():
        click.echo(f'-----\nName: {schema[10:]}\nSchema: {schema}')

        cursor.execute(sql.SQL('SELECT id FROM {table} ORDER BY id').format(
            table=sql.Identifier(schema, 'selected_collections')))
        for row in cursor.fetchall():
            click.echo(f"Collection ID: {row[0]}")

        cursor.execute(sql.SQL('SELECT note, created_at FROM {table} ORDER BY created_at').format(
            table=sql.Identifier(schema, 'note')))
        for row in cursor.fetchall():
            click.echo(f"Note: {row[0]} ({row[1].strftime('%Y-%m-%d %H:%M:%S')})")


@click.command()
@click.argument('name', callback=validate_name)
@click.option('--remove', is_flag=True, help='Drop the summary tables from the schema')
@click.option('--tables-only', is_flag=True, help='Create SQL tables instead of SQL views')
def refresh_views(name, remove, tables_only):
    """
    Creates (or re-creates) the summary tables in a schema.

    NAME is the last part of a schema's name after "view_data_".
    """
    with log_exception():
        do_refresh_views(cursor, name, remove=remove, tables_only=tables_only)


@click.command()
@click.argument('name', callback=validate_name)
@click.option('--remove', is_flag=True, help='Drop the field_counts table from the schema')
@click.option('--threads', type=int, default=1, help='The number of threads to use (up to the number of collections)')
def field_counts(name, remove, threads):
    """
    Creates (or re-creates) the field_counts table in a schema.

    NAME is the last part of a schema's name after "view_data_".
    """
    cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = %(schema)s "
                   "AND table_name = 'release_summary_with_data'", {'schema': name})
    if not cursor.fetchone():
        raise click.UsageError('release_summary_with_data table not found. Run refresh-views first.')

    with log_exception():
        do_field_counts(cursor, name, remove=remove, threads=threads)


@click.command()
def correct_user_permissions():
    """
    Grants the users in the views.read_only_user table the USAGE privilege on the public, views and collection-specific
    schemas, and the SELECT privilege on public tables, the views.mapping_sheets table, and collection-specific tables.
    """
    do_correct_user_permissions(cursor)


@click.command()
@click.argument('name', callback=validate_name)
def docs_table_ref(name):
    """
    Creates or updates the CSV files in docs/definitions.
    """
    tables = []
    for basename, content in read_sql_files().items():
        for table in re.findall(r'^CREATE\s+(?:TABLE|VIEW)\s+(\S+)', content, flags=re.MULTILINE | re.IGNORECASE):
            if not table.startswith(('tmp_', 'staged_')) and not table.endswith('_no_data'):
                tables.append(table)
    tables.append('field_counts')

    headers = ['Column Name', 'Data Type', 'Description']

    statement = """
        SELECT
            isc.column_name,
            isc.data_type,
            pg_catalog.col_description(format('%%s.%%s', isc.table_schema,isc.table_name)::regclass::oid,
                                       isc.ordinal_position) AS column_description
        FROM
            information_schema.columns isc
        WHERE
            table_schema = %(schema)s AND LOWER(isc.table_name) = LOWER(%(table)s)
    """

    filename = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'docs', 'definitions', '{}.csv')
    for table in tables:
        with open(filename.format(table), 'w') as f:
            writer = csv.writer(f, lineterminator='\n')
            writer.writerow(headers)

            cursor.execute(statement, {'schema': name, 'table': table})
            for row in cursor.fetchall():
                if 'timestamp' in row[1]:
                    row[1] = 'timestamp'
                writer.writerow(row)


cli.add_command(add_view)
cli.add_command(correct_user_permissions)
cli.add_command(delete_view)
cli.add_command(docs_table_ref)
cli.add_command(field_counts)
cli.add_command(list_views)
cli.add_command(refresh_views)
