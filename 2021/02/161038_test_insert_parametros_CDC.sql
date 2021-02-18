delete crapprm
where CDACESSO = 'REGRA_MOTOR_IBRA_CDC_PF'
/
delete crapprm
where CDACESSO = 'REGRA_MOTOR_IBRA_CDC_PJ'
/

INSERT INTO crapprm ( NMSISTEM
                     ,CDCOOPER
                     ,CDACESSO
                     ,DSTEXPRM
                     ,DSVLRPRM
                     ,PROGRESS_RECID
                    )
             values ( 'CRED'
                     ,0
                     ,'REGRA_MOTOR_IBRA_CDC_PF'
                     ,'Nome da politica de credito para CDC PF a ser executada no Motor de Credito IBRATAN'
                     ,'PoliticaCDCCooperadoPF'
                     ,NULL
                    );

INSERT INTO crapprm ( NMSISTEM
                     ,CDCOOPER
                     ,CDACESSO
                     ,DSTEXPRM
                     ,DSVLRPRM
                     ,PROGRESS_RECID
                    )
             values ( 'CRED'
                     ,0
                     ,'REGRA_MOTOR_IBRA_CDC_PJ'
                     ,'Nome da politica de credito para CDC PJ a ser executada no Motor de Credito IBRATAN'
                     ,'PoliticaCDCCooperadoPJ'
                     ,NULL
                    );
