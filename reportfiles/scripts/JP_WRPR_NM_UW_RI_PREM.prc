CREATE OR REPLACE PROCEDURE JP_WRPR_NM_UW_RI_PREM
                            (
                                    P_REP_KEY_NO  NUMBER,
                                    P_REPORT_ID   VARCHAR2,
                                    P_USER_ID     VARCHAR2,

                                    P_DIVN_FM     VARCHAR2,       P_DIVN_TO  VARCHAR2,    
                                    P_DEPT_FM     VARCHAR2,       P_DEPT_TO  VARCHAR2,
                                    P_CLASS_FM    VARCHAR2,      P_CLASS_TO  VARCHAR2,
                                    P_PROD_FM     VARCHAR2,       P_PROD_TO  VARCHAR2,
                                    P_SRC_FM      VARCHAR2,        P_SRC_TO  VARCHAR2,                                    
                                    P_CUST_FM     VARCHAR2,       P_CUST_TO  VARCHAR2,
                                    P_INSUR_FM    VARCHAR2,      P_INSUR_TO  VARCHAR2,
                                    P_MKTR_FM     VARCHAR2,      P_MKTR_TO   VARCHAR2,
                                    P_POLICY_FM   VARCHAR2,       P_POLICY_TO VARCHAR2, 
                                    P_UW_FM       NUMBER,           P_UW_TO NUMBER,
                                    P_BUS_CODE_FM VARCHAR2,   P_BUS_CODE_TO VARCHAR2,
                                    P_FM_DT       VARCHAR2,         P_TO_DT VARCHAR2,
                                    P_EVAL_DT     VARCHAR2
                                    ) 
AS
/* JOB creation for NM UW RI Premium Report*/
V_JOB_ACTION      VARCHAR2(4000);
V_JOB_NAME        VARCHAR2(200);


FUNCTION Q(P_VAL VARCHAR2) RETURN VARCHAR2 IS
BEGIN
          IF P_VAL IS NULL THEN    
                   RETURN 'NULL';            
          ELSE
                   RETURN ''''||REPLACE(P_VAL,'''', '''''')||'''';
          END IF;         
END Q;

BEGIN
              /*V_JOB_NAME       := P_REP_KEY_NO||'_'||
                                  P_REPORT_ID||'_'||
                                  P_USER_ID||'_'||
                                  TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISS')
                                  ;
              */                    

              V_JOB_NAME       := P_REPORT_ID/*||'_'||
                                  TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISS')*/
                                  ;

              V_JOB_ACTION     := 'BEGIN WRPR_NM_UW_RI_PREM('||
              
                                               'P_DIVN_FM=>'||       Q(P_DIVN_FM)    ||','||
                                               'P_DIVN_TO=>'||       Q(P_DIVN_TO)    ||','||
                                               'P_DEPT_FM=>'||       Q(P_DEPT_FM)    ||','||
                                               'P_DEPT_TO=>'||       Q(P_DEPT_TO)    ||','||
                                               'P_CLASS_FM=>'||      Q(P_CLASS_FM)   ||','||
                                               'P_CLASS_TO=>'||      Q(P_CLASS_TO)   ||','||
                                               'P_PROD_FM=>'||       Q(P_PROD_FM)    ||','||
                                               'P_PROD_TO=>'||       Q(P_PROD_TO)    ||','||
                                               'P_SRC_FM=>'||        Q(P_SRC_FM)     ||','||
                                               'P_SRC_TO=>'||        Q(P_SRC_TO)     ||','||
                                               'P_CUST_FM=>'||       Q(P_CUST_FM)    ||','||
                                               'P_CUST_TO=>'||       Q(P_CUST_TO)    ||','||
                                               'P_INSUR_FM=>'||     Q(P_INSUR_FM)   ||','||
                                               'P_INSUR_TO=>'||     Q(P_INSUR_TO)   ||','||
                                               'P_MKTR_FM=>'||      Q(P_MKTR_FM)    ||','||
                                               'P_MKTR_TO=>'||      Q(P_MKTR_TO)    ||','||
                                               'P_POLICY_FM=>'||    Q(P_POLICY_FM)  ||','||
                                               'P_POLICY_TO=>'||    Q(P_POLICY_TO)  ||','||
                                               'P_UW_FM=>'||       Q(P_UW_FM)      ||','||
                                               'P_UW_TO=>'||       Q(P_UW_TO)      ||','||
                                               'P_BUS_CODE_FM=>'|| Q(P_BUS_CODE_FM)||','||
                                               'P_BUS_CODE_TO=>'|| Q(P_BUS_CODE_TO)||','||
                                               'P_FM_DT=>'||       Q(P_FM_DT)      ||','||
                                               'P_TO_DT=>'||       Q(P_TO_DT)      ||','||
                                               'P_EVAL_DT=>'||     Q(P_EVAL_DT)  ||','||

                                               'P_REP_KEY_NO=>'||  Q(P_REP_KEY_NO)||','||
                                               'P_REPORT_ID=>'||   Q(P_REPORT_ID) ||','||
                                               'P_USER_ID=>'||     Q(P_USER_ID)
                                 ||');END;'                            
                                  ;                                                           

DBMS_SCHEDULER.CREATE_JOB(
                           JOB_NAME   => V_JOB_NAME,
                           JOB_TYPE   => 'PLSQL_BLOCK',
                           JOB_ACTION => V_JOB_ACTION,
                           START_DATE => SYSTIMESTAMP,
                           ENABLED    => TRUE,
                           AUTO_DROP  => FALSE,
                           COMMENTS   => 'NM UW RI Premium for the period '||P_FM_DT||' '||P_TO_DT
                         );       

--DBMS_SCHEDULER.RUN_JOB(V_JOB_NAME);

END;
/
