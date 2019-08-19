begin
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2293587;
	delete crapdev where crapdev.cdcooper = 1 and progress_recid = 2293588;

	commit;
end;