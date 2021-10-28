DECLARE
  CURSOR cr_crapcop IS
  SELECT *
    FROM CECRED.CRAPCOP
   WHERE CDCOOPER <> 3
     AND FLGATIVO = 1; 
BEGIN
  FOR rw_crapcop in cr_crapcop LOOP
    INSERT INTO CECRED.CRAPPRM (NMSISTEM,
                                CDCOOPER,
                                CDACESSO,
                                DSTEXPRM,
                                DSVLRPRM) VALUES
                               ('CRED'
                               ,rw_crapcop.cdcooper
                               ,'OPENIVEL_LIB_CDSITDCT_9'
                               ,'Nível Supervisor do operador, com permissão para alterar status da conta para situação 9 ou retirá-la dessa situação.'
                               ,'2,3');
  END LOOP;
  
  COMMIT;                             
  
EXCEPTION
  WHEN others THEN
    RAISE_APPLICATION_ERROR(-20501, 'Erro: ' || SQLERRM);
END;
