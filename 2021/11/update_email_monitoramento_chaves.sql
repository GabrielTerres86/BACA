declare
begin  
UPDATE cecred.crapprm
   SET dsvlrprm = 'monitoracaodefraudes@ailos.coop.br'
WHERE cdacesso = 'MONIT_EMAIL_CHAVES';

UPDATE cecred.crapprm
   SET dsvlrprm = '91'
WHERE cdacesso = 'PERC_ALTO_MONIT';
commit;
end;
/