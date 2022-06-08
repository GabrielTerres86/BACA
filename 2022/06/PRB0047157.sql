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
and	b.cdsitseg	<> 5
and	c.cdcooper	= b.cdcooper
and	c.nrdconta	= b.nrdconta
and	c.nrctrseg	= b.nrctrseg
and	c.nrproposta	in
('770613548858',
'770613394893',
'770613291784',
'770613079394',
'770613274847',
'770613212698',
'770613079300',
'770612784949',
'770613665960',
'770613419420',
'770359444435',
'770357177111',
'770613718338',
'770613083820',
'770613651683',
'770613723064',
'770354733943',
'770612843686',
'770613449493',
'770573752198',
'770573005570',
'770613247602',
'770612906424',
'770612936803',
'770612936714',
'770351342412',
'770351120568',
'770612945438',
'770613283331',
'770613278605',
'770572923401',
'770613283455',
'770613363750',
'770613283579',
'770613283587',
'770613283595',
'770613482377',
'770613176870',
'770613283633',
'770613283641',
'770612889074',
'770613024328',
'770358015344',
'770353609661',
'770353602624',
'770350285547',
'770357531608',
'770613064486',
'770613064494',
'770613064478',
'770613064516',
'770613064524',
'770613309446',
'770572943593',
'770613548041',
'770613548050',
'770613548068',
'770613309144',
'770613307494',
'770359582056',
'770612921911',
'770612929408',
'770573405234',
'770613548572',
'770613548580',
'770613533370',
'770612906440',
'770613753931',
'770612935840',
'770613104496',
'770613104259',
'770613102400',
'770613102124',
'770613663711',
'770612938962',
'770613739262',
'770613750770',
'770612791953',
'770613025081',
'770573587693',
'770612995966',
'770613133496',
'770613548920',
'770613548939',
'770613548947',
'770613548955',
'770613548963',
'770613548971',
'770613548980',
'770613548998',
'770613549005',
'770613549013',
'770613549021',
'770613549030',
'770613549064',
'770613136118',
'770613362630',
'770355413730',
'770613549188',
'770613549196',
'770613549200',
'770613549218',
'770613549226',
'770613051961',
'770613549285',
'770613549293',
'770613549307',
'770613549315',
'770613549323',
'770613549331',
'770613549340',
'770613398791',
'770613549412',
'770613549420',
'770613549501',
'770350347615',
'770350347631',
'770612921156',
'770612921164',
'770613033734',
'770352771627',
'770350533095',
'770612918708',
'770612918716',
'770613482393',
'770613121021',
'770613549692',
'770613549722',
'770613549730',
'770613549749',
'770613254790',
'770613549757',
'770613549765',
'770613549773',
'770613549781',
'770613415025',
'770613549790',
'770613549803',
'770613333320',
'770350529853',
'770350531033',
'770352316148',
'770351985100',
'770613549846',
'770612805342',
'770612805326',
'770613534520',
'770613013016',
'770350400346',
'770613421289',
'770612984948',
'770573540476',
'770355960889',
'770355995887',
'770613670505',
'770613382828',
'770613424407',
'770573771095',
'770573771133',
'770354466848',
'770354962349',
'770354466856',
'770573612728',
'770612890064',
'770612890072',
'770613497323',
'770612994358',
'770612993475',
'770613314407',
'770357830850',
'770357830869',
'770357830877',
'770357830885',
'770612890323',
'770355582337',
'770612824053',
'770612823839',
'770612890790',
'770612890803',
'770612890811',
'770612890820',
'770359717270',
'770612873127',
'770612890854',
'770355176681',
'770356019911',
'770612948216',
'770355787567',
'770613024280',
'770612891338',
'770612891346',
'770612891354',
'770613164065',
'770613164022',
'770612799962',
'770613018506',
'770353656260',
'770613321071',
'770612891486',
'770612891494',
'770612891508',
'770612891516',
'770612891524',
'770612891532',
'770613105670',
'770612988617',
'770613363360',
'770612805091',
'770355613615',
'770355613640',
'770613471324',
'770613184279',
'770613184198',
'770353495895',
'770354287625',
'770573519671',
'770613156763',
'770613663452',
'770613445072',
'770612891621',
'770358167772',
'770612891710',
'770612851999',
'770613490558',
'770613422463',
'770612891729',
'770612891737',
'770612891745',
'770613739084',
'770355302636',
'770359882807',
'770359882343',
'770613745084',
'770612891877',
'770612891885',
'770612891893',
'770613239022',
'770613239030',
'770350062491',
'770613641491',
'770613641505',
'770613641513',
'770613641521',
'770613641530',
'770350280545',
'770613130446',
'770612892393',
'770612892407',
'770357653304',
'770357653312',
'770357653320',
'770357653339',
'770357653347',
'770357653355',
'770613464930',
'770355704262',
'770613426680',
'770613426698',
'770353783840',
'770613109196',
'770613109200',
'770612892717',
'770612892725',
'770612792518',
'770613646272',
'770613023585',
'770613267395',
'770613662758',
'770612893063',
'770613242996',
'770354696223',
'770613275541',
'770612919852',
'770357226309',
'770357226317',
'770357226325',
'770612885826',
'770351776250',
'770351692588',
'770613281487',
'770613281495',
'770613281509',
'770613281517',
'770613281525',
'770357415802',
'770612931070',
'770613670122',
'770613282840',
'770355747174',
'770354534258',
'770572982602',
'770613278788',
'770613742077',
'770573060334',
'770613425632',
'770350634398',
'770612936730',
'770612936749',
'770612936757',
'770612936765',
'770612936773',
'770612936781',
'770612936790');

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/PRB0047157';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/PRB0047157';

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
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_PRB0047157_'||nr_arquivo||'.sql';

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

	if	(qt_registro	>= 10000) then

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