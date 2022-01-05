begin

begin

/* Atualizar o parâmetro para "S" */

update crapprm
set dsvlrprm = 'S'
WHERE cdcooper = 8
AND nmsistem = 'CRED'
AND cdacesso = 'FL_EXECUTADO_674';

end;

begin

/* Atualizar o parâmetro contador da quantidade de execuções do dia */

UPDATE	crapprm p
SET	p.DSVLRPRM	= '22/10/2021#0'
WHERE	p.CDACESSO	IN
	('CTRL_CRPS674_EXEC')
AND	p.cdcooper	= 8;

end;

commit;

end;