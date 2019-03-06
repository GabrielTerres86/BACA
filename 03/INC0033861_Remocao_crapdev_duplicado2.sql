begin
	delete crapdev where crapdev.cdcooper = 13 and progress_recid = 2275252;
	delete crapdev where crapdev.cdcooper = 13 and progress_recid = 2275253;

	commit;
end;