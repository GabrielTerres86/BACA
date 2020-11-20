BEGIN
  BEGIN
    insert into CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
    values
      ('CRED',
       3,
       'ENV_AILOS_NOW_CANAIS',
       'Habilitar o envio de solicita��o de autoriza��o por meio dos canais para a Modalidade Ailos Now Personalizado (0 = N�o Envia / 1 = Envia)',
       '0',
       NULL);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro = '||SQLERRM);
  END;
END;
