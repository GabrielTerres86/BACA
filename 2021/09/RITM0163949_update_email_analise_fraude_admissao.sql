declare
begin 
  
UPDATE crapprm
   SET dsvlrprm = 'zuleica.arnese@auditeste.com.br'
WHERE cdacesso = 'EMAIL_RISCOFRAUDE_ADM';

commit;
end;
/