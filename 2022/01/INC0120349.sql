begin

begin

	/* Conta: 6661599 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 6661599
	and	nrctrcrd	= 2523184;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 0
	where	cdcooper	= 1
	and	nrdconta	= 6661599
	and	nrconta_cartao	= 7563239874236;

	update	crapcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 6661599
	and	nrctrcrd	= 2523184;

end;

begin

	/* Conta: 8921318 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 8921318
	and	nrctrcrd	= 2534146;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 0
	where	cdcooper	= 1
	and	nrdconta	= 8921318
	and	nrconta_cartao	= 7563239274269;

	update	crapcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 8921318
	and	nrctrcrd	= 2534146;

end;

begin

	/* Conta: 13985400 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11,
		cdlimcrd	= 2
	where	cdcooper	= 1
	and	nrdconta	= 13985400
	and	nrctrcrd	= 2519390;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 200
	where	cdcooper	= 1
	and	nrdconta	= 13985400
	and	nrconta_cartao	= 7563239873144;

	update	crapcrd
	set	cdadmcrd	= 11,
		cdlimcrd	= 2
	where	cdcooper	= 1
	and	nrdconta	= 13985400
	and	nrctrcrd	= 2519390;

end;

begin

	/* Conta: 755699 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 755699
	and	nrctrcrd	= 2517260;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 0
	where	cdcooper	= 1
	and	nrdconta	= 755699
	and	nrconta_cartao	= 7563239112418;

	update	crapcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 755699
	and	nrctrcrd	= 2517260;

end;

begin

	/* Conta: 3568644 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 3568644
	and	nrctrcrd	= 2524738;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 0
	where	cdcooper	= 1
	and	nrdconta	= 3568644
	and	nrconta_cartao	= 7563239092928;

	update	crapcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 3568644
	and	nrctrcrd	= 2524738;

end;

begin

	/* Conta: 6989543 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11,
		cdlimcrd	= 6
	where	cdcooper	= 1
	and	nrdconta	= 6989543
	and	nrctrcrd	= 2526781;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 600
	where	cdcooper	= 1
	and	nrdconta	= 6989543
	and	nrconta_cartao	= 7563239198033;

	update	crapcrd
	set	cdadmcrd	= 11,
		cdlimcrd	= 6
	where	cdcooper	= 1
	and	nrdconta	= 6989543
	and	nrctrcrd	= 2526781;

end;

begin

	/* Conta: 14022605 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11,
		cdlimcrd	= 5
	where	cdcooper	= 1
	and	nrdconta	= 14022605
	and	nrctrcrd	= 2527131;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 500
	where	cdcooper	= 1
	and	nrdconta	= 14022605
	and	nrconta_cartao	= 7563239876030;

	update	crapcrd
	set	cdadmcrd	= 11,
		cdlimcrd	= 5
	where	cdcooper	= 1
	and	nrdconta	= 14022605
	and	nrctrcrd	= 2527131;

end;

begin

	/* Conta: 431311 - Credcrea */

	update	crawcrd
	set	nrcrcard	= 5474080241995776,
		insitcrd	= 3,
		nrcctitg	= 7564416030108,
		cdlimcrd	= 5,			-- (feito select na tabela craptlc)
		dtrejeit	= null,
		dtlibera	= trunc(SYSDATE),
		dtentreg	= null,
		vllimcrd	= 500,			-- (obtido no Sipagnet)
		nrdoccrd	= '0              '	-- nrdoccrd (arquivo posição 230, tamanho 15)
	where	cdcooper	= 7
	and	nrdconta	= 431311
	and	nrctrcrd	= 131888;

	insert	into tbcrd_conta_cartao
		(cdcooper,
		nrdconta,
		nrconta_cartao,
		vllimite_global,
		cdadmcrd)
	values	(7,
		431311,
		7564416030108,
		500,
		15);

	insert	into crapcrd
		(cdcooper,
		nrdconta,
		nrcrcard,
		nrcpftit,
		nmtitcrd,
		dddebito,
		cdlimcrd,
		dtvalida,
		nrctrcrd,
		cdmotivo,
		nrprotoc,
		cdadmcrd,
		tpcartao,
		dtcancel,
		flgdebit,
		flgprovi)
	values	(7,					-- cdcooper
		431311,					-- nrdconta
		5474080241995776,			-- nrcrcard
		7974935901,				-- nrcpftit
		'DEJANDIR OLIVEIRA',			-- nmtitcrd
		19,					-- dddebito
		5,					-- cdlimcrd
		NULL,					-- dtvalida (data de validade -- valor padrão null)
		131888,					-- nrctrcrd
		0,					-- cdmotivo (valor padrão 0)
		0,					-- nrprotoc (valor padrão 0)
		15,					-- cdadmcrd
		2,					-- tpcartao
		NULL,					-- dtcancel
		0,					-- flgdebit
		0					-- flgprovi (só será 1 quando o nome no cartã é "CARTAO PROVISORIO")
		);

end;

begin

	/* Conta: 7414900 - Viacredi */

	update	crawcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 7414900
	and	nrctrcrd	= 2538534;

	update	tbcrd_conta_cartao
	set	cdadmcrd	= 11,
		vllimite_global	= 0
	where	cdcooper	= 1
	and	nrdconta	= 7414900
	and	nrconta_cartao	= 7563239167514;

	update	crapcrd
	set	cdadmcrd	= 11
	where	cdcooper	= 1
	and	nrdconta	= 7414900
	and	nrctrcrd	= 2538534;

end;

commit;

end;