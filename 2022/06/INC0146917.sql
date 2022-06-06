begin

declare

ds_exc_erro_v		exception;
ds_erro_registro_v	exception;
ds_critica_v		crapcri.dscritic%type;
ds_critica_rollback_v	crapcri.dscritic%type;
ie_idprglog_v		cecred.tbgen_prglog.idprglog%type	:= 0;

ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);
nm_arquivo_rollback_v	varchar2(100);

cd_cooperativa_v	cecred.crapcop.cdcooper%type	:= 3;
ds_nome_diretorio_v	cecred.crapprm.dsvlrprm%type;

qt_reg_commit		number(10)	:= 0;
nr_arquivo		number(10)	:= 1;
qt_reg_arquivo		number(10)	:= 50000;

cursor	c01 is
select	a.cdcooper,
	a.nrproposta,
	a.rowid as nr_linha_tbseg,
	a.tpregist,
	c.rowid as nr_linha_crap,
	decode(	a.nrproposta,
		'770629677410',168.5,
'770628998051',22.21,
'770628958319',241.73,
'770629445820',239.45,
'770629268316',238.14,
'770629680179',123.37,
'770629677968',657.02,
'770629445510',235.85,
'770629268553',707.74,
'770629673369',17.41,
'770629003312',244.35,
'770628999619',629.27,
'770629446630',24.76,
'770629676031',74.73,
'770629001743',237.81,
'770628999864',35.94,
'770629678247',202.56,
'770629675434',181.53,
'770629004491',213.93,
'770629675230',345.08,
'770629269517',77.56,
'770629676953',64.11,
'770629447016',318.47,
'770628999279',31.84,
'770629439706',877.27,
'770629440429',222.14,
'770629269762',255.86,
'770628999627',58.6,
'770629680357',75.2,
'770629270752',186.46,
'770629002197',107.14,
'770629002901',30.43,
'770629270280',60.84,
'770629002219',27.7,
'770629000852',67.59,
'770629438009',96.09,
'770629004742',96.74,
'770629000453',162.02,
'770629271228',413.32,
'770629675493',248.27,
'770629675515',127.95,
'770629270604',124.99,
'770629674110',617.59,
'770629001000',239.12,
'770629269096',506.92,
'770629674330',948.77,
'770629269401',239.12,
'770629447067',649.14,
'770629678379',243.64,
'770629002243',2202.36,
'770629269169',186.66,
'770629439021',30.94,
'770629268480',238.79,
'770629268910',241.41,
'770629269100',123.44,
'770629003525',182.79,
'770629269908',188.74,
'770629678468',2086.45,
'770628802289',20.81,
'770629435603',40.27,
'770629676376',98.47,
'770629002383',565.32,
'770628958548',240.3,
'770629269339',288.03,
'770629437312',3105.65,
'770629001689',321.34,
'770628998540',333.81,
'770629439080',183.75,
'770629437665',100.99,
'770629270949',257.44,
'770628998663',758.59,
'770628998434',435.08,
'770629679936',23.79,
'770629440488',111.32,
'770629003355',244.69,
'770629673814',3563.98,
'770629675388',1014.03,
'770629673865',28.29,
'770628998531',18.75,
'770629680268',250.92,
'770629673350',111.61,
'770629441530',191.71,
'770629446060',32.77,
'770629676473',127.67,
'770629437983',124.96,
'770629002448',1240.95,
'770629435557',138.15,
'770629677690',1131.28,
'770629439811',382.86,
'770629437223',249.94,
'770629001069',158.68,
'770629268820',2468.74,
'770629000879',763.76,
'770629677283',76.78,
'770629436880',369.64,
'770629269126',10.27,
'770629268260',22.75,
'770629004513',115.07,
'770628998221',620.23,
'770628998566',245.82,
'770629004092',133.87,
'770629271490',1189.85,
'770628999813',40.57,
'770629446923',669.1,
'770628999171',469.24,
'770629435743',317.03,
'770629000844',13.48,
'770629270060',303.05,
'770629271031',158.66,
'770629675183',37.25,
'770628998108',263.38,
'770629437975',86.02,
'770629436952',388.93,
'770629439374',96.78,
'770629676805',488.8,
'770628999880',480.44,
'770629440526',180.02,
'770629436197',768.97,
'770629439005',749.17,
'770629268898',44.42,
'770628999902',161.82,
'770629676406',6.66,
'770629439943',612.23,
'770629437940',462.5,
'770629679502',224.69,
'770629675752',5.86,
'770628999651',67.52,
'770629438092',843.08,
'770629441069',290.1,
'770629000739',150.59,
'770629439978',364.71,
'770628999252',333.81,
'770629435506',96.97,
'770629435646',77.1,
'770629679316',66.33,
'770628998124',11.76,
'770629438963',147.04,
'770629678891',114.13,
'770629440828',27.47,
'770628802270',300.7,
'770629002880',810.4,
'770629673377',569.57,
'770629675817',581.81,
'770629004505',26.93,
'770629269215',317.11,
'770628999678',122.81,
'770629004033',270.21,
'770629676910',708.66,
'770628958777',459.46,
'770629436685',4.47,
'770629438157',950.53,
'770628998710',252.86,
'770629000909',61.76,
'770629678778',458.76,
'770629675396',483.25,
'770629268324',91.17,
'770629440020',7.85,
'770629438076',279.47,
'770629000020',127.44,
'770629437193',391.74,
'770629446575',1239.06,
'770629439064',20.89,
'770629435867',114.34,
'770629675779',652.63,
'770629438149',256.12,
'770629438556',278.96,
'770629269312',305.55,
'770629677852',489.19,
'770629676147',244.18,
'770629003410',332.7,
'770629674560',263.19,
'770629438548',364.22,
'770629678638',235.24,
'770629438017',366.5,
'770628999686',109.08,
'770629675582',189.55,
'770629439668',181.7,
'770629002081',180.08,
'770629677020',48.75,
'770628958459',234.72,
'770629675450',126.08,
'770629437401',415.75,
'770629680241',58.1,
'770629674535',73.13,
'770629436537',130.16,
'770629000178',399.63,
'770629675833',144.25,
'770629000569',15.95,
'770629435760',245.69,
'770629677720',97.54,
'770629001425',29.97,
'770629436693',26.2,
'770629676694',217.07,
'770629678573',23.58,
'770629675094',129.37,
'770629673270',369.88,
'770629674667',76.9,
'770629444467',61.38,
'770629270035',375.49,
'770629436421',1026.14,
'770629679863',103.48,
'770629003703',363,
'770629445927',4.85,
'770629446699',109.65,
'770629435441',187.62,
'770629002260',381.05,
'770629271201',559.28,
'770629269061',499.5,
'770629445196',75.88,
'770629674675',70.88,
'770629436090',575.19,
'770629002863',71.88,
'770628998213',314.85,
'770629000666',222.77,
'770628958467',23.87,
'770629436405',140.13,
'770629269053',1139.14,
'770629269304',104.5,
'770629001565',0.31,
'770629447326',3574.32,
'770629440232',733.27,
'770629446702',14.31,
'770629269690',680.44,
'770628998337',254.15,
'770629435522',29.26,
'770629436057',54.92,
'770629002456',56.55,
'770629268030',231.04,
'770628998159',384.15,
'770629674403',985.94,
'770629675400',369.58,
'770629674713',56.71,
'770629435425',218.15,
'770629271368',1.71,
'770629002570',22.48,
'770628958424',5016.35,
'770629447164',832.63,
'770629003509',254.58,
'770629438319',100.25,
'770629001077',133.78,
'770629435816',566.32,
'770628999023',354.69,
'770629674144',347.01,
'770629002308',92.91,
'770629436766',769.07,
'770629000593',287.88,
'770629001735',126.54,
'770629271023',2.9,
'770629441514',6.34,
'770629269681',254.61,
'770629674870',1144.79,
'770629003339',814.3,
'770629000925',111.07,
'770629437215',266.7,
'770629270043',203.03,
'770629675353',59.93,
'770629435620',50.26,
'770629673474',422.5,
'770629000070',89.36) vl_corrigido,
	a.vlprodut as vlprodut_tbseg,
	c.vlpremio as vlpremio_crap,
	b.rowid as nr_linha_craw,
	b.vlpremio as vlpremio_craw
