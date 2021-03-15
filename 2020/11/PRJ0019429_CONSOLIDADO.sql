BEGIN
  BEGIN
    insert into CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
    values
      ('CRED',
       3,
       'ENV_AILOS_NOW_CANAIS',
       'Habilitar o envio de solicitação de autorização por meio dos canais para a Modalidade Ailos Now Personalizado (0 = Não Envia / 1 = Envia)',
       '0',
       NULL);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro = '||SQLERRM);
  END;
  
  BEGIN
    UPDATE tbgen_versao_termo t
       SET t.dtinicio_vigencia = to_date('26/01/2021', 'DD/MM/RRRR')
     WHERE t.dschave_versao = 'TERMO ADESAO CDC PF V2';
     
     COMMIT;
  END;  
END;
