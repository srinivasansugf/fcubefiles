-- Flintcube Code Generator | CRUD | PropClaimAllocation
-- oracle DDL for table rt_prop_claim_allocation_layer

CREATE SEQUENCE sq_rt_prop_claim_alloc_layer START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE rt_prop_claim_allocation_layer (
    rpcl_glkey NUMBER(16) NOT NULL,
    rpcl_key NUMBER(16) NOT NULL,
    rpcl_tekey NUMBER(16) NOT NULL,
    rpcl_rpca_key NUMBER(32),
    rpcl_allocation_group VARCHAR2(32),
    rpcl_layerkey VARCHAR2(32),
    rpcl_retention_percentage NUMBER,
    rpcl_retn_amount NUMBER,
    rpcl_retn_amount_cc NUMBER,
    rpcl_ri_percentage NUMBER,
    rpcl_ri_amount NUMBER,
    rpcl_ri_amount_cc NUMBER,
    rpcl_created_user NUMBER(16),
    rpcl_created_datetime TIMESTAMP,
    rpcl_updated_user NUMBER(16),
    rpcl_updated_datetime TIMESTAMP,
    rpcl_record_hash VARCHAR2(1024),
    rpcl_record_status VARCHAR2(2),
    rpcl_record_type VARCHAR2(2),
    rpcl_verEffectiveFrom TIMESTAMP,
    rpcl_verEffectiveTo TIMESTAMP,
    rpcl_verApprovedDateTime TIMESTAMP,
    rpcl_version NUMBER(8),
    CONSTRAINT pk_rt_prop_claim_allocation_layer PRIMARY KEY (rpcl_key)
);
