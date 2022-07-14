INSERT INTO CECRED.TBGEN_BATCH_PARAM (IDPARAMETRO,
                               QTPARALELO,
                               QTREG_TRANSACAO,
                               CDCOOPER,
                               CDPROGRAMA)
                        VALUES((SELECT MAX(IDPARAMETRO)+1 FROM CECRED.TBGEN_BATCH_PARAM)
                              ,20
                              ,0
                              ,1
                              ,'CRPS685'); 
                              
COMMIT;                              
