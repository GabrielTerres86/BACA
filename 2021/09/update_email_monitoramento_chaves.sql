declare
begin 
  
UPDATE crapprm
   SET dsvlrprm = 'zuleica.arnese@auditeste.com.br'
WHERE cdacesso = 'MONIT_EMAIL_CHAVES';
commit;
end;
/