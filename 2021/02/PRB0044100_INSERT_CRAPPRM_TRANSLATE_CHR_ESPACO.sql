DECLARE
  CURSOR cr_crapprm IS(
    SELECT *
      FROM crapprm
     WHERE nmsistem = 'CRED'
       AND cdcooper = 0
       AND cdacesso = 'TRANSLATE_CHR_ESPACO');
  rw_crapprm cr_crapprm%ROWTYPE;
BEGIN
  dbms_output.put_line('SCRIPT "PRB0044100_INSERT_CRAPPRM_TRANSLATE_CHR_ESPACO" INICIADO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));

  OPEN cr_crapprm;
  FETCH cr_crapprm INTO rw_crapprm;
  CLOSE cr_crapprm;
  
  IF (rw_crapprm.progress_recid IS NULL) THEN
    INSERT INTO crapprm p
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      ('CRED'
      ,0
      ,'TRANSLATE_CHR_ESPACO'
      ,'Caractere que devem ser substituído do CHR correspondente no parametro por espaco em branco'
      ,'96;180;35;36;38;37;185;178;179;170;186;176;42;33;63;60;62;47;92;124;160');
  
    COMMIT;
  END IF;

  dbms_output.put_line('SCRIPT "PRB0044100_INSERT_CRAPPRM_TRANSLATE_CHR_ESPACO" FINALIZADO COM SUCESSO EM ' ||
                       to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss'));
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('ERRO NAO TRATADO NA EXECUCAO DO SCRIPT "PRB0044100_INSERT_CRAPPRM_TRANSLATE_CHR_ESPACO" EXCECAO: ' ||
                         substr(SQLERRM, 1, 255));
    ROLLBACK;
    raise_application_error(-20002,
                            'ERRO NAO TRATADO NA EXECUCAO DO SCRIPT. EXCECAO: ' ||
                            substr(SQLERRM, 1, 255));
END;
