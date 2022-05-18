begin

declare

ds_exc_erro_v		exception;
ds_erro_registro_v	exception;
cd_critica_v		cecred.crapcri.cdcritic%type;
ds_critica_v		cecred.crapcri.dscritic%type;
ds_critica_rollback_v	cecred.crapcri.dscritic%type;
ds_critica_arq_v	cecred.crapcri.dscritic%type;

ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);
nm_arquivo_rollback_v	varchar2(100);

cd_cooperativa_v	cecred.crapcop.cdcooper%type	:= 3;
ds_nome_diretorio_v	cecred.crapprm.dsvlrprm%type;

qt_reg_commit		number(10)	:= 0;
nr_arquivo		number(10)	:= 1;
qt_reg_arquivo		number(10)	:= 50000;

vr_nrctrseg		cecred.crapseg.nrctrseg%type;
vr_flgdps		varchar2(1)		:= 'N';
vr_vlproposta		cecred.crawseg.vlseguro%type;
vr_flgprestamista	varchar2(1)		:= 'N';
vr_dsmotcan		varchar2(60);

vr_dtmvtolt		cecred.crapdat.dtmvtolt%type;

type	typ_reg_ctrl_coop is
	record(	cdcooper	cecred.crapcop.cdcooper%type);  

type	typ_tab_ctrl_coop is
	table of	typ_reg_ctrl_coop
	index by	varchar2(10);

vr_tab_ctrl_coop	typ_tab_ctrl_coop;

cursor	c01 is
select	a.cdcooper,
	a.nrdconta,
	a.nrctremp,
	c.cdagenci,
	c.cdoperad,
	a.dtmvtolt
from	cecred.craptab e,
	cecred.craplcr d,
	cecred.crapseg c,
	cecred.crawseg b,
	cecred.crapepr a
where	(select	sum(x.vlsdeved)
	from	cecred.craplcr y,
		cecred.crapepr x
	where	y.flgsegpr	= 1
	and	x.cdcooper	= y.cdcooper
	and	x.cdlcremp	= y.cdlcremp
	and	x.vlsdeved	<> 0
	and	x.dtliquid	is null
	and	x.nrdconta	= a.nrdconta
	and	x.cdcooper	= a.cdcooper) > to_number(substr(e.dstextab,27,12))
and	a.cdcooper	= e.cdcooper
and	upper(e.nmsistem)	= 'CRED'
and	upper(e.tptabela)	= 'USUARI'
and	e.cdempres		= 11
and	upper(e.cdacesso)	= 'SEGPRESTAM'
and	e.tpregist		= 0
and	not exists
	(select	1
	from	cecred.crawseg y,
		cecred.crapseg x
	where	y.nrctrato	= b.nrctrato
	and	x.nrctrseg	= y.nrctrseg
	and	x.nrdconta	= y.nrdconta
	and	x.cdcooper	= y.cdcooper
	and	x.cdsitseg	= 1
	and	x.nrdconta	= c.nrdconta
	and	x.cdcooper	= c.cdcooper)
and	d.flgsegpr	= 1
and	a.cdcooper	= d.cdcooper
and	a.cdlcremp	= d.cdlcremp
and	c.cdsitseg	= 2
and	b.nrctrseg	= c.nrctrseg
and	b.nrdconta	= c.nrdconta
and	b.cdcooper	= c.cdcooper
and	b.tpcustei	= 1
and	b.tpseguro	= 4
and	a.nrctremp	= b.nrctrato
and	a.nrdconta	= b.nrdconta
and	a.cdcooper	= b.cdcooper
and	a.dtmvtolt	>= to_date('01/01/2022','dd/mm/yyyy')
and	a.inliquid	<> 1
and	a.vlsdeved	<> 0
and	a.dtliquid	is null;

cursor	c02(	pr_nrctrseg	cecred.crapseg.nrctrseg%type,
		pr_nrctremp	cecred.tbseg_prestamista.nrctremp%type,
		pr_cdcooper	cecred.tbseg_prestamista.cdcooper%type,
		pr_nrdconta	cecred.tbseg_prestamista.nrdconta%type,
		pr_dtmvtolt	cecred.crapdat.dtmvtolt%type) is
select	a.rowid as nr_linha_crawseg,
	a.nrproposta,
	a.tpcustei
from	cecred.crawseg a
where	(
		a.nrctrseg = pr_nrctrseg or
		(
			pr_nrctrseg is null and 
			a.dtmvtolt = pr_dtmvtolt and
			not exists
			(select	1
			from	cecred.crapseg x
			where	x.tpseguro	= 4
			and	x.nrctrseg	= a.nrctrseg
			and	x.nrdconta	= a.nrdconta
			and	x.cdcooper	= a.cdcooper)
		)
	)
