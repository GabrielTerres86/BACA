begin
	insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) values
	('CRED',0,'CRD_MONITORAMENTO','Email da area de negocio produto cartoes','cartoes@ailos.coop.br,gionei.correia@ailos.coop.br');
	insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) values
	('CRED',0,'DAUT_MONITORAMENTO','Monitoramento Arquivos DAUT e DAUR. 1 Ativo 0 Inativo','1');
	insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) values
	('CRED',0,'CEXT_MONITORAMENTO','Monitoramento Arquivos CEXT. 1 Ativo 0 Inativo','1');
	insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) values
	('CRED',0,'CCB_MONITORAMENTO','Monitoramento Arquivos CEXT. 1 Ativo 0 Inativo','1');
    commit;
end;