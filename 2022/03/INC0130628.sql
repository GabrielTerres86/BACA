begin

declare

ds_exc_erro_v		exception;
ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);

cd_cooperativa_v	crapcop.cdcooper%type	:= 3;
ds_nome_arquivo_bkp_v	varchar2(100);
ds_nome_diretorio_v	crapprm.dsvlrprm%type;
ds_critica_v		crapcri.dscritic%type;

qt_registro	number(10)	:= 0;
nr_arquivo	number(10)	:= 1;
qt_reg_arquivo	number(10)	:= 50000;

vr_dscritic	VARCHAR2(1000);

cursor	c01 is
select	c.rowid as id_linha,
	b.nrctrseg,
	c.nrctrseg as nrctrseg_tbseg,
	c.dtrecusa,
	c.tprecusa,
	c.cdmotrec,
	c.tpregist
from	tbseg_prestamista c,
	crawseg b,
	crapseg a
where	not exists
	(select	1
	from	tbseg_prestamista x
	where	x.cdcooper	= b.cdcooper
	and	x.nrctremp	= b.nrctrato
	and	x.nrdconta	= b.nrdconta
	and	x.nrctrseg	= b.nrctrseg
	and	x.nrproposta	= b.nrproposta)
and	exists
	(select	1
	from	crapseg y,
		crawseg x
	where	y.CDSITSEG	= 5
	and	trunc(y.DTINIVIG)	= trunc(c.DTINIVIG)
	and	x.CDCOOPER	= y.CDCOOPER
	and	x.NRDCONTA	= y.NRDCONTA
	and	x.NRCTRSEG	= y.NRCTRSEG
	and	x.NRCTRSEG	= c.NRCTRSEG
	and	x.nrctrato	= c.nrctremp
	and	x.NRPROPOSTA	<> c.NRPROPOSTA
	and	x.NRCTRSEG	<> b.NRCTRSEG
	and	x.NRCTRATO	= b.NRCTRATO
	and	x.NRDCONTA	= b.NRDCONTA
	and	x.CDCOOPER	= b.CDCOOPER)
and	c.DTRECUSA	is not null
and	trunc(a.DTINIVIG)	<> trunc(c.DTINIVIG)
and	b.NRCTRSEG	<> c.NRCTRSEG
and	b.nrctrato	= c.nrctremp
and	b.NRPROPOSTA	= c.NRPROPOSTA
and	b.NRDCONTA	= c.NRDCONTA
and	b.CDCOOPER	= c.CDCOOPER
and	a.CDCOOPER	= b.CDCOOPER
and	a.NRDCONTA	= b.NRDCONTA
and	a.NRCTRSEG	= b.NRCTRSEG
and	a.CDSITSEG	= 1;

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	crapcri.dscritic%TYPE) is

ds_critica_v	crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
   
begin

	if	(gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

		ds_critica_p	:= null;

	else

		gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'mkdir ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

		gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'chmod 777 ' || ds_nome_diretorio_p || ' 1> /dev/null',
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

if	(upper(gene0001.fn_database_name) like '%AYLLOSP%') then

	select	max(a.dsvlrprm)
	into	ds_nome_diretorio_v
	from	crapprm a
	where	a.nmsistem	= 'CRED'
	and	a.cdcooper	= cd_cooperativa_v
	and	a.cdacesso	= 'ROOT_MICROS';

	if	(ds_nome_diretorio_v	is null) then

		select	max(a.dsvlrprm)
		into	ds_nome_diretorio_v
		from	crapprm a
		where	a.nmsistem	= 'CRED'
		and	a.cdcooper	= 0
		and	a.cdacesso	= 'ROOT_MICROS';

	end if;

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0130628';

else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0130628';

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
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_INC0130628_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	update	tbseg_prestamista a
	set	a.dtrecusa	= null,
		a.tprecusa	= null,
		a.cdmotrec	= null,
		a.tpregist	= 1,
		a.nrctrseg	= r01.nrctrseg
	where	a.rowid		= r01.id_linha;

	gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	tbseg_prestamista a ' || chr(13) ||
					'set	a.dtrecusa	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtrecusa,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
					'	a.tprecusa	= ' || chr(39) || r01.tprecusa || chr(39) || ', ' || chr(13) ||
					'	a.cdmotrec	= ' || replace(nvl(trim(to_char(r01.cdmotrec)),'null'),',','.') || ', ' || chr(13) ||
					'	a.tpregist	= ' || replace(nvl(trim(to_char(r01.tpregist)),'null'),',','.') || ', ' || chr(13) ||
					'	a.nrctrseg	= ' || replace(nvl(trim(to_char(r01.nrctrseg_tbseg)),'null'),',','.') || chr(13) ||
					'where	a.rowid		= ' || chr(39) || r01.id_linha || chr(39) || ';' || chr(13) || chr(13), false);

	if	(qt_registro	>= 10000) then

		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
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

	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
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