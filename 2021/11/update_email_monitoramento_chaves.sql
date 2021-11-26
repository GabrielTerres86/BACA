declare
begin  
UPDATE cecred.crapprm
   SET dsvlrprm = 'maria.pamplona@ailos.coop.br'
WHERE cdacesso = 'MONIT_EMAIL_CHAVES';

UPDATE cecred.crapprm
   SET dsvlrprm = '55'
WHERE cdacesso = 'PERC_ALTO_MONIT';
commit;
end;
/