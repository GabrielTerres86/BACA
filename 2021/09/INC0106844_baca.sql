/* -------------------- ATENÇÃO: MUDAR TODOS OS LUGARES ONDE CONSTA O NÚMERO DO INC ----------------------- */
/* BACA para alimentar a tabela CRAPCRD (proposta de cartão efetivadas) de cartões que já foram liberados ou estão em uso */
/* Se não for encontrado o arquivo de Rollback no diretório especificado, pode-se resgatar o script retornado no campo DSXMLDAD dessa query:

	select	a.dsxmldad
	from	crapslr a
	where	a.dsarqsai	like '%INC0106844%'
	and	a.dtsolici	=
		(select	max(x.dtsolici)
		from	crapslr x
		where	x.dsarqsai like '%INC0106844%');

*/

begin

declare

ds_exc_erro_v			exception;							/* Para validar o diretório do rollback dinâmico */
ds_dados_rollback_v		clob			:= null;				/* Para gravar rollback dinâmico */
ds_texto_rollback_v		varchar2(32600);						/* Para gravar rollback dinâmico */

cd_cooperativa_v		crapcop.cdcooper%type	:= 3;
ds_nome_arquivo_bkp_v		varchar2(100);
ds_nome_diretorio_v		crapprm.dsvlrprm%type;
ds_critica_v			crapcri.dscritic%type;

dt_proposta_inicial_v		date	:= to_date('01/01/2021','dd/mm/yyyy');
dt_proposta_final_v		date	:= to_date('17/09/2021 23:59:59','dd/mm/yyyy hh24:mi:ss');
nr_cartao_v			crawcrd.nrcrcard%type;

ds_rowid_crapcrd_v		rowid;
ds_rowid_tbcrd_conta_cartao_v	rowid;

cursor	c01 is
select	distinct
	a.ds_rowid_crawcrd,									/* Rowid da CRAWCRD */
	a.ds_dtrejeit,										/* Data de rejeição atual - para rollback */
	a.ds_dtlibera,										/* Data de liberação atual - para rollback */
	a.ds_dtentreg,										/* Data de entrega atual - para rollback */
	a.nrcctitg,										/* Número da conta cartão atual */
	a.insitcrd,										/* Situação atual da proposta */
	a.cdcooper,										/* Cooperativa */
	a.nrdconta,										/* Conta */
	a.nrcrcard,										/* Número atual do cartão */
	a.nrcpftit,										/* CPF/CNPJ do titular */
	a.nmtitcrd,										/* Nome do titular */
	a.dddebito,										/* Dia do débito em conta corrente */
	a.cdlimcrd,										/* Código do limite de crédito */
	a.dtvalida,										/* Data de validade */
	a.nrctrcrd,										/* Número da proposta */
	a.cdmotivo,										/* Motivo do cancelamento */
	a.nrprotoc,										/* Número do protocolo */
	a.cdadmcrd,										/* Código da administradora */
	a.tpcartao,										/* Tipo de cartão */
	a.dtcancel,										/* Data do cancelamento */
	a.flgdebit,										/* Habilita função débito */
	a.ie_provisorio,									/* Indica se é um cartão provisório */
	a.nr_conta_cartao,									/* Número da conta cartão */
	a.nr_cartao										/* Número do cartão, obtido do arquivo CCR3 */
