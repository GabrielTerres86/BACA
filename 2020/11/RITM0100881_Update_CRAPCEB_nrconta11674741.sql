update crapceb  set inenvcob  = 2 where cdcooper = 1 and nrdconta = 11674741 and nrconven = 101002;
commit;

insert into crapprm (cdcooper, NMSISTEM, CDACESSO, DSTEXPRM, DSVLRPRM) values ('1', 'CRED', 	'FTP_CONVENIO_11674741'	,'Contas que podem usar FTP pelo convenio internet ( 1-Ativo / 0-Inativo )'	,'1');
COMMIT ;
