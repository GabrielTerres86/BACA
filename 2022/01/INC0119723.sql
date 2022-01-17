begin

	/* Conta: 495557 */

	update	crawcrd
	set	nrcrcard	= 5474080236567473,
		insitcrd	= 3,
		nrcctitg	= 7564438071854,
		cdlimcrd	= 60,			-- (feito select na tabela craptlc)
		dtrejeit	= null,
		dtlibera	= trunc(SYSDATE),
		dtentreg	= null,
		vllimcrd	= 30000,		-- (obtido no Sipagnet)
		nrdoccrd	= '5255500        '	-- nrdoccrd (arquivo posição 230, tamanho 15)
	where	cdcooper	= 11
	and	nrdconta	= 495557
	and	nrctrcrd	= 172368;

	insert	into tbcrd_conta_cartao
		(cdcooper,
		nrdconta,
		nrconta_cartao,
		vllimite_global,
		cdadmcrd)
	values	(11,
		495557,
		7564438071854,
		30000,
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
	values	(11,					-- cdcooper
		495557,					-- nrdconta
		5474080236567473,			-- nrcrcard
		5156225918,				-- nrcpftit
		'STEPHANIE LARA PANDINI',		-- nmtitcrd
		11,					-- dddebito
		60,					-- cdlimcrd
		NULL,					-- dtvalida (data de validade -- valor padrão null)
		172368,					-- nrctrcrd
		0,					-- cdmotivo (valor padrão 0)
		0,					-- nrprotoc (valor padrão 0)
		15,					-- cdadmcrd
		2,					-- tpcartao
		NULL,					-- dtcancel
		0,					-- flgdebit
		0					-- flgprovi (só será 1 quando o nome no cartã é "CARTAO PROVISORIO")
		);

	/* Conta: 13488228 */

	delete	from crawcrd a
	where	a.nrdconta	= 13488228
	and	a.cdcooper	= 1
	and	a.nrctrcrd	= 2396571;

	delete	from crawcrd a
	where	a.nrdconta	= 13488228
	and	a.cdcooper	= 1
	and	a.nrctrcrd	= 2459459;

	delete	from crawcrd a
	where	a.nrdconta	= 13488228
	and	a.cdcooper	= 1
	and	a.nrctrcrd	= 2469105;

	delete	from crawcrd a
	where	a.nrdconta	= 13488228
	and	a.cdcooper	= 1
	and	a.nrctrcrd	= 2496890;

	commit;

end;