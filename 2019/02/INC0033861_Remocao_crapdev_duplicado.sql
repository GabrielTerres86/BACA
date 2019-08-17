begin
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2264295;
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2264296;
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2264426;
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2264427;

	delete FROM crapsol WHERE crapsol.cdcooper = 1  AND
                               crapsol.dtrefere = '26/02/2019' AND
                               crapsol.nrsolici = 78
	commit;
end;