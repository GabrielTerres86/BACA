declare
begin 
	
insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
values ('CRED', 0, 'MONIT_EMAIL_CHAVES', 'Email de destino dos monitoramentos.', 'monitoracaodefraudes@ailos.coop.br');

commit;
end;
/