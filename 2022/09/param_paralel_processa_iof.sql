INSERT 
  INTO CECRED.tbgen_batch_param (IDPARAMETRO
                                ,QTPARALELO
                                ,QTREG_TRANSACAO
                                ,CDCOOPER
                                ,CDPROGRAMA)
                         VALUES ((SELECT MAX(idparametro) + 1 FROM tbgen_batch_param)
                                ,30
                                ,0
                                ,1
                                ,'PROCESSA_IOF');                                
INSERT 
  INTO crapprm (NMSISTEM,
                CDCOOPER,
                CDACESSO,
                DSTEXPRM,
                DSVLRPRM)   
         VALUES('CRED'
               ,0
               ,'EXEC_IOF_001'
               ,'Flag de execuçao do IOF/juros cheque especial no CRPS001 no primeiro dia util do mês'
               ,'S');                                
COMMIT;
