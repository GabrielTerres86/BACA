begin
  insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'EMAIL_CANC_DEBSIC', 'Email destinatario para cancelamento debitos automatico pendentes', 'convenios@ailos.coop.br,sustentacao@ailos.coop.br');

  commit;
end;