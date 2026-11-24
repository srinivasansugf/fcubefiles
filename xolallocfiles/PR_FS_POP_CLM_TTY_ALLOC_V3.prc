CREATE OR REPLACE PROCEDURE PR_FS_POP_CLM_TTY_ALLOC IS
--BEGIN EXECUTE IMMEDIATE ('TRUNCATE TABLE DEBUG_LOG_TAB'); PR_FS_POP_CLM_TTY_ALLOC; END;
---------------------------Claim RI----------------------
CURSOR C_CLM_RI IS
SELECT REC_TYPE,
       RCIH_SYS_ID,
       CLM_SYS_ID,
       CLMAP_PRAI_LVL1_SYS_ID,
       CLMAP_PRAI_LVL1_DESC,
       CLMAP_COVER_CODE,
       PAYMENT_RECOVERY,
       --CLMAP_LOSS_CODE,
       SYS_KEY,
       RCIH_ALLOC_IDX,
       TRAN_REV_NO,
       LOSS_CODE,
       TRAN_DT,
       LOSS_AMT,
       PROD_CODE
FROM
(
SELECT
       'R' REC_TYPE,
       RCIH_SYS_ID,
       CLM_SYS_ID,
       CLMAP_PRAI_LVL1_SYS_ID,
       CLMAP_PRAI_LVL1_DESC,
       CLMAP_COVER_CODE,
       (CASE WHEN  CEH_EST_TYPE IN (1,3) THEN
            'P'
            WHEN  CEH_EST_TYPE IN (2,4) THEN
            'R'
        END)PAYMENT_RECOVERY,
       CLMAP_LOSS_CODE,
       CEH_SYS_ID SYS_KEY,
       CEH_SR_NO TRAN_REV_NO,
       RCIH_ALLOC_IDX,
       CEH_EST_CODE LOSS_CODE,
       CEH_DT TRAN_DT,
       CEH_AMT_FC LOSS_AMT,
       CLM_PROD_CODE PROD_CODE
FROM PGIT_CLAIM,
     PGIT_CLM_APPL_POLICY,
     PGITH_CLM_EST,
     PGITH_RI_CLM_INTERFACE
WHERE CLM_NO IN ('CL/DP/02/2009/21/00179-0090','CL/IFF/01/4011/20/00007-21/0145')
AND CLM_SYS_ID=CLMAP_CLM_SYS_ID
AND CLMAP_SYS_ID = CEH_CLMAP_SYS_ID
AND RCIH_CE_SYS_ID=CEH_SYS_ID
AND CEH_SR_NO = RCIH_ALLOC_IDX + 1
AND RCIH_CPMTD_SYS_ID IS NULL
--ORDER BY CEH_SYS_ID,CEH_SR_NO
UNION ALL
SELECT
       'S' REC_TYPE,
       RCIH_SYS_ID,
       CLM_SYS_ID,
       CLMAP_PRAI_LVL1_SYS_ID,
       CLMAP_PRAI_LVL1_DESC,
       CLMAP_COVER_CODE,
       (CASE WHEN  CE_EST_TYPE IN (1,3) THEN
            'P'
            WHEN  CE_EST_TYPE IN (2,4) THEN
            'R'
        END)PAYMENT_RECOVERY,
       CLMAP_LOSS_CODE,
       CS_SYS_ID,
       0 REV_NO,
       RCIH_ALLOC_IDX,
       CE_EST_CODE,
       CS_DT,
       CS_AMT_FC,
       CLM_PROD_CODE PROD_CODE
FROM PGIT_CLAIM,
     PGIT_CLM_APPL_POLICY,
     PGIT_CLM_EST,
     PGIT_CLM_SETL,
     PGIT_CLM_PAYMENT_DTL,
     PGITH_RI_CLM_INTERFACE
WHERE CLM_SYS_ID=CLMAP_CLM_SYS_ID
AND CLMAP_SYS_ID = CE_CLMAP_SYS_ID
AND CS_CE_SYS_ID = CE_SYS_ID
AND CS_SYS_ID = CPMTD_CS_SYS_ID
AND CLM_NO IN ('CL/DP/02/2009/21/00179-0090','CL/IFF/01/4011/20/00007-21/0145')
AND RCIH_CPMTD_SYS_ID=CPMTD_SYS_ID
)
ORDER BY CLM_SYS_ID,REC_TYPE,SYS_KEY,TRAN_REV_NO,RCIH_ALLOC_IDX
;

TYPE R_ALLOC_CLM_DTLS IS RECORD
(
  RPCA_KEY INTEGER,
  RPCA_TRANSACTION_REVISION   INTEGER,   --alloc idx

  RPCA_TYPE VARCHAR2(100), --ALLOC_TYPE         VARCHAR2(100),
  RPCA_CLAIM_KEY     INTEGER,
  RPCA_TRANSACTION_TYPE VARCHAR2(100),--TRAN_TYPE          VARCHAR2(100),
  RPCA_TRANSACTION_KEY INTEGER,--TRAN_KEY           INTEGER, 
  
  RPCA_TRANSACTION_DATE DATE,--TRAN_DT            DATE,
  RPCA_RISK_KEY  VARCHAR2(100), 

  RPCA_COVER_KEY VARCHAR2(100), --CVR_KEY             VARCHAR2(100),
  RPCA_SMI_KEY             VARCHAR2(100), --SMI_KEY   VARCHAR2(100),
  RPCA_LOSS_KEY            VARCHAR2(100), --LOSS_KEY  VARCHAR2(100),

  RPCA_RESERVE_TYPE VARCHAR2(100),--EST_TYPE           VARCHAR2(100),
  RPCA_LOSS_TYPE          VARCHAR2(100), --LOSS_TYPE   VARCHAR2(100),
  RPCA_LOSS_CURRENCY VARCHAR2(100),--LOSS_CURR          VARCHAR2(100),
  RPCA_LOSS_AMOUNT_CC        NUMBER, --LOSS_AMT_CC      NUMBER,
  RPCA_TREATY_KEY         NUMBER, --TREATY_KEY          NUMBER,
  RPCA_CURRENCY_KEY NUMBER,--CURR_KEY           NUMBER,
  RPCA_PRODUCT_KEY        VARCHAR2(100)--,--PRODUCT_KEY        VARCHAR2(100),

  --RISK_ID_REF VARCHAR2(200)
);

