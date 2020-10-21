BEGIN
  -- PRM para email de notificacao de recargas com erro 
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCELL_EMAIL_NOTI', 'E-mail de notificacao de tentativas de recarga', 'simone.ribeiro@ailos.coop.br');

  COMMIT;
END;




