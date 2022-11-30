begin
	delete cecred.tbcc_limite_preposto 
	where cdcooper = 1 and nrdconta = 7211481 and nrcpf = 88711730900;
	commit;
end;