begin

declare

ds_exc_erro_v		exception;
ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);

cd_cooperativa_v	cecred.crapcop.cdcooper%type	:= 3;
ds_nome_arquivo_bkp_v	varchar2(100);
ds_nome_diretorio_v	cecred.crapprm.dsvlrprm%type;
ds_critica_v		cecred.crapcri.dscritic%type;

qt_registro	number(10)	:= 0;
nr_arquivo	number(10)	:= 1;
qt_reg_arquivo	number(10)	:= 50000;

vr_dscritic	VARCHAR2(1000);

vr_proxutil	date;
ds_rowidlct	rowid;

cursor	c01 is
select	b.rowid as id_linha,
	b.dtfimvig,
	b.dtcancel,
	b.cdsitseg,
	b.cdopeexc,
	b.cdageexc,
	b.dtinsexc,
	b.cdopecnl,
	c.rowid as nr_linha_tbseg,
	c.nrproposta,
	c.tpregist,
	c.tprecusa,
	c.cdmotrec,
	c.dtrecusa,
	c.situacao,
	c.tpcustei,
	c.cdcooper,
	c.nrdconta
from	cecred.crapcop d,
	cecred.tbseg_prestamista c,
	cecred.crapseg b
where	c.cdcooper	= d.cdcooper
and	b.tpseguro	= 4
and	b.cdsitseg	<> 5
and	c.cdcooper	= b.cdcooper
and	c.nrdconta	= b.nrdconta
and	c.nrctrseg	= b.nrctrseg
and	c.nrproposta	in
	('770356190556',
'770354655160',
'770658485261',
'770658266098',
'770657861545',
'770658217429',
'770658217410',
'770350580921',
'770355513742',
'770657427500',
'770658418319',
'770658418335',
'770658418343',
'770658418351',
'770657966762',
'770658367480',
'770658367498',
'770658367501',
'770657460419',
'770658640313',
'770658640321',
'770658640330',
'770658640348',
'770613120670',
'770613120688',
'770613120696',
'770613120661',
'770658244418',
'770658582178',
'770658582186',
'770658582208',
'770658582216',
'770658582143',
'770658276620',
'770658116770',
'770657677205',
'770658164163',
'770658164171',
'770658164180',
'770657945552',
'770356127803',
'770356127811',
'770356127790',
'770658641794',
'770658641808',
'770658641816',
'770658641824',
'770658641832',
'770658641840',
'770658225154',
'770658376497',
'770658376500',
'770658376519',
'770658164295',
'770658443526',
'770658443518',
'770354621118',
'770657461695',
'770351475510',
'770351397276',
'770351475528',
'770351393840',
'770657971480',
'770657971499',
'770658146750',
'770658163671',
'770658099582',
'770657462683',
'770658222813',
'770352707503',
'770658163787',
'770657933562',
'770658217780',
'770658050486',
'770658220195',
'770657647764',
'770658217747',
'770657265934',
'770613219137',
'770658217321',
'770355139611',
'770658217178',
'770658104900',
'770658194607',
'770657480240',
'770657651753',
'770658429787',
'770657335231',
'770658429680',
'770658217240',
'770356688414',
'770355573249',
'770658501984',
'770657949698',
'770657319678',
'770356054580',
'770658140329',
'770657297585',
'770658221396',
'770351318880',
'770658164481',
'770658500031',
'770657314480',
'770355347826',
'770355347834',
'770355347842',
'770355347850',
'770657862991',
'770657771031',
'770658117246',
'770657593605',
'770657892939',
'770357281350',
'770357229367',
'770658447599',
'770658586572',
'770613524720',
'770658370561',
'770573392760',
'770658609483',
'770658141023',
'770354788101',
'770354788110',
'770573136039',
'770658257536',
'770658257544',
'770658257552',
'770658257560',
'770658257579',
'770657966487',
'770658459562',
'770657947687',
'770657947695',
'770658164724',
'770658164732',
'770658164740',
'770658607294',
'770658164767',
'770658164775',
'770658253220',
'770657493953',
'770658417800',
'770658417819',
'770658164899',
'770658165291',
'770658224298',
'770657998915',
'770657998923',
'770658146440',
'770657515426',
'770658165402',
'770657265411',
'770657874779',
'770658193872',
'770658193902',
'770658193910',
'770658193929',
'770658242636',
'770658242644',
'770657947725',
'770657465275',
'770657895067',
'770658146416',
'770658588060',
'770658588079',
'770658588087',
'770658588095',
'770658588109',
'770658147498',
'770658522418',
'770658165836',
'770658165860',
'770657780235',
'770657970549',
'770657970557',
'770657970565',
'770657970573',
'770658145738',
'770658145746',
'770658218484',
'770657585289',
'770357977800',
'770356984510',
'770357168295',
'770658220020',
'770658505270',
'770658165992',
'770356558782',
'770657337501',
'770658550306',
'770658166085',
'770658166093',
'770658140515',
'770658246542',
'770658246550',
'770658246569',
'770658246577',
'770355956938',
'770355956946',
'770355956954',
'770355956962',
'770355956970',
'770658441213',
'770359853084',
'770658147633',
'770658147641',
'770658147650',
'770357679222',
'770613673873',
'770658819305',
'770658819313',
'770658819321',
'770658819330',
'770658124102',
'770613680993',
'770658524682',
'770658140191',
'770657494224',
'770356473981',
'770356473990',
'770356474015',
'770356276884',
'770657971820',
'770658416472',
'770355942694',
'770355942708',
'770355942716',
'770352269573',
'770657932531',
'770657932558',
'770657932566',
'770657932574',
'770657932582',
'770658166638',
'770658538322',
'770658166689',
'770658166697',
'770658166700',
'770658166719',
'770658166727',
'770657971278',
'770657295280',
'770657295299',
'770658162268',
'770354898896',
'770354899167',
'770355379310',
'770658463802',
'770658166964',
'770658166972',
'770657339148',
'770657295620',
'770658137735',
'770658256025',
'770658256033',
'770658256041',
'770657988243',
'770657988251',
'770657988260',
'770657933678',
'770657933635',
'770356301005',
'770356301013',
'770658162705',
'770658446371',
'770658123629',
'770658126610',
'770658527916',
'770658126393',
'770658141538',
'770658444999',
'770658445006',
'770658445014',
'770657287040',
'770658444794',
'770658104233',
'770658104241',
'770658104250',
'770658104268',
'770658104195',
'770658499580',
'770657981290',
'770573442865',
'770573442873',
'770573442881',
'770573442890',
'770573442903',
'770573442911',
'770657514934',
'770358655750',
'770658586068',
'770657983470',
'770657459534',
'770359975821',
'770658120859',
'770657570044',
'770657389560',
'770657389595',
'770658273582',
'770658446649',
'770658526731',
'770657988871',
'770657988880',
'770657988898',
'770658276727',
'770658276735',
'770658276743',
'770658500937',
'770657962929',
'770657962937',
'770657962945',
'770658147129',
'770657989266',
'770658161628',
'770355314391',
'770355314405',
'770355314413',
'770657226378',
'770357569583',
'770357569591',
'770357569605',
'770357569613',
'770357569621',
'770658163086',
'770356951174',
'770356951204',
'770356951212',
'770356885686',
'770658443976',
'770658618679',
'770353068571',
'770352647888',
'770657997668',
'770657962651',
'770657905577',
'770357424305',
'770657995487',
'770658643967',
'770658583727',
'770657989754',
'770657989762',
'770657989770',
'770657989983',
'770658162543',
'770355783898',
'770355783901',
'770353097075',
'770353172727',
'770657735647',
'770657287458',
'770658125001',
'770658193414',
'770658193422',
'770658193430',
'770658193449',
'770657990116',
'770657990124',
'770658160524',
'770657990183',
'770658245988',
'770351894644',
'770351731672',
'770351715308',
'770657703567',
'770657703524',
'770350882626',
'770354097966',
'770354097974',
'770354097982',
'770354097990',
'770354026805',
'770658483617',
'770658483625',
'770352487040',
'770658464353',
'770358502601',
'770658161857',
'770658161865',
'770658090046',
'770657551996',
'770658272403',
'770658272411',
'770658272420',
'770658272438',
'770658642383',
'770658642391',
'770657990426',
'770657990434',
'770657972363',
'770613457496',
'770657552240',
'770353072234',
'770352650382',
'770352650390',
'770352650404',
'770352650412',
'770352650420',
'770352650439',
'770352650447',
'770352650455',
'770352650374',
'770352650471',
'770352650480',
'770359440855',
'770613381198',
'770657543900',
'770657957259',
'770657538337',
'770658499270',
'770658191357',
'770357205794',
'770658246836',
'770658418416',
'770357585490',
'770357184584',
'770357585481',
'770657985376',
'770658243977',
'770658243985',
'770658243993',
'770352657174',
'770352657182',
'770352649767',
'770357824460',
'770657981303',
'770657932493',
'770353816969',
'770353746774',
'770658500627',
'770658500473',
'770359527284',
'770359527292',
'770359527306',
'770658584820',
'770658417150',
'770658417169',
'770658147153',
'770658147161',
'770658587137',
'770658587145',
'770350892907',
'770658445847',
'770658445855',
'770657966770',
'770657966789',
'770657951099',
'770657555495',
'770657947083',
'770657947091',
'770657946877',
'770658124331',
'770352467081',
'770352455733',
'770352654000',
'770658036190',
'770349741130',
'770358928897',
'770658023527',
'770658023535',
'770354632640',
'770354632659',
'770354632667',
'770658507443',
'770358723721',
'770358723730',
'770359690053',
'770356491726',
'770356491734',
'770356491742',
'770356491750',
'770658462652',
'770658462598',
'770352781762',
'770353434896',
'770658177311',
'770657873292',
'770658462466',
'770359690436',
'770360001750',
'770658191284',
'770658050877',
'770658587285',
'770658587293',
'770658587315',
'770658587323',
'770658587331',
'770658587340',
'770355041360',
'770355041379',
'770355041387',
'770355041395',
'770355041409',
'770355041417',
'770355041425',
'770355041433',
'770657965880',
'770658125834',
'770658525832',
'770658137573',
'770657570745',
'770657467405',
'770573472306',
'770573472314',
'770573472322',
'770573472330',
'770357723418',
'770357723396',
'770357723426',
'770658178032',
'770657735205',
'770658147897',
'770657328804',
'770658499041',
'770658178113',
'770657317667',
'770657317675',
'770657317683',
'770657317594',
'770658178121',
'770658820338',
'770658146645',
'770657942430',
'770658178261',
'770658178270',
'770658178288',
'770658178296',
'770658178300',
'770657687340',
'770658160281',
'770658160290',
'770658160303',
'770658178423',
'770658178458',
'770658552074',
'770658178490',
'770658178504',
'770658178512',
'770658195247',
'770658178563',
'770658178571',
'770657312410',
'770658487027',
'770658487221',
'770358716229',
'770358446930',
'770658127268',
'770573834372',
'770658608762',
'770356302290',
'770359045905',
'770359045913',
'770657515574',
'770657515540',
'770359254962',
'770658247875',
'770658178873',
'770658178881',
'770657932957',
'770352322466',
'770351757841',
'770351757337',
'770352116203',
'770352116211',
'770352806447',
'770658641603',
'770658179047',
'770658179055',
'770658179063',
'770658179071',
'770658179080',
'770658551698',
'770658447521',
'770658447530',
'770658447548',
'770658447556',
'770658447564',
'770658487507',
'770658179152',
'770658179160',
'770658179179',
'770658179187',
'770658179195',
'770658179209',
'770658179217',
'770658580329',
'770658179390',
'770658179403',
'770657521434',
'770658506544',
'770353534548',
'770353534556',
'770353534564',
'770350692479',
'770353357999',
'770353559400',
'770658584316',
'770658460854',
'770658276859',
'770658276867',
'770658276875',
'770658179721',
'770658179730',
'770658179748',
'770658179756',
'770658179764',
'770658179772',
'770658179780',
'770657966649',
'770657861740',
'770355049841',
'770356411870',
'770658500686',
'770658500694',
'770658500708',
'770658500716',
'770658500724',
'770658440942',
'770359935749',
'770658256793',
'770658256807',
'770658504150',
'770612781109',
'770658585584',
'770658491768',
'770658491750',
'770657892351',
'770658255754',
'770657972100',
'770658180037',
'770658502859',
'770354832976',
'770354832992',
'770354833000',
'770354833018',
'770658143190',
'770658444891',
'770658820354',
'770658820362',
'770658145533',
'770658529510',
'770658529528',
'770658529536',
'770658529544',
'770657274860',
'770657274879',
'770657274887',
'770657774740',
'770657954187',
'770658141651',
'770658139126',
'770356819411',
'770658122231',
'770658034405',
'770613113967',
'770354222248',
'770354222280',
'770658051857',
'770658051865',
'770658463276',
'770658463284',
'770658146475',
'770355799522',
'770355799530',
'770355799549',
'770355799557',
'770355799565',
'770657223727',
'770657223735',
'770658145240',
'770658145258',
'770657999130',
'770355200680',
'770613532838',
'770658374656',
'770658374664',
'770658102800',
'770657318213',
'770657318191',
'770359333900',
'770657961329',
'770352328979',
'770658142097',
'770657837342',
'770657837369',
'770657427314',
'770658121987',
'770658121995',
'770658122002',
'770359289197',
'770359097182',
'770657973734',
'770658206168',
'770353648020',
'770658641204',
'770658641212',
'770658641220',
'770658641239',
'770658641247',
'770657973890',
'770573205731',
'770658121650',
'770658121669',
'770658121693',
'770657994405',
'770657974005',
'770657966550',
'770657974226',
'770657974234',
'770658121340',
'770658491997',
'770658492004',
'770658255738',
'770658255746',
'770658147374',
'770658147382',
'770350259406',
'770658243420',
'770658243438',
'770358398480',
'770657690031',
'770613559906',
'770657974552',
'770658163310',
'770658163329',
'770658163337',
'770658163345',
'770658163353',
'770657780898',
'770359894287',
'770359894295',
'770658163523',
'770628951438',
'770628805962',
'770628950776',
'770629644636',
'770629230335',
'770629681329',
'770629226273',
'770628947430',
'770356880960',
'770629643575',
'770628802440');

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	cecred.crapcri.dscritic%TYPE) is

