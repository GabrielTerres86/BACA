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
	select w.rowid  nr_linha_craw,
		   w.*
	  from cecred.crapseg p,
		   cecred.crawseg w
	 where p.cdcooper = w.cdcooper
	   and p.nrdconta = w.nrdconta
	   and p.nrctrseg = w.nrctrseg
	   and w.cdcooper = 1 
	   and w.nrdconta = 935069 
	   and w.cdsegura = 5011 
	   and p.cdsitseg <> 1;
	   
cursor	c02 is
	select p.rowid  nr_linha_crap,
		   p.*
	  from cecred.crapseg p
	 where p.cdcooper = 1 
	   and p.nrdconta = 935069 
	   and p.cdsegura = 5011 
	   and p.cdsitseg <> 1;	   


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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0135928/rollback';

else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0135928/rollback';

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
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0135928_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	delete
	from	cecred.crawseg a
	where	a.rowid	= r01.nr_linha_craw;

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
					'values	(' || 'to_date(' || chr(39) || trim(to_char(r01.dtmvtolt,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r01.nrdconta)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.nrctrseg)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.tpseguro)),'null'),',','.') || ', ' ||
						chr(39) || r01.nmdsegur || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.tpplaseg)),'null'),',','.') || ', ' ||
						chr(39) || r01.nmbenefi || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.nrcadast)),'null'),',','.') || ', ' ||
						chr(39) || r01.nmdsecao || chr(39) || ', ' ||
						chr(39) || r01.dsendres || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.nrendres)),'null'),',','.') || ', ' ||
						chr(39) || r01.nmbairro || chr(39) || ', ' ||
						chr(39) || r01.nmcidade || chr(39) || ', ' ||
						chr(39) || r01.cdufresd || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.nrcepend)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r01.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'to_date(' || chr(39) || trim(to_char(r01.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						chr(39) || r01.dsmarvei || chr(39) || ', ' ||
						chr(39) || r01.dstipvei || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.nranovei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.nrmodvei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.qtpasvei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.ppdbonus)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgdnovo)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.nrapoant)),'null'),',','.') || ', ' ||
						chr(39) || r01.nmsegant || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.flgdutil)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgnotaf)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgapant)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlpreseg)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlseguro)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vldfranq)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vldcasco)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlverbae)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgassis)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vldanmat)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vldanpes)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vldanmor)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlappmor)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlappinv)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.cdsegura)),'null'),',','.') || ', ' ||
						chr(39) || r01.nmempres || chr(39) || ', ' ||
						chr(39) || r01.dschassi || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.flgrenov)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r01.dtdebito,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r01.vlbenefi)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.cdcalcul)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgcurso)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r01.dtiniseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						chr(39) || r01.nrdplaca || chr(39) || ', ' ||
						chr(39) || r01.lsctrant || chr(39) || ', ' ||
						chr(39) || r01.nrcpfcgc || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.nrctratu)),'null'),',','.') || ', ' ||
						chr(39) || r01.nmcpveic || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.flgunica)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.nrctrato)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgvisto)),'null'),',','.') || ', ' ||
						chr(39) || r01.cdapoant || chr(39) || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r01.dtprideb,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r01.vldifseg)),'null'),',','.') || ', ' ||
						chr(39) || r01.dscobext##1 || chr(39) || ', ' ||
						chr(39) || r01.dscobext##2 || chr(39) || ', ' ||
						chr(39) || r01.dscobext##3 || chr(39) || ', ' ||
						chr(39) || r01.dscobext##4 || chr(39) || ', ' ||
						chr(39) || r01.dscobext##5 || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.vlcobext##1)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlcobext##2)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlcobext##3)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlcobext##4)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlcobext##5)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgrepgr)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlfrqobr)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.tpsegvid)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r01.dtnascsg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r01.cdsexosg)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.vlpremio)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.qtparcel)),'null'),',','.') || ', ' ||
						chr(39) || r01.nrfonemp || chr(39) || ', ' ||
						chr(39) || r01.nrfonres || chr(39) || ', ' ||
						chr(39) || r01.dsoutgar || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.vloutgar)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.tpdpagto)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.cdcooper)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgconve)),'null'),',','.') || ', ' ||
						chr(39) || r01.complend || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r01.progress_recid)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.nrproposta)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flggarad)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.flgassum)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.tpcustei)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r01.tpmodali)),'null'),',','.') ||
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

