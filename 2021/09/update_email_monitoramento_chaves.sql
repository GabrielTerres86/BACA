declare
begin 
  
UPDATE cecred.crapprm
   SET dsvlrprm = 'monitoracaodefraudes@ailos.coop.br'
WHERE cdacesso = 'MONIT_EMAIL_CHAVES';
commit;
end;
/