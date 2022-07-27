begin
	delete tbcc_limite_preposto 
	where (nrdconta = 9945032  and nrcpf = 3952238902 and cdcooper = 1) 
	   or (nrdconta = 14750732 and nrcpf = 3436697907 and cdcooper = 1) 
	   or (nrdconta = 14751151 and nrcpf = 3436697907 and cdcooper = 1) 
	   or (nrdconta = 14751224 and nrcpf = 3436697907 and cdcooper = 1);
	
	commit;
end;