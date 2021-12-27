/* BACA para excluir registros do processamento CEXT e reprocessar arquivo */
/* Se não for encontrado o arquivo de Rollback no diretório especificado, pode-se resgatar o script retornado no campo DSXMLDAD dessa query:

	select	a.dsxmldad
	from	crapslr a
	where	a.dsarqsai	like '%INC0118907%'
	and	a.dtsolici	=
		(select	max(x.dtsolici)
		from	crapslr x
		where	x.dsarqsai like '%INC0118907%');

*/

begin

declare

ds_exc_erro_v		exception;						/* Para validar o diretório do rollback dinâmico */
ds_dados_rollback_v	clob			:= null;			/* Para gravar rollback dinâmico */
ds_texto_rollback_v	varchar2(32600);					/* Para gravar rollback dinâmico */

cd_cooperativa_v	crapcop.cdcooper%type	:= 3;
ds_nome_arquivo_bkp_v	varchar2(100);
ds_nome_diretorio_v	crapprm.dsvlrprm%type;
ds_critica_v		crapcri.dscritic%type;

/* Todas as linhas do arquivo */
cursor	c02 is
select	a.rowid, a.*
from	tbgen_batch_relatorio_wrk a
where	a.dsrelatorio	in ('DADOS_ARQ','CTRL_ARQ')
and	a.cdprograma	= 'CRPS670'
and	a.cdcooper	= 3
and	a.dschave	= 'CEXT_7562011_20211220_0001834.CCB'
and	a.dtmvtolt	= to_date('22/12/2021','dd/mm/yyyy');

/* Somente registros que ainda não geraram lançamento na craplcm */
    cursor c03 is
      select x.rowid, x.*
      from crapdcb x
      where x.nrseqarq = 1834
        and x.rowid not in (with registros_cext as
							  (select nvl(trim(substr(a.dscritic, 165, 6)), 0) cd_agencia,
									  to_number(substr(a.dscritic, 171, 12)) nrdconta,
									  (nvl(trim(substr(a.dscritic, 55, 11)), 0) / 100) vl_lancto,
									  nvl(trim(substr(a.dscritic, 198, 6)), 0) nrnsucap,
									  1834 nrseqarq,
									  100 cdbccxlt,
									  6902 nrdolote,
									  to_date('21/12/2021', 'dd/mm/yyyy') dt_movto,
									  trim(substr(a.dscritic, 7, 19)) cdpesqbb,
									  case
										when nvl(trim(substr(a.dscritic, 198, 6)), 0) = 0 then
										  to_number(trim(trim(substr(a.dscritic, 254, 4))) ||
													trim(to_char(trim(substr(a.dscritic, 77, 6)), '000000')) ||
													trim(to_char(trim(substr(a.dscritic, 204, 10)))))
										else
										  to_number(trim(trim(substr(a.dscritic, 254, 4))) ||
													trim(to_char(trim(substr(a.dscritic, 198, 6)), '000000')) ||
													trim(to_char(trim(substr(a.dscritic, 204, 10)))))
									  end nrdocmto
							   from tbgen_batch_relatorio_wrk a
							   where a.dsrelatorio in ('DADOS_ARQ')
							     and a.cdprograma = 'CRPS670'
								 and a.cdcooper = 3
								 and a.dschave = 'CEXT_7562011_20211220_0001834.CCB'
								 and a.dtmvtolt = to_date('22/12/2021', 'dd/mm/yyyy')
								 and a.nrdconta > 2)
						    select dcb.rowid
							from crapdcb dcb,
								 crapcop c,
								 registros_cext cext,
								 craplcm lcm,
								 craphis his
							where cext.cd_agencia = c.cdagebcb
							  -- and cext.cd_agencia = dcb.cdagenci
							  and dcb.cdcooper = c.cdcooper 
							  and cext.vl_lancto = dcb.vldtrans 
							  and cext.nrdconta = dcb.nrdconta 
							  and cext.nrnsucap = dcb.nrnsucap 
							  and cext.nrseqarq = dcb.nrseqarq 
							  and lcm.cdcooper = c.cdcooper 
							  and his.cdcooper = lcm.cdcooper 
							  and his.cdhistor = lcm.cdhistor 
							  and lcm.nrdconta = cext.nrdconta 
							  and cext.vl_lancto = lcm.vllanmto 
							  and nvl(cext.nrdocmto, -1) = nvl(lcm.nrdocmto, -1) 
							  and cext.nrdolote = lcm.nrdolote 
							  and cext.cdbccxlt = lcm.cdbccxlt 
							  and nvl(cext.cdpesqbb, 'X') = nvl(lcm.cdpesqbb, 'X') 
							  and cext.dt_movto = lcm.dtmvtolt);

