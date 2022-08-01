begin

declare

ds_exc_erro_v		exception;
ds_dados_arquivo_v	clob			:= null;
ds_texto_arquivo_v	varchar2(32600);

cd_cooperativa_v	crapcop.cdcooper%type	:= 3;
ds_nome_diretorio_v	crapprm.dsvlrprm%type;
nm_arquivo_arquivo_v	varchar2(100);
ds_critica_v		crapcri.dscritic%type;

begin

ds_nome_diretorio_v	:= '/usr/coop/cecred/arq';

dbms_lob.createtemporary(ds_dados_arquivo_v, true, dbms_lob.CALL);
dbms_lob.open(ds_dados_arquivo_v, dbms_lob.lob_readwrite);
gene0002.pc_escreve_xml(ds_dados_arquivo_v, ds_texto_arquivo_v, 'conteúdo de teste' || chr(13) || chr(13), false);
nm_arquivo_arquivo_v	:= 'teste.txt';

gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
								pr_cdprogra	=> 'JB_ARQPRST',
								pr_dtmvtolt	=> trunc(sysdate),
								pr_dsxml	=> ds_dados_arquivo_v,
								pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || nm_arquivo_arquivo_v,
								pr_flg_impri	=> 'N',
								pr_flg_gerar	=> 'S',
								pr_flgremarq	=> 'N',
								pr_nrcopias	=> 1,
								pr_des_erro	=> ds_critica_v);

			if	(trim(ds_critica_v) is not null) then

				raise	ds_exc_erro_v;

			end if;

			dbms_lob.close(ds_dados_arquivo_v);
			dbms_lob.freetemporary(ds_dados_arquivo_v);

			commit;

exception
when	ds_exc_erro_v then

	rollback;
	raise_application_error(-20111, ds_critica_v);

end;

end;