from	cecred.crapseg c,
	cecred.crawseg b,
	cecred.tbseg_prestamista a
where	c.cdsitseg		= 1
and	c.tpseguro		= 4
and	b.nrctrseg		= c.nrctrseg
and	b.nrdconta		= c.nrdconta
and	b.cdcooper		= c.cdcooper
and	a.nrproposta		= b.nrproposta
and	a.nrctrseg		= b.nrctrseg
and	a.nrdconta		= b.nrdconta
and	a.cdcooper		= b.cdcooper
and	trim(a.tprecusa)	is null
and	nvl(a.cdmotrec,0)	= 0
and	a.dtrecusa		is null
and	a.nrproposta		in
	('770629435603',
'770629676376',
'770629002383',
'770628958548',
'770629269339',
'770629437312',
'770629001689',
'770628998540',
'770629439080',
'770629437665',
'770629270949',
'770628998663',
'770628998434',
'770629679936',
'770629440488',
'770629003355',
'770629673814',
'770629675388',
'770629673865',
'770628998531',
'770629680268',
'770629673350',
'770629441530',
'770629446060',
'770629676473',
'770629437983',
'770629002448',
'770629435557',
'770629677690',
'770629439811',
'770629437223',
'770629001069',
'770629268820',
'770629000879',
'770629677283',
'770629436880',
'770629269126',
'770629268260',
'770629004513',
'770628998221',
'770628998566',
'770629004092',
'770629271490',
'770628999813',
'770629446923',
'770628999171',
'770629435743',
'770629000844',
'770629270060',
'770629271031',
'770629675183',
'770628998108',
'770629437975',
'770629436952',
'770629439374',
'770629676805',
'770628999880',
'770629440526',
'770629436197',
'770629439005',
'770629268898',
'770628999902',
'770629676406',
'770629439943',
'770629437940',
'770629679502',
'770629675752',
'770628999651',
'770629438092',
'770629441069',
'770629000739',
'770629439978',
'770628999252',
'770629435506',
'770629435646',
'770629679316',
'770628998124',
'770629438963',
'770629678891',
'770629440828',
'770628802270',
'770629002880',
'770629673377',
'770629675817',
'770629004505',
'770629269215',
'770628999678',
'770629004033',
'770629676910',
'770628958777',
'770629436685',
'770629438157',
'770628998710',
'770629000909',
'770629678778',
'770629675396',
'770629268324',
'770629440020',
'770629438076',
'770629000020',
'770629437193',
'770629446575',
'770629439064',
'770629435867',
'770629675779',
'770629438149',
'770629438556',
'770629269312',
'770629677852',
'770629676147',
'770629003410',
'770629674560',
'770629438548',
'770629678638',
'770629438017',
'770628999686',
'770629675582',
'770629439668',
'770629002081',
'770629677020',
'770628958459',
'770629675450',
'770629437401',
'770629680241',
'770629674535',
'770629436537',
'770629000178',
'770629675833',
'770629000569',
'770629435760',
'770629677720',
'770629001425',
'770629436693',
'770629676694',
'770629678573',
'770629675094',
'770629673270',
'770629674667',
'770629444467',
'770629270035',
'770629436421',
'770629679863',
'770629003703',
'770629445927',
'770629446699',
'770629435441',
'770629002260',
'770629271201',
'770629269061',
'770629445196',
'770629674675',
'770629436090',
'770629002863',
'770628998213',
'770629000666',
'770628958467',
'770629436405',
'770629269053',
'770629269304',
'770629001565',
'770629447326',
'770629440232',
'770629446702',
'770629269690',
'770628998337',
'770629435522',
'770629436057',
'770629002456',
'770629268030',
'770628998159',
'770629674403',
'770629675400',
'770629674713',
'770629435425',
'770629271368',
'770629002570',
'770628958424',
'770629447164',
'770629003509',
'770629438319',
'770629001077',
'770629435816',
'770628999023',
'770629674144',
'770629002308',
'770629436766',
'770629000593',
'770629001735',
'770629271023',
'770629441514',
'770629269681',
'770629674870',
'770629003339',
'770629000925',
'770629437215',
'770629270043',
'770629675353',
'770629435620',
'770629673474',
'770629000070',
'770629677410',
'770628998051',
'770628958319',
'770629445820',
'770629268316',
'770629680179',
'770629677968',
'770629445510',
'770629268553',
'770629673369',
'770629003312',
'770628999619',
'770629446630',
'770629676031',
'770629001743',
'770628999864',
'770629678247',
'770629675434',
'770629004491',
'770629675230',
'770629269517',
'770629676953',
'770629447016',
'770628999279',
'770629439706',
'770629440429',
'770629269762',
'770628999627',
'770629680357',
'770629270752',
'770629002197',
'770629002901',
'770629270280',
'770629002219',
'770629000852',
'770629438009',
'770629004742',
'770629000453',
'770629271228',
'770629675493',
'770629675515',
'770629270604',
'770629674110',
'770629001000',
'770629269096',
'770629674330',
'770629269401',
'770629447067',
'770629678379',
'770629002243',
'770629269169',
'770629439021',
'770629268480',
'770629268910',
'770629269100',
'770629003525',
'770629269908',
'770629678468',
'770628802289');

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

