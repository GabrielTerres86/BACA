BEGIN
  BEGIN
    insert into CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
    values
      ('CRED',
       3,
       'SLC_GRAVA_LOG_TRANSACAO',
       'Habilitar a grava��o de logs das transacoes de cartoes, recebidos pelo SILOC(0 = N�o Gravar / 1 = Gravar)',
       '0',
       NULL);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro = '||SQLERRM);
  END;
END;