TYPE T_ALLOC_CLM_DTLS IS TABLE OF R_ALLOC_CLM_DTLS INDEX BY BINARY_INTEGER;

ALLOC_CLM_DTLS T_ALLOC_CLM_DTLS;

TYPE R_ALLOC_CLM_DTLS_TP_REF IS RECORD
(
  RPCATR_RPCA_KEY INTEGER,
  RPCATR_CLAIM_KEY_TP_REF     INTEGER, --CLM_KEY_TP_REF

  RPCATR_TRANSACTION_KEY_TP_REF    INTEGER, --TRAN_KEY_TP_REF    INTEGER,
  RPCATR_RISK_KEY_TP_REF    VARCHAR2(100), --RISK_KEY_TP_REF    VARCHAR2(100),
  RPCATR_COVER_KEY_TP_REF   VARCHAR2(100), --RPCATR_COVER_KEY_TP_REF   VARCHAR2(100),
  RPCATR_SMI_KEY_TP_REF     VARCHAR2(100), --SMI_KEY_TP_REF     VARCHAR2(100),
  RPCATR_LOSS_KEY_TP_REF    VARCHAR2(100), --RPCATR_LOSS_KEY_TP_REF    VARCHAR2(100),
  RPCATR_TREATY_KEY_TP_REF  NUMBER,   --TREATY_KEY_TP_REF  NUMBER,  
  RPCATR_PRODUCT_KEY_TP_REF VARCHAR2(100),--, --PRODUCT_KEY_TP_REF VARCHAR2(100),
  RPCATR_CURRENCY_KEY_TP_REF VARCHAR2(20)
  --RPCATR_RISK_ID_REF VARCHAR2(200)
);

TYPE T_ALLOC_CLM_DTLS_TP_REF IS TABLE OF R_ALLOC_CLM_DTLS_TP_REF INDEX BY BINARY_INTEGER;

ALLOC_CLM_DTLS_TP_REF T_ALLOC_CLM_DTLS_TP_REF;

TYPE T_CLM_RI IS TABLE OF C_CLM_RI%ROWTYPE;

L_CLM_RI T_CLM_RI;

M_RPCA_KEY_ID INTEGER :=0;

---------------------------Claim RI Layer---------------------------------
--RETN-RES
CURSOR C_CLM_RES_RETN_LYR(P_CLM_SYS_ID NUMBER, P_CE_SYS_ID NUMBER, P_CE_REV_NO NUMBER ) IS
SELECT
      RCIH_SYS_ID,
      RCIH_ALLOC_IDX,
      RCETAH_SYS_ID,
      RCETAH_RPT_SYS_ID,
      RCETAH_RPTL_SYS_ID,
      RCETAH_RPTA_SYS_ID,
      RCETAH_RPTT_TTY_TYPE_CODE,
      RCETAH_TTY_AMT_FC,
      RCETAH_TTY_AMT_LC_1
 FROM PGITH_RI_CLM_INTERFACE,
      PGITH_RI_CLM_EST_TTY_ALLOC X,
      PGITH_CLM_EST,
      PGIT_CLAIM
--WHERE CLM_NO IN ('CL/DP/02/2009/21/00179-0090','CL/IFF/01/4011/20/00007-21/0145')
WHERE RCIH_SYS_ID = RCETAH_RCI_SYS_ID
AND RCIH_CLM_SYS_ID = CLM_SYS_ID
AND CEH_SYS_ID = RCIH_CE_SYS_ID
--AND RCIH_CE_SYS_ID=502934
 AND RCETAH_ALLOC_IDX = RCIH_ALLOC_IDX
   AND NVL(RCETAH_REV_YN, '0') = '0'
   AND RCIH_CPMTD_SYS_ID IS NULL
   AND NVL(RCIH_CLM_AMT_LC_1, 0) <> 0
   AND CLM_SYS_ID=P_CLM_SYS_ID
   AND CEH_SYS_ID = P_CE_SYS_ID
   AND CEH_SR_NO = P_CE_REV_NO
   AND CEH_SR_NO = RCIH_ALLOC_IDX + 1
   AND RCETAH_RPTT_TTY_TYPE_CODE LIKE '%RETN%'
;

L_CLM_RES_RETN_LYR C_CLM_RES_RETN_LYR%ROWTYPE;

--QS
CURSOR C_CLM_RES_QS_LYR(P_CLM_SYS_ID NUMBER, P_CE_SYS_ID NUMBER, P_CE_REV_NO NUMBER ) IS
SELECT
      RCIH_SYS_ID,
      RCIH_ALLOC_IDX,
      RCETAH_SYS_ID,
      RCETAH_RPT_SYS_ID,
      RCETAH_RPTL_SYS_ID,
      RCETAH_RPTA_SYS_ID,
      RCETAH_RPTT_TTY_TYPE_CODE,
      RCETAH_TTY_AMT_FC,
      RCETAH_TTY_AMT_LC_1
 FROM PGITH_RI_CLM_INTERFACE,
      PGITH_RI_CLM_EST_TTY_ALLOC X,
      PGITH_CLM_EST,
      PGIT_CLAIM
