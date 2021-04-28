BEGIN
  INSERT INTO cecred.crapprm p
    (nmsistem
    ,cdcooper
    ,cdacesso
    ,dstexprm
    ,dsvlrprm)
  VALUES
    ('CRED'
    ,0
    ,'EMAIL_ERRO_IMP_CB093'
    ,'E-mail destinatario erros na importacao do arquivo CB093'
    ,'heloiza.silva@ailos.coop.br,odirlei.busana@ailos.coop.br,ligia.pickler@ailos.coop.br,rene.santos@ailos.coop.br,juliana@ailos.coop.br,rafael.macagnani@ailos.coop.br');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100, 'Erro na criação de parametro - ' || SQLERRM);
END;
