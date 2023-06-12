BEGIN
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'FLG_ENVIAR_ARQ_COB605', '1=Ativo (envia o arquivo) / 0=Inativo (não envia o arquivo)','1'); 

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
    ROLLBACK;
END;
  