--WHERE CLM_NO IN ('CL/DP/02/2009/21/00179-0090','CL/IFF/01/4011/20/00007-21/0145')
WHERE RCIH_SYS_ID = RCETAH_RCI_SYS_ID
AND RCIH_CLM_SYS_ID = CLM_SYS_ID
AND CEH_SYS_ID = RCIH_CE_SYS_ID
--AND RCIH_CE_SYS_ID=502934
 AND RCETAH_ALLOC_IDX = RCIH_ALLOC_IDX
   AND NVL(RCETAH_REV_YN, '0') = '0'
   AND RCIH_CPMTD_SYS_ID IS NULL
   AND NVL(RCIH_CLM_AMT_LC_1, 0) <> 0
   AND CLM_SYS_ID=P_CLM_SYS_ID
   AND CEH_SYS_ID = P_CE_SYS_ID
   AND CEH_SR_NO = P_CE_REV_NO
   AND CEH_SR_NO = RCIH_ALLOC_IDX + 1
   AND RCETAH_RPTT_TTY_TYPE_CODE LIKE '%QS%'
;

L_CLM_RES_QS_LYR C_CLM_RES_QS_LYR%ROWTYPE;

--OTH
CURSOR C_CLM_RES_OTH_LYR(P_CLM_SYS_ID NUMBER, P_CE_SYS_ID NUMBER, P_CE_REV_NO NUMBER ) IS
SELECT
      RCIH_SYS_ID,
      RCIH_ALLOC_IDX,
      RCETAH_SYS_ID,
      RCETAH_RPT_SYS_ID,
      RCETAH_RPTL_SYS_ID,
      RCETAH_RPTA_SYS_ID,
      RCETAH_RPTT_TTY_TYPE_CODE,
      RCETAH_TTY_AMT_FC,
      RCETAH_TTY_AMT_LC_1
 FROM PGITH_RI_CLM_INTERFACE,
      PGITH_RI_CLM_EST_TTY_ALLOC X,
      PGITH_CLM_EST,
      PGIT_CLAIM
--WHERE CLM_NO IN ('CL/DP/02/2009/21/00179-0090','CL/IFF/01/4011/20/00007-21/0145')
WHERE RCIH_SYS_ID = RCETAH_RCI_SYS_ID
AND RCIH_CLM_SYS_ID = CLM_SYS_ID
AND CEH_SYS_ID = RCIH_CE_SYS_ID
--AND RCIH_CE_SYS_ID=502934
 AND RCETAH_ALLOC_IDX = RCIH_ALLOC_IDX
   AND NVL(RCETAH_REV_YN, '0') = '0'
   AND RCIH_CPMTD_SYS_ID IS NULL
   AND NVL(RCIH_CLM_AMT_LC_1, 0) <> 0
   AND CLM_SYS_ID=P_CLM_SYS_ID
   AND CEH_SYS_ID = P_CE_SYS_ID
   AND CEH_SR_NO = P_CE_REV_NO
   AND CEH_SR_NO = RCIH_ALLOC_IDX + 1
   AND (RCETAH_RPTT_TTY_TYPE_CODE NOT LIKE '%RETN%' AND RCETAH_RPTT_TTY_TYPE_CODE NOT LIKE '%QS%')
;

TYPE T_CLM_RES_OTH_LYR IS TABLE OF C_CLM_RES_OTH_LYR%ROWTYPE;

L_CLM_RES_OTH_LYR T_CLM_RES_OTH_LYR;

L_CLM_RES_RI_LYR C_CLM_RES_QS_LYR%ROWTYPE;


--RETN-SETL
CURSOR C_CLM_SETL_RETN_LYR(P_CLM_SYS_ID NUMBER, P_CS_SYS_ID NUMBER) IS
SELECT
          RCIH_SYS_ID,
          RCIH_ALLOC_IDX,
          CPMTD_CS_SYS_ID,
          CS_DT,
          RCPTAH_SYS_ID,
          RCPTAH_RPT_SYS_ID,
          RCPTAH_RPTT_TTY_TYPE_CODE,
          RCPTAH_RPTL_SYS_ID,
          RCPTAH_RPTA_SYS_ID,
          RCPTAH_TTY_AMT_FC,
          RCPTAH_TTY_AMT_LC_1
FROM PGIT_CLAIM,
    PGIT_CLM_SETL,
    PGIT_CLM_PAYMENT_DTL,
    PGITH_RI_CLM_INTERFACE,
    PGITH_RI_CLM_PAY_TTY_ALLOC
WHERE CLM_SYS_ID=CS_CLM_SYS_ID--248235;
AND CS_SYS_ID = CPMTD_CS_SYS_ID
AND CPMTD_SYS_ID=RCPTAH_CPMTD_SYS_ID
AND RCIH_CPMTD_SYS_ID=CPMTD_SYS_ID
AND CLM_SYS_ID = P_CLM_SYS_ID
AND CS_SYS_ID  = P_CS_SYS_ID
AND RCIH_CPMTD_SYS_ID IS NOT NULL
AND RCPTAH_RPTT_TTY_TYPE_CODE LIKE '%RETN%'
;

L_CLM_SETL_RETN_LYR C_CLM_SETL_RETN_LYR%ROWTYPE;

--QS-SETL
CURSOR C_CLM_SETL_QS_LYR(P_CLM_SYS_ID NUMBER, P_CS_SYS_ID NUMBER) IS
SELECT
          RCIH_SYS_ID,
          RCIH_ALLOC_IDX,
          CPMTD_CS_SYS_ID,
          CS_DT,
          RCPTAH_SYS_ID,
          RCPTAH_RPT_SYS_ID,
          RCPTAH_RPTT_TTY_TYPE_CODE,
          RCPTAH_RPTL_SYS_ID,
          RCPTAH_RPTA_SYS_ID,
          RCPTAH_TTY_AMT_FC,
          RCPTAH_TTY_AMT_LC_1