qt_registro	number(10);
vr_dscritic	VARCHAR2(1000);
nr_arquivo	number(10);
qt_reg_arquivo	number(10);

/* Valida se o diretório do rollback existe ou se pode ser criado */
procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	crapcri.dscritic%TYPE) is

ds_critica_v	crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
   
begin

	/* Verificar se o diretório existe */
	if	(gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

		ds_critica_p	:= null;

	else

		/* Se o diretório não foi encontrado, vamos criá-lo */
		gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'mkdir ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		/* Tratar um eventual erro na criação do diretório */
		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

		/* Conceder permissão total no novo diretório criado, para que o usuário executor da rotina consiga criar o arquivo de rollback dinâmico */
		gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'chmod 777 ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		/* Tratar um eventual erro na concessão das permissões */
		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

	end if;

exception
when	ds_exc_erro_v then

        ds_critica_p	:= ds_critica_v;

end valida_diretorio_p;

begin

/* Diretório de Produção: /micros/cpd/bacas/INC0118907 */
if	(gene0001.fn_database_name like '%AYLLOSP%') then

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0118907';

/* Diretório de Homologação: /progress/f0033552/usr/coop/cecred/INC0118907 */
else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0118907';

end if;
 
/* Validar diretório de rollback e criar pasta do incidente */
valida_diretorio_p(	ds_nome_diretorio_p	=> ds_nome_diretorio_v,
			ds_critica_p		=> ds_critica_v);

/* Tratar eventual erro no diretório */
if	(trim(ds_critica_v) is not null) then

	raise ds_exc_erro_v;

end if;

delete	from crapccb a
where	a.nrseqarq = 1834;

qt_reg_arquivo	:= 50000;
qt_registro	:= 0;
nr_arquivo	:= 1;

/* Excluir crapdcb */
for	r03 in c03 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		/* Inicializa as variáveis de rollback */
		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, '-- Programa para rollback das informacoes INC0118907'||chr(13), false);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_INC0118907_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

        delete	from crapdcb a
        where	a.rowid = r03.rowid;
      
        gene0002.pc_escreve_xml(ds_dados_rollback_v,
                                ds_texto_rollback_v,
                                'insert into crapdcb(tpmensag, nrnsucap, dtdtrgmt, hrdtrgmt, cdcooper, nrdconta, nrseqarq, nrinstit, cdprodut, nrcrcard, tpdtrans, cddtrans, cdhistor, dtdtrans, dtpostag, dtcnvvlr, vldtrans, vldtruss, cdautori, ' ||
													 'dsdtrans, cdcatest, cddmoeda, vlmoeori, cddreftr, cdagenci, nridvisa, cdtrresp, incoopon, txcnvuss, cdautban, idtrterm, tpautori, cdproces, dstrorig, cdresori, progress_recid, nrnsuori, dtmvtolt) ' ||
                                'values (' || chr(39) || r03.tpmensag || chr(39) || ', ' ||
										   nvl(trim(to_char(r03.nrnsucap)), 'null') || ', ' ||
										   'to_date(' || chr(39) || trim(to_char(r03.dtdtrgmt, 'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
										   nvl(trim(to_char(r03.hrdtrgmt)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.cdcooper)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.nrdconta)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.nrseqarq)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.nrinstit)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.cdprodut)), 'null') || ', ' ||
										   chr(39) || r03.nrcrcard || chr(39) || ', ' ||
										   chr(39) || r03.tpdtrans || chr(39) || ', ' ||
										   nvl(trim(to_char(r03.cddtrans)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.cdhistor)), 'null') || ', ' ||
										   'to_date(' || chr(39) || trim(to_char(r03.dtdtrans, 'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
										   'to_date(' || chr(39) || trim(to_char(r03.dtpostag, 'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
										   'to_date(' || chr(39) || trim(to_char(r03.dtcnvvlr, 'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
										   nvl(trim(to_char(r03.vldtrans)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.vldtruss)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.cdautori)), 'null') || ', ' ||
										   chr(39) || r03.dsdtrans || chr(39) || ', ' ||
										   nvl(trim(to_char(r03.cdcatest)), 'null') || ', ' ||
										   chr(39) || r03.cddmoeda || chr(39) || ', ' ||
										   nvl(trim(to_char(r03.vlmoeori)), 'null') || ', ' ||
										   chr(39) || r03.cddreftr || chr(39) || ', ' ||
										   nvl(trim(to_char(r03.cdagenci)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.nridvisa)), 'null') || ', ' ||
										   chr(39) || r03.cdtrresp || chr(39) || ', ' ||
										   nvl(trim(to_char(r03.incoopon)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.txcnvuss)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.cdautban)), 'null') || ', ' ||
										   chr(39) || r03.idtrterm || chr(39) || ', ' ||
										   chr(39) || r03.tpautori || chr(39) || ', ' ||
										   chr(39) || r03.cdproces || chr(39) || ', ' ||
										   chr(39) || r03.dstrorig || chr(39) || ', ' ||
										   chr(39) || r03.cdresori || chr(39) || ', ' ||
										   nvl(trim(to_char(r03.progress_recid)), 'null') || ', ' ||
										   nvl(trim(to_char(r03.nrnsuori)), 'null') || ', ' ||
										   'to_date(' || chr(39) || trim(to_char(r03.dtmvtolt, 'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || '); ' || chr(13) || chr(13),
										   false);

	if	(qt_registro	>= 10000) then

		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;'||chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		/* Concluindo script de rollback */
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		/* Gravar o arquivo de rollback */
		gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,					/* Cooperativa conectada */
							pr_cdprogra	=> 'ATENDA',						/* Programa chamador - utilizamos apenas um existente */
							pr_dtmvtolt	=> trunc(sysdate),					/* Data do movimento atual */
							pr_dsxml	=> ds_dados_rollback_v,					/* Arquivo XML de dados */
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,	/* Path/Nome do arquivo gerado */
							pr_flg_impri	=> 'N',							/* Chamar a impressão (Imprim.p) */
							pr_flg_gerar	=> 'S',							/* Gerar o arquivo na hora */
							pr_flgremarq	=> 'N',							/* Remover arquivo apos geracao */
							pr_nrcopias	=> 1,							/* Número de cópias para impressão */
							pr_des_erro	=> ds_critica_v);					/* Retorno de erro */

		/* Tratar eventual erro ao criar arquivo de rollback */
		if	(trim(ds_critica_v) is not null) then

			rollback;
			raise	ds_exc_erro_v;

		end if;

		/* Liberando a memória alocada para o clob */
		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when others then
		vr_dscritic	:= 'Falha ao excluir crapdcb ' || r03.rowid;
		rollback;
		exit;
	end;

