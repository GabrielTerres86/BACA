begin
	delete crapdev where crapdev.cdcooper = 13 and progress_recid = 2275252;
	delete crapdev where crapdev.cdcooper = 13 and progress_recid = 2275253;

	DELETE FROM crapsol WHERE crapsol.cdcooper = 13  AND
                               crapsol.dtrefere = '06/03/2019' AND
                               crapsol.nrsolici = 78;
	commit;
end;