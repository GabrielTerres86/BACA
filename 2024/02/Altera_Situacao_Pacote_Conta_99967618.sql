BEGIN
	update cecred.tbtarif_contas_pacote pct set pct.flgsituacao = 0 where pct.cdcooper = 9 and pct.nrdconta = 99967618;
	COMMIT;
END;