from	(
	/* INC0106844 */
	select	b.rowid as ds_rowid_crawcrd,
		decode(b.dtrejeit,null,'null','to_date(' || chr(39) || trim(to_char(b.dtrejeit,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtrejeit,
		decode(b.dtlibera,null,'null','to_date(' || chr(39) || trim(to_char(b.dtlibera,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtlibera,
		decode(b.dtentreg,null,'null','to_date(' || chr(39) || trim(to_char(b.dtentreg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtentreg,
		b.nrcctitg,
		b.insitcrd,
		b.cdcooper,
		b.nrdconta,
		b.nrcrcard,
		b.nrcpftit,
		b.nmtitcrd,
		b.dddebito,
		b.cdlimcrd,
		b.dtvalida,
		b.nrctrcrd,
		b.cdmotivo,
		b.nrprotoc,
		b.cdadmcrd,
		b.tpcartao,
		b.dtcancel,
		b.flgdebit,
		decode(upper(b.nmtitcrd),'CARTAO PROVISORIO',1,0) ie_provisorio,
		to_number(nvl(trim(h.dsvalor),1000000000000)) as nr_conta_cartao,
		to_number(nvl(trim(i.dsvalor),0)) as nr_cartao
	from	tbcrd_linha_arquivo_item i,							/* Log importação arquivo CCR3 - campo número do cartão */
		tbcrd_linha_arquivo_item h,							/* Log importação arquivo CCR3 - campo número da conta cartão */
		tbcrd_linha_arquivo_item g,							/* Log importação arquivo CCR3 - campo tipo de operação */
		tbcrd_linha_arquivo_item f,							/* Log importação arquivo CCR3 - campo tipo de registro */
		tbcrd_linha_arquivo_item e,							/* Log importação arquivo CCR3 - campo número da conta */
		tbcrd_linha_arquivo d,								/* Log importação arquivo CCR3 - linha */
		tbcrd_arquivo c,								/* Log importação arquivo CCR3 - capa */
		crawcrd b,									/* Propostas de cartão */
		tbgen_webservice_aciona a							/* Log integração API */
	where	i.nmcampo				= 'NRCRCARD'
	and	d.idlinha_arquivo			= i.idlinha_arquivo
	and	substr(h.dsvalor,length(h.dsvalor)-5,6)	<> '000000'				/* Somente se a conta cartão não estiver zerada */
	and	h.nmcampo				= 'NRCONTA_CARTAO'
	and	d.idlinha_arquivo			= h.idlinha_arquivo
	and	g.dsvalor				= '01'
	and	g.nmcampo				= 'TPOPERACAO'
	and	d.idlinha_arquivo			= g.idlinha_arquivo
	and	f.dsvalor				= '02'					/* Tipo de registro = dados do cartão */
	and	f.nmcampo				= 'TPREGISTRO'
	and	d.idlinha_arquivo			= f.idlinha_arquivo
	and	e.nmcampo				= 'NRCONTA_DEBITAR'
	and	ltrim(e.dsvalor,'0')			= b.nrdconta
	and	d.idlinha_arquivo			= e.idlinha_arquivo
	and	d.dsinformacao				is null
	and	c.idarquivo				= d.idarquivo
	and	c.idarquivo				= 101					/* Restringir arquivo do dia 21/09/2021 */
	and	(nvl(b.nrcrcard,0) = 0 or b.nrcrcard = 111111)					/* Número do cartão zerado */
	and	a.nrctrprp				= b.nrctrcrd
	and	a.cdcooper				= b.cdcooper
	and	a.nrdconta				= b.nrdconta
	and	a.dsresposta_requisicao			like '%3 - Processado com sucesso!%'	/* Apenas casos onde o Bancoob retornou resultado 3 na API */
	and	a.dhacionamento				between to_date('20/09/2021','dd/mm/yyyy') and to_date('20/09/2021 23:59:59','dd/mm/yyyy hh24:mi:ss')	/* Considerar casos da última execução da nova rotina 672 */
	union
	/* INC0107672 */
	select	b.rowid as ds_rowid_crawcrd,
		decode(b.dtrejeit,null,'null','to_date(' || chr(39) || trim(to_char(b.dtrejeit,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtrejeit,
		decode(b.dtlibera,null,'null','to_date(' || chr(39) || trim(to_char(b.dtlibera,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtlibera,
		decode(b.dtentreg,null,'null','to_date(' || chr(39) || trim(to_char(b.dtentreg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtentreg,
		b.nrcctitg,
		b.insitcrd,
		b.cdcooper,
		b.nrdconta,
		b.nrcrcard,
		b.nrcpftit,
		b.nmtitcrd,
		b.dddebito,
		b.cdlimcrd,
		b.dtvalida,
		b.nrctrcrd,
		b.cdmotivo,
		b.nrprotoc,
		b.cdadmcrd,
		b.tpcartao,
		b.dtcancel,
		b.flgdebit,
		decode(upper(b.nmtitcrd),'CARTAO PROVISORIO',1,0) ie_provisorio,
		7563239818938 as nr_conta_cartao,
		5127070387423353 as nr_cartao
	from	crawcrd b
	where	b.cdcooper	= 1
	and	b.nrdconta	= 13450263
	and	b.nrctrcrd	= 2384083
	union
	/* INC0107838 */
	select	b.rowid as ds_rowid_crawcrd,
		decode(b.dtrejeit,null,'null','to_date(' || chr(39) || trim(to_char(b.dtrejeit,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtrejeit,
		decode(b.dtlibera,null,'null','to_date(' || chr(39) || trim(to_char(b.dtlibera,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtlibera,
		decode(b.dtentreg,null,'null','to_date(' || chr(39) || trim(to_char(b.dtentreg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtentreg,
		b.nrcctitg,
		b.insitcrd,
		b.cdcooper,
		b.nrdconta,
		b.nrcrcard,
		b.nrcpftit,
		b.nmtitcrd,
		b.dddebito,
		b.cdlimcrd,
		b.dtvalida,
		b.nrctrcrd,
		b.cdmotivo,
		b.nrprotoc,
		b.cdadmcrd,
		b.tpcartao,
		b.dtcancel,
		b.flgdebit,
		decode(upper(b.nmtitcrd),'CARTAO PROVISORIO',1,0) ie_provisorio,
		7563239818724 as nr_conta_cartao,
		5127070387381445 as nr_cartao
	from	crawcrd b
	where	b.cdcooper	= 1
	and	b.nrdconta	= 13452606
	and	b.nrctrcrd	= 2390315
	union
	/* INC0107838 */
	select	b.rowid as ds_rowid_crawcrd,
		decode(b.dtrejeit,null,'null','to_date(' || chr(39) || trim(to_char(b.dtrejeit,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtrejeit,
		decode(b.dtlibera,null,'null','to_date(' || chr(39) || trim(to_char(b.dtlibera,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtlibera,
		decode(b.dtentreg,null,'null','to_date(' || chr(39) || trim(to_char(b.dtentreg,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ')') as ds_dtentreg,
		b.nrcctitg,
		b.insitcrd,
		b.cdcooper,
		b.nrdconta,
		b.nrcrcard,
		b.nrcpftit,
		b.nmtitcrd,
		b.dddebito,
		b.cdlimcrd,
		b.dtvalida,
		b.nrctrcrd,
		b.cdmotivo,
		b.nrprotoc,
		b.cdadmcrd,
		b.tpcartao,
		b.dtcancel,
		b.flgdebit,
		decode(upper(b.nmtitcrd),'CARTAO PROVISORIO',1,0) ie_provisorio,
		7563239818933 as nr_conta_cartao,
		5127070387422967 as nr_cartao
	from	crawcrd b
	where	b.cdcooper	= 1
	and	b.nrdconta	= 13448358
	and	b.nrctrcrd	= 2384991
	) a
where	substr(a.nr_conta_cartao,length(a.nr_conta_cartao)-5,6) <> '000000'			/* Desconsiderar conta cartão com número zerado */
/* Somente se não existir registro da conta cartão */
and	not exists
	(select	1
	from	tbcrd_conta_cartao x
	where	x.nrdconta		= a.nrdconta
	and	x.cdcooper		= a.cdcooper
	and	x.nrconta_cartao	= a.nr_conta_cartao)
/* Somente se não existir registro de proposta efetivada */
and	not exists
	(select	1
	from	crapcrd x
	where	x.nrcrcard		= a.nr_cartao
	and	x.nrdconta		= a.nrdconta
	and	x.cdcooper		= a.cdcooper);

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

/* Diretório de Produção: /micros/cpd/bacas/INC0106844 */
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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0106844';

/* Diretório de Homologação: /progress/f0033552/usr/coop/cecred/INC0106844 */
else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0106844';

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
gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, '-- Programa para rollback das informacoes INC0106844'||chr(13), false);
gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin'||chr(13), false);  
ds_nome_arquivo_bkp_v	:= 'ROLLBACK_INC0106844_'||to_char(sysdate,'hh24miss')||'.sql';

for	r01 in c01 loop

	ds_rowid_crapcrd_v	:= null;

	/* Executar os principais comandos do BACA */
	insert	into tbcrd_conta_cartao
		(cdcooper,
		nrdconta,
		nrconta_cartao,
		vllimite_global,
		cdadmcrd)
	values	(r01.cdcooper,
		r01.nrdconta,
		r01.nr_conta_cartao,
		null,
		r01.cdadmcrd)
	returning rowid into ds_rowid_tbcrd_conta_cartao_v;

	update	crawcrd
	set	nrcrcard	= r01.nr_cartao,
		insitcrd	= 3,
		nrcctitg	= r01.nr_conta_cartao,
		cdlimcrd	= 0,
		dtrejeit	= null,
		dtlibera	= trunc(sysdate),
		dtentreg	= null
	where	rowid		= r01.ds_rowid_crawcrd;

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
		r01.nr_cartao,
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
		r01.ie_provisorio)
	returning rowid into ds_rowid_crapcrd_v;

	/* Alimenta o script de rollback */
	if	(ds_rowid_crapcrd_v		is not null) and
		(ds_rowid_tbcrd_conta_cartao_v	is not null) and
		(r01.ds_rowid_crawcrd		is not null) then

		gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'delete	from tbcrd_conta_cartao ' || chr(13) ||
						'where rowid = ' || chr(39) || ds_rowid_tbcrd_conta_cartao_v || chr(39) || '; ' || chr(13) || chr(13) ||

						'update	crawcrd ' || chr(13) ||
						'set nrcrcard = ' || r01.nrcrcard || ', ' || chr(13) ||
						'insitcrd = ' || r01.insitcrd || ', ' || chr(13) ||
						'nrcctitg = ' || r01.nrcctitg || ', ' || chr(13) ||
						'cdlimcrd = ' || r01.cdlimcrd || ', ' || chr(13) ||
						'dtrejeit = ' || r01.ds_dtrejeit || ', ' || chr(13) ||
						'dtlibera = ' || r01.ds_dtlibera || ', ' || chr(13) ||
						'dtentreg = ' || r01.ds_dtentreg || chr(13) ||
						'where rowid = ' || chr(39) || r01.ds_rowid_crawcrd || chr(39) || '; ' || chr(13) || chr(13) ||

						'delete	from crapcrd '	|| chr(13) ||
						'where rowid = ' || chr(39) || ds_rowid_crapcrd_v || chr(39) ||  '; ' || chr(13) || chr(13), false);

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