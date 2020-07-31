CREATE OR REPLACE FUNCTION common_comments(
    table_name text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS
$$
    DECLARE template text;
    BEGIN
    template :=
        $template$
        Comment on column %%1$s.id IS 'Unique id representing a release, compiled_release or record' ;
        Comment on column %%1$s.release_type IS 'Either release, record, compiled_release or embedded_release. With "release", individual releases are read through the release table. With "record", a compiled release is read from a record''s compiledRelease field through the record table. With "compiled_release", a compiled release is read through the compiled_release table, which is calculated by Kingfisher Process (for example, by merging a collection of releases). With "embedded_releases", individual releases are read from a record''s releases array through the record table.';
        Comment on column %%1$s.collection_id IS 'id from Kingfisher collection table' ;
        Comment on column %%1$s.ocid IS 'ocid from the data' ;
        Comment on column %%1$s.release_id IS 'Release id from the data. Relevant for releases and not for compiled_releases or records' ;
        Comment on column %%1$s.data_id IS 'id for the "data" table in Kingfisher that holds the original JSON data.' ;
        $template$
        ;
        execute format(template, table_name);
        return 'Common comments added';
    END;
$$;

CREATE OR REPLACE FUNCTION common_milestone_comments(
    table_name text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS
$$
    DECLARE template text;
    BEGIN
    template :=
        $template$
        Comment on column %%1$s.milestone_index IS 'Position of the milestone in the milestone array';
        Comment on column %%1$s.milestone IS 'JSONB of milestone object';
        Comment on column %%1$s.type IS '`type` from milestone object';
        Comment on column %%1$s.code IS '`code` from milestone object';
        Comment on column %%1$s.status IS '`status` from milestone object';
        $template$
        ;
        execute format(template, table_name);
        return 'Common milestone comments added';
    END;
$$;

CREATE OR REPLACE FUNCTION common_item_comments(
    table_name text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS
$$
    DECLARE template text;
    BEGIN
    template :=
        $template$
        Comment on column %%1$s.item_index IS 'Position of the item in the items array';
        Comment on column %%1$s.item IS 'JSONB of item object';
        Comment on column %%1$s.item_id IS '`id` field in the item object';
        Comment on column %%1$s.quantity IS '`quantity` from the item object';
        Comment on column %%1$s.unit_amount IS '`amount` from the unit/value object';
        Comment on column %%1$s.unit_currency IS '`currency` from the unit/value object';
        Comment on column %%1$s.item_classification IS 'Concatenation of classification/scheme and classification/id';
        Comment on column %%1$s.item_additionalidentifiers_ids IS 'JSONB list of the concatenation of additionalClassification/scheme and additionalClassification/id';
        Comment on column %%1$s.additional_classification_count IS 'Count of additional classifications';
        $template$
        ;
        execute format(template, table_name);
        return 'Common item comments added';
    END;
$$;

CREATE OR REPLACE FUNCTION common_document_comments(
    table_name text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS
$$
    DECLARE template text;
    BEGIN
    template :=
        $template$
        Comment on column %%1$s.document_index IS 'Position of the document in the documents array';
        Comment on column %%1$s.document IS 'JSONB of the document';
        Comment on column %%1$s.documenttype IS '`documentType` field from the document object';
        Comment on column %%1$s.format IS '`format` field from the document object';
        $template$
        ;
        execute format(template, table_name);
        return 'Common document comments added';
    END;
$$;


select common_comments('parties_summary');
Comment on column parties_summary.party_index IS 'Position of the party in the parties array';
Comment on column parties_summary.parties_id IS '`id` in party object';
Comment on column parties_summary.roles IS 'JSONB list of the party roles';
Comment on column parties_summary.identifier IS 'Concatenation of `scheme` and `id` from `identifier` object in the form `<scheme>-<id>`';
Comment on column parties_summary.unique_identifier_attempt IS 'The `id` from party object if it exists, otherwise the identifier described above if it exists, otherwise the party name';
Comment on column parties_summary.parties_additionalidentifiers_ids IS 'JSONB list of the concatenation of scheme and id of all additionalIdentifier objects';
Comment on column parties_summary.parties_additionalidentifiers_count IS 'Count of additional identifiers';
Comment on column parties_summary.party IS 'JSONB of party object';

select common_comments('buyer_summary');
Comment on column buyer_summary.buyer IS 'JSONB of buyer object';
Comment on column buyer_summary.buyer_parties_id IS '`id` from buyer object';
Comment on column buyer_summary.buyer_identifier IS 'Concatenation of `scheme` and `id` from `identifier` object in the form `<scheme>-<id>`';
Comment on column buyer_summary.unique_identifier_attempt IS 'The `id` from buyer object if it exists, otherwise the identifier described above if it exists, otherwise the party name';
Comment on column buyer_summary.buyer_additionalidentifiers_ids IS 'JSONB list of the concatenation of scheme and id of all additionalIdentifier objects';
Comment on column buyer_summary.buyer_additionalidentifiers_count IS 'Count of additional identifiers';
Comment on column buyer_summary.link_to_parties IS 'Does this buyer link to a party in the parties array using the `id` field from buyer object linking to the `id` field in a party object? If this is true then 1, otherwise 0';
Comment on column buyer_summary.link_with_role IS 'If there is a link does the parties object have `buyer` in its roles list? If it does then 1 otherwise 0';
Comment on column buyer_summary.party_index IS 'If there is a link what is the index of the party in the `parties` array then this can be used for joining to the `parties_summary` table';

select common_comments('procuringentity_summary');
Comment on column procuringentity_summary.procuringentity IS 'JSONB of procuringEntity object';
Comment on column procuringentity_summary.procuringentity_parties_id IS '`id` from procuringEntity object';
Comment on column procuringentity_summary.procuringentity_identifier IS 'Concatenation of `scheme` and `id` from `identifier` object in the form `<scheme>-<id>`';
Comment on column procuringentity_summary.unique_identifier_attempt IS 'The `id` from procuringEntity object if it exists, otherwise the identifier described above if it exists, otherwise the party name';
Comment on column procuringentity_summary.procuringentity_additionalidentifiers_ids IS 'JSONB list of the concatenation of scheme and id of all additionalIdentifier objects';
Comment on column procuringentity_summary.procuringentity_additionalidentifiers_count IS 'Count of additional identifiers';
Comment on column procuringentity_summary.link_to_parties IS 'Does this procuringEntity link to a party in the parties array using the `id` field from buyer object linking to the `id` field in a party object? If this is true then 1, otherwise 0';
Comment on column procuringentity_summary.link_with_role IS 'If there is a link does the parties object have `procuringEntity` in its roles list? If it does then 1 otherwise 0';
Comment on column procuringentity_summary.party_index IS 'If there is a link what is the index of the party in the `parties` array then this can be used for joining to the `parties_summary` table';

select common_comments('tenderers_summary');
Comment on column tenderers_summary.tenderer_index IS 'Position of the tenderer in the tenderer array';
Comment on column tenderers_summary.tenderer IS 'JSONB of tenderer object';
Comment on column tenderers_summary.tenderer_parties_id IS '`id` from tenderer object';
Comment on column tenderers_summary.tenderer_identifier IS 'Concatenation of `scheme` and `id` from `identifier` object in the form `<scheme>-<id>`';
Comment on column tenderers_summary.unique_identifier_attempt IS 'The `id` from tenderer object if it exists, otherwise the identifier described above if it exists, otherwise the party name';
Comment on column tenderers_summary.tenderer_additionalidentifiers_ids IS 'JSONB list of the concatenation of scheme and id of all additionalIdentifier objects';
Comment on column tenderers_summary.tenderer_additionalidentifiers_count IS 'Count of additional identifiers';
Comment on column tenderers_summary.link_to_parties IS 'Does this tenderer link to a party in the parties array using the `id` field from buyer object linking to the `id` field in a party object? If this is true then 1, otherwise 0';
Comment on column tenderers_summary.link_with_role IS 'If there is a link does the parties object have `tenderers` in its roles list? If it does then 1 otherwise 0';
Comment on column tenderers_summary.party_index IS 'If there is a link what is the index of the party in the `parties` array. This can be used for joining to the `parties_summary` table';

select common_comments('planning_documents_summary');
select common_document_comments('planning_documents_summary');

select common_comments('planning_milestones_summary');
select common_milestone_comments('planning_milestones_summary');

select common_comments('planning_summary');
Comment on column planning_summary.planning_budget_amount IS 'amount/amount from `budget` object';
Comment on column planning_summary.planning_budget_currency IS 'amount/currency from `budget` object';
Comment on column planning_summary.planning_budget_projectid IS '`projectID` from `budget` object';
Comment on column planning_summary.documents_count IS 'Number of documents in documents array';
Comment on column planning_summary.documenttype_counts IS 'JSONB object with the keys as unique documentTypes and the values as count of the appearances of that `documentType` in the `documents` array';
Comment on column planning_summary.milestones_count IS 'Count of milestones';
Comment on column planning_summary.milestonetype_counts IS 'JSONB object with the keys as unique milestoneTypes and the values as a count of the appearances of that `milestoneType` in the `milestones` array';

select common_comments('tender_documents_summary');
Comment on column tender_documents_summary.document_index IS 'Position of the document in the documents array';
select common_document_comments('tender_documents_summary');

select common_comments('tender_items_summary');
select common_item_comments('tender_items_summary');

select common_comments('tender_milestones_summary');
select common_milestone_comments('tender_milestones_summary');

DO
$$
DECLARE template text;

BEGIN
    template :=
        $template$
        Comment on column %%1$s.tender_id IS '`id` from `tender` object';
        Comment on column %%1$s.tender_title IS '`title` from `tender` object';
        Comment on column %%1$s.tender_status IS '`status` from `tender` object';
        Comment on column %%1$s.tender_value_amount IS '`amount` from `value` object';
        Comment on column %%1$s.tender_value_currency IS '`currency` from `value` object';
        Comment on column %%1$s.tender_minvalue_amount IS '`amount` from `minValue` object';
        Comment on column %%1$s.tender_minvalue_currency IS '`currency` from `minValue` object';
        Comment on column %%1$s.tender_procurementmethod IS '`procumentMethod` form `tender` object';
        Comment on column %%1$s.tender_mainprocurementcategory IS '`mainProcurementCategory` from tender object';
        Comment on column %%1$s.tender_additionalprocurementcategories IS '`additionalProcurementCategories` from tender object';
        Comment on column %%1$s.tender_awardcriteria IS '`awardCriteria` from tender object';
        Comment on column %%1$s.tender_submissionmethod IS '`submissionMethod` from tender object';
        Comment on column %%1$s.tender_tenderperiod_startdate IS '`startDate` from tenderPeriod object';
        Comment on column %%1$s.tender_tenderperiod_enddate IS '`endDate` from tenderPeriod object';
        Comment on column %%1$s.tender_tenderperiod_maxextentdate IS '`maxExtentDate` from tenderPeriod object';
        Comment on column %%1$s.tender_tenderperiod_durationindays IS '`durationInDays` from tenderPeriod object';
        Comment on column %%1$s.tender_enquiryperiod_startdate IS '`startDate` from enquiryPeriod object';
        Comment on column %%1$s.tender_enquiryperiod_enddate IS '`endDate` from enquiryPeriod object';
        Comment on column %%1$s.tender_enquiryperiod_maxextentdate IS '`maxExtentDate` from enquiryPeriod object';
        Comment on column %%1$s.tender_enquiryperiod_durationindays IS '`durationInDays` from enquiryPeriod object';
        Comment on column %%1$s.tender_hasenquiries IS '`hasEnquiries` from tender object';
        Comment on column %%1$s.tender_eligibilitycriteria IS '`eligibilityCriteria from tender object';
        Comment on column %%1$s.tender_awardperiod_startdate IS '`startDate` from awardPeriod object';
        Comment on column %%1$s.tender_awardperiod_enddate IS '`endDate` from awardPeriod object';
        Comment on column %%1$s.tender_awardperiod_maxextentdate IS '`maxExtentDate` from awardPeriod object';
        Comment on column %%1$s.tender_awardperiod_durationindays IS '`durationInDays` from awardPeriod object';
        Comment on column %%1$s.tender_contractperiod_startdate IS '`startDate` from awardPeriod object';
        Comment on column %%1$s.tender_contractperiod_enddate IS '`endDate` from awardPeriod object';
        Comment on column %%1$s.tender_contractperiod_maxextentdate IS '`maxExtentDate` from awardPeriod object';
        Comment on column %%1$s.tender_contractperiod_durationindays IS '`durationInDays` from awardPeriod object';
        Comment on column %%1$s.tender_numberoftenderers IS '`numberOfTenderers` from tender object';
        Comment on column %%1$s.tenderers_count IS 'Count of amount of tenderers';
        Comment on column %%1$s.documents_count IS 'Count of amount of tender documents';
        Comment on column %%1$s.documenttype_counts IS 'JSONB object with the keys as unique documentTypes and the values as count of the appearances of that `documentType` in the `documents` array';
        Comment on column %%1$s.milestones_count IS 'Count of milestones';
        Comment on column %%1$s.milestonetype_counts IS 'JSONB object with the keys as unique milestoneTypes and the values as a count of the appearances of that `milestoneType` in the `milestones` array';
        Comment on column %%1$s.items_count IS 'Count of items';
        $template$
    ;
    execute format(template, 'tender_summary');
    execute format(template, 'tender_summary_with_data');
END;
$$;

select common_comments('tender_summary');
select common_comments('tender_summary_with_data');
Comment on column tender_summary_with_data.tender IS 'JSONB of tender object';

select common_comments('award_documents_summary');
Comment on column award_documents_summary.award_index IS 'Position of the award in the awards array';
select common_document_comments('award_documents_summary');

select common_comments('award_items_summary');
select common_item_comments('award_items_summary');
Comment on column award_items_summary.award_index IS 'Position of the award in the awards array';

select common_comments('award_suppliers_summary');
Comment on column award_suppliers_summary.award_index IS 'Position of the award in the awards array';
Comment on column award_suppliers_summary.supplier_index IS 'Position of the supplier in the supplier array';
Comment on column award_suppliers_summary.supplier IS 'JSONB of supplier object';
Comment on column award_suppliers_summary.supplier_parties_id IS '`id` from supplier object';
Comment on column award_suppliers_summary.supplier_identifier IS 'Concatenation of `scheme` and `id` from `identifier` object in the form `<scheme>-<id>`';
Comment on column award_suppliers_summary.unique_identifier_attempt IS 'The `id` from party object if it exists, otherwise the identifier described above if it exists, otherwise the party name';
Comment on column award_suppliers_summary.supplier_additionalidentifiers_ids IS 'JSONB list of the concatenation of scheme and id of all additionalIdentifier objects';
Comment on column award_suppliers_summary.supplier_additionalidentifiers_count IS 'Count of additional identifiers';
Comment on column award_suppliers_summary.link_to_parties IS 'Does this buyer link to a party in the parties array using the `id` field from buyer object linking to the `id` field in a party object? If this is true then 1, otherwise 0';
Comment on column award_suppliers_summary.link_with_role IS 'If there is a link does the parties object have `suppliers` in its roles list? If it does then 1 otherwise 0';
Comment on column award_suppliers_summary.party_index IS 'Position of the party in the parties array';

select common_comments('awards_summary');
Comment on column awards_summary.award_index IS 'Position of the award in the awards array';
Comment on column awards_summary.award_id IS '`id` field from award object';
Comment on column awards_summary.award_title IS '`title` field from award object';
Comment on column awards_summary.award_status IS '`status` field from award object';
Comment on column awards_summary.award_value_amount IS '`value` field from award/amount object';
Comment on column awards_summary.award_value_currency IS '`currency` field from award/amount object';
Comment on column awards_summary.award_date IS '`date` field from award object';
Comment on column awards_summary.award_contractperiod_startdate IS '`startDate` field from contractPeriod';
Comment on column awards_summary.award_contractperiod_enddate IS '`endDate` field from contractPeriod';
Comment on column awards_summary.award_contractperiod_maxextentdate IS '`maxExtentDate` field from contractPeriod';
Comment on column awards_summary.award_contractperiod_durationindays IS '`durationInDays` field from contractPeriod';
Comment on column awards_summary.suppliers_count IS 'The number of suppliers declared for this award.';
Comment on column awards_summary.documents_count IS 'Number of documents in documents array';
Comment on column awards_summary.documenttype_counts IS 'JSONB object with the keys as unique documentTypes and the values as count of the appearances of that `documentType` in the `documents` array';
Comment on column awards_summary.items_count IS 'Count of items';
Comment on column awards_summary.award IS 'JSONB of award object';

select common_comments('contract_documents_summary');
Comment on column contract_documents_summary.contract_index IS 'Position of the contract in the contracts array';
select common_document_comments('contract_documents_summary');

select common_comments('contract_implementation_documents_summary');
Comment on column contract_implementation_documents_summary.contract_index IS 'Position of the contract in the contracts array';
select common_document_comments('contract_implementation_documents_summary');

select common_comments('contract_implementation_milestones_summary');
select common_milestone_comments('contract_implementation_milestones_summary');
Comment on column contract_implementation_milestones_summary.contract_index IS 'Position of the contract in the contracts array';

select common_comments('contract_implementation_transactions_summary');
Comment on column contract_implementation_transactions_summary.contract_index IS 'Position of the contract in the contracts array';
Comment on column contract_implementation_transactions_summary.transaction_index IS 'Position of the transaction in the transaction array';
Comment on column contract_implementation_transactions_summary.transaction_amount IS '`amount` field from the value object or the deprecated amount object';
Comment on column contract_implementation_transactions_summary.transaction_currency IS '`currency` field from the value object or the deprecated amount object';

select common_comments('contract_items_summary');
Comment on column contract_items_summary.contract_index IS 'Position of the contract in the contracts array';
select common_item_comments('contract_items_summary');

select common_comments('contract_milestones_summary');
select common_milestone_comments('contract_milestones_summary');
Comment on column contract_milestones_summary.contract_index IS 'Position of the contract in the contracts array';

select common_comments('contracts_summary');
Comment on column contracts_summary.contract_index IS 'Position of the contract in the contracts array';
Comment on column contracts_summary.award_id IS '`awardID` field in contract object';
Comment on column contracts_summary.link_to_awards IS 'If there is an award with the above `awardID` then 1 otherwise 0';
Comment on column contracts_summary.contract_id IS '`id` field from contract object';
Comment on column contracts_summary.contract_title IS '`title` field from contract object';
Comment on column contracts_summary.contract_status IS '`status` field from contract object';
Comment on column contracts_summary.contract_value_amount IS '`amount` field from value object';
Comment on column contracts_summary.contract_value_currency IS '`currency` field from value object';
Comment on column contracts_summary.datesigned IS '`dateSigned` from contract object';
Comment on column contracts_summary.contract_period_startdate IS '`startDate` field from contractPeriod';
Comment on column contracts_summary.contract_period_enddate IS '`endDate` field from contractPeriod';
Comment on column contracts_summary.contract_period_maxextentdate IS '`maxExtentDate` field from contractPeriod';
Comment on column contracts_summary.contract_period_durationindays IS '`durationInDays` field from contractPeriod';
Comment on column contracts_summary.documents_count IS 'Number of documents in documents array';
Comment on column contracts_summary.documenttype_counts IS 'JSONB object with the keys as unique documentTypes and the values as count of the appearances of that `documentType` in the `documents` array';
Comment on column contracts_summary.milestones_count IS 'Count of milestones';
Comment on column contracts_summary.milestonetype_counts IS 'JSONB object with the keys as unique milestoneTypes and the values as a count of the appearances of that `milestoneType` in the `milestones` array';
Comment on column contracts_summary.items_count IS 'Count of items';
Comment on column contracts_summary.implementation_documents_count IS 'Number of documents in documents array';
Comment on column contracts_summary.implementation_documenttype_counts IS 'JSONB object with the keys as unique documentTypes and the values as count of the appearances of that `documentType` in the `documents` array';
Comment on column contracts_summary.implementation_milestones_count IS 'Number of documents in documents array';
Comment on column contracts_summary.implementation_milestonetype_counts IS 'JSONB object with the keys as unique milestoneTypes and the values as count of the appearances of that `milestoneType` in the `milestone` array';
Comment on column contracts_summary.contract IS 'JSONB of contract object';


DO
$$
DECLARE template text;

BEGIN
    template :=
        $template$
        Comment on column %%1$s.table_id IS '`id` from either release, compiled_release or release tables in Kingfisher Process where this row was generated from';
        Comment on column %%1$s.package_data_id IS '`id` from package_data table';
        Comment on column %%1$s.package_version IS 'OCDS version gathered from the `version` field in package';
        Comment on column %%1$s.release_date IS '`date` field from release';
        Comment on column %%1$s.release_tag IS 'JSONB list of `tags` field from release';
        Comment on column %%1$s.release_language IS '`language` field from release object';
        Comment on column %%1$s.role_counts IS 'JSONB object with the keys as unique `roles` and the values as count of the appearances of those `roles`';
        Comment on column %%1$s.total_roles IS 'Total amount of roles specified across all parties';
        Comment on column %%1$s.total_parties IS 'Count of parties';
        Comment on column %%1$s.award_count IS 'Count of awards';
        Comment on column %%1$s.first_award_date IS 'Earliest `date` in all award objects';
        Comment on column %%1$s.last_award_date IS 'Latest `date` in all award objects';
        Comment on column %%1$s.total_award_documents IS 'The sum of `documents_count` for each `award` in this release';
        Comment on column %%1$s.total_award_items IS 'Count of all items in all awards';
        Comment on column %%1$s.total_award_suppliers IS 'The sum of `suppliers_count` for each `award` in this release';
        Comment on column %%1$s.award_amount IS 'Total of all value/amount across awards. NOTE: This ignores the fact that amounts could be of different currencies and sums them anyway';
        Comment on column %%1$s.unique_award_suppliers IS 'A count of distinct suppliers for all awards for this release, based on the `unique_identifier_attempt` field';
        Comment on column %%1$s.award_documenttype_counts IS 'JSONB object with the keys as unique awards/documents/documentType and the values as count of the appearances of those documentTypes';
        Comment on column %%1$s.contract_count IS 'Count of contracts';
        Comment on column %%1$s.total_contract_link_to_awards IS 'Count of all contracts that have link to awards through awardID field';
        Comment on column %%1$s.contract_amount IS 'Total of all value/amount across contracts. NOTE: This ignores the fact that amounts could be of different currencies and sums them anyway';
        Comment on column %%1$s.first_contract_datesigned IS 'First `dateSigned` across all contracts';
        Comment on column %%1$s.last_contract_datesigned IS 'Last `dateSigned` across all contracts';
        Comment on column %%1$s.total_contract_documents IS 'Count of contracts/documents';
        Comment on column %%1$s.total_contract_milestones IS 'Count of contracts/milestones';
        Comment on column %%1$s.total_contract_items IS 'Count of contracts/items';
        Comment on column %%1$s.total_contract_implementation_documents IS 'Count of contracts/implementation/documents';
        Comment on column %%1$s.total_contract_implementation_milestones IS 'Count of contracts/implementation/milestones';
        Comment on column %%1$s.contract_documenttype_counts IS 'JSONB object with the keys as unique contracts/documents/documentType and the values as count of the appearances of those documentTypes';
        Comment on column %%1$s.contract_implemetation_documenttype_counts IS 'JSONB object with the keys as unique contracts/implementation/documents/documentType and the values as count of the appearances of those documentTypes';
        Comment on column %%1$s.contract_milestonetype_counts IS 'JSONB object with the keys as unique contracts/milestone/milestoneType and the values as count of the appearances of those milestoneTypes';
        Comment on column %%1$s.contract_implementation_milestonetype_counts IS 'JSONB object with the keys as unique contracts/implementation/documents/milestoneType and the values as count of the appearances of those milestoneTypes';
        Comment on column %%1$s.total_documenttype_counts IS 'JSONB object with the keys as unique documentTypes from all documents in the release and the values as count of the appearances of those documentTypes';
        Comment on column %%1$s.total_documents IS 'Count of documents in the release';
        Comment on column %%1$s.milestonetype_counts IS 'JSONB object with the keys as unique milestoneTypes from all milestones in the release and the values as count of the appearances of those milestoneTypes';
        Comment on column %%1$s.total_milestones IS 'Count of milestones in the release';
        $template$
    ;
    execute format(template, 'release_summary');
    execute format(template, 'release_summary_with_checks');
    execute format(template, 'release_summary_with_data');
END;

$$;


DO
$$
DECLARE template text;

BEGIN
    template :=
        $template$
        Comment on column %%1$s.source_id IS '`source_id` from Kingfisher Process collection table';
        Comment on column %%1$s.data_version IS '`data_version` from Kingfisher Process collection table';
        Comment on column %%1$s.store_start_at IS '`store_start_at` from Kingfisher Process collection table';
        Comment on column %%1$s.store_end_at IS '`store_end_at` from Kingfisher Process collection table';
        Comment on column %%1$s.sample IS '`sample` from Kingfisher Process collection table';
        Comment on column %%1$s.transform_type IS '`transform_type` from Kingfisher Process collection table';
        Comment on column %%1$s.transform_from_collection_id IS '`transform_from_collection_id` from Kingfisher Process collection table';
        Comment on column %%1$s.deleted_at IS '`deleted_at` from Kingfisher Process collection table';
        $template$
    ;
    execute format(template, 'release_summary_with_checks');
    execute format(template, 'release_summary_with_data');
END;

$$;

select common_comments('release_summary');
select common_comments('release_summary_with_checks');
select common_comments('release_summary_with_data');

Comment on column release_summary_with_checks.release_check IS 'JSONB of Data Review Tool output which includes validation errors and additional field information';
Comment on column release_summary_with_checks.release_check11 IS 'JSONB of Data Review Tool output run against 1.1 version of OCDS even if the data is from 1.0';
Comment on column release_summary_with_checks.record_check IS 'JSONB of Data Review Tool output which includes validation errors and additional field information';
Comment on column release_summary_with_checks.record_check11 IS 'JSONB of Data Review Tool output run against 1.1 version of OCDS even if the data is from 1.0';

Comment on column release_summary_with_data.data IS '`data` from Kingfisher Process data table. This is the whole release in JSONB';
Comment on column release_summary_with_data.package_data IS '`data` from Kingfisher Process package_data table. This is the package data in either a release or record package. For compiled releaeses generated by Kingfisher Process this is NULL';
