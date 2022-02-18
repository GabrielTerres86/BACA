BEGIN
	update tbrisco_operacoes
	   set flintegrar_sas = 1
	 where (cdcooper, nrdconta) in ((14, 188859), (1, 10338470))
	   and tpctrato = 11;

	commit;
END;