and	a.nrdconta	= pr_nrdconta
and	a.cdcooper	= pr_cdcooper
and	a.nrctrato	= pr_nrctremp;

cursor	c03(	pr_nrctrseg	cecred.crapseg.nrctrseg%type,
		pr_cdcooper	cecred.tbseg_prestamista.cdcooper%type,
		pr_nrdconta	cecred.tbseg_prestamista.nrdconta%type) is
select	a.rowid nr_linha_crapseg
from	cecred.crapseg a
where	a.tpseguro	= 4
and	a.nrdconta	= pr_nrdconta
and	a.cdcooper	= pr_cdcooper
and	a.nrctrseg	= pr_nrctrseg;

cursor	c04(	pr_nrctrseg	cecred.crapseg.nrctrseg%type,
		pr_nrctremp	cecred.tbseg_prestamista.nrctremp%type,
		pr_cdcooper	cecred.tbseg_prestamista.cdcooper%type,
		pr_nrdconta	cecred.tbseg_prestamista.nrdconta%type) is
select	a.rowid nr_linha_tbseg
from	cecred.tbseg_prestamista a
where	a.nrctrseg	= pr_nrctrseg
and	a.nrdconta	= pr_nrdconta
and	a.cdcooper	= pr_cdcooper
and	a.nrctremp	= pr_nrctremp;

cursor	c05 is
select	a.rowid as nr_linha_crawseg,
	a.tpcustei,
	a.nrdconta,
	a.nrctrato
from	cecred.crawepr f,
	cecred.crapseg d,
	cecred.craplcr c,
	cecred.crapepr b,
	cecred.crawseg a
where	not exists
	(select	1
	from	cecred.crapseg x
	where	x.cdsitseg	<> 2
	and	x.nrctrseg	= a.nrctrseg
	and	x.nrdconta	= a.nrdconta
	and	x.cdcooper	= a.cdcooper)
and	f.CDORIGEM	in (1,5)
and	a.CDCOOPER	= f.CDCOOPER
and	a.NRDCONTA	= f.NRDCONTA
and	a.NRCTRATO	= f.NRCTREMP
and	d.CDSITSEG	= 2
and	d.tpseguro	= 4
and	a.CDCOOPER	= d.CDCOOPER
and	a.NRDCONTA	= d.NRDCONTA
and	a.NRCTRSEG	= d.NRCTRSEG
and	c.TPCUSPR	= 0
and	b.CDCOOPER	= c.CDCOOPER
and	b.CDLCREMP	= c.CDLCREMP
and	b.INLIQUID	<> 1
and	a.NRCTRATO	= b.NRCTREMP
and	a.CDCOOPER	= b.CDCOOPER
and	a.NRDCONTA	= b.NRDCONTA
and	a.tpcustei	= 1
and	a.DTMVTOLT	between to_date('10/05/2022','dd/mm/yyyy') and to_date('12/05/2022 23:59:59','dd/mm/yyyy hh24:mi:ss')
and	a.cdcooper	in (9,13);

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	cecred.crapcri.dscritic%TYPE) is

ds_critica_v	cecred.crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
   
