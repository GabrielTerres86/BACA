begin
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2281134;
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2281135;
    delete FROM crapsol WHERE crapsol.cdcooper = 1  AND
                               crapsol.dtrefere = '07/03/2019' AND
                               crapsol.nrsolici = 78;
							   
	commit;
end;