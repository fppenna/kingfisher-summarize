CREATE TABLE tmp_planning_documents_aggregates AS
SELECT
    id,
    jsonb_object_agg(coalesce(documentType, ''), total_documentTypes) planning_document_documenttype_counts
FROM (
    SELECT
        id,
        documentType,
        count(*) total_documentTypes
    FROM
        planning_documents_summary
    GROUP BY
        id,
        documentType) AS d
GROUP BY
    id;

CREATE UNIQUE INDEX tmp_planning_documents_aggregates_id ON tmp_planning_documents_aggregates (id);