FROM PGIT_CLAIM,
    PGIT_CLM_SETL,
    PGIT_CLM_PAYMENT_DTL,
    PGITH_RI_CLM_INTERFACE,
    PGITH_RI_CLM_PAY_TTY_ALLOC
WHERE CLM_SYS_ID=CS_CLM_SYS_ID--248235;
AND CS_SYS_ID = CPMTD_CS_SYS_ID
AND CPMTD_SYS_ID=RCPTAH_CPMTD_SYS_ID
AND RCIH_CPMTD_SYS_ID=CPMTD_SYS_ID
AND CLM_SYS_ID = P_CLM_SYS_ID
AND CS_SYS_ID  = P_CS_SYS_ID
AND RCIH_CPMTD_SYS_ID IS NOT NULL
AND RCPTAH_RPTT_TTY_TYPE_CODE LIKE '%QS%'
;

L_CLM_SETL_QS_LYR C_CLM_SETL_QS_LYR%ROWTYPE;
L_CLM_SETL_RI_LYR C_CLM_SETL_QS_LYR%ROWTYPE;

--OTH-SETL
CURSOR C_CLM_SETL_OTH_LYR(P_CLM_SYS_ID NUMBER, P_CS_SYS_ID NUMBER) IS
SELECT
          RCIH_SYS_ID,
          RCIH_ALLOC_IDX,
          CPMTD_CS_SYS_ID,
          CS_DT,
          RCPTAH_SYS_ID,
          RCPTAH_RPT_SYS_ID,
          RCPTAH_RPTT_TTY_TYPE_CODE,
          RCPTAH_RPTL_SYS_ID,
          RCPTAH_RPTA_SYS_ID,
          RCPTAH_TTY_AMT_FC,
          RCPTAH_TTY_AMT_LC_1
FROM PGIT_CLAIM,
    PGIT_CLM_SETL,
    PGIT_CLM_PAYMENT_DTL,
    PGITH_RI_CLM_INTERFACE,
    PGITH_RI_CLM_PAY_TTY_ALLOC
WHERE CLM_SYS_ID=CS_CLM_SYS_ID--248235;
AND CS_SYS_ID = CPMTD_CS_SYS_ID
AND CPMTD_SYS_ID=RCPTAH_CPMTD_SYS_ID
AND RCIH_CPMTD_SYS_ID=CPMTD_SYS_ID
AND CLM_SYS_ID = P_CLM_SYS_ID
AND CS_SYS_ID  = P_CS_SYS_ID
AND RCIH_CPMTD_SYS_ID IS NOT NULL
AND (RCPTAH_RPTT_TTY_TYPE_CODE NOT LIKE '%RETN%' AND RCPTAH_RPTT_TTY_TYPE_CODE NOT LIKE '%QS%')
;

TYPE T_CLM_SETL_OTH_LYR IS TABLE OF C_CLM_SETL_OTH_LYR%ROWTYPE;

L_CLM_SETL_OTH_LYR T_CLM_SETL_OTH_LYR;

TYPE R_ALLOC_CLM_LYR_DTLS IS RECORD
(
  RPCL_KEY INTEGER,
  RPCL_RPCA_KEY INTEGER,

  RPCL_ALLOCATION_GROUP VARCHAR2(100),--PRI_TXN_ALLOC_GRP  VARCHAR2(100),

  RPCL_LAYERKEY INTEGER,--TTY_LYR_KEY        INTEGER,

  RPCL_RETENTION_PERCENTAGE NUMBER,--TTY_RETN_PERC      NUMBER,
  RPCL_RETN_AMOUNT NUMBER,--TTY_RETN_LOSS_AMT_TC NUMBER,
  RPCL_RETN_AMOUNT_CC NUMBER,   --TTY_RETN_LOSS_AMT_CC NUMBER,

  RPCL_RI_PERCENTAGE NUMBER,--TTY_RI_PERC      NUMBER,
  RPCL_RI_AMOUNT NUMBER,--TTY_RI_LOSS_AMT_TC NUMBER,
  RPCL_RI_AMOUNT_CC NUMBER--TTY_RI_LOSS_AMT_CC NUMBER,
)
;

TYPE T_ALLOC_CLM_LYR_DTLS IS TABLE OF R_ALLOC_CLM_LYR_DTLS INDEX BY BINARY_INTEGER;

ALLOC_CLM_LYR_DTLS T_ALLOC_CLM_LYR_DTLS;

TYPE R_ALLOC_CLM_LYR_DTLS_TP_REF IS RECORD
(
  RPCLTR_RPCL_KEY INTEGER,

  RPCLTR_CLM_RI_HDR_KEY_TP_REF NUMBER,
  RPCLTR_CLM_ALLOC_KEY_TP_REF  NUMBER,
  RPCLTR_REV_NO_TP_REF            NUMBER,

  RPCLTR_RETN_LYR_KEY_TP_REF NUMBER,
  RPCLTR_RETN_LYR_ALLOC_KEY_TP_REF NUMBER,
  RPCLTR_RETN_LYR_TTY_TYPE_CODE_TP_REF VARCHAR2(100),
  RPCLTR_RETN_LYR_CLM_ALLOC_KEY_TP_REF NUMBER,

  RPCLTR_RI_LYR_KEY_TP_REF NUMBER,
  RPCLTR_RI_LYR_ALLOC_KEY_TP_REF NUMBER,
  RPCLTR_RI_LYR_TTY_TYPE_CODE_TP_REF VARCHAR2(100),
  RPCLTR_RI_LYR_CLM_ALLOC_KEY_TP_REF NUMBER
)
;

