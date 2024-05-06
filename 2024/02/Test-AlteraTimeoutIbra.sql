begin

update	cecred.crapprm
set	dsvlrprm = 90
where	nmsistem = 'CRED'
and	cdacesso = 'TIMEOUT_CONEXAO_IBRA';

commit;

end;