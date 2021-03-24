declare
begin

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
values ('CRED', 0, 'ROOT_MICROS_QBRSIG', 'Diretório raiz dos Micros para a QBRSIG', '/usr/sistemas/', null);

commit;

exception
	when others then
		null;
end;
/