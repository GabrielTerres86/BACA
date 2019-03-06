begin
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2275314;
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2275315;
	
	commit;
end;