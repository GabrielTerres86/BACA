DECLARE
  CURSOR cr_crapprm IS(
    SELECT *
      FROM crapprm
     WHERE nmsistem = 'CRED'
       AND cdcooper = 0
       AND cdacesso = 'SHELL_PROGRESS');
  rw_crapprm cr_crapprm%ROWTYPE;
BEGIN
  dbms_output.put_line('SCRIPT INICIADO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

  OPEN cr_crapprm;
  FETCH cr_crapprm
    INTO rw_crapprm;
  IF (cr_crapprm%NOTFOUND) THEN
  
    INSERT INTO crapprm
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      ('CRED'
      ,0
      ,'SHELL_PROGRESS'
      ,'Script Shell para executar progress'
      ,'sh /usr/local/cecred/bin/ExecutarProgress.sh');
  
    COMMIT;
  END IF;

  CLOSE cr_crapprm;

  dbms_output.put_line('SCRIPT FINALIZADO COM SUCESSO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('ERRO NAO TRATADO NA EXECUCAO DO SCRIPT EXCECAO: ' ||
                         substr(SQLERRM, 1, 255));
    ROLLBACK;
    raise_application_error(-20002,
                            'ERRO NAO TRATADO NA EXECUCAO DO SCRIPT. EXCECAO: ' ||
                            substr(SQLERRM, 1, 255));
END;
