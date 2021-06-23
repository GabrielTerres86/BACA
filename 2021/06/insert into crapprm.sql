declare
begin 
	
insert into crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm) 
values ('CRED', 0, 'MONIT_EMAIL_CHAVES', 'Email de destino dos monitoramentos.', 'coaf@ailos.coop.br');

commit;
end;
/