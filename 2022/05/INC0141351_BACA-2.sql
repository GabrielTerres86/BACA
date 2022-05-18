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
select	d.rowid as nr_linha_crap,
	d.cdsitseg,
	d.dtcancel,
	d.dtfimvig,
	a.nrctrato,
	a.cdcooper,
	a.nrdconta,
	a.nrctrseg
from	cecred.crawepr f,
	cecred.crapseg d,
	cecred.craplcr c,
	cecred.crapepr b,
	cecred.crawseg a
where	f.CDORIGEM	in (1,5)
and	a.CDCOOPER	= f.CDCOOPER
and	a.NRDCONTA	= f.NRDCONTA
and	a.NRCTRATO	= f.NRCTREMP
and	d.CDSITSEG	= 1
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

cursor	c02 is
select	a.rowid as nr_linha_craw,
	a.*
from	cecred.crawepr b,
	cecred.crawseg a
where	not exists
	(select	1
	from	cecred.tbseg_prestamista x
	where	x.nrctrseg	= a.nrctrseg
	and	x.nrctremp	= a.nrctrato
	and	x.nrdconta	= a.nrdconta
	and	x.cdcooper	= a.cdcooper)
and	not exists
	(select	1
	from	cecred.crapseg x
	where	x.cdsitseg	= 1
	and	x.tpseguro	= 4
	and	x.nrctrseg	= a.nrctrseg
	and	x.nrdconta	= a.nrdconta
	and	x.cdcooper	= a.cdcooper)
and	a.nrctrato	= b.nrctremp
and	a.nrdconta	= b.nrdconta
and	a.cdcooper	= b.cdcooper
and	a.tpcustei	= 1
and	a.dtmvtolt	between to_date('10/05/2022','dd/mm/yyyy') and to_date('12/05/2022 23:59:59','dd/mm/yyyy hh24:mi:ss')
and	a.cdcooper	in (9,13);

cursor	c03(	cdcooper_p	cecred.tbseg_prestamista.cdcooper%type,
		nrdconta_p	cecred.tbseg_prestamista.nrdconta%type,
		nrctremp_p	cecred.tbseg_prestamista.nrctremp%type,
		nrctrseg_p	cecred.tbseg_prestamista.nrctrseg%type) is
select	a.rowid as nr_linha_tbseg,
	a.tpregist
from	cecred.tbseg_prestamista a
where	a.tpregist	<> 0
and	a.nrctrseg	= nrctrseg_p
and	a.nrctremp	= nrctremp_p
and	a.nrdconta	= nrdconta_p
and	a.cdcooper	= cdcooper_p;

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	crapcri.dscritic%TYPE) is

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0141351/rollback';

else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0141351/rollback';

end if;
 
valida_diretorio_p(	ds_nome_diretorio_p	=> ds_nome_diretorio_v,
			ds_critica_p		=> ds_critica_v);

if	(trim(ds_critica_v) is not null) then

	raise ds_exc_erro_v;

end if;

update	cecred.crapprm p
set	p.DSVLRPRM	= '0'
where	p.cdacesso	like '%TPCUSTEI_PADRAO%'
and	p.NMSISTEM	= 'CRED'
and	p.CDCOOPER	in (9,13);

for	r01 in c01 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0141351-2_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	update	cecred.crapseg a
	set	a.cdsitseg	= 2,
		a.dtcancel	= trunc(sysdate),
		a.dtfimvig	= trunc(sysdate)
	where	a.rowid		= r01.nr_linha_crap;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.crapseg a ' || chr(13) ||
					'set	a.cdsitseg	= ' || replace(nvl(trim(to_char(r01.cdsitseg)),'null'),',','.') || ', ' || chr(13) ||
					'	a.dtcancel	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
					'	a.dtfimvig	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' || chr(13) ||
					'where	a.rowid		= ' || chr(39) || r01.nr_linha_crap || chr(39) || ';' || chr(13) || chr(13), false);

	for	r03 in c03(	cdcooper_p	=> r01.cdcooper,
				nrdconta_p	=> r01.nrdconta,
				nrctremp_p	=> r01.nrctrato,
				nrctrseg_p	=> r01.nrctrseg) loop

		begin

		update	cecred.tbseg_prestamista a
		set	a.tpregist	= 0
		where	a.rowid		= r03.nr_linha_tbseg;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	cecred.tbseg_prestamista a ' || chr(13) ||
						'set	a.tpregist	= ' || replace(nvl(trim(to_char(r03.tpregist)),'null'),',','.') || chr(13) ||
						'where	a.rowid		= ' || chr(39) || r03.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

		exception
		when others then
			vr_dscritic	:= 'Falha ao atualizar tbseg_prestamista';
			rollback;
			exit;
		end;

	end loop;

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

