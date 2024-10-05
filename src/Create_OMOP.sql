 -- --------------- Create your database using the master provided ---------------
USE master;
GO

IF NOT EXISTS (
      SELECT name
      FROM sys.databases
      WHERE name = N'OMOP'
      )
   CREATE DATABASE [OMOP];
GO
 -- --------------- Create OMOP Schemas ---------------
-- Syntax : DROP SCHEMA  [ IF EXISTS ] schema_name; GO;   CREATE SCHEMA [YrSchemaName]; Go; 
CREATE SCHEMA standardized_clinical_data;
GO

CREATE SCHEMA standardized_health_system;
GO

CREATE SCHEMA standardized_vocabularies;
GO

CREATE SCHEMA standardized_health_economies;
GO

CREATE SCHEMA standardized_derived_elements;
GO

CREATE SCHEMA results_schema;
GO 

CREATE SCHEMA standardized_metadata;
GO


 -- --------------- Creating the tables with the following effective priorities ---------------
--- standardized_health_system
IF OBJECT_ID('[standardized_health_system].[location]','U') IS NOT NULL
DROP TABLE [standardized_health_system].[location];
GO 

CREATE TABLE [standardized_health_system].[location](
    location_id int PRIMARY KEY NOT NULL, 
    address_1 varchar(50) UNIQUE,
    address_2 varchar(50) UNIQUE,
    city      varchar(50) UNIQUE,
    [state]     varchar(20) UNIQUE,
    [zip]       varchar(9) UNIQUE,
    county    varchar(20) UNIQUE,
    location_source_value varchar(50) UNIQUE,
    country_concept_id    int UNIQUE,
    country_source_value  varchar(20) UNIQUE,
    latitude  NUMERIC UNIQUE,
    longitude NUMERIC UNIQUE);
GO

IF OBJECT_ID('[standardized_health_system].[care_site]','U') IS NOT NULL
DROP TABLE [standardized_health_system].[care_site]
GO 

CREATE TABLE [standardized_health_system].[care_site](
    care_site_id int PRIMARY KEY NOT NULL, 
    care_site_name varchar(255) UNIQUE,
    place_of_service_concept_id int UNIQUE,
    care_site_source_value varchar(50) UNIQUE,
    place_of_service_source_value varchar(50) UNIQUE,
    location_id int UNIQUE,
    FK_location INT UNIQUE,
    CONSTRAINT FK_location FOREIGN KEY (location_id) REFERENCES standardized_health_system.location(location_id));
GO



IF OBJECT_ID('[standardized_health_system].[provider]','U') IS NOT NULL
DROP TABLE [standardized_health_system].[provider]
GO 

CREATE TABLE [standardized_health_system].[provider](
    provider_id int PRIMARY KEY NOT NULL, 
    provider_name  varchar(255) UNIQUE,
    npi varchar(20) UNIQUE,
    dea varchar(20) UNIQUE,
    specialty_concept_id   int UNIQUE,
    year_of_birth          int UNIQUE,
    gender_concept_id      int UNIQUE,
    provider_source_value  varchar(50) UNIQUE,
    specialty_source_value varchar(50) UNIQUE,
    specialty_source_concept_id int UNIQUE,
    gender_source_value         varchar(50) UNIQUE,
    gender_source_concept_id    int UNIQUE,
    care_site_id                int UNIQUE,
    FK_care_site INT UNIQUE,
    CONSTRAINT FK_care_site FOREIGN KEY (care_site_id) REFERENCES standardized_health_system.care_site(care_site_id));
GO