ds_critica_v	cecred.crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
   
begin

	if	(cecred.gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

		ds_critica_p	:= null;

	else

		cecred.gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'mkdir ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

		cecred.gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'chmod 777 ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

	end if;

exception
when	ds_exc_erro_v then

        ds_critica_p	:= ds_critica_v;

end valida_diretorio_p;

PROCEDURE pc_efetuar_estorno(	pr_cdcooper	in	cecred.craplau.cdcooper%TYPE,
				pr_nrdconta	in	cecred.craplau.nrdconta%TYPE,
				pr_nrproposta	in	cecred.tbseg_prestamista.nrproposta%TYPE,
				pr_dtmvtolt	in	cecred.crapdat.dtmvtolt%TYPE,
				pr_rowidlct	out	rowid) IS

vr_tab_retorno	cecred.LANC0001.typ_reg_retorno;
vr_incrineg	INTEGER DEFAULT 0 ;
vr_cdcritic	PLS_INTEGER;
vr_dscritic	VARCHAR2(4000);
vr_exc_erro	EXCEPTION;

cursor	cr_craplcm(	pr_cdcooper	cecred.craplau.cdcooper%TYPE,
			pr_nrdconta	cecred.craplau.nrdconta%TYPE,
			pr_nrproposta	cecred.tbseg_prestamista.nrproposta%TYPE) IS

SELECT	m.cdagenci,
	m.cdbccxlt,
	m.nrdolote,
	m.nrdconta,
	m.nrdocmto,
	m.cdhistor,
	m.nrseqdig,
	m.vllanmto,
	m.nrdctabb,
	m.cdcooper,
	m.nrdctitg
FROM	cecred.craplau u,
	cecred.craplcm m
WHERE	u.cdcooper	= pr_cdcooper
AND	u.nrdconta	= pr_nrdconta
AND	u.cdhistor	= 3651          -- Historico de debito
AND	u.cdseqtel	= pr_nrproposta -- Numero da proposta
AND	u.insitlau	= 2             -- Efetivado
AND	m.cdcooper	= u.cdcooper
AND	m.nrdconta	= u.nrdconta
AND	m.cdhistor	= u.cdhistor
AND	m.dtmvtolt	= u.dtmvtopg
AND	m.nrdocmto	= u.nrdocmto
AND	m.vllanmto	= u.vllanaut
AND	NOT EXISTS
	(SELECT	1
	FROM	cecred.craplcm b
	WHERE	b.cdcooper	= m.cdcooper
	AND	b.nrdconta	= m.nrdconta
	AND	b.nrdocmto || '001'	= m.nrdocmto
	AND	b.cdhistor	= 3852 -- Estorno do valor debitado do seguro contributario
	AND	b.dtmvtolt	>= m.dtmvtolt
	AND	b.vllanmto	= m.vllanmto);

rw_craplcm	cr_craplcm%ROWTYPE;

begin

	OPEN	cr_craplcm(	pr_cdcooper	=> pr_cdcooper,
				pr_nrdconta	=> pr_nrdconta,
				pr_nrproposta	=> pr_nrproposta);
	FETCH	cr_craplcm INTO rw_craplcm;

		IF	(cr_craplcm%FOUND) THEN

			lanc0001.pc_gerar_lancamento_conta(	pr_dtmvtolt	=> pr_dtmvtolt,
								pr_cdagenci	=> rw_craplcm.cdagenci,
								pr_cdbccxlt	=> rw_craplcm.cdbccxlt,
								pr_nrdolote	=> rw_craplcm.nrdolote,
								pr_nrdconta	=> rw_craplcm.nrdconta,
								pr_nrdocmto	=> rw_craplcm.nrdocmto || '001',
								pr_cdhistor	=> 3852,
								pr_nrseqdig	=> rw_craplcm.nrseqdig + 1,
								pr_vllanmto	=> rw_craplcm.vllanmto,
								pr_nrdctabb	=> rw_craplcm.nrdctabb,
								pr_dtrefere	=> pr_dtmvtolt,
								pr_hrtransa	=> to_char(SYSDATE,'SSSSS'),
								pr_cdcooper	=> rw_craplcm.cdcooper,
								pr_nrdctitg	=> rw_craplcm.nrdctitg,
								pr_tab_retorno	=> vr_tab_retorno,
								pr_incrineg	=> vr_incrineg,
								pr_cdcritic	=> vr_cdcritic,
								pr_dscritic	=> vr_dscritic);

			pr_rowidlct	:= vr_tab_retorno.rowidlct;

			IF	(NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NOT NULL) THEN

				RAISE vr_exc_erro;

		        END IF;

		END IF;

	CLOSE cr_craplcm;

EXCEPTION
WHEN	vr_exc_erro THEN

	ds_critica_v	:= vr_dscritic || SQLERRM;

WHEN	OTHERS THEN

	vr_dscritic	:= 'Erro ao alterar craplau SEGU0001.pc_efetiva_pgto_prest_contrib';
	ds_critica_v	:= vr_dscritic||SQLERRM;

END	pc_efetuar_estorno;

begin

if	(upper(cecred.gene0001.fn_database_name) like '%AYLLOSP%' or upper(cecred.gene0001.fn_database_name) like '%AILOSTS%') then

	select	max(a.dsvlrprm)
	into	ds_nome_diretorio_v
	from	cecred.crapprm a
	where	a.nmsistem	= 'CRED'
	and	a.cdcooper	= cd_cooperativa_v
	and	a.cdacesso	= 'ROOT_MICROS';

	if	(ds_nome_diretorio_v	is null) then

		select	max(a.dsvlrprm)
		into	ds_nome_diretorio_v
		from	cecred.crapprm a
		where	a.nmsistem	= 'CRED'
		and	a.cdcooper	= 0
		and	a.cdacesso	= 'ROOT_MICROS';

	end if;

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/PRB0047157-4';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/PRB0047157-4';

end if;
 
valida_diretorio_p(	ds_nome_diretorio_p	=> ds_nome_diretorio_v,
			ds_critica_p		=> ds_critica_v);

if	(trim(ds_critica_v) is not null) then

	raise ds_exc_erro_v;

end if;

for	r01 in c01 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_PRB0047157-4_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	update	cecred.tbseg_prestamista a
	set	a.tpregist	= 0,
		a.tprecusa	= '01072022',
		a.cdmotrec	= 1062,
		a.dtrecusa	= sysdate,
		a.situacao	= 0
	where	a.dtrecusa	is null
	and	a.rowid		= r01.nr_linha_tbseg;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.tbseg_prestamista a ' || chr(13) ||
					'set	a.tpregist	= ' || nvl(trim(to_char(r01.tpregist)),'null') || ', ' || chr(13) ||
					'	a.tprecusa	= ' || chr(39) || r01.tprecusa || chr(39) || ', ' || chr(13) ||
					'	a.cdmotrec	= ' || nvl(trim(to_char(r01.cdmotrec)),'null') || ', ' || chr(13) ||
					'	a.dtrecusa	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtrecusa,'dd/mm/yyyy hh24:mi:ss')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy hh24:mi:ss' || chr(39) || '), ' || chr(13) ||
					'	a.situacao	= ' || nvl(trim(to_char(r01.situacao)),'null') || chr(13) ||
					'where	a.rowid		= ' || chr(39) || r01.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

	update	cecred.crapseg a
	set	a.dtfimvig	= trunc(sysdate),
		a.dtcancel	= trunc(sysdate),
		a.cdsitseg	= 5,
		a.cdopeexc	= '1',
		a.cdageexc	= 1,
		a.dtinsexc	= trunc(sysdate),
		a.cdopecnl	= '1'
	where	a.rowid		= r01.id_linha;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.crapseg a ' || chr(13) ||
					'set	a.dtfimvig	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
					'	a.dtcancel	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
					'	a.cdsitseg	= ' || replace(nvl(trim(to_char(r01.cdsitseg)),'null'),',','.') || ', ' || chr(13) ||
					'	a.cdopeexc	= ' || chr(39) || r01.cdopeexc || chr(39) || ', ' || chr(13) ||
					'	a.cdageexc	= ' || replace(nvl(trim(to_char(r01.cdageexc)),'null'),',','.') || ', ' || chr(13) ||
					'	a.dtinsexc	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtinsexc,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
					'	a.cdopecnl	= ' || chr(39) || r01.cdopecnl || chr(39) || chr(13) ||
					'where	a.rowid		= ' || chr(39) || r01.id_linha || chr(39) || ';' || chr(13) || chr(13), false);

	if	(r01.tpcustei	= 0) then

		vr_proxutil	:= GENE0005.fn_valida_dia_util(	pr_cdcooper	=> r01.cdcooper,
								pr_dtmvtolt	=> TRUNC(SYSDATE),
								pr_tipo		=> 'P');

		pc_efetuar_estorno(	pr_cdcooper	=> r01.cdcooper,
					pr_nrdconta	=> r01.nrdconta,
					pr_nrproposta	=> r01.nrproposta,
					pr_dtmvtolt	=> vr_proxutil,
					pr_rowidlct	=> ds_rowidlct);

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'delete	from cecred.craplcm a ' || chr(13) ||
						'where	a.rowid	= ' || chr(39) || ds_rowidlct || chr(39) || ';' || chr(13) || chr(13), false);

	end if;

	if	(qt_registro	>= 1000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> ds_critica_v);

		if	(trim(ds_critica_v) is not null) then

			rollback;
			raise	ds_exc_erro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when others then
		vr_dscritic	:= 'Falha ao atualizar crapseg';
		rollback;
		exit;
	end;

end loop;

if	(qt_reg_arquivo	<> 50000) then

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
						pr_cdprogra	=> 'ATENDA',
						pr_dtmvtolt	=> trunc(sysdate),
						pr_dsxml	=> ds_dados_rollback_v,
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
						pr_flg_impri	=> 'N',
						pr_flg_gerar	=> 'S',
						pr_flgremarq	=> 'N',
						pr_nrcopias	=> 1,
						pr_des_erro	=> ds_critica_v);

	if	(trim(ds_critica_v) is not null) then

		raise	ds_exc_erro_v;

	end if;

	dbms_lob.close(ds_dados_rollback_v);
	dbms_lob.freetemporary(ds_dados_rollback_v);

end if;

if	(trim(vr_dscritic) is not null) then

	ds_critica_v	:= vr_dscritic;
	raise	ds_exc_erro_v;

end if;

commit;

exception
when	ds_exc_erro_v then

	raise_application_error(-20111, ds_critica_v);

end;

end;