begin

	if	(gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

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

if	(upper(cecred.gene0001.fn_database_name) like '%AYLLOSP%') then

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0130632';

else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0130632';

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
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'LOGS E ROLLBACK ' || chr(13) || chr(13), false);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin ' || chr(13) || chr(13), false);  
		nm_arquivo_rollback_v	:= 'ROLLBACK_INC0130632_' || nr_arquivo || '.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_reg_commit		:= qt_reg_commit + 1;
	qt_reg_arquivo		:= qt_reg_arquivo + 1;

	cd_critica_v		:= null;
	ds_critica_v		:= null;

	vr_nrctrseg		:= null;
	vr_flgdps		:= 'N';
	vr_vlproposta		:= null;
	vr_flgprestamista	:= 'N';
	vr_dsmotcan		:= null;

	cecred.SEGU0003.pc_validar_prestamista(	pr_cdcooper		=> r01.cdcooper,
						pr_nrdconta		=> r01.nrdconta,
						pr_nrctremp		=> r01.nrctremp,
						pr_cdagenci		=> r01.cdagenci,
						pr_nrdcaixa		=> 0,
						pr_cdoperad		=> r01.cdoperad,
						pr_nmdatela		=> 'SEGURO',
						pr_idorigem		=> 1,
						pr_valida_proposta	=> 'N',
						pr_sld_devedor		=> vr_vlproposta,
						pr_flgprestamista	=> vr_flgprestamista,
						pr_flgdps		=> vr_flgdps,
						pr_dsmotcan		=> vr_dsmotcan,
						pr_cdcritic		=> cd_critica_v,
						pr_dscritic		=> ds_critica_v);

	if	(trim(ds_critica_v)	is null) then

		cecred.segu0003.pc_cria_proposta_sp(		pr_cdcooper		=> r01.cdcooper,
							pr_nrdconta		=> r01.nrdconta,
							pr_nrctremp		=> r01.nrctremp,
							pr_cdagenci		=> r01.cdagenci,
							pr_nrdcaixa		=> 0,
							pr_cdoperad		=> r01.cdoperad,
							pr_nmdatela		=> 'SEGURO',
							pr_idorigem		=> 1,
							pr_cdcritic		=> cd_critica_v,
							pr_dscritic		=> ds_critica_v);

		if	(trim(ds_critica_v)	is null) then

			cecred.segu0001.pc_efetiva_proposta_seguro_p(	pr_cdcooper		=> r01.cdcooper,
								pr_nrdconta		=> r01.nrdconta,
								pr_nrctrato		=> r01.nrctremp,
								pr_cdoperad		=> r01.cdoperad,
								pr_cdagenci		=> r01.cdagenci,
								pr_vlslddev		=> vr_vlproposta,
								pr_idimpdps		=> vr_flgdps,
								pr_nrctrseg		=> vr_nrctrseg,
								pr_cdcritic		=> cd_critica_v,
								pr_dscritic		=> ds_critica_v);

			if	(trim(ds_critica_v)	is null) then

				cecred.segu0003.pc_vincula_emp_prest(	pr_cdcooper		=> r01.cdcooper,
								pr_nrdconta		=> r01.nrdconta,
								pr_nrctrseg		=> vr_nrctrseg,
								pr_nrctremp		=> r01.nrctremp,
								pr_cdagenci		=> r01.cdagenci,
								pr_nrdcaixa		=> 0,
								pr_cdoperad		=> r01.cdoperad,
								pr_nmdatela		=> 'SEGURO',
								pr_idorigem		=> 1,
								pr_cdcritic		=> cd_critica_v,
								pr_dscritic		=> ds_critica_v);

				if	(trim(ds_critica_v)	is null) then

					commit;

				end if;

			end if;

		end if;

		select	max(a.dtmvtolt)
		into	vr_dtmvtolt
		from	cecred.crapdat a
		where	a.cdcooper	= r01.cdcooper;

		for	r02 in c02(	pr_nrctrseg	=> vr_nrctrseg,
					pr_nrctremp	=> r01.nrctremp,
					pr_cdcooper	=> r01.cdcooper,
					pr_nrdconta	=> r01.nrdconta,
					pr_dtmvtolt	=> vr_dtmvtolt) loop

			if	(trim(ds_critica_v)	is not null) then

				delete	from cecred.crawseg a
				where	a.rowid	= r02.nr_linha_crawseg;

				update	tbseg_nrproposta a
				set	a.dhseguro	= null
				where	a.nrproposta	= r02.nrproposta
				and	a.tpcustei	= r02.tpcustei;

			else

				update	cecred.crawseg a
				set	a.dtmvtolt	= r01.dtmvtolt,
					a.dtinivig	= r01.dtmvtolt,
					a.dtdebito	= r01.dtmvtolt,
					a.dtiniseg	= r01.dtmvtolt,
					a.dtprideb	= r01.dtmvtolt
				where	a.rowid		= r02.nr_linha_crawseg;

				cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
							ds_texto_rollback_v,
							'delete	from cecred.crawseg a ' || chr(13) ||
							'where	a.rowid	= ' || chr(39) || r02.nr_linha_crawseg || chr(39) || ';' || chr(13) || chr(13), false);

				cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
							ds_texto_rollback_v,
							'update	tbseg_nrproposta a ' || chr(13) ||
							'set	a.dhseguro = null ' || chr(13) ||
							'where	a.tpcustei = ' || replace(nvl(trim(to_char(r02.tpcustei)),'null'),',','.') || chr(13) ||
							'and	a.nrproposta = ' || replace(nvl(trim(to_char(r02.nrproposta)),'null'),',','.') || ';' || chr(13) || chr(13), false);

			end if;

		end loop;

		for	r03 in c03(	pr_nrctrseg	=> vr_nrctrseg,
					pr_cdcooper	=> r01.cdcooper,
					pr_nrdconta	=> r01.nrdconta) loop

			if	(trim(ds_critica_v)	is not null) then

				delete	from cecred.crapseg a
				where	a.rowid	= r03.nr_linha_crapseg;

			else

				update	cecred.crapseg a
				set	a.dtmvtolt	= r01.dtmvtolt,
					a.dtinivig	= r01.dtmvtolt,
					a.dtdebito	= r01.dtmvtolt,
					a.dtiniseg	= r01.dtmvtolt,
					a.dtprideb	= r01.dtmvtolt,
					a.dtultpag	= r01.dtmvtolt,
					a.dtinsori	= r01.dtmvtolt
				where	a.rowid		= r03.nr_linha_crapseg;

				cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
							ds_texto_rollback_v,
							'delete	from cecred.crapseg a ' || chr(13) ||
							'where	a.rowid	= ' || chr(39) || r03.nr_linha_crapseg || chr(39) || ';' || chr(13) || chr(13), false);

			end if;

		end loop;

		for	r04 in c04(	pr_nrctrseg	=> vr_nrctrseg,
					pr_nrctremp	=> r01.nrctremp,
					pr_cdcooper	=> r01.cdcooper,
					pr_nrdconta	=> r01.nrdconta) loop

			if	(trim(ds_critica_v)	is not null) then

				delete	from cecred.tbseg_prestamista a
				where	a.rowid	= r04.nr_linha_tbseg;

			else

				update	cecred.tbseg_prestamista a
				set	a.dtdevend	= r01.dtmvtolt,
					a.dtinivig	= r01.dtmvtolt,
					a.dtrefcob	= r01.dtmvtolt,
					a.dtdenvio	= r01.dtmvtolt
				where	a.rowid		= r04.nr_linha_tbseg;

				cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
							ds_texto_rollback_v,
							'delete	from cecred.tbseg_prestamista a ' || chr(13) ||
							'where	a.rowid	= ' || chr(39) || r04.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

			end if;

		end loop;

		if	(qt_reg_commit	>= 10000) then

			cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

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

	end if;

	if	(trim(ds_critica_v)	is not null) then

		raise	ds_erro_registro_v;

	end if;

	exception
	when	ds_erro_registro_v then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: falha mapeada ao atualizar registro:' || chr(13) ||
					'Conta: ' || r01.nrdconta || chr(13) ||
					'Contrato: ' || r01.nrctremp || chr(13) ||
					'Crítica: ' || ds_critica_v || chr(13) || chr(13), false);

	when	others then

		rollback;

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: erro de sistema ao atualizar registro:' || chr(13) ||
					'Conta: ' || r01.nrdconta || chr(13) ||
					'Contrato: ' || r01.nrctremp || chr(13) ||
					'Erro: ' || sqlerrm || chr(13) || chr(13), false);

		exit;

	end;

