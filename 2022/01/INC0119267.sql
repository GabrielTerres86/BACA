BEGIN

declare

	vr_nrctrcrd	crawcrd.nrctrcrd%TYPE;
	vr_nrseqcrd	crawcrd.nrseqcrd%TYPE;

begin

/* Conta: 9008 */

begin

	vr_nrctrcrd	:= fn_sequence('CRAPMAT','NRCTRCRD', 7);
	vr_nrseqcrd	:= CCRD0003.fn_sequence_nrseqcrd(7);

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
	values	(9008,					-- nrdconta
		5474080239979832,			-- nrcrcard
		7564416003141,				-- nrcctitg
		48285277968,				-- nrcpftit
		28000,					-- vllimcrd (obtido no Sipagnet)
		3,					-- flgctitg
		trunc(sysdate),				-- dtmvtolt
		'ARIVAN SAMPAIO ZANLUCA',		-- nmextttl
		0,					-- flgprcrd (primeiro cartão da adm para a conta)
		3,					-- tpdpagto (forma de pagamento da fatura)
		0,					-- flgdebcc (débito em conta corrente)
		0,					-- tpenvcrd (forma de envio do cartão)
		0,					-- vlsalari (valor salário)
		11,					-- dddebito (dia do débito)
		127,					-- cdlimcrd (feito select na tabela craptlc)
		2,					-- tpcartao (tipo de cartão)
		to_date('01/02/1963','dd/mm/yyyy'),	-- dtnasccr (obtido no Sipagnet)
		'373501         ',			-- nrdoccrd (arquivo posição 230, tamanho 15)
		'ARIVAN SAMPAIO ZANLUCA',		-- nmtitcrd
		vr_nrctrcrd,				-- nrctrcrd
		15,					-- cdadmcrd (obtido da tbcrd_conta_cartao porque registro já existe, mas pode ser obtido grupo afinidade no arquivo posição 42, tamanho 7, dados da conta cartão e feito select na function cartao.crd_grupo_afinidade_bin.consultarADMGrpAfin(cooperativa, grupo afinidade) */
		7,					-- cdcooper
		vr_nrseqcrd,				-- nrseqcrd
		to_date('10/12/2021','dd/mm/rrrr'),	-- dtpropos
		to_date('03/01/2022','dd/mm/rrrr'),	-- dtsolici
		0,					-- flgdebit (habilita função débito)
		0,					-- cdgraupr (grau de parentesco entre os titulares)
		3,					-- insitcrd
		trunc(sysdate),				-- dtlibera
		1					-- insitdec (indicar de decisão sobre a análise do crédito do cartão)
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
	values	(7,					-- cdcooper
		9008,					-- nrdconta
		5474080239979832,			-- nrcrcard
		48285277968,				-- nrcpftit
		'ARIVAN SAMPAIO ZANLUCA',		-- nmtitcrd
		11,					-- dddebito
		127,					-- cdlimcrd
		NULL,					-- dtvalida (data de validade -- valor padrão null)
		vr_nrctrcrd,				-- nrctrcrd
		0,					-- cdmotivo (valor padrão 0)
		0,					-- nrprotoc (valor padrão 0)
		15,					-- cdadmcrd
		2,					-- tpcartao
		NULL,					-- dtcancel
		0,					-- flgdebit
		0					-- flgprovi (só será 1 quando o nome no cartã é "CARTAO PROVISORIO")
		);

end;

/* Conta: 52647 */

begin

	vr_nrctrcrd	:= fn_sequence('CRAPMAT','NRCTRCRD', 14);
	vr_nrseqcrd	:= CCRD0003.fn_sequence_nrseqcrd(14);

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
	values	(52647,					-- nrdconta
		5474080237825680,			-- nrcrcard
		7564468003185,				-- nrcctitg
		33528560959,				-- nrcpftit
		20000,					-- vllimcrd (obtido no Sipagnet)
		3,					-- flgctitg
		trunc(sysdate),				-- dtmvtolt
		'ARLINDO R DOS SANTOS',			-- nmextttl
		1,					-- flgprcrd (primeiro cartão da adm para a conta)
		3,					-- tpdpagto (forma de pagamento da fatura)
		0,					-- flgdebcc (débito em conta corrente)
		1,					-- tpenvcrd (forma de envio do cartão)
		0,					-- vlsalari (valor salário)
		11,					-- dddebito (dia do débito)
		54,					-- cdlimcrd (feito select na tabela craptlc)
		2,					-- tpcartao (tipo de cartão)
		to_date('09/01/1940','dd/mm/yyyy'),	-- dtnasccr (obtido no Sipagnet)
		'34402787       ',			-- nrdoccrd (arquivo posição 230, tamanho 15)
		'ARLINDO R DOS SANTOS',			-- nmtitcrd
		vr_nrctrcrd,				-- nrctrcrd
		15,					-- cdadmcrd (obtido da tbcrd_conta_cartao porque registro já existe, mas pode ser obtido grupo afinidade no arquivo posição 42, tamanho 7, dados da conta cartão e feito select na function cartao.crd_grupo_afinidade_bin.consultarADMGrpAfin(cooperativa, grupo afinidade) */
		14,					-- cdcooper
		vr_nrseqcrd,				-- nrseqcrd
		to_date('22/11/2021','dd/mm/rrrr'),	-- dtpropos
		to_date('13/12/2021','dd/mm/rrrr'),	-- dtsolici
		1,					-- flgdebit (habilita função débito)
		0,					-- cdgraupr (grau de parentesco entre os titulares)
		3,					-- insitcrd
		trunc(sysdate),				-- dtlibera
		1					-- insitdec (indicar de decisão sobre a análise do crédito do cartão)
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
	values	(14,					-- cdcooper
		52647,					-- nrdconta
		5474080237825680,			-- nrcrcard
		33528560959,				-- nrcpftit
		'ARLINDO R DOS SANTOS',			-- nmtitcrd
		11,					-- dddebito
		54,					-- cdlimcrd
		NULL,					-- dtvalida (data de validade -- valor padrão null)
		vr_nrctrcrd,				-- nrctrcrd
		0,					-- cdmotivo (valor padrão 0)
		0,					-- nrprotoc (valor padrão 0)
		15,					-- cdadmcrd
		2,					-- tpcartao
		NULL,					-- dtcancel
		1,					-- flgdebit
		0					-- flgprovi (só será 1 quando o nome no cartã é "CARTAO PROVISORIO")
		);

end;

commit;

end;

END;