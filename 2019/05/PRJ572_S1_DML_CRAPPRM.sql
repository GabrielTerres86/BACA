DECLARE
  --
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
  ORDER BY cop.cdcooper;
  --
  vr_exc_erro EXCEPTION;
  vr_dscritic VARCHAR2(10000);
  --
BEGIN
  --
  FOR rw_crapcop IN cr_crapcop LOOP
    --
    BEGIN
      --
      INSERT INTO crapprm(nmsistem
                         ,cdcooper
                         ,cdacesso
                         ,dstexprm
                         ,dsvlrprm
                         ) 
                   VALUES('CRED'
                         ,rw_crapcop.cdcooper
                         ,'IMPORTACAO_CB093'
                         ,'Parametros de controle para importacao do arquivo CB093'
                         ,'01/01/1900;0;0'
                         );
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := SQLERRM;
        RAISE vr_exc_erro;
    END;
    --
  END LOOP;
  --
  COMMIT;
  --
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_output.put_line('Erro: ' || vr_dscritic);
END;
