import os.path
import re
from configparser import NoOptionError, NoSectionError
from unittest import TestCase
from unittest.mock import patch

import pytest
from click import UsageError

from ocdskingfisherviews.config import get_database_uri


def fixture(filename):
    path = os.path.join('tests', 'fixtures', filename)
    if not os.path.isfile(path):
        raise Exception('fixture {} is missing'.format(path))
    if 'pgpass' in filename and 'permissions' not in filename:
        os.chmod(path, 0o600)
    return path


@patch.dict('os.environ', {'KINGFISHER_VIEWS_DB_URI': 'postgresql:///test', 'PGPASSFILE': fixture('pgpass.txt')})
@patch('os.path.expanduser')
def test_env(ini, caplog):
    ini.return_value = fixture('config.ini')

    database_uri = get_database_uri()

    assert database_uri == 'postgresql:/test'
    assert len(caplog.records) == 0


@patch.dict('os.environ', {'KINGFISHER_VIEWS_DB_URI': ''})
@patch('os.path.expanduser')
class NoEnv(TestCase):
    @pytest.fixture(autouse=True)
    def fixtures(self, caplog):
        self.caplog = caplog

    def test_ini(self, ini):
        ini.return_value = fixture('config.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://ocdskingfisher:secret@localhost:5432/ocdskingfisher'
        assert len(self.caplog.records) == 0

    @patch.dict('os.environ', {'PGPASSFILE': fixture('pgpass.txt')})
    def test_pgpass_password(self, ini):
        ini.return_value = fixture('config.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://ocdskingfisher:secret@localhost:5432/ocdskingfisher'
        assert len(self.caplog.records) == 0

    @patch.dict('os.environ', {'PGPASSFILE': fixture('pgpass.txt')})
    def test_pgpass_no_password(self, ini):
        ini.return_value = fixture('config-empty-password.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://ocdskingfisher:protected@localhost:5432/ocdskingfisher'
        assert len(self.caplog.records) == 0

    @patch.dict('os.environ', {'PGPASSFILE': fixture('pgpass-empty-file.txt')})
    def test_pgpass_empty_file(self, ini):
        ini.return_value = fixture('config-empty-password.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://ocdskingfisher@localhost:5432/ocdskingfisher'
        assert len(self.caplog.records) == 0

    @patch.dict('os.environ', {'PGPASSFILE': fixture('pgpass-no-match.txt')})
    def test_pgpass_no_match(self, ini):
        ini.return_value = fixture('config-empty-password.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://ocdskingfisher@localhost:5432/ocdskingfisher'
        assert len(self.caplog.records) == 0

    @patch.dict('os.environ', {'PGPASSFILE': fixture('pgpass-bad-permissions.txt')})
    def test_pgpass_bad_permissions(self, ini):
        ini.return_value = fixture('config-empty-password.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://ocdskingfisher@localhost:5432/ocdskingfisher'

        message = r'^Skipping PostgreSQL Password File: Invalid Permissions for ' \
                  r'tests/fixtures/pgpass-bad-permissions\.txt: 0o6\d4\.\nTry: chmod 600 ' \
                  r'tests/fixtures/pgpass-bad-permissions\.txt$'

        assert len(self.caplog.records) == 1
        assert self.caplog.records[0].levelname == 'WARNING'
        assert re.search(message, self.caplog.records[0].message)

    @patch.dict('os.environ', {'PGPASSFILE': fixture('pgpass-bad-port.txt')})
    def test_pgpass_bad_port(self, ini):
        ini.return_value = fixture('config-empty-password.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://ocdskingfisher@localhost:5432/ocdskingfisher'

        message = 'Skipping PostgreSQL Password File: Error validating port value "invalid"'

        assert len(self.caplog.records) == 1
        assert self.caplog.records[0].levelname == 'WARNING'
        assert self.caplog.records[0].message == message

    def test_ini_nonexistent(self, ini):
        ini.return_value = 'nonexistent.ini'

        with pytest.raises(UsageError) as excinfo:
            get_database_uri()

        assert str(excinfo.value) == 'You must either set the KINGFISHER_VIEWS_DB_URI environment variable or ' \
                                     'create the ~/.config/ocdskingfisher-views/config.ini file.\nSee https://' \
                                     'kingfisher-views.readthedocs.io/en/latest/get-started.html'

    def test_ini_empty_file(self, ini):
        ini.return_value = fixture('config-empty-file.ini')

        with pytest.raises(NoSectionError):
            get_database_uri()

    def test_ini_empty_section(self, ini):
        ini.return_value = fixture('config-empty-section.ini')

        with pytest.raises(NoOptionError):
            get_database_uri()

    def test_ini_empty_dbname(self, ini):
        ini.return_value = fixture('config-empty-dbname.ini')

        with pytest.raises(UsageError) as excinfo:
            get_database_uri()

        assert str(excinfo.value) == 'You must set DBNAME in ~/.config/ocdskingfisher-views/config.ini.'

    def test_ini_bad_port(self, ini):
        ini.return_value = fixture('config-bad-port.ini')

        with pytest.raises(UsageError) as excinfo:
            get_database_uri()

        assert str(excinfo.value) == 'PORT is invalid in ~/.config/ocdskingfisher-views/config.ini. ' \
                                     "(invalid literal for int() with base 10: 'invalid')"

    @patch('getpass.getuser')
    def test_ini_empty_options(self, user, ini):
        user.return_value = 'morgan'
        ini.return_value = fixture('config-empty-options.ini')

        database_uri = get_database_uri()

        assert database_uri == 'postgresql://morgan@localhost:5432/ocdskingfisher'