for	r02 in c02 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0141351_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	delete
	from	cecred.crawseg a
	where	a.rowid	= r02.nr_linha_craw;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'insert	into cecred.crawseg ' ||
					'	(dtmvtolt, ' ||
					'	nrdconta, ' ||
					'	nrctrseg, ' ||
					'	tpseguro, ' ||
					'	nmdsegur, ' ||
					'	tpplaseg, ' ||
					'	nmbenefi, ' ||
					'	nrcadast, ' ||
					'	nmdsecao, ' ||
					'	dsendres, ' ||
					'	nrendres, ' ||
					'	nmbairro, ' ||
					'	nmcidade, ' ||
					'	cdufresd, ' ||
					'	nrcepend, ' ||
					'	dtinivig, ' ||
					'	dtfimvig, ' ||
					'	dsmarvei, ' ||
					'	dstipvei, ' ||
					'	nranovei, ' ||
					'	nrmodvei, ' ||
					'	qtpasvei, ' ||
					'	ppdbonus, ' ||
					'	flgdnovo, ' ||
					'	nrapoant, ' ||
					'	nmsegant, ' ||
					'	flgdutil, ' ||
					'	flgnotaf, ' ||
					'	flgapant, ' ||
					'	vlpreseg, ' ||
					'	vlseguro, ' ||
					'	vldfranq, ' ||
					'	vldcasco, ' ||
					'	vlverbae, ' ||
					'	flgassis, ' ||
					'	vldanmat, ' ||
					'	vldanpes, ' ||
					'	vldanmor, ' ||
					'	vlappmor, ' ||
					'	vlappinv, ' ||
					'	cdsegura, ' ||
					'	nmempres, ' ||
					'	dschassi, ' ||
					'	flgrenov, ' ||
					'	dtdebito, ' ||
					'	vlbenefi, ' ||
					'	cdcalcul, ' ||
					'	flgcurso, ' ||
					'	dtiniseg, ' ||
					'	nrdplaca, ' ||
					'	lsctrant, ' ||
					'	nrcpfcgc, ' ||
					'	nrctratu, ' ||
					'	nmcpveic, ' ||
					'	flgunica, ' ||
					'	nrctrato, ' ||
					'	flgvisto, ' ||
					'	cdapoant, ' ||
					'	dtprideb, ' ||
					'	vldifseg, ' ||
					'	dscobext##1, ' ||
					'	dscobext##2, ' ||
					'	dscobext##3, ' ||
					'	dscobext##4, ' ||
					'	dscobext##5, ' ||
					'	vlcobext##1, ' ||
					'	vlcobext##2, ' ||
					'	vlcobext##3, ' ||
					'	vlcobext##4, ' ||
					'	vlcobext##5, ' ||
					'	flgrepgr, ' ||
					'	vlfrqobr, ' ||
					'	tpsegvid, ' ||
					'	dtnascsg, ' ||
					'	cdsexosg, ' ||
					'	vlpremio, ' ||
					'	qtparcel, ' ||
					'	nrfonemp, ' ||
					'	nrfonres, ' ||
					'	dsoutgar, ' ||
					'	vloutgar, ' ||
					'	tpdpagto, ' ||
					'	cdcooper, ' ||
					'	flgconve, ' ||
					'	complend, ' ||
					'	progress_recid, ' ||
					'	nrproposta, ' ||
					'	flggarad, ' ||
					'	flgassum, ' ||
					'	tpcustei, ' ||
					'	tpmodali) ' || chr(13) ||
					'values	(' || 'to_date(' || chr(39) || trim(to_char(r02.dtmvtolt,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.nrdconta)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrctrseg)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpseguro)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmdsegur || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.tpplaseg)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmbenefi || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.nrcadast)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmdsecao || chr(39) || ', ' ||
						chr(39) || r02.dsendres || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.nrendres)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmbairro || chr(39) || ', ' ||
						chr(39) || r02.nmcidade || chr(39) || ', ' ||
						chr(39) || r02.cdufresd || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.nrcepend)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						chr(39) || r02.dsmarvei || chr(39) || ', ' ||
						chr(39) || r02.dstipvei || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.nranovei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrmodvei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.qtpasvei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.ppdbonus)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgdnovo)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrapoant)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmsegant || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.flgdutil)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgnotaf)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgapant)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlpreseg)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlseguro)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vldfranq)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vldcasco)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlverbae)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgassis)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vldanmat)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vldanpes)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vldanmor)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlappmor)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlappinv)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdsegura)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmempres || chr(39) || ', ' ||
						chr(39) || r02.dschassi || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.flgrenov)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtdebito,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.vlbenefi)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdcalcul)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgcurso)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtiniseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						chr(39) || r02.nrdplaca || chr(39) || ', ' ||
						chr(39) || r02.lsctrant || chr(39) || ', ' ||
						chr(39) || r02.nrcpfcgc || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.nrctratu)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmcpveic || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.flgunica)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrctrato)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgvisto)),'null'),',','.') || ', ' ||
						chr(39) || r02.cdapoant || chr(39) || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtprideb,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.vldifseg)),'null'),',','.') || ', ' ||
						chr(39) || r02.dscobext##1 || chr(39) || ', ' ||
						chr(39) || r02.dscobext##2 || chr(39) || ', ' ||
						chr(39) || r02.dscobext##3 || chr(39) || ', ' ||
						chr(39) || r02.dscobext##4 || chr(39) || ', ' ||
						chr(39) || r02.dscobext##5 || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.vlcobext##1)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlcobext##2)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlcobext##3)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlcobext##4)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlcobext##5)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgrepgr)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlfrqobr)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpsegvid)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtnascsg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.cdsexosg)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlpremio)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.qtparcel)),'null'),',','.') || ', ' ||
						chr(39) || r02.nrfonemp || chr(39) || ', ' ||
						chr(39) || r02.nrfonres || chr(39) || ', ' ||
						chr(39) || r02.dsoutgar || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.vloutgar)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpdpagto)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdcooper)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgconve)),'null'),',','.') || ', ' ||
						chr(39) || r02.complend || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.progress_recid)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrproposta)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flggarad)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgassum)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpcustei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpmodali)),'null'),',','.') ||
					');' || chr(13) || chr(13), false);

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