begin

if	(upper(gene0001.fn_database_name) like '%AYLLOSP%' or upper(gene0001.fn_database_name) like '%AILOSTS%') then

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0146917';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0146917';

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
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin ' || chr(13) || chr(13), false);  
		nm_arquivo_rollback_v	:= 'ROLLBACK_INC0146917_' || nr_arquivo || '.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_reg_commit		:= qt_reg_commit + 1;
	qt_reg_arquivo		:= qt_reg_arquivo + 1;

	update	cecred.tbseg_prestamista a
	set	a.vlprodut	= r01.vl_corrigido
	where	a.rowid		= r01.nr_linha_tbseg;

	gene0002.pc_escreve_xml(ds_dados_rollback_v,
				ds_texto_rollback_v,
				'update	cecred.tbseg_prestamista a ' || chr(13) ||
				'set	a.vlprodut = ' || replace(nvl(trim(to_char(r01.vlprodut_tbseg)),'null'),',','.') || chr(13) ||
				'where	a.rowid	= ' || chr(39) || r01.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

	update	cecred.crawseg a
	set	a.vlpremio	= r01.vl_corrigido
	where	a.rowid		= r01.nr_linha_craw;

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
				ds_texto_rollback_v,
				'update	crawseg a ' || chr(13) ||
				'set	a.vlpremio = ' || replace(nvl(trim(to_char(r01.vlpremio_craw)),'null'),',','.') || chr(13) ||
				'where	a.rowid	= ' || chr(39) || r01.nr_linha_craw || chr(39) || ';' || chr(13) || chr(13), false);

	update	cecred.crapseg a
	set	a.vlpremio	= r01.vl_corrigido
	where	a.rowid		= r01.nr_linha_crap;

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
				ds_texto_rollback_v,
				'update	crapseg a ' || chr(13) ||
				'set	a.vlpremio = ' || replace(nvl(trim(to_char(r01.vlpremio_crap)),'null'),',','.') || chr(13) ||
				'where	a.rowid	= ' || chr(39) || r01.nr_linha_crap || chr(39) || ';' || chr(13) || chr(13), false);

	if	(qt_reg_commit	>= 5000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_reg_commit	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || nm_arquivo_rollback_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> ds_critica_rollback_v);

		if	(trim(ds_critica_rollback_v) is not null) then

			raise	ds_erro_registro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when	ds_erro_registro_v then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: falha mapeada ao atualizar registro:' || chr(13) ||
					'Proposta: ' || r01.nrproposta || chr(13) ||
					'Crítica: ' || ds_critica_rollback_v || chr(13) || chr(13), false);

	when	others then

		rollback;

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: erro de sistema ao atualizar registro:' || chr(13) ||
					'Proposta: ' || r01.nrproposta || chr(13) ||
					'Erro: ' || sqlerrm || chr(13) || chr(13), false);

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
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || nm_arquivo_rollback_v,
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

	commit;

end if;

exception
when	ds_exc_erro_v then

	rollback;
	raise_application_error(-20111, ds_critica_v);

end;

end;