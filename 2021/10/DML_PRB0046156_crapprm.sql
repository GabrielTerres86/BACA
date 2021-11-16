BEGIN

  INSERT INTO crapprm
    (NMSISTEM
    ,CDCOOPER
    ,CDACESSO
    ,DSTEXPRM
    ,DSVLRPRM)
  VALUES
    ('CRED'
    ,0
    ,'EMAIL_SQUAD_RECUPERACAO'
    ,'E-mails da squad de recuperacao de credito, para uso de alertas'
    ,'heloiza.silva@ailos.coop.br,odirlei.busana@ailos.coop.br,ligia.pickler@ailos.coop.br,karine.kupas@ailos.coop.br,rodrigo.heiden@ailos.coop.br,giovane.gibbert@ailos.coop.br');
    
    COMMIT;

EXCEPTION
  WHEN dup_val_on_index THEN
    NULL;
  WHEN OTHERS THEN
    raise_application_error(-20500, 'Erro ao gravar prm: ' || SQLERRM);
END;
