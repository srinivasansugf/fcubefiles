--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE POPULATE_CLAIM_DATA (
    P_TRAN_TYPE IN  VARCHAR2,                 -- 'C' claim, 'R' reserve, 'S' settlement
    P_KEY       IN  NUMBER   DEFAULT NULL,    -- TP key of that type
    P_FROM      IN  DATE     DEFAULT NULL,    -- period, used when P_KEY is null
    P_TO        IN  DATE     DEFAULT NULL,
    P_OUT_KEY   OUT VARCHAR2                  -- our key (last record when a period is run)
) IS
    M_TYPE VARCHAR2(1) := UPPER(P_TRAN_TYPE);

    ----------------------------------------------------------------------------
    -- 1) RECORD types as per our tables
    ----------------------------------------------------------------------------
    TYPE REC_CLAIM IS RECORD (                       -- CT_CLAIM
        CCLM_KEY                 INTEGER,
        CCLM_CLAIM_KEY_TP_REF    INTEGER,
        CCLM_CLAIM_NO            VARCHAR2(100),
        CCLM_LOSS_DATETIME       TIMESTAMP(6),
        CCLM_DISCOVERY_DATETIME  TIMESTAMP(6),
        CCLM_INTIMATTION_DATETIME TIMESTAMP(6),
        CCLM_POLICY_NO           VARCHAR2(64),
        CCLM_STATUS              VARCHAR2(32),
        CCLM_PRODUCT             VARCHAR2(32),
        CCLM_EVENT_KEY           NUMBER(32),
        CCLM_FILE_KEY            NUMBER(32));

    TYPE REC_RESERVE IS RECORD (                     -- CT_CLAIM_RESERVE
        CCR_KEY                         VARCHAR2(50),
        CCR_CLAIM_KEY                   VARCHAR2(50),
        CCR_FILE_NUMBER                 VARCHAR2(50),
        CCR_RESERVE_TYPE                VARCHAR2(50),
        CCR_RESERVE_KEY_TP_REF          INTEGER,
        CCR_RESERVE_KEY_REVISION_TP_REF INTEGER,
        CCR_COVER_KEY                   VARCHAR2(50),
        CCR_SMI_KEY                     VARCHAR2(50),
        CCR_LOSS_CODE                   VARCHAR2(50),
        CCR_RESERVE_AMOUNT              NUMBER(18,2),
        CCR_RESERVE_AMOUNT_DIFF         NUMBER(18,2),
        CCR_RESERVE_STATUS              VARCHAR2(50),
        CCR_RESERVE_DATE                DATE,
        CCR_REVISION_REASON             VARCHAR2(255),
        CCR_REVISION_REMARKS            VARCHAR2(500));

    TYPE REC_SETTLEMENT IS RECORD (                  -- RT_CLAIM_SETTLEMENT
        CCS_KEY                   VARCHAR2(50),
        CCS_CLAIM_KEY             VARCHAR2(50),
        CCS_CLAIM_NUMBER          VARCHAR2(50),
        CCS_RESERVE_KEY           VARCHAR2(50),
        CCS_SETTLEMENT_KEY_TP_REF VARCHAR2(50),
        CCS_DATE                  DATE,
        CCS_SETTLEMENT_AMOUNT     NUMBER(18,2),
        CCS_SETTLEMENT_STATUS     VARCHAR2(50));

    ----------------------------------------------------------------------------
    -- 2) Collections (index = TP key)  -- these play the role of our tables
    ----------------------------------------------------------------------------
    TYPE T_CLAIM_TAB      IS TABLE OF REC_CLAIM      INDEX BY PLS_INTEGER;
    TYPE T_RESERVE_TAB    IS TABLE OF REC_RESERVE    INDEX BY PLS_INTEGER;
    TYPE T_SETTLEMENT_TAB IS TABLE OF REC_SETTLEMENT INDEX BY PLS_INTEGER;

    L_CLAIM      T_CLAIM_TAB;        -- CT_CLAIM            by TP claim key
    L_RESERVE    T_RESERVE_TAB;      -- CT_CLAIM_RESERVE    by TP reserve key
    L_SETTLEMENT T_SETTLEMENT_TAB;   -- RT_CLAIM_SETTLEMENT by TP settlement key

    -- stand-ins for SEQ_CCLM_KEY / SEQ_CCR_KEY / SEQ_CCS_KEY
    M_CLM_SEQ NUMBER := 0;
    M_RSV_SEQ NUMBER := 0;
    M_STL_SEQ NUMBER := 0;

    ----------------------------------------------------------------------------
    -- DBMS_OUTPUT helpers
    ----------------------------------------------------------------------------
    PROCEDURE P (P_LABEL IN VARCHAR2, P_VALUE IN VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('   ' || RPAD(P_LABEL, 30) || ': ' || P_VALUE);
    END P;

    PROCEDURE SHOW_CLAIM (R IN REC_CLAIM) IS
    BEGIN
        P('CCLM_KEY', R.CCLM_KEY);
        P('CCLM_CLAIM_KEY_TP_REF', R.CCLM_CLAIM_KEY_TP_REF);
        P('CCLM_CLAIM_NO', R.CCLM_CLAIM_NO);
        P('CCLM_LOSS_DATETIME', TO_CHAR(R.CCLM_LOSS_DATETIME, 'YYYY-MM-DD HH24:MI:SS'));
        P('CCLM_DISCOVERY_DATETIME', TO_CHAR(R.CCLM_DISCOVERY_DATETIME, 'YYYY-MM-DD HH24:MI:SS'));
        P('CCLM_INTIMATTION_DATETIME', TO_CHAR(R.CCLM_INTIMATTION_DATETIME, 'YYYY-MM-DD HH24:MI:SS'));
        P('CCLM_POLICY_NO', R.CCLM_POLICY_NO);
        P('CCLM_STATUS', R.CCLM_STATUS);
        P('CCLM_PRODUCT', R.CCLM_PRODUCT);
        P('CCLM_EVENT_KEY', R.CCLM_EVENT_KEY);
        P('CCLM_FILE_KEY', R.CCLM_FILE_KEY);
    END SHOW_CLAIM;

    PROCEDURE SHOW_RESERVE (R IN REC_RESERVE) IS
    BEGIN
        P('CCR_KEY', R.CCR_KEY);
        P('CCR_CLAIM_KEY', R.CCR_CLAIM_KEY);
        P('CCR_FILE_NUMBER', R.CCR_FILE_NUMBER);
        P('CCR_RESERVE_TYPE', R.CCR_RESERVE_TYPE);
        P('CCR_RESERVE_KEY_TP_REF', R.CCR_RESERVE_KEY_TP_REF);
        P('CCR_RESERVE_KEY_REVISION_TP_REF', R.CCR_RESERVE_KEY_REVISION_TP_REF);
        P('CCR_COVER_KEY', R.CCR_COVER_KEY);
        P('CCR_SMI_KEY', R.CCR_SMI_KEY);
        P('CCR_LOSS_CODE', R.CCR_LOSS_CODE);
        P('CCR_RESERVE_AMOUNT', R.CCR_RESERVE_AMOUNT);
        P('CCR_RESERVE_AMOUNT_DIFF', R.CCR_RESERVE_AMOUNT_DIFF);
        P('CCR_RESERVE_STATUS', R.CCR_RESERVE_STATUS);
        P('CCR_RESERVE_DATE', TO_CHAR(R.CCR_RESERVE_DATE, 'YYYY-MM-DD'));
        P('CCR_REVISION_REASON', R.CCR_REVISION_REASON);
        P('CCR_REVISION_REMARKS', R.CCR_REVISION_REMARKS);
    END SHOW_RESERVE;

    PROCEDURE SHOW_SETTLEMENT (R IN REC_SETTLEMENT) IS
    BEGIN
        P('CCS_KEY', R.CCS_KEY);
        P('CCS_CLAIM_KEY', R.CCS_CLAIM_KEY);
        P('CCS_CLAIM_NUMBER', R.CCS_CLAIM_NUMBER);
        P('CCS_RESERVE_KEY', R.CCS_RESERVE_KEY);
        P('CCS_SETTLEMENT_KEY_TP_REF', R.CCS_SETTLEMENT_KEY_TP_REF);
        P('CCS_DATE', TO_CHAR(R.CCS_DATE, 'YYYY-MM-DD'));
        P('CCS_SETTLEMENT_AMOUNT', R.CCS_SETTLEMENT_AMOUNT);
        P('CCS_SETTLEMENT_STATUS', R.CCS_SETTLEMENT_STATUS);
    END SHOW_SETTLEMENT;

    ----------------------------------------------------------------------------
    -- 3) GET = POPULATE
    ----------------------------------------------------------------------------
    FUNCTION GET_CLAIM_DETAILS (P_TP_KEY IN NUMBER) RETURN NUMBER IS
        L_TP  PGIT_CLAIM%ROWTYPE;
        L_CLM REC_CLAIM;
    BEGIN
        -- >>> LATER <<<  SELECT MIN(CCLM_KEY) ... FROM CT_CLAIM WHERE CCLM_CLAIM_KEY_TP_REF = P_TP_KEY
        IF L_CLAIM.EXISTS(P_TP_KEY) THEN
            DBMS_OUTPUT.PUT_LINE('CLAIM ' || P_TP_KEY || ' already available -> our key '
                                 || L_CLAIM(P_TP_KEY).CCLM_KEY);
            RETURN L_CLAIM(P_TP_KEY).CCLM_KEY;
        END IF;

        BEGIN
            SELECT * INTO L_TP FROM PGIT_CLAIM WHERE CLM_KEY = P_TP_KEY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20002, 'Claim ' || P_TP_KEY || ' not found in TP');
        END;

        M_CLM_SEQ := M_CLM_SEQ + 1;                       -- >>> LATER <<< SEQ_CCLM_KEY.NEXTVAL
        
        --SELECT * FROM PGIT_CLAIM;
        
        L_CLM.CCLM_KEY                   := M_CLM_SEQ;
        L_CLM.CCLM_CLAIM_KEY_TP_REF      := L_TP.CLM_SYS_ID--L_TP.CLM_KEY;
        L_CLM.CCLM_CLAIM_NO              := L_TP.CLM_NO;
        L_CLM.CCLM_LOSS_DATETIME         := L_TP.CLM_LOSS_DT;--L_TP.LOSS_DT;
        L_CLM.CCLM_DISCOVERY_DATETIME    := NULL;--L_TP.DISC_DT;
        L_CLM.CCLM_INTIMATTION_DATETIME  := L_TP.CLM_INTM_DT;--L_TP.INTM_DT;
        L_CLM.CCLM_POLICY_NO             := L_TP.CLM_POL_NO;--L_TP.POL_NO;
        L_CLM.CCLM_STATUS                := NULL;--L_TP.CLM_STATUS;--L_TP.STATUS;
        L_CLM.CCLM_PRODUCT               := L_TP.CLM_PROD_CODE;--L_TP.PRODUCT;
        L_CLM.CCLM_EVENT_KEY             := L_TP.CLM_EVENT_CODE;--L_TP.EVENT_KEY;
        L_CLM.CCLM_FILE_KEY              := L_TP.CLM_SYS_ID;--L_TP.FILE_KEY;

        L_CLAIM(P_TP_KEY) := L_CLM;                       -- >>> LATER <<< INSERT INTO CT_CLAIM VALUES L_CLM
        DBMS_OUTPUT.PUT_LINE('CLAIM ' || P_TP_KEY || ' populated');
        SHOW_CLAIM(L_CLM);
        RETURN L_CLM.CCLM_KEY;
    END GET_CLAIM_DETAILS;

    FUNCTION GET_RESERVE_DETAILS (P_TP_KEY IN NUMBER) RETURN VARCHAR2 IS
        L_TP      PGIT_CLAIM_EST%ROWTYPE;
        L_RSV     REC_RESERVE;
        M_CLM_KEY NUMBER;
        CURSOR C1 IS
        SELECT NVL(GET_FCUBE_KEY('COVER_CODE',CLMAP_COVER_CODE),CLMAP_COVER_CODE)FS_COVER_CODE,
               CLMAP_COVER_CODE FROM PGIT_CLM_APPL_POLICY 
        (SELECT DISTINCT CE_CLMAP_SYS_ID FROM PGITH_CLM_EST WHERE CEH_SYS_ID=P_TP_KEY);
        
        C1REC C1%ROWTYPE;
    BEGIN
        -- >>> LATER <<<  SELECT MIN(CCR_KEY) ... FROM CT_CLAIM_RESERVE WHERE CCR_RESERVE_KEY_TP_REF = P_TP_KEY
        IF L_RESERVE.EXISTS(P_TP_KEY) THEN
            DBMS_OUTPUT.PUT_LINE('RESERVE ' || P_TP_KEY || ' already available -> our key '
                                 || L_RESERVE(P_TP_KEY).CCR_KEY);
            RETURN L_RESERVE(P_TP_KEY).CCR_KEY;
        END IF;

        BEGIN
            SELECT * INTO L_TP FROM PGIT_CLAIM_EST WHERE RSV_KEY = P_TP_KEY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20003, 'Reserve ' || P_TP_KEY || ' not found in TP');
        END;

        M_CLM_KEY := GET_CLAIM_DETAILS(L_TP.CLM_KEY);     -- claim: get or populate
        M_RSV_SEQ := M_RSV_SEQ + 1;                       -- >>> LATER <<< SEQ_CCR_KEY.NEXTVAL
        
        --SELECT * FROM PGITH_CLM_EST;
        OPEN C1;
        FETCH C1 INTO C1REC;
        CLOSE C1;
                
        L_RSV.CCR_KEY                         := TO_CHAR(M_RSV_SEQ);
        L_RSV.CCR_RESERVE_KEY_TP_REF          := L_TP.CEH_SYS_ID--L_TP.RSV_KEY;
        L_RSV.CCR_RESERVE_KEY_REVISION_TP_REF := L_TP.CEH_SR_NO; --L_TP.RSV_REV_KEY;
        L_RSV.CCR_CLAIM_KEY                   := TO_CHAR(M_CLM_KEY);
        --L_RSV.CCR_FILE_NUMBER                 := NULL;--L_TP.FILE_NO;
        
        IF  CE_EST_TYPE IN (1,3) THEN 
              L_RSV.CCR_RESERVE_TYPE  = 'P';
        ELSIF CE_EST_TYPE IN (1,3) THEN
              L_RSV.CCR_RESERVE_TYPE  = 'R';
        END IF; 
        
        L_RSV.CCR_COVER_KEY                   := C1REC.FS_COVER_CODE; --L_TP.COVER_KEY;
        L_RSV.CCR_SMI_KEY                     := NULL;--L_TP.SMI_KEY;
        L_RSV.CCR_LOSS_CODE                   := NVL(GET_FS_KEY('LOSS_CODE',L_TP.CHE_EST_CODE),L_TP.CHE_EST_CODE);--L_TP.LOSS_CODE;

        L_RSV.CCR_COVER_KEY_TP_REF                   := C1REC.CLMAP_COVER_CODE;--L_TP.COVER_KEY;
        L_RSV.CCR_SMI_KEY_TP_REF                     := NULL;--L_TP.SMI_KEY;
        L_RSV.CCR_LOSS_CODE_TP_REF                   := L_TP.CHE_EST_CODE;--L_TP.LOSS_CODE;
        
        L_RSV.CCR_RESERVE_AMOUNT              := NULL;--L_TP.RSV_AMT;
        L_RSV.CCR_RESERVE_AMOUNT_DIFF         := L_TP.CHE_EST_AMF_FT;--L_TP.RSV_AMT_DIFF;
        L_RSV.CCR_RESERVE_STATUS              := L_TP.STATUS;
        L_RSV.CCR_RESERVE_DATE                := L_TP.RSV_DATE;
        L_RSV.CCR_REVISION_REASON             := L_TP.REV_REASON;
        L_RSV.CCR_REVISION_REMARKS            := L_TP.REV_REMARKS;

        L_RESERVE(P_TP_KEY) := L_RSV;                     -- >>> LATER <<< INSERT INTO CT_CLAIM_RESERVE VALUES L_RSV
        DBMS_OUTPUT.PUT_LINE('RESERVE ' || P_TP_KEY || ' populated');
        SHOW_RESERVE(L_RSV);
        RETURN L_RSV.CCR_KEY;
    END GET_RESERVE_DETAILS;

    FUNCTION GET_SETTLEMENT_DETAILS (P_TP_KEY IN NUMBER) RETURN VARCHAR2 IS
        L_TP      PGIT_CLAIM_SETL%ROWTYPE;
        L_STL     REC_SETTLEMENT;
        M_CLM_KEY NUMBER;
        M_RSV_KEY VARCHAR2(50);
    BEGIN
        -- >>> LATER <<<  SELECT MIN(CCS_KEY) ... FROM RT_CLAIM_SETTLEMENT WHERE CCS_SETTLEMENT_KEY_TP_REF = ...
        IF L_SETTLEMENT.EXISTS(P_TP_KEY) THEN
            DBMS_OUTPUT.PUT_LINE('SETTLEMENT ' || P_TP_KEY || ' already available -> our key '
                                 || L_SETTLEMENT(P_TP_KEY).CCS_KEY);
            RETURN L_SETTLEMENT(P_TP_KEY).CCS_KEY;
        END IF;

        BEGIN
        SELECT * FROM PGIT_CLAIM_SETL;
            --SELECT * INTO L_TP FROM PGIT_CLAIM_SETL WHERE STL_KEY = P_TP_KEY;
            SELECT * INTO L_TP FROM PGIT_CLAIM_SETL WHERE CS_SYS_ID = P_TP_KEY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20004, 'Settlement ' || P_TP_KEY || ' not found in TP');
        END;

        M_RSV_KEY := GET_RESERVE_DETAILS(L_TP.CS_CE_SYS_ID--L_TP.RSV_KEY
                                         );   -- reserve (and its claim)
        M_CLM_KEY := GET_CLAIM_DETAILS  (L_TP.CS_CLM_SYS_ID--L_TP.CLM_KEY
                                         );
        M_STL_SEQ := M_STL_SEQ + 1;                       -- >>> LATER <<< SEQ_CCS_KEY.NEXTVAL

        L_STL.CCS_KEY                   := TO_CHAR(M_STL_SEQ);
        L_STL.CCS_SETTLEMENT_KEY_TP_REF := TO_CHAR(L_TP.CS_SYS_ID--L_TP.STL_KEY
                                                   );
        L_STL.CCS_CLAIM_KEY             := TO_CHAR(L_TP.CS_CLM_SYS_ID--M_CLM_KEY
                                                   );
        --L_STL.CCS_CLAIM_NUMBER          := L_T--L_TP.CLM_NO;
        L_STL.CCS_RESERVE_KEY           := L_TP.CS_CE_SYS_ID;--M_RSV_KEY;
        L_STL.CCS_DATE                  := L_TP.CS_DT;--L_TP.STL_DATE;
        L_STL.CCS_SETTLEMENT_AMOUNT     := L_TP.CS_AMT_FC;--L_TP.STL_AMT;
        L_STL.CCS_SETTLEMENT_STATUS     := NULL;--L_TP.STATUS;

        L_SETTLEMENT(P_TP_KEY) := L_STL;                  -- >>> LATER <<< INSERT INTO RT_CLAIM_SETTLEMENT VALUES L_STL
        DBMS_OUTPUT.PUT_LINE('SETTLEMENT ' || P_TP_KEY || ' populated');
        SHOW_SETTLEMENT(L_STL);
        RETURN L_STL.CCS_KEY;
    END GET_SETTLEMENT_DETAILS;

