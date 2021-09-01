BEGIN
  INSERT INTO CECRED.crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'TAXA_MAX_LIM_CHQ_ESP'
    ,'Taxa m�xima para linhas de limite de cr�dito (cheque especial) PF e PJ'
    ,8);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