for	r02 in c02 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0135928_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	delete
	from	cecred.crapseg p
	where	p.rowid	= r02.nr_linha_crap;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'insert into cecred.crapseg(nrdconta, ' ||
                    '	nrctrseg, ' ||
                    '	dtinivig, ' ||
                    '	dtfimvig, ' ||
                    '	dtmvtolt, ' || 
                    '	cdagenci, ' ||
                    '	cdbccxlt, ' ||
                    '	cdsitseg, ' ||
                    '	dtaltseg, ' ||
                    '	dtcancel, ' ||
                    '	dtdebito, ' ||
                    '	dtiniseg, ' ||
                    '	indebito, ' ||
                    '	nrdolote, ' ||
                    '	nrseqdig, ' ||
                    '	qtprepag, ' ||
                    '	vlprepag, ' ||
                    '	vlpreseg, ' ||
                    '	dtultpag, ' ||
                    '	tpseguro, ' ||
                    '	tpplaseg, ' ||
                    '	qtprevig, ' ||
                    '	cdsegura, ' ||
                    '	lsctrant, ' ||
                    '	nrctratu, ' ||
                    '	flgunica, ' ||
                    '	dtprideb, ' ||
                    '	vldifseg, ' ||
                    '	nmbenvid##1, ' ||
                    '	nmbenvid##2, ' ||
                    '	nmbenvid##3, ' ||
                    '	nmbenvid##4, ' ||
                    '	nmbenvid##5, ' ||
                    '	dsgraupr##1, ' ||
                    '	dsgraupr##2, ' ||
                    '	dsgraupr##3, ' ||
                    '	dsgraupr##4, ' ||
                    '	dsgraupr##5, ' ||
                    '	txpartic##1, ' ||
                    '	txpartic##2, ' ||
                    '	txpartic##3, ' ||
                    '	txpartic##4, ' ||
                    '	txpartic##5, ' ||
                    '	dtultalt, ' ||
                    '	cdoperad, ' ||
                    '	vlpremio, ' ||
                    '	qtparcel, ' ||
                    '	tpdpagto, ' ||
                    '	cdcooper, ' ||
                    '	flgconve, ' ||
                    '	flgclabe, ' ||
                    '	cdmotcan, ' ||
                    '	tpendcor, ' ||
                    '	progress_recid, ' ||
                    '	cdopecnl, ' ||
                    '	dtrenova, ' ||
                    '	cdopeori, ' ||
                    '	cdageori, ' ||
                    '	dtinsori, ' ||
                    '	cdopeexc, ' ||
                    '	cdageexc, ' ||
                    '	dtinsexc, ' ||
                    '	vlslddev, ' ||
                    '	idimpdps)' || chr(13) ||
					'values	(' || replace(nvl(trim(to_char(r02.nrdconta)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrctrseg)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtmvtolt,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.cdagenci)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdbccxlt)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdsitseg)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtaltseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtdebito,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtiniseg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.indebito)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrdolote)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.nrseqdig)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.qtprepag)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlprepag)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.vlpreseg)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtultpag,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.tpseguro)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpplaseg)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.qtprevig)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdsegura)),'null'),',','.') || ', ' ||
						chr(39) || r02.lsctrant || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.nrctratu)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgunica)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtprideb,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.vldifseg)),'null'),',','.') || ', ' ||
						chr(39) || r02.nmbenvid##1 || chr(39) || ', ' ||
						chr(39) || r02.nmbenvid##2 || chr(39) || ', ' ||
						chr(39) || r02.nmbenvid##3 || chr(39) || ', ' ||
						chr(39) || r02.nmbenvid##4 || chr(39) || ', ' ||
						chr(39) || r02.nmbenvid##5 || chr(39) || ', ' ||
						chr(39) || r02.dsgraupr##1 || chr(39) || ', ' ||
						chr(39) || r02.dsgraupr##2 || chr(39) || ', ' ||
						chr(39) || r02.dsgraupr##3 || chr(39) || ', ' ||
						chr(39) || r02.dsgraupr##4 || chr(39) || ', ' ||
						chr(39) || r02.dsgraupr##5 || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.txpartic##1)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.txpartic##2)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.txpartic##3)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.txpartic##4)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.txpartic##5)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtultalt,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						chr(39) || r02.cdoperad || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.vlpremio)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.qtparcel)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpdpagto)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdcooper)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgconve)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.flgclabe)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.cdmotcan)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.tpendcor)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.progress_recid)),'null'),',','.') || ', ' ||
						chr(39) || r02.cdopecnl || chr(39) || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtrenova,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						chr(39) || r02.cdopeori || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.cdageori)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtinsori,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						chr(39) || r02.cdopeexc || chr(39) || ', ' ||
						replace(nvl(trim(to_char(r02.cdageexc)),'null'),',','.') || ', ' ||
						'to_date(' || chr(39) || trim(to_char(r02.dtinsexc,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						replace(nvl(trim(to_char(r02.vlslddev)),'null'),',','.') || ', ' ||
						replace(nvl(trim(to_char(r02.idimpdps)),'null'),',','.') ||
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