begin

declare

vr_nmarqmov			varchar2(200) := '%IS_0495_9650_%';
vr_listadir			varchar2(4000);
vr_diretorio			varchar2(200);
vr_tab_nmarqtel			gene0002.typ_split;
vr_arqhandle			utl_file.file_type; 
vr_dslinharq			varchar2(4000);

vr_cdcritic			crapcri.cdcritic%type;
vr_dscritic			varchar2(4000) := '';
vr_exc_sem_arq			exception;
vr_exc_saida			exception;

ds_dados_rollback_v		clob			:= null;
ds_texto_rollback_v		varchar2(32600);
ds_nome_arquivo_bkp_v		varchar2(100);
qt_registro_v			number(10)		:= 0;

ds_rowid_proposta_v		rowid;

type vr_tab_tbseg_nrproposta	is table of tbseg_nrproposta%ROWTYPE INDEX BY BINARY_INTEGER;
typ_tab_tbseg_nrproposta	vr_tab_tbseg_nrproposta;
vr_id_nrproposta		number := 0; 

cursor	cr_tbseg_nrproposta(pr_nrproposta	tbseg_nrproposta.nrproposta%type) is
select	1
from	tbseg_nrproposta
where	nrproposta	= pr_nrproposta;

rw_tbseg_nrproposta		cr_tbseg_nrproposta%ROWTYPE;

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	crapcri.dscritic%TYPE) is

ds_critica_v	crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
ds_exc_erro_v	exception;
   
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
		into	vr_diretorio
		from	crapprm a
		where	a.nmsistem	= 'CRED'
		and	a.cdcooper	= 3
		and	a.cdacesso	= 'ROOT_MICROS';

		if	(vr_diretorio	is null) then

			select	max(a.dsvlrprm)
			into	vr_diretorio
			from	crapprm a
			where	a.nmsistem	= 'CRED'
			and	a.cdcooper	= 0
			and	a.cdacesso	= 'ROOT_MICROS';

		end if;

		vr_diretorio	:= vr_diretorio || 'cpd/bacas/INC0141351';

	else

		vr_diretorio	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

		vr_diretorio	:= vr_diretorio || '/INC0141351';

	end if;

	valida_diretorio_p(	ds_nome_diretorio_p	=> vr_diretorio,
				ds_critica_p		=> vr_dscritic);

	if	(trim(vr_dscritic) is not null) then

		raise vr_exc_saida;

	end if;

	gene0001.pc_lista_arquivos(	pr_path		=> vr_diretorio,
					pr_pesq		=> vr_nmarqmov,
					pr_listarq	=> vr_listadir,
					pr_des_erro	=> vr_dscritic);

	if	(vr_dscritic	is not null) then

		raise	vr_exc_saida;

	end if;

	vr_tab_nmarqtel	:= gene0002.fn_quebra_string(pr_string => vr_listadir);

	if	(vr_tab_nmarqtel.count	<= 0) then

		vr_cdcritic	:= 182;
		vr_dscritic	:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
				' - caminho:'	|| vr_diretorio ||
				', nome:'	|| vr_nmarqmov;
		raise	vr_exc_sem_arq;

	end if;

	for	idx in 1..vr_tab_nmarqtel.count loop

		vr_nmarqmov	:= vr_tab_nmarqtel(idx);
		gene0001.pc_abre_arquivo(	pr_nmdireto	=> vr_diretorio||'/',
						pr_nmarquiv	=> vr_nmarqmov,
						pr_tipabert	=> 'R',
						pr_utlfileh	=> vr_arqhandle,
						pr_des_erro	=> vr_dscritic);

		if	(vr_dscritic	is not null) then

			vr_dscritic	:= 'Erro na abertura do arquivo -> ' || vr_diretorio||'/'||vr_nmarqmov|| ' -> ' ||vr_dscritic;
			raise	vr_exc_saida;

		end if;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_INC0141351_' || idx || '.sql';

		loop

		begin

			vr_cdcritic	:= 0;
          
			begin

				gene0001.pc_le_linha_arquivo(	pr_utlfileh	=> vr_arqhandle,
								pr_des_text	=> vr_dslinharq);

			exception
			when others then

				vr_dslinharq := '';

			end;

			if	(nvl(trim(vr_dslinharq),' ')	= ' ') then

				exit;

			end if;

			vr_id_nrproposta	:= typ_tab_tbseg_nrproposta.count + 1;
			typ_tab_tbseg_nrproposta(vr_id_nrproposta).nrproposta	:= TRIM(SUBSTR(vr_dslinharq,1,12));

			continue;

		exception
		when	vr_exc_saida then

			if	(vr_cdcritic > 0) and (vr_dscritic is null) then

				vr_dscritic	:= gene0001.fn_busca_critica(vr_cdcritic);

			end if;

		end;

		end loop;

		gene0001.pc_fecha_arquivo(vr_arqhandle);

		if	(vr_id_nrproposta > 0) and (vr_dscritic is null) then

			for	vr_ind in typ_tab_tbseg_nrproposta.first .. typ_tab_tbseg_nrproposta.last loop

				open	cr_tbseg_nrproposta(typ_tab_tbseg_nrproposta(vr_ind).nrproposta);
				fetch	cr_tbseg_nrproposta
				into	rw_tbseg_nrproposta;

				if	(cr_tbseg_nrproposta%notfound) then

					begin

						insert	into tbseg_nrproposta(nrproposta, tpcustei, dhseguro)
						values	(typ_tab_tbseg_nrproposta(vr_ind).nrproposta, 1, null)
						returning rowid into ds_rowid_proposta_v;

						gene0002.pc_escreve_xml(	ds_dados_rollback_v,
										ds_texto_rollback_v,
										'delete	from tbseg_nrproposta a where a.rowid = ' || chr(39) || ds_rowid_proposta_v || chr(39) || ';' || chr(13), false);

						qt_registro_v	:= nvl(qt_registro_v,0) + 1;

						if	(qt_registro_v	>= 10000) then

							commit;

							gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13) || 'commit;' || chr(13) || chr(13), FALSE);

							qt_registro_v	:= 0;

						end if;

						typ_tab_tbseg_nrproposta.delete(vr_ind);

					exception
					when	others then

						vr_dscritic	:= ' Ao inserir na tbseg_nrproposta -> '|| SQLERRM;
						close		cr_tbseg_nrproposta;
						raise		vr_exc_saida;

					end;

				end if;

				close	cr_tbseg_nrproposta;

			end loop;

		end if;

		if	(nvl(qt_registro_v,0)	<> 0) then

			commit;

			gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13) || 'commit;' || chr(13) || chr(13), FALSE);

		end if;

		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> 3,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> vr_diretorio || '/rollback/' || ds_nome_arquivo_bkp_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> vr_dscritic);

		if	(trim(vr_dscritic) is not null) then

			raise	vr_exc_saida;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end loop;
	commit;

exception
when	vr_exc_saida then

	dbms_output.put_line('Erro '||vr_dscritic);
	rollback;

when	others then

	dbms_output.put_line('Erro Geral: '||sqlerrm);
	rollback;

end;

end;