begin

UPDATE	crapprm p
SET	p.DSVLRPRM	= '15/12/2021#1'
WHERE	p.CDACESSO	IN
	('CTRL_CRPS663_EXEC',
	'CTRL_CRPS688_EXEC',
	'CTRL_DEBBAN_EXEC',
	'CTRL_DEBNET_EXEC',
	'CTRL_DEBNET_PRIORI_EXEC',
	'CTRL_DEBSIC_EXEC',
	'CTRL_DEBSIC_PRIORI_EXEC',
	'CTRL_DEBUNITAR_EXEC',
	'CTRL_JOBAGERCEL_EXEC',
	'CTRL_CRPS674_EXEC',
    'CTRL_CRPS724_EXEC',
    'CTRL_CRPS750_EXEC'
    )
AND	p.cdcooper	= 10;

update crapepr
set CDORIGEM = 4
where nrctremp = 36199
and nrdconta = 210153
and cdcooper = 10;

exception
  when others then
    rollback;

commit;

end;