end loop;

for	r05 in c05 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'LOGS E ROLLBACK ' || chr(13) || chr(13), false);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin ' || chr(13) || chr(13), false);  
		nm_arquivo_rollback_v	:= 'ROLLBACK_INC0130632_' || nr_arquivo || '.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_reg_commit		:= qt_reg_commit + 1;
	qt_reg_arquivo		:= qt_reg_arquivo + 1;

	update	cecred.crawseg a
	set	a.tpcustei	= 0
	where	a.rowid		= r05.nr_linha_crawseg;

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
				ds_texto_rollback_v,
				'update	crawseg a ' || chr(13) ||
				'set	a.tpcustei = ' || replace(nvl(trim(to_char(r05.tpcustei)),'null'),',','.') || chr(13) ||
				'where	a.rowid = ' || chr(39) || r05.nr_linha_crawseg || chr(39) || ';' || chr(13) || chr(13), false);

	if	(qt_reg_commit	>= 10000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

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
					'LOG: falha mapeada ao atualizar tpcustei:' || chr(13) ||
					'Conta: ' || r05.nrdconta || chr(13) ||
					'Contrato: ' || r05.nrctrato || chr(13) ||
					'Crítica: ' || ds_critica_rollback_v || chr(13) || chr(13), false);
	when	others then

		rollback;

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: erro de sistema ao atualizar tpcustei:' || chr(13) ||
					'Conta: ' || r05.nrdconta || chr(13) ||
					'Contrato: ' || r05.nrctrato || chr(13) ||
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

if	(ds_critica_arq_v	is not null) then

	ds_critica_v	:= ds_critica_arq_v;
	raise	ds_exc_erro_v;

end if;

exception
when	ds_exc_erro_v then

	rollback;
	raise_application_error(-20111, ds_critica_v);

end;

end;