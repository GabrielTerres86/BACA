BEGIN
  INSERT INTO CECRED.crapprm(NMSISTEM
                            ,CDCOOPER
                            ,CDACESSO
                            ,DSTEXPRM
                            ,DSVLRPRM)
                      VALUES('CRED'
                            ,0
                            ,'QT_DIAS_HISTOR_LGM_LGI'
                            ,'Quantidade de dias que os históricos da CRAPLGM e CRAPLGI são mantidos'
                            ,7);

  COMMIT;
END;
