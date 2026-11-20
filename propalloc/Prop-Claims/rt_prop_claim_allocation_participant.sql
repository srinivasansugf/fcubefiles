-- Flintcube Code Generator | CRUD | PropClaimAllocation
-- oracle DDL for table rt_prop_claim_allocation_participant

CREATE SEQUENCE sq_rt_prop_claim_alloc_ppnt START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE rt_prop_claim_allocation_participant (
    rpcp_glkey NUMBER(16) NOT NULL,
    rpcp_key NUMBER(16) NOT NULL,
    rpcp_tekey NUMBER(16) NOT NULL,
    rpcp_rpcl_key NUMBER(32),
    rpcp_participant_key NUMBER(32),
    rpcp_broker_key NUMBER(32),
    rpcp_share_percentage NUMBER,
    rpcp_share_amount NUMBER,
    rpcp_share_amount_cc NUMBER,
    rpcp_created_user NUMBER(16),
    rpcp_created_datetime TIMESTAMP,
    rpcp_updated_user NUMBER(16),
    rpcp_updated_datetime TIMESTAMP,
    rpcp_record_hash VARCHAR2(1024),
    rpcp_record_status VARCHAR2(2),
    rpcp_record_type VARCHAR2(2),
    rpcp_verEffectiveFrom TIMESTAMP,
    rpcp_verEffectiveTo TIMESTAMP,
    rpcp_verApprovedDateTime TIMESTAMP,
    rpcp_version NUMBER(8),
    CONSTRAINT pk_rt_prop_claim_allocation_participant PRIMARY KEY (rpcp_key)
);
