BEGIN
  FOR rw_cooper IN (SELECT cdcooper FROM CECRED.crapcop WHERE flgativo = 1) LOOP
    INSERT INTO CECRED.CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
       rw_cooper.cdcooper,
       'EXEC_IOF_001',
       'Flag de execu�ao do IOF/juros cheque especial no CRPS001 no primeiro dia util do m�s',
       '25/10/2022');
  END LOOP;
  
  INSERT INTO CECRED.tbgen_batch_param (idparametro, qtparalelo, qtreg_transacao, cdcooper, cdprograma) VALUES(104,20,0,1,'CRPS001');
  
  COMMIT;
END;
