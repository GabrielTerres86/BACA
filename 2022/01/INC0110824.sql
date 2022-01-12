BEGIN
	-- update da tabela CRAPHCB
	update CRAPHCB set
		   cdhistor = 1617
	where cdtrnbcb in (324,427);

	update CRAPHCB set
		   cdhistor = 1611
	where cdtrnbcb in (428);


	-- update da tabela tbcrd_his_vinculo_bancoob
	update tbcrd_his_vinculo_bancoob set
		   cdhistor = 1617
	where cdtrnbcb in (324,427);

	update tbcrd_his_vinculo_bancoob set
		   cdhistor = 1611
	where cdtrnbcb in (428);
	commit;
END;