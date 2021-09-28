/* BACA para alimentar a tabela CRAPCRD (proposta de cartão efetivadas) de cartões que já foram liberados ou estão em uso */
/* Se não for encontrado o arquivo de Rollback no diretório especificado, pode-se resgatar o script retornado no campo DSXMLDAD dessa query:

	select	a.dsxmldad
	from	crapslr a
	where	a.dsarqsai	like '%INC0106414%'
	and	a.dtsolici	=
		(select	max(x.dtsolici)
		from	crapslr x
		where	x.dsarqsai like '%INC0106414%');

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

dt_proposta_inicial_v	date	:= to_date('01/01/2021','dd/mm/yyyy');
dt_proposta_final_v	date	:= to_date('17/09/2021 23:59:59','dd/mm/yyyy hh24:mi:ss');

ds_rowid_crapcrd_v	rowid;

/* Propostas de cartões que já estão "Liberados" ou "Em uso", cuja conta cartão existe, mas que não têm registro na tabela de proposta efetivadas (CRAPCRD) */
/* A previsão é que esta query retorne 60 registros */
cursor	c01 is
select	a.cdcooper,								/* Cooperativa */
	a.nrdconta,								/* Conta */
	a.nrcrcard,								/* Cartão */
	a.nrcpftit,								/* CPF/CNPJ do titular */
	a.nmtitcrd,								/* Nome do titular */
	a.dddebito,								/* Dia do débito em conta corrente */
	a.cdlimcrd,								/* Código do limite de crédito */
	a.dtvalida,								/* Data de validade */
	a.nrctrcrd,								/* Número da proposta */
	a.cdmotivo,								/* Motivo do cancelamento */
	a.nrprotoc,								/* Número do protocolo */
	a.cdadmcrd,								/* Código da administradora */
	a.tpcartao,								/* Tipo de cartão */
	a.dtcancel,								/* Data do cancelamento */
	a.flgdebit,								/* Habilita função débito */
	decode(upper(a.nmtitcrd),'CARTAO PROVISORIO',1,0) flgprovi		/* Indica se é um cartão provisório */
from	crapass b,								/* Conta do cooperado */
	crawcrd a								/* Proposta de cartão */
where	b.dtdemiss	is null							/* Apenas contas sem data de "demissão" */
and	a.cdcooper	= b.cdcooper
and	a.nrdconta	= b.nrdconta
/* Somente se não existir registro na tabela de propostas de cartão efetivadas */
and	not exists
	(select	1
	from	crapcrd x
	where	x.cdcooper		= a.cdcooper
	and	x.nrcrcard		= a.nrcrcard)				/* Número da proposta */
/* Somente se existir registro da conta cartão */
and	exists
	(select	1
	from	tbcrd_conta_cartao x
	where	x.nrdconta		= a.nrdconta
	and	x.cdcooper		= a.cdcooper
	and	x.nrconta_cartao	= a.nrcctitg)				/* Número da conta cartão */
and	a.insitcrd	in (3,4)						/* Apenas propostas com situação "Liberado" ou "Em uso" */
and	a.dtpropos	between dt_proposta_inicial_v and dt_proposta_final_v	/* Filtrar um período específico, para evitar casos que ainda estão pendentes de alguma resposta do BANCOOB */
and	a.nrcrcard	<> 0							/* Número do cartão diferente de 0 */
and	a.nrcrcard	is not null;						/* Número do cartão não pode estar vazio */

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

/* Diretório de Produção: /micros/cpd/bacas/INC0106414 */
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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0106414';

/* Diretório de Homologação: /progress/f0033552/usr/coop/cecred/INC0106414 */
else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0106414';

end if;
 
/* Validar diretório de rollback e criar pasta do incidente */
valida_diretorio_p(	ds_nome_diretorio_p	=> ds_nome_diretorio_v,
			ds_critica_p		=> ds_critica_v);

/* Tratar eventual erro no diretório */
if	(trim(ds_critica_v) is not null) then

	raise ds_exc_erro_v;

end if;

/* Inicializa as variáveis de rollback */
dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, '-- Programa para rollback das informacoes INC0106414'||chr(13), false);
gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin'||chr(13), false);  
ds_nome_arquivo_bkp_v	:= 'ROLLBACK_INC0106414_'||to_char(sysdate,'hh24miss')||'.sql';

for	r01 in c01 loop

	ds_rowid_crapcrd_v	:= null;

	/* Executar os principais comandos do BACA */
	insert	into crapcrd
		(cdcooper,
		nrdconta,
		nrcrcard,
		nrcpftit,
		nmtitcrd,
		dddebito,
		cdlimcrd,
		dtvalida,
		nrctrcrd,
		cdmotivo,
		nrprotoc,
		cdadmcrd,
		tpcartao,
		dtcancel,
		flgdebit,
		flgprovi)
	values	(r01.cdcooper,
		r01.nrdconta,
		r01.nrcrcard,
		r01.nrcpftit,
		r01.nmtitcrd,
		r01.dddebito,
		r01.cdlimcrd,
		r01.dtvalida,
		r01.nrctrcrd,
		r01.cdmotivo,
		r01.nrprotoc,
		r01.cdadmcrd,
		r01.tpcartao,
		r01.dtcancel,
		r01.flgdebit,
		r01.flgprovi)
	returning rowid into ds_rowid_crapcrd_v;

	/* Alimenta o script de rollback */
	/* gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'delete	from crapcrd '	|| chr(13) ||
					'where	cdcooper	= ' || r01.cdcooper || chr(13) ||
					'and	nrdconta	= ' || r01.nrdconta || chr(13) ||
					'and	nrcrcard	= ' || r01.nrcrcard || chr(13) ||
					'and	nvl(nrctrcrd,0)	= nvl(' || r01.nrctrcrd || ',0); ' || chr(13) || chr(13), false); */

	if	(ds_rowid_crapcrd_v	is not null) then

		gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'delete	from crapcrd '	|| chr(13) ||
						'where	rowid = ' || chr(39) || ds_rowid_crapcrd_v || chr(39) ||  '; ' || chr(13) || chr(13), false);

	end if;

end loop;

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

commit;

exception
when	ds_exc_erro_v then

	raise_application_error(-20111, ds_critica_v);

end;

end;