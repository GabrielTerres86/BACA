BEGIN
	insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
	values ('CRED', 'TCARGA', 'TCARGA', ' ', ' ', ' ', 50, (select max(b.nrordprg) + 1 from crapprg b where b.cdcooper = 3 and b.nrsolici = 50), 1, 0, 0, 0, 0, 0, 1, 3, null);

	COMMIT;
	
EXCEPTION
	WHEN OTHERS THEN
	NULL;
END;