BEGIN
    IF M_TYPE NOT IN ('C','R','S') THEN
        RAISE_APPLICATION_ERROR(-20001, 'P_TRAN_TYPE must be C, R or S');
    END IF;

    IF P_KEY IS NOT NULL THEN
        P_OUT_KEY := CASE M_TYPE
                         WHEN 'C' THEN TO_CHAR(GET_CLAIM_DETAILS(P_KEY))
                         WHEN 'R' THEN GET_RESERVE_DETAILS(P_KEY)
                         WHEN 'S' THEN GET_SETTLEMENT_DETAILS(P_KEY)
                     END;
    ELSE
        IF M_TYPE = 'C' THEN
            FOR R IN (SELECT CLM_SYS_ID KEY 
                        FROM PGIT_CLAIM
                       WHERE TRUNC(CLM_LOSS_DT) BETWEEN P_FROM AND P_TO) LOOP
                P_OUT_KEY := TO_CHAR(GET_CLAIM_DETAILS(R.KEY));
            END LOOP;
        ELSIF M_TYPE = 'R' THEN
            FOR R IN (SELECT DISTINCT CEH_SYS_ID KEY FROM PGIT_CLAIM_EST
                       WHERE TRUNC(CEH_DT) BETWEEN P_FROM AND P_TO) LOOP
                P_OUT_KEY := GET_RESERVE_DETAILS(R.KEY);
            END LOOP;
        ELSE
            FOR R IN (SELECT CS_SYS_ID KEY FROM PGIT_CLAIM_SETL
                       WHERE CS_DT BETWEEN P_FROM AND P_TO) LOOP
                P_OUT_KEY := GET_SETTLEMENT_DETAILS(R.KEY);
            END LOOP;
        END IF;
    END IF;

    -- 4) summary of what is now in the collections
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('L_CLAIM.COUNT      = ' || L_CLAIM.COUNT);
    DBMS_OUTPUT.PUT_LINE('L_RESERVE.COUNT    = ' || L_RESERVE.COUNT);
    DBMS_OUTPUT.PUT_LINE('L_SETTLEMENT.COUNT = ' || L_SETTLEMENT.COUNT);
    DBMS_OUTPUT.PUT_LINE('P_OUT_KEY          = ' || P_OUT_KEY);
    -- no COMMIT needed now: nothing is written to any table
END POPULATE_CLAIM_DATA;
/