-- standardized_clinical_data
IF OBJECT_ID('[standardized_clinical_data].[person]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[person]
GO 


CREATE TABLE [standardized_clinical_data].[person](
    user_id int PRIMARY KEY NOT NULL, 
    user_name nvarchar(50) NOT NULL UNIQUE, 
    user_email nvarchar(100) UNIQUE,
    year_of_birth int UNIQUE, 
    month_of_birth int UNIQUE, 
    day_of_birth  int UNIQUE, 
    birth_datetime  TIMESTAMP UNIQUE, 
    race_concept_id int UNIQUE, 
    race_source_value varchar UNIQUE, 
    person_source_value varchar UNIQUE,
    gender_source_value varchar UNIQUE,
    gender_source_concept_id int UNIQUE, 
    race_source_concept_id int UNIQUE, 
    ethnicity_source_value varchar UNIQUE,
    ethnicity_source_concept_id int UNIQUE, 
    FK_location int UNIQUE,
    location_id int,
    FK_care_site int UNIQUE,
    care_site_id int UNIQUE,
    FK_provider int UNIQUE,
    provider_id int UNIQUE,
    CONSTRAINT FK_location FOREIGN KEY (location_id) REFERENCES standardized_health_system.location(location_id),
    CONSTRAINT FK_care_site FOREIGN KEY (care_site_id) REFERENCES standardized_health_system.care_site(care_site_id),
    CONSTRAINT FK_provider FOREIGN KEY (provider_id) REFERENCES standardized_health_system.provider(provider_id));

GO


-- standardized_health_economics
IF OBJECT_ID('[standardized_health_economies].[cost]','U') IS NOT NULL
DROP TABLE [standardized_health_economies].[cost];
GO 

CREATE TABLE [standardized_health_economies].[cost](
    cost_id       int PRIMARY KEY NOT NULL, 
    cost_event_id  int NOT NULL UNIQUE,
    cost_domain_id varchar(20) UNIQUE,
    cost_type_concept_id int NOT NULL UNIQUE,
    currency_concept_id  int UNIQUE,
    total_charge         NUMERIC UNIQUE,
    total_cost           NUMERIC UNIQUE,
    total_paid           NUMERIC UNIQUE,
    paid_by_payer        NUMERIC UNIQUE,
    paid_by_patient      NUMERIC UNIQUE,
    paid_patient_copay   NUMERIC UNIQUE,
    paid_patient_coinsurance  NUMERIC UNIQUE,
    paid_patient_deductible   NUMERIC UNIQUE,
    paid_by_primary           NUMERIC UNIQUE,
    paid_ingredient_cost      NUMERIC UNIQUE,
    paid_dispensing_fee       NUMERIC UNIQUE,
    payer_plan_period_id      int UNIQUE,
    amount_allowed            NUMERIC UNIQUE,
    revenue_code_concept_id   int UNIQUE,
    revenue_code_source_value varchar(50) UNIQUE,
    drg_concept_id   int UNIQUE,
    drg_source_value   varchar(3) UNIQUE,
    person_id        int UNIQUE,
    FK_person int,
    CONSTRAINT FK_person FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id));
GO


IF OBJECT_ID('[standardized_health_economies].[payer_plan_period]','U') IS NOT NULL
DROP TABLE [standardized_health_economies].[payer_plan_period];
GO 

CREATE TABLE [standardized_health_economies].[payer_plan_period](
    payer_plan_period_id int PRIMARY KEY NOT NULL, 
    payer_plan_period_start_date DATE NOT NULL UNIQUE, 
    payer_plan_period_end_date   DATE NOT NULL UNIQUE, 
    payer_concept_id             int UNIQUE,
    payer_source_value           varchar(50) UNIQUE,
    payer_source_concept_id      int UNIQUE,
    plan_concept_id        int UNIQUE,
    plan_source_value      varchar(50) UNIQUE,
    plan_source_concept_id int UNIQUE,
    sponsor_concept_id     int UNIQUE,
    sponsor_source_value   varchar(50) UNIQUE,
    sponsor_source_concept_id int UNIQUE,
    family_source_value       varchar(50) UNIQUE,
    stop_reason_concept_id    int UNIQUE,
    stop_reason_source_value  varchar(50) UNIQUE,
    stop_reason_source_concept_id int UNIQUE,
    person_id        int UNIQUE,
    FK_personPP int, 
    CONSTRAINT FK_personPP FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id));
GO


-- Standardized Metadata
IF OBJECT_ID('[standardized_metadata].[CDM_source]','U') IS NOT NULL
DROP TABLE [standardized_metadata].[CDM_source];
GO

CREATE TABLE [standardized_metadata].[CDM_source](
    cdm_source_id int PRIMARY KEY NOT NULL, 
    cdm_source_abbreviation varchar(25) UNIQUE,
    cdm_holder              varchar(255) UNIQUE,
    source_description    nvarchar(100)  UNIQUE,
    source_documentation_reference varchar(255) UNIQUE,
    cdm_etl_reference      varchar(255) UNIQUE,
    source_release_date    DATE UNIQUE,
    cdm_release_date       DATE UNIQUE,
    cdm_version            varchar(10) UNIQUE,
    cdm_version_concept_id int UNIQUE,
    vocabulary_version     varchar(20) UNIQUE);
GO


IF OBJECT_ID('[standardized_metadata].[metadata]','U') IS NOT NULL
DROP TABLE [standardized_metadata].[metadata];
GO

CREATE TABLE [standardized_metadata].[metadata](
    metadata_id   int PRIMARY KEY NOT NULL, 
    metadata_concept_id      int UNIQUE,
    metadata_type_concept_id int UNIQUE,
    [name]            varchar(10) UNIQUE,
    value_as_string varchar(10) UNIQUE,
    value_as_concept_id int UNIQUE,
    value_as_number     NUMERIC UNIQUE,
    metadata_date       DATE UNIQUE,
    metadata_datetime   TIMESTAMP UNIQUE);
GO

