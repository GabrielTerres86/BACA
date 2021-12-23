begin
  insert into cecred.crapprm
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values
    ('CRED', 0, 'CONTAB_EMAIL_CONTAB', 'Contabilidade - Destinatario de e-mail geral da contabilidade', 'contabilidade01@ailos.coop.br');
  
  commit;
end;
