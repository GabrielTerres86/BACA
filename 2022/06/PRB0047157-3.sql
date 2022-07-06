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
	b.cdopecnl,
	c.rowid as nr_linha_tbseg,
	c.nrproposta,
	c.tpregist,
	c.tprecusa,
	c.cdmotrec,
	c.dtrecusa,
	c.situacao
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
	('770629271538',
	'770629268740',
	'770629226273');

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/PRB0047157-3';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/PRB0047157-3';

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
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_PRB0047157-3_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	if	(r01.nrproposta	= '770629226273') then

		update	cecred.tbseg_prestamista a
		set	a.tpregist	= 0,
			a.tprecusa	= '01062022',
			a.cdmotrec	= 1062,
			a.dtrecusa	= sysdate,
			a.situacao	= 0
		where	a.rowid		= r01.nr_linha_tbseg;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	cecred.tbseg_prestamista a ' || chr(13) ||
						'set	a.tpregist	= ' || nvl(trim(to_char(r01.tpregist)),'null') || ', ' || chr(13) ||
						'	a.tprecusa	= ' || chr(39) || r01.tprecusa || chr(39) || ', ' || chr(13) ||
						'	a.cdmotrec	= ' || nvl(trim(to_char(r01.cdmotrec)),'null') || ', ' || chr(13) ||
						'	a.dtrecusa	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtrecusa,'dd/mm/yyyy hh24:mi:ss')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy hh24:mi:ss' || chr(39) || '), ' || chr(13) ||
						'	a.situacao	= ' || nvl(trim(to_char(r01.situacao)),'null') || chr(13) ||
						'where	a.rowid		= ' || chr(39) || r01.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

	end if;

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