-- results_schema
IF OBJECT_ID('[results_schema].[cohort_definition]','U') IS NOT NULL
DROP TABLE [results_schema].[cohort_definition];
GO

CREATE TABLE [results_schema].[cohort_definition](
    cohort_definition_id  int PRIMARY KEY NOT NULL, 
    cohort_definition_name        varchar(255) UNIQUE,
    cohort_definition_description nvarchar(100) UNIQUE,
    definition_type_concept_id    int NOT NULL UNIQUE,
    cohort_definition_syntax      nvarchar(100) UNIQUE,
    subject_concept_id     int NOT NULL UNIQUE,
    cohort_initiation_date DATE UNIQUE,
);
GO

IF OBJECT_ID('[results_schema].[cohort]','U') IS NOT NULL
DROP TABLE [results_schema].[cohort];
GO

CREATE TABLE [results_schema].[cohort](
    cohort_id     int PRIMARY KEY NOT NULL, 
    subject_id     int NOT NULL UNIQUE,
    cohort_start_date DATE NOT NULL UNIQUE, 
    cohort_end_date   DATE NOT NULL UNIQUE, 
    person_id int UNIQUE,
    FK_personc int, 
    cohort_definition_id int UNIQUE,
    FK_cohort int, 
    CONSTRAINT FK_personc FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_cohort FOREIGN KEY (cohort_definition_id) REFERENCES results_schema.cohort_definition(cohort_definition_id),
); 
GO


