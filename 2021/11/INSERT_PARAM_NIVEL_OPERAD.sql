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
                               ,'N�vel Supervisor do operador, com permiss�o para alterar status da conta para situa��o 9 ou retir�-la dessa situa��o.'
                               ,'2,3');
  END LOOP;
  
  COMMIT;                             
  
EXCEPTION
  WHEN others THEN
    RAISE_APPLICATION_ERROR(-20501, 'Erro: ' || SQLERRM);
END;
