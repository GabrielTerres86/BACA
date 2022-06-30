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

cursor	c01 is
select	b.rowid as id_linha,
	b.dtfimvig,
	b.dtcancel,
	b.cdsitseg,
	b.cdopeexc,
	b.cdageexc,
	b.dtinsexc,
	b.cdopecnl
from	cecred.crapcop d,
	cecred.tbseg_prestamista c,
	cecred.crapseg b
where	c.cdcooper	= d.cdcooper
and	b.tpseguro	= 4
and	b.cdsitseg	<> 5
and	c.cdcooper	= b.cdcooper
and	c.nrdconta	= b.nrdconta
and	c.nrctrseg	= b.nrctrseg
and	c.dtrecusa	is not null
and	c.nrproposta	in
('770612996571',
'770356212550',
'770613154965',
'770657218545',
'770657292753',
'770613545786',
'770613545816',
'770657868906',
'770657292826',
'770657573671',
'770612954062',
'770657292893',
'770657292907',
'770657420581',
'770657421677',
'770657420395',
'770353920227',
'770613564276',
'770613564284',
'770613564292',
'770613564314',
'770613553215',
'770613360174',
'770612968489',
'770657743640',
'770657770795',
'770657410969',
'770613226540',
'770573427840',
'770573204263',
'770657730238',
'770657928275',
'770657525316',
'770613247637',
'770613071130',
'770613081925',
'770613698264',
'770572892859',
'770657361542',
'770613072098',
'770613298614',
'770657653500',
'770613326561',
'770613620877',
'770657868981',
'770573620313',
'770573620330',
'770573620348',
'770573620356',
'770573620364',
'770573620305',
'770613115293',
'770657293083',
'770657293091',
'770657293105',
'770657293113',
'770657293121',
'770657293130',
'770657293148',
'770657420140',
'770613001824',
'770657367931',
'770657293199',
'770657293202',
'770613429859',
'770657472832',
'770657786209',
'770657346799',
'770657293539',
'770657293547',
'770657387797',
'770613437991',
'770657855294',
'770657293520',
'770657293555',
'770657293563',
'770657450480',
'770657450456',
'770613760113',
'770354600951',
'770354600943',
'770657869090',
'770657730548',
'770613210229',
'770355693970',
'770355693988',
'770355693872',
'770657121053',
'770613103015',
'770613103023',
'770613103031',
'770613365630',
'770657869180',
'770613678131',
'770657829544',
'770613768653',
'770657840882',
'770657840890',
'770657841986',
'770613112430',
'770657221031',
'770657888400',
'770657868949',
'770657868086',
'770657469408',
'770657872539',
'770657869155',
'770657868590',
'770613557954',
'770657613720',
'770657294500',
'770657294519',
'770612961085',
'770657842842',
'770657274941',
'770358205364',
'770657731030',
'770657869775',
'770613119299',
'770613680985',
'770657119954',
'770657897574',
'770613592997',
'770657295469',
'770657295477',
'770657295485',
'770657332372',
'770657295604',
'770657295612',
'770613433163',
'770613675493',
'770573634845',
'770612777470',
'770612777489',
'770657295787',
'770657295795',
'770657295809',
'770657561975',
'770657868531',
'770657296015',
'770657296023',
'770657296031',
'770612859418',
'770612859337',
'770657405612',
'770657296244',
'770657296155',
'770657296163',
'770657296171',
'770657296180',
'770657296198',
'770657472557',
'770657296252',
'770657389412',
'770359560141',
'770613701923',
'770657345571',
'770657475823',
'770613110356',
'770657714321',
'770355365662',
'770354929627',
'770354929635',
'770612860114',
'770657389676',
'770612945390',
'770613674357',
'770354700395',
'770354700409',
'770573597788',
'770657389668',
'770657834424',
'770657120227',
'770657868205',
'770657915343',
'770657419265',
'770357824060',
'770357824079',
'770357824087',
'770357824095',
'770358596088',
'770657852570',
'770657390232',
'770657390240',
'770657390259',
'770657390267',
'770657390275',
'770657390283',
'770657390291',
'770657390305',
'770657420212',
'770657411841',
'770657853445',
'770357456100',
'770355320707',
'770355320294',
'770612870284',
'770657378364',
'770351560088',
'770657484121',
'770657910830',
'770349061350',
'770349064863',
'770657223255',
'770657223263',
'770657390810',
'770657390828',
'770657390836',
'770657384348',
'770657868574',
'770657656399',
'770657267333',
'770657343102',
'770657869074',
'770350452249',
'770350452257',
'770350452265',
'770350452281',
'770350838929',
'770657343099',
'770613757988',
'770657391077',
'770657391085',
'770657391093',
'770613169296',
'770613564152',
'770657442615',
'770657442631',
'770657292060',
'770657291897',
'770657843377',
'770657419982',
'770349103974',
'770657868183',
'770613767851',
'770657391468',
'770657391476',
'770657391484',
'770657391492',
'770657391395',
'770657391409',
'770657391417',
'770657843539',
'770657391450',
'770613209255',
'770613264922',
'770613598642',
'770613598669',
'770613598685',
'770657391590',
'770657391603',
'770657391611',
'770612971056',
'770657391620',
'770657391638',
'770657391646',
'770657391654',
'770657713929',
'770657909386',
'770657868302',
'770657869139',
'770613429387',
'770350991581',
'770657382809',
'770657382817',
'770657382523',
'770613049169',
'770657197475',
'770657917508',
'770657456462',
'770657371726',
'770613504532',
'770657456217',
'770657456225',
'770657456233',
'770657456241',
'770657456250',
'770657456268',
'770657824372',
'770657824291',
'770657456330',
'770613114084',
'770657456438',
'770657456446',
'770657456454',
'770657456527',
'770657606693',
'770657868485',
'770657456519',
'770613113819',
'770612864519',
'770356117280',
'770657786829',
'770657279110',
'770657742422',
'770657868965',
'770349914093',
'770349914115',
'770349914123',
'770613115390',
'770352236748',
'770657720240',
'770657720259',
'770657720267',
'770657720275',
'770657891746',
'770657891754',
'770613220089',
'770612779716',
'770657813389',
'770657518700',
'770657518697',
'770657519197',
'770657454702',
'770613324780',
'770657343552',
'770657420689',
'770657307700',
'770613676198',
'770612965358',
'770612965366',
'770612965374',
'770657276170',
'770657892360',
'770657892378',
'770657330388',
'770613442782',
'770613442790',
'770613442804',
'770613442839',
'770657344672',
'770657419877',
'770657121142',
'770657345903',
'770657892483',
'770657892491',
'770657868060',
'770657868248',
'770613763732',
'770573188179',
'770657223506',
'770657223514',
'770657223522',
'770657223530',
'770351018968',
'770353219839',
'770353221949',
'770612854688',
'770657223603',
'770657223611',
'770657223620',
'770657223638',
'770657223646',
'770657223654',
'770613773770',
'770350541764',
'770572983544',
'770657223867',
'770657267937',
'770353161520',
'770613621059',
'770349908670',
'770349908700',
'770349908719',
'770657389374',
'770657224065',
'770657224073',
'770657224081',
'770657224090',
'770657224103',
'770657224111',
'770613008756',
'770613008764',
'770613008772',
'770613008683',
'770613555013',
'770657224154',
'770657224162',
'770657224367',
'770657224375',
'770657224383',
'770657224391',
'770657224405',
'770657224413',
'770657224421',
'770612863768',
'770573531663',
'770573531671',
'770573531680',
'770573531698',
'770572909395',
'770657417718',
'770358249663',
'770358249671',
'770358249680',
'770358249698',
'770358249701',
'770613002057',
'770355493261',
'770657224626',
'770657325287',
'770354556766',
'770354555930',
'770353401998',
'770353399101',
'770657321664',
'770657351792',
'770657671100',
'770657292575',
'770657292583',
'770657864706',
'770657292559',
'770657292567',
'770612964912');

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/PRB0047157-2';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/PRB0047157-2';

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
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_PRB0047157-2_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

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