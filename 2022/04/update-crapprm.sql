declare
begin  
UPDATE cecred.crapprm
   SET dsvlrprm = 'zuleica.arnese@auditeste.com.br'
WHERE cdacesso = 'MONIT_EMAIL_FRAUDE_INT';
commit;
end;
/