end loop;

/* Excluir linhas do arquivo e header */
for	r02 in c02 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		/* Inicializa as variáveis de rollback */
		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, '-- Programa para rollback das informacoes INC0118907'||chr(13), false);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK_INC0118907_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	delete	from tbgen_batch_relatorio_wrk a
	where	a.rowid	= r02.rowid;

	gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'delete from tbgen_batch_relatorio_wrk a ' ||
					'where a.cdcooper = ' || nvl(trim(to_char(r02.cdcooper)),'null') ||
					' and a.cdprograma = ' || chr(39) || r02.cdprograma || chr(39) ||
					' and a.dsrelatorio = ' || chr(39) || r02.dsrelatorio || chr(39) ||
					' and a.dtmvtolt = to_date(' || chr(39) || trim(to_char(sysdate,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' ||
					' and a.cdagenci = ' || nvl(trim(to_char(r02.cdagenci)),'null') ||
					' and a.nrdconta = ' || nvl(trim(to_char(r02.nrdconta)),'null') ||
					' and a.dschave = ' || chr(39) || 'CEXT_7562011_20211220_0001834.CCB' || chr(39) || '; ' || chr(13) || chr(13), false);

	gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'insert	into tbgen_batch_relatorio_wrk (cdcooper, cdprograma, dsrelatorio, dtmvtolt, cdagenci, dschave, nrdconta, nrcnvcob, ' ||
					'nrdocmto, nrctremp, dsdoccop, tpparcel, dtvencto, vltitulo, vldpagto, dscritic, dsxml, vlacumul) ' ||
					'values (' ||	nvl(trim(to_char(r02.cdcooper)),'null') || ', ' ||
							chr(39) || r02.cdprograma || chr(39) || ', ' ||
							chr(39) || r02.dsrelatorio || chr(39) || ', ' ||
							'to_date(' || chr(39) || trim(to_char(r02.dtmvtolt,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
							nvl(trim(to_char(r02.cdagenci)),'null') || ', ' ||
							chr(39) || r02.dschave || chr(39) || ', ' ||
							nvl(trim(to_char(r02.nrdconta)),'null') || ', ' ||
							nvl(trim(to_char(r02.nrcnvcob)),'null') || ', ' ||
							nvl(trim(to_char(r02.nrdocmto)),'null') || ', ' ||
							nvl(trim(to_char(r02.nrctremp)),'null') || ', ' ||
							chr(39) || r02.dsdoccop || chr(39) || ', ' ||
							nvl(trim(to_char(r02.tpparcel)),'null') || ', ' ||
							'to_date(' || chr(39) || trim(to_char(r02.dtvencto,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
							replace(trim(to_char(nvl(trim(to_char(r02.vltitulo)),'null'))),',','.') || ', ' ||
							replace(trim(to_char(nvl(trim(to_char(r02.vldpagto)),'null'))),',','.') || ', ' ||
							chr(39) || r02.dscritic || chr(39) || ', null, ' ||
							replace(trim(to_char(nvl(trim(to_char(r02.vlacumul)),'null'))),',','.') || '); ' || chr(13) || chr(13), false);

	if	(qt_registro	>= 10000) then

		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;'||chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		/* Concluindo script de rollback */
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		/* Gravar o arquivo de rollback */
		gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,					/* Cooperativa conectada */
							pr_cdprogra	=> 'ATENDA',						/* Programa chamador - utilizamos apenas um existente */
							pr_dtmvtolt	=> trunc(sysdate),					/* Data do movimento atual */
							pr_dsxml	=> ds_dados_rollback_v,					/* Arquivo XML de dados */
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,	/* Path/Nome do arquivo gerado */
							pr_flg_impri	=> 'N',							/* Chamar a impressão (Imprim.p) */
							pr_flg_gerar	=> 'S',							/* Gerar o arquivo na hora */
							pr_flgremarq	=> 'N',							/* Remover arquivo apos geracao */
							pr_nrcopias	=> 1,							/* Número de cópias para impressão */
							pr_des_erro	=> ds_critica_v);					/* Retorno de erro */

		/* Tratar eventual erro ao criar arquivo de rollback */
		if	(trim(ds_critica_v) is not null) then

			rollback;
			raise	ds_exc_erro_v;

		end if;

		/* Liberando a memória alocada para o clob */
		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when others then
		vr_dscritic	:= 'Falha ao excluir tbgen_batch_relatorio_wrk ' || r02.rowid;
		rollback;
		exit;
	end;

end loop;

if	(qt_reg_arquivo	<> 50000) then

	/* Concluindo script de rollback */
	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;'||chr(13), FALSE);
	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	/* Gravar o arquivo de rollback */
	gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,					/* Cooperativa conectada */
						pr_cdprogra	=> 'ATENDA',						/* Programa chamador - utilizamos apenas um existente */
						pr_dtmvtolt	=> trunc(sysdate),					/* Data do movimento atual */
						pr_dsxml	=> ds_dados_rollback_v,					/* Arquivo XML de dados */
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,	/* Path/Nome do arquivo gerado */
						pr_flg_impri	=> 'N',							/* Chamar a impressão (Imprim.p) */
						pr_flg_gerar	=> 'S',							/* Gerar o arquivo na hora */
						pr_flgremarq	=> 'N',							/* Remover arquivo apos geracao */
						pr_nrcopias	=> 1,							/* Número de cópias para impressão */
						pr_des_erro	=> ds_critica_v);					/* Retorno de erro */

	/* Tratar eventual erro ao criar arquivo de rollback */
	if	(trim(ds_critica_v) is not null) then

		raise	ds_exc_erro_v;

	end if;

	/* Liberando a memória alocada para o clob */
	dbms_lob.close(ds_dados_rollback_v);
	dbms_lob.freetemporary(ds_dados_rollback_v);

end if;

if	(trim(vr_dscritic) is not null) then

	ds_critica_v	:= vr_dscritic;
	raise	ds_exc_erro_v;

end if;

update	crapscb
set	crapscb.nrseqarq	= 1833
WHERE	crapscb.tparquiv	= 2;

commit;

/* Executar processamento dos arquivos CEXT */
PC_BANCOOB_RECEBE_ARQUIVO_CEXT(pr_dscritic => vr_dscritic);

IF	vr_dscritic IS NOT NULL THEN

	raise_application_error(-20001, vr_dscritic);

END IF;

exception
when	ds_exc_erro_v then

	raise_application_error(-20111, ds_critica_v);

end;

update	crapscb
set	crapscb.nrseqarq	= 1838
WHERE	crapscb.tparquiv	= 2;

commit;

end;