TYPE T_ALLOC_CLM_LYR_DTLS_TP_REF IS TABLE OF R_ALLOC_CLM_LYR_DTLS_TP_REF INDEX BY BINARY_INTEGER;
ALLOC_CLM_LYR_DTLS_TP_REF T_ALLOC_CLM_LYR_DTLS_TP_REF;

M_RPCL_KEY_ID INTEGER :=0;

M_RPT_SYS_ID NUMBER;

BEGIN

   OPEN C_CLM_RI;
   FETCH C_CLM_RI BULK COLLECT INTO L_CLM_RI;
   CLOSE C_CLM_RI;
   DEBUG_LOG('L_CLM_RI.COUNT',L_CLM_RI.COUNT);
   FOR ITR_HDR_IDX IN 1 .. L_CLM_RI.COUNT LOOP --L_CLM_RI

      --M_CLM_IDX := M_CLM_IDX + 1;
      
      SELECT SEQ_RPCL_KEY_ID.NEXTVAL INTO M_RPCA_KEY_ID FROM DUAL;
       
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_KEY                        := M_RPCA_KEY_ID ;
      
      --DEBUG_LOG('L_CLM_RI-DTLS',M_CLM_IDX,L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID,L_CLM_RI(ITR_HDR_IDX).REC_TYPE,L_CLM_RI(ITR_HDR_IDX).SYS_KEY,L_CLM_RI(ITR_HDR_IDX).TRAN_REV_NO,L_CLM_RI(ITR_HDR_IDX).LOSS_AMT);
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_TYPE                       := 'PROP';

      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_CLAIM_KEY                  := NVL(GET_FCUBE_TKEY('CLM_KEY',L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID),L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID);
      
      
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_TRANSACTION_TYPE           := L_CLM_RI(ITR_HDR_IDX).REC_TYPE;
      
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_TRANSACTION_KEY            := NVL( GET_FCUBE_TKEY('CLM_RES_SETL_KEY',L_CLM_RI(ITR_HDR_IDX).SYS_KEY,L_CLM_RI(ITR_HDR_IDX).REC_TYPE)
                                                                       ,L_CLM_RI(ITR_HDR_IDX).SYS_KEY                                                                   
                                                                      );
         

      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_TRANSACTION_REVISION   := L_CLM_RI(ITR_HDR_IDX).TRAN_REV_NO;
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_TRANSACTION_DATE       := L_CLM_RI(ITR_HDR_IDX).TRAN_DT;

      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_RISK_KEY                      := NVL(GET_FCUBE_TKEY('CLM_RISK_ID',L_CLM_RI(ITR_HDR_IDX).CLMAP_PRAI_LVL1_SYS_ID)
                                                                            ,L_CLM_RI(ITR_HDR_IDX).CLMAP_PRAI_LVL1_SYS_ID
                                                                          ); --L_CLM_RI(ITR_HDR_IDX).CLMAP_PRAI_LVL1_DESC;
      

      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_COVER_KEY                    := NVL(GET_FCUBE_KEY1('COVER_ID',L_CLM_RI(ITR_HDR_IDX).CLMAP_COVER_CODE)
                                                                ,L_CLM_RI(ITR_HDR_IDX).CLMAP_COVER_CODE                                                                
                                                                );  
      
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_SMI_KEY                                  := NULL;
      
      
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_LOSS_KEY                                := NVL(GET_FCUBE_KEY1('LOSS_ID',L_CLM_RI(ITR_HDR_IDX).LOSS_CODE)
                                                                    ,L_CLM_RI(ITR_HDR_IDX).LOSS_CODE);
      
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_RESERVE_TYPE                     := L_CLM_RI(ITR_HDR_IDX).PAYMENT_RECOVERY;
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_LOSS_TYPE                             := 'INDEMNITY-HC';

      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_LOSS_CURRENCY                    := '001';
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_LOSS_AMOUNT_CC                         := L_CLM_RI(ITR_HDR_IDX).LOSS_AMT;

      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_TREATY_KEY                          := NULL;
      
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_CURRENCY_KEY        := NULL;
      
      ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_PRODUCT_KEY        := NVL(GET_FCUBE_KEY1('PROD_CODE',L_CLM_RI(ITR_HDR_IDX).PROD_CODE)
                                                                  ,L_CLM_RI(ITR_HDR_IDX).PROD_CODE
                                                                  );
                                                                      
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_CLAIM_KEY_TP_REF  := L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID;                                                                   
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_TRANSACTION_KEY_TP_REF   := L_CLM_RI(ITR_HDR_IDX).SYS_KEY;
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_RISK_KEY_TP_REF    := L_CLM_RI(ITR_HDR_IDX).CLMAP_PRAI_LVL1_SYS_ID;
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_SMI_KEY_TP_REF                   := NULL;   
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_COVER_KEY_TP_REF    := L_CLM_RI(ITR_HDR_IDX).CLMAP_COVER_CODE;
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_LOSS_KEY_TP_REF                 := L_CLM_RI(ITR_HDR_IDX).LOSS_CODE;
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_TREATY_KEY_TP_REF            := NULL;      
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_CURRENCY_KEY_TP_REF      := NULL;
      ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_PRODUCT_KEY_TP_REF           := L_CLM_RI(ITR_HDR_IDX).PROD_CODE;      
          M_RPT_SYS_ID := NULL;                                                                 
     
       --Reserve Claim-RI
          IF L_CLM_RI(ITR_HDR_IDX).REC_TYPE ='R' THEN

             L_CLM_RES_RETN_LYR :=NULL;

             OPEN C_CLM_RES_RETN_LYR(L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID, L_CLM_RI(ITR_HDR_IDX).SYS_KEY, L_CLM_RI(ITR_HDR_IDX).TRAN_REV_NO);
             FETCH C_CLM_RES_RETN_LYR INTO L_CLM_RES_RETN_LYR;
             CLOSE C_CLM_RES_RETN_LYR;

             L_CLM_RES_QS_LYR :=NULL;

             OPEN C_CLM_RES_QS_LYR(L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID, L_CLM_RI(ITR_HDR_IDX).SYS_KEY, L_CLM_RI(ITR_HDR_IDX).TRAN_REV_NO);
             FETCH C_CLM_RES_QS_LYR INTO L_CLM_RES_QS_LYR;

                  IF C_CLM_RES_QS_LYR%FOUND THEN
                    L_CLM_RES_RI_LYR := L_CLM_RES_QS_LYR;
                  ELSE
                    L_CLM_RES_RI_LYR := L_CLM_RES_RETN_LYR;
                  END IF;
             CLOSE C_CLM_RES_QS_LYR;

                  --M_RPCL_KEY_ID := M_RPCL_KEY_ID + 1; -- RES QS/Retn-Only Layer Entry
                  
                  SELECT SEQ_RPCL_KEY_ID.NEXTVAL INTO M_RPCL_KEY_ID FROM DUAL;

                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_KEY                           := M_RPCL_KEY_ID;
                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RPCA_KEY                      := M_RPCA_KEY_ID;

                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).CLM_RI_HDR_KEY_TP_REF            := L_CLM_RES_RI_LYR.RCIH_SYS_ID; --REF
                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).REV_NO_TP_REF                    := L_CLM_RES_RI_LYR.RCIH_ALLOC_IDX; --REF

                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_ALLOCATION_GROUP         := NULL;
                  
                                                               M_RPT_SYS_ID       := L_CLM_RES_RI_LYR.RCETAH_RPT_SYS_ID;

                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_LAYERKEY :=  NVL(GET_FCUBE_KEY1('TREATY_LAYER_KEY',L_CLM_RES_RI_LYR.RCETAH_RPTL_SYS_ID)
                                                                                                  ,L_CLM_RES_RI_LYR.RCETAH_RPTL_SYS_ID                                                                           
                                                                                       );  
                                                                                                   
                                                                                                  
                  
                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_CURR                      := '001';

                    --RETN
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RETENTION_PERCENTAGE     := NULL;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RETN_AMOUNT           := L_CLM_RES_RETN_LYR.RCETAH_TTY_AMT_FC;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RETN_AMOUNT_CC           := L_CLM_RES_RETN_LYR.RCETAH_TTY_AMT_LC_1;

                    
                    --QS 
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_PERCENTAGE                    := NULL;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT                        := L_CLM_RES_QS_LYR.RCETAH_TTY_AMT_FC;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT_CC                     := L_CLM_RES_QS_LYR.RCETAH_TTY_AMT_LC_1;
                    
                    --REF
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RPCL_KEY                := M_RPCL_KEY_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_RI_HDR_KEY_TP_REF   := L_CLM_RES_RI_LYR.RCIH_SYS_ID;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_REV_NO_TP_REF           := L_CLM_RES_RI_LYR.RCIH_ALLOC_IDX;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_ALLOC_KEY_TP_REF    := L_CLM_RES_RI_LYR.RCETAH_SYS_ID ;
                    
                    --RETN REF                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_KEY_TP_REF             := L_CLM_RES_RETN_LYR.RCETAH_RPTL_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_ALLOC_KEY_TP_REF       := L_CLM_RES_RETN_LYR.RCETAH_RPTA_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_TTY_TYPE_CODE_TP_REF   := L_CLM_RES_RETN_LYR.RCETAH_RPTT_TTY_TYPE_CODE;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_CLM_ALLOC_KEY_TP_REF   := L_CLM_RES_RETN_LYR.RCETAH_SYS_ID;

                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_KEY_TP_REF               := L_CLM_RES_QS_LYR.RCETAH_RPTL_SYS_ID;                  
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_ALLOC_KEY_TP_REF         := L_CLM_RES_QS_LYR.RCETAH_RPTA_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_TTY_TYPE_CODE_TP_REF     := L_CLM_RES_QS_LYR.RCETAH_RPTT_TTY_TYPE_CODE;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_CLM_ALLOC_KEY_TP_REF     := L_CLM_RES_QS_LYR.RCETAH_SYS_ID;
                  
                   OPEN C_CLM_RES_OTH_LYR(L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID, L_CLM_RI(ITR_HDR_IDX).SYS_KEY, L_CLM_RI(ITR_HDR_IDX).TRAN_REV_NO);
                   FETCH C_CLM_RES_OTH_LYR BULK COLLECT INTO L_CLM_RES_OTH_LYR;
                   CLOSE C_CLM_RES_OTH_LYR;

                   DEBUG_LOG('L_CLM_RI-LYR_DTLS',M_RPCA_KEY_ID,M_RPCL_KEY_ID,L_CLM_RES_RI_LYR.RCIH_SYS_ID, L_CLM_RES_RI_LYR.RCIH_ALLOC_IDX,
                                                 L_CLM_RES_RI_LYR.RCETAH_RPTT_TTY_TYPE_CODE,L_CLM_RES_RI_LYR.RCETAH_SYS_ID,
                                                 L_CLM_RES_RETN_LYR.RCETAH_TTY_AMT_FC,
                                                 L_CLM_RES_QS_LYR.RCETAH_TTY_AMT_FC

                             );

                   FOR ITR_CLM_RI_IDX IN 1 .. L_CLM_RES_OTH_LYR.COUNT LOOP

                      --M_RPCL_KEY_ID := M_RPCL_KEY_ID + 1; ----RES OTH (Sur1, Sur2....)
                        SELECT SEQ_RPCL_KEY_ID.NEXTVAL INTO M_RPCL_KEY_ID FROM DUAL;

                      M_RPT_SYS_ID := NULL;

                      -----------------------------
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_KEY                         := M_RPCL_KEY_ID;
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RPCA_KEY                    := M_RPCA_KEY_ID;

                      --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).CLM_RI_HDR_KEY_REF            := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCIH_SYS_ID; --REF
                      --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).REV_NO_REF                    := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCIH_ALLOC_IDX; --REF

                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_ALLOCATION_GROUP              := NULL;

                                                                         M_RPT_SYS_ID := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPT_SYS_ID;

                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_LAYERKEY                    :=  NVL(GET_FCUBE_KEY1('TREATY_LAYER_KEY',
                                                                                                                 L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTL_SYS_ID
                                                                                                               )
                                                                                                 ,L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTL_SYS_ID                                                                           
                                                                                               );  
                                                                                                   
                      --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_KEY_TP_REF             := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPT_SYS_ID;
                      --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_LYR_KEY_TP_REF         := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTL_SYS_ID;
                      --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_CURR                   := '001';
                      -----------------------------

                     -- ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RI_LYR_KEY_TP_REF          := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTL_SYS_ID;
                     -- ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RI_LYR_ALLOC_KEY_TP_REF    := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTA_SYS_ID;
                     -- ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RI_LYR_TTY_TYPE_CODE       := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTT_TTY_TYPE_CODE;
                     -- ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RI_LYR_CLM_ALLOC_KEY_TP_REF := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_SYS_ID;
                      -----------------------------

                      --OTH (Sur1, Sur2....)
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_PERCENTAGE       := NULL;
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT           := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_TTY_AMT_FC;
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT_CC        := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_TTY_AMT_LC_1;

                    --REF
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RPCL_KEY                := M_RPCL_KEY_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_RI_HDR_KEY_TP_REF   := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCIH_SYS_ID;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_REV_NO_TP_REF           := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCIH_ALLOC_IDX;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_ALLOC_KEY_TP_REF    := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_SYS_ID ;
                    
                    --RETN REF Not required                   
                    
                    --RI REF
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_KEY_TP_REF               := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTL_SYS_ID;                  
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_ALLOC_KEY_TP_REF         := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTA_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_TTY_TYPE_CODE_TP_REF     := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_RPTT_TTY_TYPE_CODE;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_CLM_ALLOC_KEY_TP_REF     := L_CLM_RES_OTH_LYR(ITR_CLM_RI_IDX).RCETAH_SYS_ID;

                   END LOOP;

         END IF; --L_CLM_RI(ITR_HDR_IDX).REC_TYPE ='R'
         DEBUG_LOG('STEP-2');
          
         --Settlement Claim-RI
          IF L_CLM_RI(ITR_HDR_IDX).REC_TYPE ='S' THEN

             L_CLM_SETL_RETN_LYR := NULL;

             OPEN C_CLM_SETL_RETN_LYR(L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID, L_CLM_RI(ITR_HDR_IDX).SYS_KEY);
             FETCH C_CLM_SETL_RETN_LYR INTO L_CLM_SETL_RETN_LYR;
             CLOSE C_CLM_SETL_RETN_LYR;

             L_CLM_SETL_QS_LYR := NULL;

             OPEN C_CLM_SETL_QS_LYR(L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID, L_CLM_RI(ITR_HDR_IDX).SYS_KEY);
             FETCH C_CLM_SETL_QS_LYR INTO L_CLM_SETL_QS_LYR;


               IF C_CLM_SETL_QS_LYR%NOTFOUND THEN
                  L_CLM_SETL_RI_LYR := L_CLM_SETL_QS_LYR;
               ELSE
                  L_CLM_SETL_RI_LYR := L_CLM_SETL_RETN_LYR;
               END IF;

             CLOSE C_CLM_SETL_QS_LYR;
             
                  --M_RPCL_KEY_ID := M_RPCL_KEY_ID + 1; --SETL QS/Retn-Only Layer Entry

                  SELECT SEQ_RPCL_KEY_ID.NEXTVAL INTO M_RPCL_KEY_ID FROM DUAL;                  

                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_KEY                         := M_RPCL_KEY_ID;
                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RPCA_KEY                    := M_RPCA_KEY_ID;

                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).CLM_RI_HDR_KEY_REF            := L_CLM_SETL_RI_LYR.RCIH_SYS_ID; --REF
                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).REV_NO_REF                    := L_CLM_SETL_RI_LYR.RCIH_ALLOC_IDX; --REF

                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_ALLOCATION_GROUP              := NULL;
                                                                 M_RPT_SYS_ID       := L_CLM_SETL_RI_LYR.RCPTAH_RPT_SYS_ID;
                                                                                                   
                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_KEY                       := --L_CLM_SETL_RI_LYR.RCPTAH_RPT_SYS_ID;
                                                                              
                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_LYR_KEY                   := L_CLM_SETL_RI_LYR.RCPTAH_RPTL_SYS_ID;
                  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_LAYERKEY                     :=  NVL(GET_FCUBE_KEY1('TREATY_LAYER_KEY',L_CLM_SETL_RI_LYR.RCPTAH_RPTL_SYS_ID)
                                                                                                                            ,L_CLM_SETL_RI_LYR.RCPTAH_RPTL_SYS_ID
                                                                                       );  

                  --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_CURR                      := '001';

                  
                    --RETN
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RETENTION_PERCENTAGE     := NULL;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RETN_AMOUNT           := L_CLM_SETL_RETN_LYR.RCPTAH_TTY_AMT_FC;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RETN_AMOUNT_CC           := L_CLM_SETL_RETN_LYR.RCPTAH_TTY_AMT_LC_1;


                    
                    --QS
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_PERCENTAGE       := NULL;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT           := L_CLM_SETL_QS_LYR.RCPTAH_TTY_AMT_FC;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT_CC        := L_CLM_SETL_QS_LYR.RCPTAH_TTY_AMT_LC_1;

  
                    --REF
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RPCL_KEY                := M_RPCL_KEY_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_RI_HDR_KEY_TP_REF   := L_CLM_SETL_RI_LYR.RCIH_SYS_ID;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_REV_NO_TP_REF           := L_CLM_SETL_RI_LYR.RCIH_ALLOC_IDX;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_ALLOC_KEY_TP_REF    := L_CLM_SETL_RI_LYR.RCPTAH_SYS_ID ;
                    
                    --RETN REF                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_KEY_TP_REF             := L_CLM_SETL_RETN_LYR.RCPTAH_RPTL_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_ALLOC_KEY_TP_REF       := L_CLM_SETL_RETN_LYR.RCPTAH_RPTA_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_TTY_TYPE_CODE_TP_REF   := L_CLM_SETL_RETN_LYR.RCPTAH_RPTT_TTY_TYPE_CODE;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RETN_LYR_CLM_ALLOC_KEY_TP_REF   := L_CLM_SETL_RETN_LYR.RCPTAH_SYS_ID;

                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_KEY_TP_REF               := L_CLM_SETL_RI_LYR.RCPTAH_RPTL_SYS_ID;                  
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_ALLOC_KEY_TP_REF         := L_CLM_SETL_RI_LYR.RCPTAH_RPTA_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_TTY_TYPE_CODE_TP_REF     := L_CLM_SETL_RI_LYR.RCPTAH_RPTT_TTY_TYPE_CODE;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_CLM_ALLOC_KEY_TP_REF     := L_CLM_SETL_RI_LYR.RCPTAH_SYS_ID;
             
                   OPEN C_CLM_SETL_OTH_LYR(L_CLM_RI(ITR_HDR_IDX).CLM_SYS_ID, L_CLM_RI(ITR_HDR_IDX).SYS_KEY);
                   FETCH C_CLM_SETL_OTH_LYR BULK COLLECT INTO L_CLM_SETL_OTH_LYR;
                   CLOSE C_CLM_SETL_OTH_LYR;

                   M_RPT_SYS_ID := NULL;

                   FOR ITR_CLM_RI_IDX IN 1 .. L_CLM_SETL_OTH_LYR.COUNT LOOP

                      --M_RPCL_KEY_ID := M_RPCL_KEY_ID + 1; ----SETL OTH (Sur1, Sur2....)
                        
                      SELECT SEQ_RPCL_KEY_ID.NEXTVAL INTO M_RPCL_KEY_ID FROM DUAL;
                        
                      -----------------------------
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_KEY                         := M_RPCL_KEY_ID;
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RPCA_KEY                    := M_RPCA_KEY_ID;

                      --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).CLM_RI_HDR_KEY_REF            := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCIH_SYS_ID; --REF
                      --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).REV_NO_REF                    := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCIH_ALLOC_IDX; --REF

                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_ALLOCATION_GROUP           := NULL;
                                                                         M_RPT_SYS_ID   := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPT_SYS_ID;

                     --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_KEY                        := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPT_SYS_ID;                                                                                     
                                                                           
                    --ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_LYR_KEY                     := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPTL_SYS_ID;
                    ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_LAYERKEY                     := NVL(GET_FCUBE_KEY1('TREATY_LAYER_KEY',L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPTL_SYS_ID)
                                                                                                                               ,L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPTL_SYS_ID
                                                                                             );  
                                                                                       
                    --  ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).TTY_CURR                      := '001';
                      -----------------------------

                      --OTH (Sur1, Sur2....)
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_PERCENTAGE                  := NULL;
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT           := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_TTY_AMT_FC;
                      ALLOC_CLM_LYR_DTLS(M_RPCL_KEY_ID).RPCL_RI_AMOUNT_CC           := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_TTY_AMT_LC_1;
  
                    --REF
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RPCL_KEY                := M_RPCL_KEY_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_RI_HDR_KEY_TP_REF   := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCIH_SYS_ID;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_REV_NO_TP_REF           := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCIH_ALLOC_IDX;                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_CLM_ALLOC_KEY_TP_REF    := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_SYS_ID ;
                    
                    --RETN REF  Not applicable                
                    
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_KEY_TP_REF               := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPTL_SYS_ID;                  
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_ALLOC_KEY_TP_REF         := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPTA_SYS_ID;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_TTY_TYPE_CODE_TP_REF     := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_RPTT_TTY_TYPE_CODE;
                    ALLOC_CLM_LYR_DTLS_TP_REF(M_RPCL_KEY_ID).RPCLTR_RI_LYR_CLM_ALLOC_KEY_TP_REF     := L_CLM_SETL_OTH_LYR(ITR_CLM_RI_IDX).RCPTAH_SYS_ID;
             
                   END LOOP;
                   
                    ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_TREATY_KEY                               :=  NVL(GET_FCUBE_KEY1('TREATY_KEY',M_RPT_SYS_ID)
                                                                                                              ,M_RPT_SYS_ID
                                                                                                   );
                                                                                                   
                    ALLOC_CLM_DTLS(M_RPCA_KEY_ID).RPCA_CURRENCY_KEY                              := '001';
                    --REF
                    ALLOC_CLM_DTLS_TP_REF(M_RPCA_KEY_ID).RPCATR_TREATY_KEY_TP_REF                := M_RPT_SYS_ID;

         END IF; --L_CLM_RI(ITR_HDR_IDX).REC_TYPE ='S'
   DEBUG_LOG('END');
  END LOOP; --L_CLM_RI
END;
/
