-- Flintcube Code Generator | CRUD | PropClaimAllocation
-- oracle DDL for table rt_prop_claim_allocation

CREATE SEQUENCE sq_rt_prop_claim_allocation START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE rt_prop_claim_allocation (
    rpca_glkey NUMBER(16) NOT NULL,
    rpca_key NUMBER(16) NOT NULL,
    rpca_tekey NUMBER(16) NOT NULL,
    rpca_risk_key NUMBER(32),
    rpca_cover_key NUMBER(32),
    rpca_smi_key NUMBER(32),
    rpca_loss_key NUMBER(32),
    rpca_type VARCHAR2(32),
    rpca_claim_key NUMBER(32),
    rpca_transaction_type VARCHAR2(32),
    rpca_transaction_key NUMBER(32),
    rpca_transaction_revision NUMBER(8),
    rpca_transaction_date TIMESTAMP,
    rpca_reserve_type VARCHAR2(32),
    rpca_loss_type VARCHAR2(32),
    rpca_loss_amount NUMBER,
    rpca_loss_currency NUMBER,
    rpca_loss_amount_cc NUMBER,
    rpca_treaty_key NUMBER(32),
    rpca_currency_key NUMBER(32),
    rpca_product_key NUMBER(32),
    rpca_created_user NUMBER(16),
    rpca_created_datetime TIMESTAMP,
    rpca_updated_user NUMBER(16),
    rpca_updated_datetime TIMESTAMP,
    rpca_record_hash VARCHAR2(1024),
    rpca_record_status VARCHAR2(2),
    rpca_record_type VARCHAR2(2),
    rpca_verEffectiveFrom TIMESTAMP,
    rpca_verEffectiveTo TIMESTAMP,
    rpca_verApprovedDateTime TIMESTAMP,
    rpca_version NUMBER(8),
    CONSTRAINT pk_rt_prop_claim_allocation PRIMARY KEY (rpca_key)
);
