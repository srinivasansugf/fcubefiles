-- Flintcube Code Generator | CRUD | ClaimEvent
-- oracle DDL for table cc_claim_event

CREATE SEQUENCE sq_ct_legal_case START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE cc_claim_event (
    ccev_glkey NUMBER(16) NOT NULL,
    ccev_key NUMBER(16) NOT NULL,
    ccev_tekey NUMBER(16) NOT NULL,
    ccev_description VARCHAR2(1024),
    ccev_event_key VARCHAR2(32),
    ccev_start_datetime TIMESTAMP,
    ccev_name VARCHAR2(256),
    ccev_event_type VARCHAR2(32),
    ccev_reported_start_datatime TIMESTAMP,
    ccev_reported_end_datatime TIMESTAMP,
    ccev_end_datetime TIMESTAMP,
    ccev_created_user NUMBER(16),
    ccev_created_datetime TIMESTAMP,
    ccev_updated_user NUMBER(16),
    ccev_updated_datetime TIMESTAMP,
    ccev_record_hash VARCHAR2(1024),
    ccev_record_status VARCHAR2(2),
    ccev_verEffectiveFrom TIMESTAMP,
    ccev_verEffectiveTo TIMESTAMP,
    ccev_verApprovedDateTime TIMESTAMP,
    ccev_version NUMBER(8),
    CONSTRAINT pk_cc_claim_event PRIMARY KEY (ccev_key),
    CONSTRAINT uq_cc_claim_event_ccev_event_key UNIQUE (ccev_event_key)
);