-- standardized_clinical_data
IF OBJECT_ID('[standardized_clinical_data].[observation_period]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[observation_period];
GO 


CREATE TABLE [standardized_clinical_data].[observation_period](
    observation_period_id int PRIMARY KEY NOT NULL, 
    observation_period_start_date DATE NOT NULL UNIQUE,
    observation_period_end_date DATE NOT NULL UNIQUE,
    period_type_concept_id int UNIQUE,
    person_id int UNIQUE,
    FK_persono int,
    CONSTRAINT FK_persono FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
);
GO



IF OBJECT_ID('[standardized_clinical_data].[death]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[death];
GO 

CREATE TABLE [standardized_clinical_data].[death](
    death_id      int PRIMARY KEY NOT NULL, 
    death_date     DATE NOT NULL UNIQUE, 
    death_datetime TIMESTAMP UNIQUE, 
    death_type_concept_id int UNIQUE,
    cause_concept_id      int UNIQUE,
    cause_source_value    varchar UNIQUE,
    cause_source_concept_id int UNIQUE,
    person_id int UNIQUE,
    FK_persond int,
    CONSTRAINT FK_persond FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
);
GO


IF OBJECT_ID('[standardized_clinical_data].[visit_occurrence]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[visit_occurrence];
GO 

CREATE TABLE [standardized_clinical_data].[visit_occurrence](
    visit_occurrence_id int PRIMARY KEY NOT NULL, 
    visit_concept_id   int UNIQUE,
    visit_start_date   DATE UNIQUE,
    visit_start_datetime smalldatetime, 
    visit_end_date       DATE UNIQUE,
    visit_end_datetime   smalldatetime, 
    visit_type_concept_id    int UNIQUE,
    visit_source_value       varchar UNIQUE,
    visit_source_concept_id  int UNIQUE,
    admitted_from_concept_id int UNIQUE,
    admitted_from_source_value varchar UNIQUE,
    discharged_to_concept_id   int UNIQUE,
    discharged_to_source_value varchar UNIQUE,
    preceding_visit_occurrence_id int UNIQUE,
    person_id int UNIQUE,
    FK_personv int,
    care_site_id int UNIQUE,
    FK_carev int,
    provider_id int UNIQUE,
    FK_provv int,
    CONSTRAINT FK_personv FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_carev FOREIGN KEY (care_site_id) REFERENCES standardized_health_system.care_site(care_site_id),
    CONSTRAINT FK_provv FOREIGN KEY (provider_id) REFERENCES standardized_health_system.provider(provider_id));
GO

IF OBJECT_ID('[standardized_clinical_data].[visit_detail]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[visit_detail];
GO 

CREATE TABLE [standardized_clinical_data].[visit_detail](
    visit_detail_id int NOT NULL UNIQUE, 
    visit_detail_concept_id      int UNIQUE,
    visit_detail_start_date      DATE UNIQUE,
    visit_detail_start_datetime  smalldatetime, 
    visit_detail_end_date        DATE UNIQUE,
    visit_detail_end_datetime    smalldatetime, 
    visit_detail_type_concept_id int UNIQUE,
    visit_detail_source_value      varchar UNIQUE,
    visit_detail_source_concept_id int UNIQUE,
    admitted_from_concept_id   int UNIQUE,
    admitted_from_source_value varchar UNIQUE,
    discharged_to_source_value varchar UNIQUE,
    discharged_to_concept_id   int UNIQUE,
    preceding_visit_detail_id  int UNIQUE,
    visit_occurrence_id  int UNIQUE,
    person_id int UNIQUE,
    FK_visitvd int,
    FK_personvd int,
    CONSTRAINT FK_visitvd FOREIGN KEY (visit_occurrence_id) REFERENCES [standardized_clinical_data].[visit_occurrence](visit_occurrence_id),
    CONSTRAINT FK_personvd FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id));
GO


IF OBJECT_ID('[standardized_clinical_data].[specimen]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[specimen];
GO 


CREATE TABLE [standardized_clinical_data].[specimen](
    specimen_id   int PRIMARY KEY NOT NULL, 
    specimen_concept_id      int UNIQUE,
    specimen_type_concept_id int UNIQUE,
    specimen_date            DATE UNIQUE,
    specimen_datetime        TIMESTAMP UNIQUE, 
    quantity        NUMERIC UNIQUE,
    unit_concept_id int UNIQUE,
    anatomic_site_concept_id  int UNIQUE,
    disease_status_concept_id int UNIQUE,
    specimen_source_id        varchar UNIQUE,
    specimen_source_value     varchar UNIQUE,
    unit_source_value         varchar UNIQUE,
    anatomic_site_source_value  varchar UNIQUE,
    disease_status_source_value varchar UNIQUE,
    person_id int UNIQUE,
    FK_persons int,
    CONSTRAINT FK_persons FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id), 
); 
GO


IF OBJECT_ID('[standardized_clinical_data].[fact_relationship]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[fact_relationship];
GO 


CREATE TABLE [standardized_clinical_data].[fact_relationship](
    fact_relationship_id   int PRIMARY KEY NOT NULL, 
    fact_id_1               int UNIQUE,
    domain_concept_id_2     int UNIQUE,
    fact_id_2               int UNIQUE,
    relationship_concept_id int UNIQUE,
);
GO



-- Standardized Vocabularies
IF OBJECT_ID('[standardized_vocabularies].[source_to_concept_map]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[source_to_concept_map];
GO 

CREATE TABLE [standardized_vocabularies].[source_to_concept_map](
    source_to_concept_map_id int PRIMARY KEY NOT NULL, 
    source_concept_id       int NOT NULL UNIQUE,
    source_vocabulary_id    varchar(20) NOT NULL UNIQUE,
    source_code_description varchar(255) UNIQUE,
    target_concept_id       int NOT NULL UNIQUE,
    target_vocabulary_id    varchar(20) UNIQUE,
    valid_start_date        DATE NOT NULL UNIQUE, 
    valid_end_date          DATE NOT NULL UNIQUE, 
    invalid_reason          varchar(1) UNIQUE);
GO

IF OBJECT_ID('[standardized_vocabularies].[drug_strength]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[drug_strength];
GO 

CREATE TABLE [standardized_vocabularies].[drug_strength](
    drug_strength_id int PRIMARY KEY NOT NULL, 
    ingredient_concept_id  int NOT NULL UNIQUE,
    amount_value           NUMERIC UNIQUE,
    amount_unit_concept_id int UNIQUE,
    numerator_value        NUMERIC UNIQUE,
    numerator_unit_concept_id   int UNIQUE,
    denominator_value           NUMERIC UNIQUE,
    denominator_unit_concept_id int UNIQUE,
    box_size         int UNIQUE,
    valid_start_date DATE NOT NULL UNIQUE, 
    valid_end_date   DATE NOT NULL UNIQUE, 
    invalid_reason   varchar(1) UNIQUE); 
GO


IF OBJECT_ID('[standardized_vocabularies].[vocabulary]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[vocabulary];
GO 

CREATE TABLE [standardized_vocabularies].[vocabulary](
    vocabulary_id  int PRIMARY KEY NOT NULL, 
    vocabulary_name varchar(255) UNIQUE,
    vocabulary_reference  varchar(255) UNIQUE,
    vocabulary_version    varchar(255) UNIQUE,
    vocabulary_concept_id int NOT NULL UNIQUE);
GO



IF OBJECT_ID('[standardized_vocabularies].[domain]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[domain];
GO 

CREATE TABLE [standardized_vocabularies].[domain](
    domain_id        int PRIMARY KEY NOT NULL, 
    domain_name       varchar(20) NOT NULL UNIQUE,
    domain_concept_id int NOT NULL UNIQUE);
GO



IF OBJECT_ID('[standardized_vocabularies].[concept_class]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[concept_class];
GO 

CREATE TABLE [standardized_vocabularies].[concept_class](
    concept_class_id        int PRIMARY KEY NOT NULL, 
    concept_class_name       varchar NOT NULL UNIQUE,
    concept_class_concept_id int NOT NULL UNIQUE);
GO


IF OBJECT_ID('[standardized_vocabularies].[concept_synonym]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[concept_synonym];
GO 

CREATE TABLE [standardized_vocabularies].[concept_synonym](
    concept_synonym_id  int PRIMARY KEY NOT NULL, 
    concept_synonym_name varchar(1000) UNIQUE,
    language_concept_id  int NOT NULL UNIQUE);
GO


IF OBJECT_ID('[standardized_vocabularies].[concept]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[concept];
GO 

CREATE TABLE [standardized_vocabularies].[concept](
    concept_id        int PRIMARY KEY NOT NULL, 
    concept_name  varchar(20) NOT NULL UNIQUE,
    standard_concept varchar(1) UNIQUE,
    concept_code     varchar(20) NOT NULL UNIQUE,
    valid_start_date DATE NOT NULL UNIQUE, 
    valid_end_date   DATE NOT NULL UNIQUE, 
    invalid_reason   varchar(1) UNIQUE,
    vocabulary_id      int UNIQUE,
    domain_id          int UNIQUE,
    concept_class_id   int UNIQUE,
    concept_synonym_id int UNIQUE,
    FK_vocabc int,
    FK_domainc int,
    FK_conclsc int,
    FK_consyn int,
    CONSTRAINT FK_vocabc FOREIGN KEY (vocabulary_id) REFERENCES standardized_vocabularies.vocabulary(vocabulary_id),
    CONSTRAINT FK_domainc FOREIGN KEY (domain_id) REFERENCES standardized_vocabularies.domain(domain_id),
    CONSTRAINT FK_conclsc FOREIGN KEY (concept_class_id) REFERENCES standardized_vocabularies.concept_class(concept_class_id),
    CONSTRAINT FK_consyn FOREIGN KEY (concept_synonym_id) REFERENCES standardized_vocabularies.concept_synonym(concept_synonym_id));
GO



IF OBJECT_ID('[standardized_vocabularies].[relationship]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[relationship];
GO 

CREATE TABLE [standardized_vocabularies].[relationship](
    relationship_id  int PRIMARY KEY NOT NULL, 
    relationship_name varchar(20) NOT NULL UNIQUE,
    is_hierarchical   varchar(1) NOT NULL UNIQUE,
    defines_ancestry  varchar(1) UNIQUE,
    reverse_relationship_id varchar(20) NOT NULL UNIQUE,
    relationship_concept_id int NOT NULL UNIQUE);
GO


IF OBJECT_ID('[standardized_vocabularies].[concept_relationship]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[concept_relationship];
GO 

CREATE TABLE [standardized_vocabularies].[concept_relationship](
    concept_relationship_id int PRIMARY KEY NOT NULL, 
    concept_id         int UNIQUE,
    relationship_id    int UNIQUE,
    FK_relation int,
    FK_conc int,
    CONSTRAINT FK_conc FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id),
    CONSTRAINT FK_relation FOREIGN KEY (relationship_id) REFERENCES standardized_vocabularies.relationship(relationship_id));
GO


IF OBJECT_ID('[standardized_vocabularies].[concept_ancestor]','U') IS NOT NULL
DROP TABLE [standardized_vocabularies].[concept_ancestor];
GO 

CREATE TABLE [standardized_vocabularies].[concept_ancestor](
    concept_ancestor_id    int PRIMARY KEY NOT NULL, 
    descendant_concept_id   int NOT NULL UNIQUE,
    min_levels_of_separation int NOT NULL UNIQUE,
    max_levels_of_separation int NOT NULL UNIQUE,
    concept_relationship_id  int UNIQUE,
    FK_concr int,
    CONSTRAINT FK_concr FOREIGN KEY (concept_relationship_id) REFERENCES standardized_vocabularies.concept_relationship(concept_relationship_id));
GO



-- standardized_derived_elements
IF OBJECT_ID('[standardized_derived_elements].[condition_era]','U') IS NOT NULL
DROP TABLE [standardized_derived_elements].[condition_era];
GO 

CREATE TABLE [standardized_derived_elements].[condition_era](
    condition_era_id int PRIMARY KEY NOT NULL, 
    condition_concept_id       int NOT NULL UNIQUE,
    condition_era_start_date   DATE NOT NULL UNIQUE, 
    condition_era_end_date     DATE NOT NULL UNIQUE, 
    condition_occurrence_count int UNIQUE,
    person_id  int UNIQUE,
    concept_id int UNIQUE,
    FK_personce int,
    FK_concce int,
    CONSTRAINT FK_personce FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_concce FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO



IF OBJECT_ID('[standardized_derived_elements].[drug_era]','U') IS NOT NULL
DROP TABLE [standardized_derived_elements].[drug_era];
GO 

CREATE TABLE [standardized_derived_elements].[drug_era](
    drug_era_id    int PRIMARY KEY NOT NULL, 
    drug_concept_id int NOT NULL UNIQUE,
    drug_era_start_date DATE NOT NULL UNIQUE, 
    drug_era_end_date   DATE NOT NULL UNIQUE, 
    drug_exposure_count int UNIQUE,
    gap_days   int UNIQUE,
    person_id  int UNIQUE,
    concept_id int UNIQUE,
    FK_personde int,
    FK_concde int,
    CONSTRAINT FK_personde FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_concde FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO



IF OBJECT_ID('[standardized_derived_elements].[dose_era]','U') IS NOT NULL
DROP TABLE [standardized_derived_elements].[dose_era];
GO 

CREATE TABLE [standardized_derived_elements].[dose_era](
    dose_era_id    int PRIMARY KEY NOT NULL, 
    drug_concept_id int NOT NULL UNIQUE,
    unit_concept_id int NOT NULL UNIQUE,
    dose_value          NUMERIC NOT NULL UNIQUE,
    dose_era_start_date DATE NOT NULL UNIQUE, 
    dose_era_end_date   DATE NOT NULL UNIQUE, 
    person_id  int UNIQUE,
    concept_id int UNIQUE, 
    FK_persondoe int, 
    FK_concdoe int, 
    CONSTRAINT FK_persondoe FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_concdoe FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO


-- standardized_clinical_data
IF OBJECT_ID('[standardized_clinical_data].[condition_occurrence]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[condition_occurrence];
GO 

CREATE TABLE [standardized_clinical_data].[condition_occurrence](
    condition_occurrence_id  int PRIMARY KEY NOT NULL,
    condition_concept_id     int UNIQUE,
    condition_start_date     DATE UNIQUE,
    condition_start_datetime  smalldatetime,
    condition_end_date       DATE UNIQUE,
    condition_end_datetime   smalldatetime,
    condition_type_concept_id   int UNIQUE,
    condition_status_concept_id int UNIQUE,
    stop_reason varchar UNIQUE,
    provider_id int UNIQUE,
    visit_detail_id        int UNIQUE,
    condition_source_value varchar UNIQUE,
    condition_source_concept_id   int UNIQUE,
    condition_status_source_value varchar UNIQUE,
    person_id          int UNIQUE,
    visit_occurrence_id int UNIQUE,
    concept_id         int UNIQUE,
    FK_personco int,
    FK_visitconc int,
    FK_conco int, 
    CONSTRAINT FK_personco FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_visitconc FOREIGN KEY (visit_occurrence_id) REFERENCES standardized_clinical_data.visit_occurrence(visit_occurrence_id),
    CONSTRAINT FK_conco FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO


IF OBJECT_ID('[standardized_clinical_data].[drug_exposure]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[drug_exposure];
GO 

CREATE TABLE [standardized_clinical_data].[drug_exposure](
    drug_exposure_id int PRIMARY KEY NOT NULL, 
    drug_concept_id  int UNIQUE,
    drug_exposure_start_date     DATE UNIQUE,
    drug_exposure_start_datetime smalldatetime,
    drug_exposure_end_date       DATE UNIQUE,
    drug_exposure_end_datetime   varchar UNIQUE,
    verbatim_end_date    DATE UNIQUE,
    drug_type_concept_id int UNIQUE,
    stop_reason          varchar UNIQUE,
    refills     int UNIQUE,
    quantity    NUMERIC UNIQUE,
    days_supply int UNIQUE,
    sig         NVARCHAR UNIQUE,
    route_concept_id  int UNIQUE,
    lot_number        varchar UNIQUE,
    provider_id       int UNIQUE,
    visit_detail_id   int UNIQUE,
    drug_source_value varchar UNIQUE,
    drug_source_concept_id int UNIQUE,
    route_source_value     varchar UNIQUE,
    dose_unit_source_value varchar UNIQUE,
    person_id              int UNIQUE,
    visit_occurrence_id     int UNIQUE,
    concept_id             int UNIQUE,
    FK_persondr int,
    FK_visit int, 
    FK_concdr int,
    CONSTRAINT FK_persondr FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_visit FOREIGN KEY (visit_occurrence_id) REFERENCES standardized_clinical_data.visit_occurrence(visit_occurrence_id),
    CONSTRAINT FK_concdr FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));

GO


IF OBJECT_ID('[standardized_clinical_data].[procedure_occurrence]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[procedure_occurrence];
GO 

CREATE TABLE [standardized_clinical_data].[procedure_occurrence](
    procedure_occurrence_id int NOT NULL PRIMARY KEY, 
    procedure_concept_id    int UNIQUE,
    procedure_date     DATE UNIQUE,
    procedure_datetime smalldatetime UNIQUE, 
    procedure_end_date DATE UNIQUE,
    procedure_end_datetime smalldatetime UNIQUE, 
    procedure_type_concept_id int UNIQUE,
    modifier_concept_id       int UNIQUE,
    quantity        int UNIQUE,
    provider_id     int UNIQUE,
    visit_detail_id int UNIQUE,
    procedure_source_value      varchar UNIQUE,
    procedure_source_concept_id int UNIQUE,
    modifier_source_value       varchar UNIQUE,
    person_id              int UNIQUE,
    visit_occurrence_id     int UNIQUE,
    concept_id             int UNIQUE,
    FK_personpo int,
    FK_visitpo int, 
    FK_concpro int,
    CONSTRAINT FK_personpo FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_visitpo FOREIGN KEY (visit_occurrence_id) REFERENCES standardized_clinical_data.visit_occurrence(visit_occurrence_id),
    CONSTRAINT FK_concpro FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO


IF OBJECT_ID('[standardized_clinical_data].[device_exposure]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[pdevice_exposure];
GO 

CREATE TABLE [standardized_clinical_data].[device_exposure](
    device_exposure_id int NOT NULL PRIMARY KEY, 
    device_concept_id  int UNIQUE,
    device_exposure_start_date     DATE UNIQUE,
    device_exposure_start_datetime smalldatetime UNIQUE, 
    device_exposure_end_date       DATE UNIQUE,
    device_exposure_end_datetime   smalldatetime UNIQUE, 
    device_type_concept_id int UNIQUE,
    unique_device_id       varchar UNIQUE,
    production_id          varchar UNIQUE,
    quantity               int UNIQUE,
    provider_id            int UNIQUE,
    visit_detail_id          int UNIQUE,
    device_source_value      varchar UNIQUE,
    device_source_concept_id int UNIQUE,
    unit_concept_id          int UNIQUE,
    unit_source_value      varchar UNIQUE,
    unit_source_concept_id int UNIQUE,
    person_id              int UNIQUE,
    visit_occurrence_id     int UNIQUE,
    concept_id             int UNIQUE,
    FK_persondex int,
    FK_visitdex int, 
    FK_concdex int,
    CONSTRAINT FK_persondex FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_visitdex FOREIGN KEY (visit_occurrence_id) REFERENCES standardized_clinical_data.visit_occurrence(visit_occurrence_id),
    CONSTRAINT FK_concdex FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO


IF OBJECT_ID('[standardized_clinical_data].[measurements]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[measurements];
GO 

CREATE TABLE [standardized_clinical_data].[measurements](
    measurements_id int NOT NULL PRIMARY KEY, 
    measurement_concept_id int UNIQUE,
    measurement_date       DATE UNIQUE,
    measurement_datetime   smalldatetime UNIQUE, 
    measurement_time       varchar UNIQUE,
    measurement_type_concept_id int UNIQUE,
    operator_concept_id         int UNIQUE,
    value_as_number             NUMERIC UNIQUE,
    value_as_concept_id         int UNIQUE,
    unit_concept_id int UNIQUE,
    range_low       NUMERIC UNIQUE,
    range_high      NUMERIC UNIQUE,
    provider_id     int UNIQUE,
    visit_detail_id int UNIQUE,
    measurement_source_value      varchar UNIQUE,
    measurement_source_concept_id int UNIQUE,
    unit_source_value             varchar UNIQUE,
    unit_source_concept_id        int UNIQUE,
    value_source_value            varchar UNIQUE,
    measurement_event_id        int UNIQUE,
    meas_event_field_concept_id int UNIQUE,
    person_id              int UNIQUE,
    visit_occurrence_id     int UNIQUE,
    concept_id             int UNIQUE,
    FK_personmes int,
    FK_visitmes int, 
    FK_concmes int,
    CONSTRAINT FK_personmes FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_visitmes FOREIGN KEY (visit_occurrence_id) REFERENCES standardized_clinical_data.visit_occurrence(visit_occurrence_id),
    CONSTRAINT FK_concmes FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO




IF OBJECT_ID('[standardized_clinical_data].[observation]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[observation];
GO 

CREATE TABLE [standardized_clinical_data].[observation](
    observation_id int NOT NULL PRIMARY KEY, 
    observation_concept_id int UNIQUE,
    observation_date       DATE UNIQUE,
    observation_datetime   smalldatetime UNIQUE, 
    observation_type_concept_id int UNIQUE,
    value_as_number NUMERIC UNIQUE,
    value_as_string varchar UNIQUE,
    value_as_concept_id  int UNIQUE,
    qualifier_concept_id int UNIQUE,
    unit_concept_id int UNIQUE,
    provider_id     int UNIQUE,
    visit_detail_id     int UNIQUE,
    observation_source_value      varchar UNIQUE,
    observation_source_concept_id int UNIQUE,
    unit_source_value      varchar UNIQUE,
    qualifier_source_value varchar UNIQUE,
    value_source_value         varchar UNIQUE,
    observation_event_id       int UNIQUE,
    obs_event_field_concept_id int UNIQUE,
    person_id              int UNIQUE,
    visit_occurrence_id     int UNIQUE,
    concept_id             int UNIQUE,
    FK_personob int,
    FK_visitob int, 
    FK_concob int,
    CONSTRAINT FK_personob FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_visitob FOREIGN KEY (visit_occurrence_id) REFERENCES standardized_clinical_data.visit_occurrence(visit_occurrence_id),
    CONSTRAINT FK_concob FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO



IF OBJECT_ID('[standardized_clinical_data].[note]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[note];
GO 

CREATE TABLE [standardized_clinical_data].[note](
    note_id       int NOT NULL PRIMARY KEY, 
    note_date      DATE UNIQUE,
    note_datetime  smalldatetime UNIQUE, 
    note_type_concept_id  int UNIQUE,
    note_class_concept_id int UNIQUE,
    note_title varchar UNIQUE,
    note_text nvarchar NOT NULL UNIQUE,
    encoding_concept_id int UNIQUE,
    language_concept_id int UNIQUE,
    provider_id       int UNIQUE,
    visit_detail_id   int UNIQUE,
    note_source_value varchar UNIQUE,
    note_event_id     int UNIQUE,
    note_event_field_concept_id int UNIQUE,
    person_id              int UNIQUE,
    visit_occurrence_id     int UNIQUE,
    concept_id             int UNIQUE,
    FK_personnt int,
    FK_visitnt int, 
    FK_concnt int,
    CONSTRAINT FK_personnt FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_visitnt FOREIGN KEY (visit_occurrence_id) REFERENCES standardized_clinical_data.visit_occurrence(visit_occurrence_id),
    CONSTRAINT FK_concnt FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO


IF OBJECT_ID('[standardized_clinical_data].[note_NLP]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[note_NLP];
GO 

CREATE TABLE [standardized_clinical_data].[note_NLP](
    note_NLP_id   int NOT NULL PRIMARY KEY, 
    snippet        varchar UNIQUE,
    lexical_variant            varchar UNIQUE,
    note_nlp_concept_id        int UNIQUE,
    section_concept_id         int UNIQUE,
    note_nlp_source_concept_id int UNIQUE,
    nlp_system     varchar UNIQUE,
    nlp_date       DATE UNIQUE,
    nlp_datetime   smalldatetime UNIQUE, 
    term_exists    varchar UNIQUE,
    term_temporal  varchar UNIQUE,
    term_modifiers varchar UNIQUE,
    note_id        int UNIQUE,
    concept_id     int UNIQUE,
    FK_note int,
    FK_conntnlp int,
    CONSTRAINT FK_note FOREIGN KEY (note_id) REFERENCES standardized_clinical_data.note(note_id),
    CONSTRAINT FK_conntnlp FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO


IF OBJECT_ID('[standardized_clinical_data].[episode]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[episode];
GO 

CREATE TABLE [standardized_clinical_data].[episode](
    episode_id    int NOT NULL PRIMARY KEY, 
    episode_concept_id     int UNIQUE,
    episode_start_date     DATE UNIQUE,
    episode_start_datetime smalldatetime UNIQUE, 
    episode_end_date       DATE UNIQUE,
    episode_end_datetime   smalldatetime UNIQUE, 
    episode_parent_id int UNIQUE,
    episode_number    int UNIQUE,
    episode_object_concept_id int UNIQUE,
    episode_type_concept_id   int UNIQUE,
    episode_source_value      varchar UNIQUE,
    episode_source_concept_id int UNIQUE,
    person_id              int UNIQUE,
    concept_id             int UNIQUE,
    FK_personepi int,
    FK_concepi int,
    CONSTRAINT FK_personepi FOREIGN KEY (person_id) REFERENCES standardized_clinical_data.person(user_id),
    CONSTRAINT FK_concepi FOREIGN KEY (concept_id) REFERENCES standardized_vocabularies.concept(concept_id));
GO


IF OBJECT_ID('[standardized_clinical_data].[pisode_event]','U') IS NOT NULL
DROP TABLE [standardized_clinical_data].[pisode_event];
GO 

CREATE TABLE [standardized_clinical_data].[pisode_event](
    pisode_event_id int NOT NULL PRIMARY KEY, 
    event_id         int UNIQUE,
    episode_event_field_concept_id int UNIQUE,
    episode_id int UNIQUE,
    FK_concepie int,
    CONSTRAINT FK_concepie FOREIGN KEY (episode_id) REFERENCES standardized_clinical_data.episode(episode_id));
GO











