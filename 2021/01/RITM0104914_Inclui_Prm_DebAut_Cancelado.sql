-- RITM0104914 - Incluir par�metro do e-mail para d�bitos autom�ticos cancelados.
insert into crapprm
  (nmsistem,
   cdcooper,
   cdacesso,
   dstexprm,
   dsvlrprm)
values
  ('CRED',
   0,
   'EMAIL_CANC_DEBBAN',
   'Email destinatario para cancelamento debitos automatico pendentes',
   'convenios@ailos.coop.br,sustentacao@ailos.coop.br');
commit;
