BEGIN

declare

	vr_nrctrcrd	crawcrd.nrctrcrd%TYPE;
	vr_nrseqcrd	crawcrd.nrseqcrd%TYPE;

begin

/* Conta: 754609 */

begin

	vr_nrctrcrd	:= fn_sequence('CRAPMAT','NRCTRCRD', 2);
	vr_nrseqcrd	:= CCRD0003.fn_sequence_nrseqcrd(2);

	insert	into crawcrd
		(nrdconta,
		nrcrcard,
		nrcctitg,
		nrcpftit,
		vllimcrd,
		flgctitg,
		dtmvtolt,
		nmextttl,
		flgprcrd,
		tpdpagto,
		flgdebcc,
		tpenvcrd,
		vlsalari,
		dddebito,
		cdlimcrd,
		tpcartao,
		dtnasccr,
		nrdoccrd,
		nmtitcrd,
		nrctrcrd,
		cdadmcrd,
		cdcooper,
		nrseqcrd,
		dtpropos,
		dtsolici,
		flgdebit,
		cdgraupr,
		insitcrd,
		dtlibera,
		insitdec)
	values	(754609,				-- nrdconta
		5127070394595037,			-- nrcrcard
		7563265026676,				-- nrcctitg
		43928064991,				-- nrcpftit
		4200,					-- vllimcrd (obtido no Sipagnet)
		3,					-- flgctitg
		trunc(sysdate),				-- dtmvtolt
		'ROSA MARIA REINERT',			-- nmextttl
		0,					-- flgprcrd (primeiro cartão da adm para a conta)
		1,					-- tpdpagto (forma de pagamento da fatura)
		1,					-- flgdebcc (débito em conta corrente)
		1,					-- tpenvcrd (forma de envio do cartão)
		0,					-- vlsalari (valor salário)
		11,					-- dddebito (dia do débito)
		70,					-- cdlimcrd (feito select na tabela craptlc)
		2,					-- tpcartao (tipo de cartão)
		to_date('10/04/1937','dd/mm/yyyy'),	-- dtnasccr (obtido no Sipagnet)
		'1263392        ',			-- nrdoccrd (arquivo posição 230, tamanho 15)
		'ROSA MARIA REINERT',			-- nmtitcrd
		vr_nrctrcrd,				-- nrctrcrd
		12,					-- cdadmcrd (obtido da tbcrd_conta_cartao porque registro já existe, mas pode ser obtido grupo afinidade no arquivo posição 42, tamanho 7, dados da conta cartão e feito select na function cartao.crd_grupo_afinidade_bin.consultarADMGrpAfin(cooperativa, grupo afinidade) */
		2,					-- cdcooper
		vr_nrseqcrd,				-- nrseqcrd
		to_date('08/11/2021','dd/mm/rrrr'),	-- dtpropos
		to_date('23/11/2021','dd/mm/rrrr'),	-- dtsolici
		1,					-- flgdebit (habilita função débito)
		6,					-- cdgraupr (grau de parentesco entre os titulares)
		3,					-- insitcrd
		trunc(sysdate),				-- dtlibera
		2					-- insitdec (indicar de decisão sobre a análise do crédito do cartão)
		);

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
	values	(2,					-- cdcooper
		754609,					-- nrdconta
		5127070394595037,			-- nrcrcard
		43928064991,				-- nrcpftit
		'ROSA MARIA REINERT',			-- nmtitcrd
		11,					-- dddebito
		70,					-- cdlimcrd
		NULL,					-- dtvalida (data de validade -- valor padrão null)
		vr_nrctrcrd,				-- nrctrcrd
		0,					-- cdmotivo (valor padrão 0)
		0,					-- nrprotoc (valor padrão 0)
		12,					-- cdadmcrd
		2,					-- tpcartao
		NULL,					-- dtcancel
		1,					-- flgdebit
		0					-- flgprovi (só será 1 quando o nome no cartã é "CARTAO PROVISORIO")
		);

end;

commit;

end;

END;