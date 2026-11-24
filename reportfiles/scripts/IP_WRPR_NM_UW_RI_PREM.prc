CREATE OR REPLACE PROCEDURE IP_WRPR_NM_UW_RI_PREM
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
/* Interface procedure  for JOB NM UW RI Premium Report*/

BEGIN
             JP_WRPR_NM_UW_RI_PREM
              (
                                      P_REP_KEY_NO  =>   P_REP_KEY_NO,
                                      P_REPORT_ID   =>   P_REPORT_ID ,
                                      P_USER_ID     =>   P_USER_ID  ,
                                      P_DIVN_FM     =>   P_DIVN_FM  ,
                                      P_DIVN_TO     =>   P_DIVN_TO  ,
                                      P_DEPT_FM     =>   P_DEPT_FM  ,
                                      P_DEPT_TO     =>   P_DEPT_TO  ,
                                      P_CLASS_FM    =>   P_CLASS_FM ,
                                      P_CLASS_TO    =>   P_CLASS_TO ,
                                      P_PROD_FM     =>   P_PROD_FM  ,
                                      P_PROD_TO     =>   P_PROD_TO  ,
                                      P_SRC_FM      =>   P_SRC_FM   ,
                                      P_SRC_TO      =>   P_SRC_TO  ,
                                      P_CUST_FM     =>   P_CUST_FM  ,
                                      P_CUST_TO     =>   P_CUST_TO  ,
                                      P_INSUR_FM    =>   P_INSUR_FM ,
                                      P_INSUR_TO    =>   P_INSUR_TO ,
                                      P_MKTR_FM     =>   P_MKTR_FM  ,
                                      P_MKTR_TO     =>   P_MKTR_TO  ,
                                      P_POLICY_FM   =>   P_POLICY_FM ,
                                      P_POLICY_TO   =>   P_POLICY_TO ,
                                      P_UW_FM       =>   P_UW_FM     ,
                                      P_UW_TO       =>   P_UW_TO ,
                                      P_BUS_CODE_FM =>   P_BUS_CODE_FM ,
                                      P_BUS_CODE_TO =>   P_BUS_CODE_TO ,
                                      P_FM_DT       =>   P_FM_DT       ,
                                      P_TO_DT       =>   P_TO_DT       ,
                                      P_EVAL_DT     =>   P_EVAL_DT     
                );

END;
