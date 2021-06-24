declare
begin 
	
update crapprm
set dsvlrprm = 'monitoracaodefraudes@ailos.coop.br'
where cdacesso = 'MONIT_EMAIL_CHAVES';

commit;
end;
/