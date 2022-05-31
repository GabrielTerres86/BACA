begin

declare

ds_exc_erro_v		exception;
ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);

cd_cooperativa_v	cecred.crapcop.cdcooper%type	:= 3;
ds_nome_arquivo_bkp_v	varchar2(100);
ds_nome_diretorio_v	cecred.crapprm.dsvlrprm%type;
ds_critica_v		cecred.crapcri.dscritic%type;

qt_registro		number(10)	:= 0;
nr_arquivo		number(10)	:= 1;
qt_reg_arquivo		number(10)	:= 50000;

vr_dscritic		VARCHAR2(1000);

vr_apolice		cecred.tbseg_parametros_prst.nrapolic%TYPE;
vr_pgtosegu		cecred.tbseg_parametros_prst.pagsegu%TYPE;
vr_vlsdeved		NUMBER(15,2);
vr_vlpremor		NUMBER(15,2);
vr_vlpreinv		NUMBER(15,2);
vr_preperda		NUMBER(15,2);
vr_vlpreliq		NUMBER(15,2);
vr_vlpreiof		NUMBER(15,2);
vr_vlpretot		NUMBER(15,2);
vr_cdcritic		PLS_INTEGER;

cursor	c01 is
select	b.CDCOOPER,
	b.NRDCONTA,
	b.NRCTREMP,
	a.DTNASCSG,
	c.VLPREEMP,
	c.QTPREEMP,
	a.FLGGARAD,
	b.DTINIVIG,
	b.DTFIMVIG,
	e.vlemprst,
	b.pemorte,
	b.peinvalidez,
	b.peiftttaxa,
	b.qtifttdias,
	b.vlpielimit,
	b.vlifttlimi,
	b.vlprodut vlprodut_tbseg,
	a.vlpremio vlpremio_craw,
	f.vlpremio vlpremio_crap,
	b.rowid nr_linha_tbseg,
	a.rowid nr_linha_craw,
	f.rowid nr_linha_crap
from	cecred.crapseg f,
	cecred.crapsim e,
	cecred.crawepr d,
	cecred.crapepr c,
	cecred.tbseg_prestamista b,
	cecred.crawseg a
where	f.cdsitseg	not in (2,5)
and	a.cdcooper	= f.cdcooper
and	a.nrdconta	= f.nrdconta
and	a.nrctrseg	= f.nrctrseg
and	d.cdcooper	= e.cdcooper(+)
and	d.nrdconta	= e.nrdconta(+)
and	d.nrsimula	= e.nrsimula(+)
and	c.cdcooper	= d.cdcooper
and	c.nrdconta	= d.nrdconta
and	c.nrctremp	= d.nrctremp
and	b.CDCOOPER	= c.CDCOOPER
and	b.NRDCONTA	= c.NRDCONTA
and	b.NRCTREMP	= c.NRCTREMP
and	b.TPREGIST	<> 0
and	a.CDCOOPER	= b.CDCOOPER
and	a.NRDCONTA	= b.NRDCONTA
and	a.NRCTRATO	= b.NRCTREMP
and	a.NRCTRSEG	= b.NRCTRSEG
and	a.TPCUSTEI	= 0;

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

if	(upper(cecred.gene0001.fn_database_name) like '%AYLLOSP%' or upper(gene0001.fn_database_name) like '%AILOSTS%') then

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/RITM0223100';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/RITM0223100';

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
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_RITM0223100_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	cecred.segu0003.pc_retorna_valores_contributario(	pr_cdcooper	=> r01.cdcooper,
								pr_nrdconta	=> r01.nrdconta,
								pr_nrctremp	=> r01.nrctremp,
								pr_dtnascsg	=> r01.dtnascsg,
								pr_vlpreemp	=> r01.vlpreemp,
								pr_qtpreemp	=> r01.qtpreemp,
								pr_flggarad	=> r01.flggarad,
								pr_dtinivig	=> r01.dtinivig,
								pr_dtfimvig	=> r01.dtfimvig,
								pr_totsimul	=> r01.vlemprst,
								pr_flefetivada	=> 'N',
								pr_pemorte	=> r01.pemorte,
								pr_peinvalidez	=> r01.peinvalidez,
								pr_peiftttaxa	=> r01.peiftttaxa,
								pr_qtifttdias	=> r01.qtifttdias,
								pr_pielimit	=> r01.vlpielimit,
								pr_ifttlimi	=> r01.vlifttlimi,
								pr_apolice	=> vr_apolice,
								pr_pgtosegu	=> vr_pgtosegu,
								pr_vlsdeved	=> vr_vlsdeved,
								pr_vlpremor	=> vr_vlpremor,
								pr_vlpreinv	=> vr_vlpreinv,
								pr_preperda	=> vr_preperda,
								pr_vlpreliq	=> vr_vlpreliq,
								pr_vlpreiof	=> vr_vlpreiof,
								pr_vlpretot	=> vr_vlpretot,
								pr_cdcritic	=> vr_cdcritic,
								pr_dscritic	=> ds_critica_v);

	if	(ds_critica_v	is not null) then

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'Falha ao calcular valor coop: ' || r01.cdcooper || ', conta: ' || r01.nrdconta || ', contrato: ' || r01.nrctremp || chr(13) || chr(13), false);

	elsif	(r01.vlprodut_tbseg <> vr_vlpretot) and (nvl(vr_vlpretot,0) <> 0) then

		qt_registro	:= qt_registro + 1;
		qt_reg_arquivo	:= qt_reg_arquivo + 1;

		update	tbseg_prestamista a
		set	a.vlprodut	= vr_vlpretot
		where	a.rowid		= r01.nr_linha_tbseg;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	tbseg_prestamista a ' || chr(13) ||
						'set	a.vlprodut	= ' || replace(nvl(trim(to_char(r01.vlprodut_tbseg)),'null'),',','.') || chr(13) ||
						'where	a.rowid		= ' || chr(39) || r01.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

		update	crapseg a
		set	a.vlpremio	= vr_vlpretot
		where	a.rowid		= r01.nr_linha_crap;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	crapseg a ' || chr(13) ||
						'set	a.vlpremio	= ' || replace(nvl(trim(to_char(r01.vlpremio_crap)),'null'),',','.') || chr(13) ||
						'where	a.rowid		= ' || chr(39) || r01.nr_linha_crap || chr(39) || ';' || chr(13) || chr(13), false);

		update	crawseg a
		set	a.vlpremio	= vr_vlpretot
		where	a.rowid		= r01.nr_linha_craw;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	crawseg a ' || chr(13) ||
						'set	a.vlpremio	= ' || replace(nvl(trim(to_char(r01.vlpremio_craw)),'null'),',','.') || chr(13) ||
						'where	a.rowid		= ' || chr(39) || r01.nr_linha_craw || chr(39) || ';' || chr(13) || chr(13), false);

	end if;

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