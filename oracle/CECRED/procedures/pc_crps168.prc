CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS168(pr_cdcooper  IN crapcop.cdcooper%type
                                             ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo Agencia
                                             ,pr_idparale  IN crappar.idparale%TYPE --> Indicador de processoparalelo
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%type
                                             ,pr_dscritic OUT varchar2) is
/* ...........................................................................

   Programa: pc_crps168 (antigo Fontes/crps168.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/96                      Ultima atualizacao: 27/05/2018

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 5.
               Gerar cadastro de informacoes gerenciais.
               Ordem do programa na solicitacao 26.

               Desmembrado do programa crps133.

   Alteracoes: 26/11/96 - Tratar RDCAII (Odair).

               29/06/2005 - Alimentado campo cdcooper da tabela crapger (Diego).

               07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).

               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               29/11/2006 - Melhoria de performance (Evandro).

               08/08/2007 - Tratamento para aplicacoes RDC (David).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise).

               02/06/2011 - Estanciado a b1wgen0004 ao inicio do programa e
                            deletado ao final para ganho de performance
                            (Adriano).

               11/01/2011 - Melhoria de desempenho (Gabriel).

               28/05/2013 - Conversão Progress >> Oracle PL/SQL (Daniel-Supero)
               
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

               
               11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel).

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)
							 
							 25/08/2014 - Adicionado tratamento para os novos produtos de 
							              captação (craprac). (Reinert)
                            
               17/09/2014 - (Chamado 164892) Programa estava rodando sempre que
                            era chamado, duplicando dados na crapger
                            (Tiago Castro - RKAM).

               17/05/2018 - Projeto Revitalização Sistemas - Andreatta (MOUTs)

............................................................................. */
  
  --- ################################ Variáveis ################################# ----

  -- Exception para tratamento de erros trataveis sem abortar a execucao
  vr_exc_mensagem  exception;
  -- Codigo do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Controle de Datas
  vr_dtdiault      crapdat.dtmvtolt%type;
  vr_flgmensa      boolean;
  -- Datas de utilizacao da taxa de Poupanca
  vr_dtinitax      crapdat.dtmvtolt%type;
  vr_dtfimtax      crapdat.dtmvtolt%TYPE;
  -- Variaveis para calculo do saldo
  vr_vlsdrdca      craprda.vlsdrdca%type := 0;
  vr_vlsldapl      craprda.vlsdrdca%type := 0;
  vr_vldperda      craprda.vlsdrdca%type := 0;
  vr_txaplica      craptrd.txofidia%type := 0;
  vr_vlaplrda      craprda.vlsdrdca%type := 0;
  vr_qtaplrda      number(10) := 0;
  vr_temaplic      boolean;
  vr_vlsldrdc      craprda.vlsdrdca%type := 0;
  vr_vlrdirrf      craplap.vllanmto%type := 0;
  vr_perirrgt      number(18,2) := 0;
  vr_sldpresg      craprda.vlsdrdca%type := 0;
  vr_qtctrrpp      number(10) := 0;
  vr_vlctrrpp      craprpp.vlprerpp%type := 0;
  vr_vlsdrdpp      craprpp.vlsdrdpp%type := 0;
  vr_vlrentot      number(20,10) := 0;
  vr_vlaplrpp      number(20,10) := 0;
  vr_vlcaptal      number(20,10) := 0;
  vr_vlplanos      number(20,10) := 0;
  vr_vlsmpmes      number(20,10) := 0;
  vr_vlaplrdc      craprda.vlsdrdca%type := 0;
  vr_qtaplrdc      number(10) := 0;
  vr_qtaplrpp      number(10) := 0;
  vr_qtassapl      number(10) := 0;
  vr_qtassoci      number(10) := 0;
  vr_qtctacor      number(10) := 0;
  vr_qtplanos      number(10) := 0;
  vr_qtassepr      number(10) := 0;
  vr_sldpresg_tmp  craplap.vllanmto%TYPE; --> Valor saldo de resgate
  vr_dup_vlsdrdca  craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA
	
	-- Variaveis usadas no retorno da procedure pc_posicao_saldo_aplicacao_pre
	vr_vlsldtot NUMBER;      --> Saldo Total da Aplicação
  vr_vlultren NUMBER;      --> Valor Último Rendimento
 	vr_vlsldrgt NUMBER;      --> Saldo Total para Resgate
	vr_vlrevers NUMBER;      --> Valor de Reversão
	vr_percirrf NUMBER;      --> Percentual do IRRF
	vr_vlbascal NUMBER := 0; --> Valor Base Cálculo
	
  --Informacoes tabelas genericas
  vr_dstextab      craptab.dstextab%type;
  vr_prcaplic      craptab.dstextab%type;
  
  -- Tratamento de erros
  vr_des_erro      varchar2(3);
  vr_tab_erro      gene0001.typ_tab_erro;
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  vr_cdcritic      PLS_INTEGER;
  vr_dscritic      VARCHAR2(4000);  
  
  -- ID para o paralelismo
  vr_idparale      integer;
  -- Qtde parametrizada de Jobs
  vr_qtdjobs       number;
  -- Job name dos processos criados
  vr_jobname       varchar2(30);
  -- Bloco PLSQL para chamar a execução paralela do pc_crps750
  vr_dsplsql       varchar2(4000);

  -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
  vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
  vr_idlog_ini_ger tbgen_prglog.idprglog%type;
  vr_idlog_ini_par tbgen_prglog.idprglog%type;
  vr_tpexecucao    tbgen_prglog.tpexecucao%type;
  vr_qterro        number := 0;
  
  --- ################################ Estruturas ################################# ----
  -- Registro para armazenar as informacoes de dias uteis
  type typ_tab_qtdiaute is table of number index by varchar2(8);
  -- PL/Table para armazenar as informacoes de dias uteis
  vr_tab_qtdiaute typ_tab_qtdiaute;
  -- Registro para armazenar as informacoes de moedas
  type typ_reg_moedatx is record (vlmoefix crapmfx.vlmoefix%type,
                                  txaplmes number(18,8));
  -- PL/Table para armazenar as informacoes de moedas
  type typ_tab_moedatx is table of typ_reg_moedatx index by varchar2(10);
  -- Vetores para armazenar as informacoes de moedas
  vr_tab_moedatx typ_tab_moedatx;

  --Tipo para tabelas de memoria
  type typ_tab_crapdtc is table of number index by pls_integer;

  --Tabela de memoria para aplicacoes  
  vr_tab_crapdtc  typ_tab_crapdtc;  
  
  --- ################################ Cursores ################################# ----

  rw_crapdat     btch0001.cr_crapdat%rowtype;

  -- Dados da cooperativa
  cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
    select 1
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop    cr_crapcop%ROWTYPE;

  -- Lista das agências da Cooperativa
  CURSOR cr_crapage(pr_cdcooper in craprpp.cdcooper%type
                   ,pr_cdprogra in tbgen_batch_controle.cdprogra%type
                   ,pr_qterro   in number
                   ,pr_dtmvtolt in tbgen_batch_controle.dtmvtolt%type) IS
    select distinct crapass.cdagenci
      from crapass
     where crapass.cdcooper  = pr_cdcooper
       and crapass.dtelimin is NULL
       and (pr_qterro = 0 or
           (pr_qterro > 0 and exists (select 1
                                        from tbgen_batch_controle
                                       where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                         and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                         and tbgen_batch_controle.tpagrupador = 1
                                         and tbgen_batch_controle.cdagrupador = crapass.cdagenci
                                         and tbgen_batch_controle.insituacao  = 1
                                         and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
    order by crapass.cdagenci;

  -- Busca as contas e agencias
  cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type,
                     pr_cdagenci in crapass.cdagenci%type) is
    select crapass.cdagenci,
           crapass.nrdconta,
           lead(crapass.cdagenci, 1) over(order by crapass.cdagenci) as prox_cdagenci
      from crapass
     where crapass.cdcooper = pr_cdcooper
       and crapass.dtelimin is NULL
       and cdagenci = decode(pr_cdagenci,0,cdagenci,pr_cdagenci)
     order by crapass.cdagenci;
  TYPE typ_crapass IS TABLE OF cr_crapass%ROWTYPE INDEX BY PLS_INTEGER;
  rw_crapass typ_crapass;        

  -- Aplicacoes RDCA
  cursor cr_craprda (pr_cdcooper in craprda.cdcooper%type,
                     pr_insaqtot IN craprda.insaqtot%TYPE,
                     pr_cdagenci in craprda.cdagenci%type,
                     pr_nrdconta in craprda.nrdconta%TYPE) is
    select craprda.tpaplica,
           craprda.nraplica,
           craprda.dtvencto,
           craprda.dtmvtolt,
           craprda.vlsdrdca,
           craprda.qtdiauti,
           craprda.vlsltxmm,
           craprda.dtatslmm,
           craprda.vlsltxmx,
           craprda.dtatslmx
      from craprda craprda
     where craprda.cdcooper = pr_cdcooper
       and craprda.insaqtot = pr_insaqtot
       and craprda.cdageass = pr_cdagenci
       and craprda.nrdconta = pr_nrdconta;
	
	-- Aplicações de captação
	CURSOR cr_craprac (pr_cdcooper IN craprac.cdcooper%TYPE
	                  ,pr_nrdconta IN craprac.nrdconta%TYPE
										,pr_cdagenci IN crapass.cdagenci%TYPE) IS
			 SELECT rac.cdprodut
			       ,rac.qtdiacar
						 ,rac.nrdconta
						 ,rac.nraplica
						 ,rac.dtmvtolt
						 ,rac.txaplica
						 ,rac.dtvencto
						 ,rac.vlaplica
						 ,ass.cdagenci
				 FROM craprac rac,
				      crapass ass
				WHERE rac.cdcooper = pr_cdcooper
					AND rac.idsaqtot = 0
					AND rac.nrdconta = pr_nrdconta
					AND ass.cdagenci = pr_cdagenci
					AND ass.cdcooper = rac.cdcooper 
					AND ass.nrdconta = rac.nrdconta;
					
	-- Cadastro dos produtos de captacao
	CURSOR cr_crapcpc (pr_cdprodut IN crapcpc.cdprodut%TYPE) IS
	  SELECT cpc.idtippro
		      ,cpc.idtxfixa
					,cpc.cddindex
		  FROM crapcpc cpc
		 WHERE cpc.cdprodut = pr_cdprodut;
	rw_crapcpc cr_crapcpc%ROWTYPE;
	
  -- Tipos de aplicacao oferecidos para o cooperado
  cursor cr_crapdtc (pr_cdcooper in crapdtc.cdcooper%type,
                     pr_tpaplica in crapdtc.tpaplica%type) is
    select tpaplrdc
      from crapdtc
     where crapdtc.cdcooper = pr_cdcooper
       and crapdtc.tpaplica = pr_tpaplica;
  rw_crapdtc      cr_crapdtc%rowtype;

  -- Tipos de aplicacao oferecidos para o cooperado
  cursor cr_crapdtc_carga (pr_cdcooper in crapdtc.cdcooper%type) is
    select crapdtc.tpaplrdc
          ,crapdtc.tpaplica
      from crapdtc
     where crapdtc.cdcooper = pr_cdcooper;

  -- Poupanca programada
  cursor cr_craprpp (pr_cdcooper in craprpp.cdcooper%type,
                     pr_nrdconta in craprpp.nrdconta%type) is
    select cdsitrpp,
           dtinirpp,
           vlprerpp,
           rowid
      from craprpp
     where craprpp.cdcooper = pr_cdcooper
       and craprpp.nrdconta = pr_nrdconta;

  -- Busca informacoes gerenciais para todas as agencias para calcular a soma
  cursor cr_crapger (pr_cdcooper in crapger.cdcooper%type,
                     pr_dtdiault in crapger.dtrefere%type) is
    select sum(nvl(qtassoci,0)) qtassoci
          ,sum(nvl(qtctacor,0)) qtctacor
          ,sum(nvl(qtplanos,0)) qtplanos
          ,sum(nvl(qtaplrda,0)) qtaplrda
          ,sum(nvl(qtaplrdc,0)) qtaplrdc
          ,sum(nvl(vlcaptal,0)) vlcaptal
          ,sum(nvl(vlplanos,0)) vlplanos
          ,sum(nvl(vlaplrda,0)) vlaplrda
          ,sum(nvl(vlaplrdc,0)) vlaplrdc
          ,sum(nvl(vlsmpmes,0)) vlsmpmes
          ,sum(nvl(qtassepr,0)) qtassepr
          ,sum(nvl(qtctrrpp,0)) qtctrrpp
          ,sum(nvl(vlctrrpp,0)) vlctrrpp
          ,sum(nvl(qtaplrpp,0)) qtaplrpp
          ,sum(nvl(vlaplrpp,0)) vlaplrpp
          ,sum(nvl(qtassapl,0)) qtassapl
      from crapger
     where crapger.cdcooper = pr_cdcooper
       and crapger.dtrefere = pr_dtdiault
       and crapger.cdagenci > 0;
  rw_crapger cr_crapger%ROWTYPE;
BEGIN
  --- ################################ Programa Principal ################################# ----
  vr_cdprogra := 'CRPS168';
  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS168',
                             pr_action => vr_cdprogra);
                             
  -- Na execução principal
  if nvl(pr_idparale,0) = 0 then
    -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    vr_idlog_ini_ger := null;
    pc_log_programa(pr_dstiplog   => 'I',
                    pr_cdprograma => vr_cdprogra,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_ger);
  end if;                           
                             
  -- Validacoes iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Limpar tabela de memoria
  vr_tab_crapdtc.delete;
  vr_tab_qtdiaute.delete;
  vr_tab_moedatx.delete;

  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
  fetch btch0001.cr_crapdat into rw_crapdat;
  if btch0001.cr_crapdat%notfound then
    -- Fechar o cursor pois havera raise
    close btch0001.cr_crapdat;
    vr_cdcritic:= 1;
    -- Montar mensagem de critica
    raise vr_exc_saida;
  end if;
  close btch0001.cr_crapdat;
    
  -- Busca o ultimo dia do mes e verifica se é a execucao mensal
  vr_dtdiault := rw_crapdat.dtultdia;
  vr_flgmensa := (to_char(rw_crapdat.dtmvtolt, 'mm') <> to_char(rw_crapdat.dtmvtopr,'mm'));
  if not vr_flgmensa then
    raise vr_exc_fimprg;
  end if;  

  -- Buscar os dados da cooperativa
  open cr_crapcop(pr_cdcooper);
  fetch cr_crapcop into rw_crapcop;
  if cr_crapcop%notfound then
    close cr_crapcop;
    vr_cdcritic := 651;
    raise vr_exc_saida;
  end if;
  close cr_crapcop;

  -- Buscar o percentual de IR da aplicacao
  vr_prcaplic := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                            pr_nmsistem => 'CRED',
                                            pr_tptabela => 'CONFIG',
                                            pr_cdempres => 0,
                                            pr_cdacesso => 'PERCIRAPLI',
                                            pr_tpregist => 0);

  -- Buscar data de fim e inicio da utilizacao da taxa de Poupanca.
  -- Utiliza-se essa data quando o rendimento da aplicacao for menor que
  -- a Poupanca, a cooperativa opta por usar ou nao.
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                            pr_nmsistem => 'CRED',
                                            pr_tptabela => 'USUARI',
                                            pr_cdempres => 11,
                                            pr_cdacesso => 'MXRENDIPOS',
                                            pr_tpregist => 1);
  if vr_dstextab is null then
    vr_dtinitax := to_date('01/01/9999', 'dd/mm/yyyy');
    vr_dtfimtax := to_date('01/01/9999', 'dd/mm/yyyy');
  else
    vr_dtinitax := to_date(gene0002.fn_busca_entrada(1, vr_dstextab, ';'), 'dd/mm/yyyy');
    vr_dtfimtax := to_date(gene0002.fn_busca_entrada(2, vr_dstextab, ';'), 'dd/mm/yyyy');
  end if;

  --Carrega tabela memoria aplicacoes
  for rw_crapdtc in cr_crapdtc_carga (pr_cdcooper => pr_cdcooper) loop
    vr_tab_crapdtc(rw_crapdtc.tpaplica):= rw_crapdtc.tpaplrdc;
  end loop;
  
  -- Buscar quantidade parametrizada de Jobs
  vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --> Código da coopertiva
                                               ,vr_cdprogra --> Código do programa
                                               );

  /* Paralelismo visando performance Rodar Somente no processo Noturno */
  if rw_crapdat.inproces > 2 and vr_qtdjobs > 0 and pr_cdagenci  = 0 then
    -- Gerar o ID para o paralelismo
    vr_idparale := gene0001.fn_gera_ID_paralelo;

    -- Se houver algum erro, o id vira zerado
    IF vr_idparale = 0 THEN
       -- Levantar exceção
       vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
       RAISE vr_exc_saida;
    END IF;

    -- Verifica se algum job paralelo executou com erro
    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                 ,pr_cdprogra    => vr_cdprogra
                                                 ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                 ,pr_tpagrupador => 1
                                                 ,pr_nrexecucao  => 1);

    -- Retorna todas as agências da Cooperativa
    for rw_crapage in cr_crapage (pr_cdcooper
                                 ,vr_cdprogra
                                 ,vr_qterro
                                 ,rw_crapdat.dtmvtolt) loop

      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := vr_cdprogra ||'_'|| rw_crapage.cdagenci || '$';

      -- Cadastra o programa paralelo
      gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                ,pr_idprogra => LPAD(rw_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      -- Montar o bloco PLSQL que será executado
      -- Ou seja, executaremos a geração dos dados
      -- para a agência atual atraves de Job no banco
      vr_dsplsql := 'DECLARE' || chr(13)
                 || '  wpr_stprogra NUMBER;' || chr(13)
                 || '  wpr_infimsol NUMBER;' || chr(13)
                 || '  wpr_cdcritic NUMBER;' || chr(13)
                 || '  wpr_dscritic VARCHAR2(1500);' || chr(13)
                 || 'BEGIN' || chr(13)
                 || '  PC_CRPS168('|| pr_cdcooper
                 || '            ,'|| rw_crapage.cdagenci
                 || '            ,'|| vr_idparale
                 || '            ,wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);'
                 || chr(13)
                 || 'END;'; --

      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                            ,pr_cdprogra => vr_cdprogra  --> Código do programa
                            ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                            ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                            ,pr_jobname  => vr_jobname   --> Nome randomico criado
                            ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      -- Chama rotina que irá pausar este processo controlador
      -- caso tenhamos excedido a quantidade de JOBS em execuçao
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                  ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if  vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

    end loop;
    
    -- Chama rotina de aguardo agora passando 0, para esperarmos
    -- até que todos os Jobs tenha finalizado seu processamento
    gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                ,pr_qtdproce => 0
                                ,pr_des_erro => vr_dscritic);

    -- Testar saida com erro
    if  vr_dscritic is not null then
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;

    -- Verifica se algum job executou com erro
    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                 ,pr_cdprogra    => vr_cdprogra
                                                 ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                 ,pr_tpagrupador => 1
                                                 ,pr_nrexecucao  => 1);
    if vr_qterro > 0 then
      vr_cdcritic := 0;
      vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
      raise vr_exc_saida;
    end if;
  else

    if pr_cdagenci <> 0 then
      vr_tpexecucao := 2;
    else
      vr_tpexecucao := 1;
    end if;

    -- Grava controle de batch por agência
    gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                    ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                    ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                    ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                    ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                    ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                    ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                    ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                    ,pr_dscritic    => vr_dscritic);
    -- Testar saida com erro
    if vr_dscritic is not null then
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;

    -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    pc_log_programa(pr_dstiplog   => 'I'
                   ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci
                   ,pr_cdcooper   => pr_cdcooper
                   ,pr_tpexecucao => vr_tpexecucao    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_idprglog   => vr_idlog_ini_par);
  
    -- Busca as contas
    OPEN cr_crapass(pr_cdcooper,pr_cdagenci);
    LOOP
      FETCH cr_crapass BULK COLLECT INTO rw_crapass LIMIT 500;
      EXIT WHEN rw_crapass.COUNT = 0;            
      FOR idx IN rw_crapass.first..rw_crapass.last LOOP                                 
        -- Indicador de encontro de alguma aplicacao
        vr_temaplic := false;
        -- Busca aplicacoes RDCA
        for rw_craprda in cr_craprda (pr_cdcooper => pr_cdcooper
                                     ,pr_insaqtot => 0
                                     ,pr_cdagenci => rw_crapass(idx).cdagenci
                                     ,pr_nrdconta => rw_crapass(idx).nrdconta) loop
          -- Limpa tabela de erros
          vr_tab_erro.delete;
          --
          if rw_craprda.tpaplica = 3 then
            -- Consulta saldo aplicacao RDCA30 (Antiga includes/b1wgen0004.i)
            apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper         -- Cooperativa
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data do processo
                                                 ,pr_inproces => rw_crapdat.inproces -- Indicador do processo
                                                 ,pr_dtmvtopr => rw_crapdat.dtmvtopr -- Proximo dia util
                                                 ,pr_cdprogra => vr_cdprogra         -- Programa em execucao
                                                 ,pr_cdagenci => rw_crapass(idx).cdagenci -- Codigo da agencia
                                                 ,pr_nrdcaixa => 0                   -- Numero do caixa
                                                 ,pr_nrdconta => rw_crapass(idx).nrdconta -- Nro da conta da aplicacao RDCA
                                                 ,pr_nraplica => rw_craprda.nraplica -- Nro da aplicacao RDCA
                                                 ,pr_vlsdrdca => vr_vlsdrdca         -- Saldo da aplicacao
                                                 ,pr_vlsldapl => vr_vlsldapl         -- Saldo da aplicacao RDCA
                                                 ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                                 ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                 ,pr_vldperda => vr_vldperda         -- Valor calculado da perda
                                                 ,pr_txaplica => vr_txaplica         -- Taxa aplicada sob o empréstimo
                                                 ,pr_des_reto => vr_des_erro         -- OK ou NOK
                                                 ,pr_tab_erro => vr_tab_erro);       -- Tabela com erros
            --Se retornou erro
            if vr_des_erro = 'NOK' then
              -- Tenta buscar o erro no vetor de erro
              if vr_tab_erro.count > 0 then
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic|| ' Conta: '||rw_crapass(idx).nrdconta;
              else
                vr_cdcritic := 0;
                vr_dscritic := 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca30 e sem informacao na pr_tab_erro, conta: '||rw_crapass(idx).nrdconta;
              end if;
              --Levantar Excecao
              raise vr_exc_saida;
            end if;
            -- Se encontrou saldo, acumula valor e quantidade
            if vr_vlsdrdca <> 0 then
              vr_vlaplrda := vr_vlaplrda + vr_vlsdrdca;
              vr_qtaplrda := vr_qtaplrda + 1;
              vr_temaplic := true;
            end if;
          elsif rw_craprda.tpaplica = 5 then
            -- Consulta saldo aplicacao RDCA60 (Antiga includes/b1wgen0004a.i)
            apli0001.pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper          -- Cooperativa
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data do processo
                                                 ,pr_dtmvtopr => rw_crapdat.dtmvtopr  -- Proximo dia util
                                                 ,pr_cdprogra => vr_cdprogra          -- Programa em execucao
                                                 ,pr_cdagenci => rw_crapass(idx).cdagenci  -- Codigo da agencia
                                                 ,pr_nrdcaixa => 0                    -- Numero do caixa
                                                 ,pr_nrdconta => rw_crapass(idx).nrdconta  -- Numero da conta
                                                 ,pr_nraplica => rw_craprda.nraplica  -- Numero da aplicacao
                                                 ,pr_vlsdrdca => vr_vlsdrdca          -- Saldo aplicacao
                                                 ,pr_sldpresg => vr_sldpresg          -- Saldo para resgate
                                                 ,pr_des_reto => vr_des_erro          -- OK ou NOK
                                                 ,pr_tab_erro => vr_tab_erro);        -- Tabela com erros
            -- Se retornou erro
            if vr_des_erro = 'NOK' then
              -- Tenta buscar o erro no vetor de erro
              if vr_tab_erro.count > 0 then
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic|| ' Conta: '||rw_crapass(idx).nrdconta;
              else
                vr_cdcritic := 0;
                vr_dscritic := 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca60 e sem informacao na pr_tab_erro, conta: '||rw_crapass(idx).nrdconta;
              end if;
              --Levantar Excecao
              raise vr_exc_saida;
            end if;
            -- Se encontrou saldo, acumula valor e quantidade
            if vr_vlsdrdca <> 0  then
              vr_vlaplrda := vr_vlaplrda + vr_vlsdrdca;
              vr_qtaplrda := vr_qtaplrda + 1;
              vr_temaplic := true;
            end if;
          else
            -- Busca o tipo de aplicacao
            if not vr_tab_crapdtc.exists(rw_craprda.tpaplica) then
              vr_dscritic := gene0001.fn_busca_critica(346)||
                             ' Conta/dv: '||rw_crapass(idx).nrdconta||
                             ' Nr.Aplicacao: '||rw_craprda.nraplica;
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratato
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_dscritic ,
                                         pr_nmarqlog => vr_cdprogra);
              continue;
            else
              rw_crapdtc.tpaplrdc:= vr_tab_crapdtc(rw_craprda.tpaplica);
            end if;
            --
            vr_vlsldrdc := 0;
            --
            if rw_crapdtc.tpaplrdc = 1 then /* RDCPRE */
              -- Consultar saldo rdc pre
              apli0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper          -- Cooperativa
                                       ,pr_nrdconta => rw_crapass(idx).nrdconta  -- Nro da conta da aplicacao RDCA
                                       ,pr_nraplica => rw_craprda.nraplica  -- Nro da aplicacao RDCA
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt   -- Data do processo (nao necessariamente da CRAPDAT)
                                       ,pr_dtiniper => NULL                 -- Data de inicio da aplicacao
                                       ,pr_dtfimper => NULL                 -- Data de término da aplicacao
                                       ,pr_flggrvir => FALSE                -- Identificador se deve gravar valor insento
                                       ,pr_txaplica => 0                    -- Taxa aplicada
                                       ,pr_tab_crapdat => rw_crapdat         -- Controle de Datas
                                       ,pr_vlsdrdca => vr_vlsldrdc          -- Saldo da aplicacao pos calculo
                                       ,pr_vlrdirrf => vr_vlrdirrf          -- Valor de IR
                                       ,pr_perirrgt => vr_perirrgt          -- Percentual de IR resgatado
                                       ,pr_des_reto => vr_des_erro          -- OK ou NOK
                                       ,pr_tab_erro => vr_tab_erro);        -- Tabela com erros
              -- Se retornou erro
              if vr_des_erro = 'NOK' then
                -- Buscar o erro no vetor de erro
                if vr_tab_erro.count > 0 then
                  vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic|| ' Conta: '||rw_crapass(idx).nrdconta ||' Nr.Aplicacao: '||rw_craprda.nraplica;
                else
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Retorno "NOK" na apli0001.pc_saldo_rdc_pre e sem informacao na pr_tab_erro, Conta: '||rw_crapass(idx).nrdconta;
                end if;
                --
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2, -- Erro tratato
                                           pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_dscritic ,
                                           pr_nmarqlog => vr_cdprogra);
                continue;
              end if;
            elsif  rw_crapdtc.tpaplrdc = 2  then /* RDCPOS */
              -- Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF.
              apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper         -- Cooperativa
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data movimento atual
                                       ,pr_dtmvtopr => rw_crapdat.dtmvtopr -- Data do movimento do Proximo dia
                                       ,pr_nrdconta => rw_crapass(idx).nrdconta -- Nro da conta da aplicacao RDCA
                                       ,pr_nraplica => rw_craprda.nraplica -- Nro da aplicacao RDCA
                                       ,pr_dtmvtpap => rw_crapdat.dtmvtolt -- Data do processo (nao necessariamente da CRAPDAT)
                                       ,pr_dtcalsld => rw_crapdat.dtmvtolt -- Data para calculo do saldo
                                       ,pr_flantven => FALSE               -- Flag antecede vencimento
                                       ,pr_flggrvir => FALSE                -- Identificador se deve gravar valor insento
                                       ,pr_dtinitax => vr_dtinitax         -- Data de inicio da utilizacao da taxa de poupanca.
                                       ,pr_dtfimtax => vr_dtfimtax         -- Data de fim da utilizacao da taxa de poupanca.
                                       ,pr_vlsdrdca => vr_vlsldrdc         -- Saldo da aplicacao pos calculo
                                       ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                       ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IR
                                       ,pr_perirrgt => vr_perirrgt         -- Percentual de IR resgatado
                                       ,pr_des_reto => vr_des_erro         -- OK ou NOK
                                       ,pr_tab_erro => vr_tab_erro);       -- Tabela com erros
              -- Se retornou erro
              if vr_des_erro = 'NOK' then
                -- Tenta buscar o erro no vetor de erro
                if vr_tab_erro.count > 0 then
                  vr_cdcritic:=  vr_tab_erro(vr_tab_erro.first).cdcritic;
                  vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic|| ' Conta: '||rw_crapass(idx).nrdconta ||' Nr.Aplicacao: '||rw_craprda.nraplica;
                else
                  vr_cdcritic:= 0;
                  vr_dscritic := 'Retorno "NOK" na apli0001.pc_saldo_rgt_rdc_pos e sem informacao na pr_tab_erro, Conta: '||rw_crapass(idx).nrdconta;
                end if;
                --
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2, -- Erro tratato
                                           pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_dscritic ,
                                           pr_nmarqlog => vr_cdprogra);
                continue;
              end if;
            end if;
            -- Se encontrou saldo, acumula valor e quantidade
            if vr_vlsldrdc > 0 then
              vr_vlaplrdc := vr_vlaplrdc + vr_vlsldrdc;
              vr_qtaplrdc := vr_qtaplrdc + 1;
              vr_temaplic := true;
            end if;
            --close cr_crapdtc;
          end if;
        end loop; -- Fim do loop cr_craprda
    		
        -- Para cada registro de aplicação de captação
        FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper               --> Cooperativa
                                    ,pr_nrdconta => rw_crapass(idx).nrdconta       --> Nr. da conta
                                    ,pr_cdagenci => rw_crapass(idx).cdagenci) LOOP --> PA
    			
          OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut); --> Código do produto
          FETCH cr_crapcpc INTO rw_crapcpc;
    			
          -- Se não encontrar produto de captação
          IF cr_crapcpc%NOTFOUND THEN
            -- Gerar crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Produto de captacao nao cadastrado';
            CLOSE cr_crapcpc;
            -- Levantar exceção
            RAISE vr_exc_saida;
          END IF;
          CLOSE cr_crapcpc;			
          IF rw_crapcpc.idtippro = 1 THEN -- Pré-fixada
            -- Calculo para obter saldo atualizado de aplicacao pre
            APLI0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                                   ,pr_nrdconta => rw_craprac.nrdconta   --> Número da Conta
                                                   ,pr_nraplica => rw_craprac.nraplica   --> Número da Aplicação
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt   --> Data de Início da Aplicação
                                                   ,pr_txaplica => rw_craprac.txaplica   --> Taxa da Aplicação
                                                   ,pr_idtxfixa => rw_crapcpc.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
                                                   ,pr_cddindex => rw_crapcpc.cddindex   --> Código do Indexador
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar   --> Dias de Carência
                                                   ,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                   ,pr_dtinical => rw_craprac.dtmvtolt   --> Data Inicial Cálculo
                                                   ,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
                                                   ,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                   ,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                   ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
                                                   ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
                                                   ,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
                                                   ,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
                                                   ,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
                                                   ,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
                                                   ,pr_percirrf => vr_percirrf           --> Percentual do IRRF
                                                   ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                                   ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
            -- Se procedure retornou erro																				
            IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pre -> ' || vr_dscritic;
              -- Levanta exceção
              RAISE vr_exc_saida;
            END IF;
          ELSIF rw_crapcpc.idtippro = 2 THEN -- Pós-fixada
    			
            APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                                   ,pr_nrdconta => rw_craprac.nrdconta   --> Número da Conta
                                                   ,pr_nraplica => rw_craprac.nraplica   --> Número da Aplicação
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt   --> Data de Início da Aplicação
                                                   ,pr_txaplica => rw_craprac.txaplica   --> Taxa da Aplicação
                                                   ,pr_idtxfixa => rw_crapcpc.idtxfixa   --> Taxa Fixa (1-SIM/2-NAO)
                                                   ,pr_cddindex => rw_crapcpc.cddindex   --> Código do Indexador
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar   --> Dias de Carência
                                                   ,pr_idgravir => 0                     --> Gravar Imunidade IRRF (0-Não/1-Sim)
                                                   ,pr_dtinical => rw_craprac.dtmvtolt   --> Data Inicial Cálculo
                                                   ,pr_dtfimcal => rw_crapdat.dtmvtolt   --> Data Final Cálculo
                                                   ,pr_idtipbas => 2                     --> Tipo Base Cálculo – 1-Parcial/2-Total)
                                                   ,pr_vlbascal => vr_vlbascal           --> Valor Base Cálculo (Retorna valor proporcional da base de cálculo de entrada)
                                                   ,pr_vlsldtot => vr_vlsldtot           --> Saldo Total da Aplicação
                                                   ,pr_vlsldrgt => vr_vlsldrgt           --> Saldo Total para Resgate
                                                   ,pr_vlultren => vr_vlultren           --> Valor Último Rendimento
                                                   ,pr_vlrentot => vr_vlrentot           --> Valor Rendimento Total
                                                   ,pr_vlrevers => vr_vlrevers           --> Valor de Reversão
                                                   ,pr_vlrdirrf => vr_vlrdirrf           --> Valor do IRRF
                                                   ,pr_percirrf => vr_percirrf           --> Percentual do IRRF
                                                   ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                                   ,pr_dscritic => vr_des_erro);         --> Descrição da crítica
    																									
            -- Se procedure retornou erro																				
            IF vr_cdcritic <> 0 OR TRIM(vr_des_erro) IS NOT NULL THEN
              vr_des_erro := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pos -> ' || vr_des_erro;
              -- Levanta exceção
              RAISE vr_exc_saida;
            END IF;
    				
          END IF;
    			
          -- Incrementa saldo total das aplicações rdc e quantidade de aplicações
          vr_vlaplrdc := vr_vlaplrdc + vr_vlsldtot;
          vr_qtaplrdc := vr_qtaplrdc + 1;
          vr_temaplic := true;
    		
        END LOOP;

        -- Buscar informacoes da Poupanca programada
        for rw_craprpp in cr_craprpp (pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => rw_crapass(idx).nrdconta) loop
          -- Para Poupancas ativas deve incrementar a quantidade e somar o valor
          if rw_craprpp.cdsitrpp = 1 and
             rw_craprpp.dtinirpp <= rw_crapdat.dtmvtolt then
            vr_qtctrrpp := vr_qtctrrpp + 1;
            vr_vlctrrpp := vr_vlctrrpp + rw_craprpp.vlprerpp;
          end if;
          -- Executa calculo de Poupanca (antigo poupanca.i)
          apli0001.pc_calc_poupanca (pr_cdcooper => pr_cdcooper          --> Cooperativa
                                    ,pr_dstextab => vr_prcaplic          --> Percentual de IR da aplicacao
                                    ,pr_cdprogra => vr_cdprogra          --> Programa chamador
                                    ,pr_inproces => rw_crapdat.inproces  --> Indicador do processo
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data do processo
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr  --> Proximo dia util
                                    ,pr_rpp_rowid => rw_craprpp.rowid    --> Identificador do registro da tabela CRAPRPP em processamento
                                    ,pr_vlsdrdpp => vr_vlsdrdpp          --> Saldo da Poupanca programada
                                    ,pr_cdcritic => vr_cdcritic          --> Codigo da critica de erro
                                    ,pr_des_erro => vr_dscritic);        --> Descricao do erro encontrado
          if vr_dscritic is not null or vr_cdcritic is not null then
            raise vr_exc_saida;
          end if;
          -- Se encontrou saldo, acumula valor e quantidade
          if vr_vlsdrdpp > 0 then
            vr_qtaplrpp := vr_qtaplrpp + 1;
            vr_vlaplrpp := vr_vlaplrpp + vr_vlsdrdpp;
            vr_temaplic := true;
          end if;
        end loop;
        -- Verifica se encontrou alguma aplicacao
        if vr_temaplic then
          vr_qtassapl := vr_qtassapl + 1;
        end if;
        
        -- Verifica se é o ultimo para a agencia (LAST-OF)
        if rw_crapass(idx).cdagenci <> nvl(rw_crapass(idx).prox_cdagenci, 0) then
          -- Atualiza / cria informacoes gerenciais
          begin
            update crapger
               set crapger.qtaplrda = vr_qtaplrda,
                   crapger.qtaplrdc = vr_qtaplrdc,
                   crapger.vlaplrda = vr_vlaplrda,
                   crapger.vlaplrdc = vr_vlaplrdc,
                   crapger.qtaplrpp = vr_qtaplrpp,
                   crapger.vlaplrpp = vr_vlaplrpp,
                   crapger.qtctrrpp = vr_qtctrrpp,
                   crapger.vlctrrpp = vr_vlctrrpp,
                   crapger.qtassapl = vr_qtassapl
             where crapger.cdcooper = pr_cdcooper
               and crapger.dtrefere = vr_dtdiault
               and crapger.cdempres = 0
               and crapger.cdagenci = rw_crapass(idx).cdagenci;
            if sql%rowcount = 0 then
              insert into crapger (cdcooper,
                                   dtrefere,
                                   cdempres,
                                   cdagenci,
                                   qtaplrda,
                                   qtaplrdc,
                                   vlaplrda,
                                   vlaplrdc,
                                   qtaplrpp,
                                   vlaplrpp,
                                   qtctrrpp,
                                   vlctrrpp,
                                   qtassapl,
                                   qtassoci,
                                   qtctacor,
                                   qtautent,
                                   qtplanos,
                                   vlplanos,
                                   vlcaptal,
                                   vlsmpmes,
                                   qtassepr,
                                   qtrettal,
                                   qtsoltal,
                                   qtrttlct,
                                   qtrttlbc,
                                   qtsltlct,
                                   qtsltlbc)
              values (pr_cdcooper,
                      vr_dtdiault,
                      0,
                      rw_crapass(idx).cdagenci,
                      vr_qtaplrda,
                      vr_qtaplrdc,
                      vr_vlaplrda,
                      vr_vlaplrdc,
                      vr_qtaplrpp,
                      vr_vlaplrpp,
                      vr_qtctrrpp,
                      vr_vlctrrpp,
                      vr_qtassapl,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0,
                      0);
            end if;
          exception
            when others then
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar crapger: '||sqlerrm;
              raise vr_exc_saida;
          END;
          -- Zera Variaveis totalizadoras
          vr_qtaplrda := 0;
          vr_qtaplrdc := 0;
          vr_vlaplrda := 0;
          vr_vlaplrdc := 0;
          vr_qtctrrpp := 0;
          vr_vlctrrpp := 0;
          vr_qtaplrpp := 0;
          vr_vlaplrpp := 0;
          vr_qtassapl := 0;
        end if;
      END LOOP; -- Loop Buffer
    end loop; -- Fim do loop cr_crapass
  
    -- Grava data fim para o JOB na tabela de LOG
    pc_log_programa(pr_dstiplog   => 'F'
                   ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci
                   ,pr_cdcooper   => pr_cdcooper
                   ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_idprglog   => vr_idlog_ini_par
                   ,pr_flgsucesso => 1);
                   
  END IF;
  
  -- Se for o programa principal ou sem paralelismo
  if nvl(pr_idparale,0) = 0 then

    -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
    pc_log_programa(pr_dstiplog     => 'O'
                   ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                   ,pr_cdcooper     => pr_cdcooper
                   ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_tpocorrencia => 4
                   ,pr_dsmensagem   => 'Inicio - Alimentação das tabelas.'
                   ,pr_idprglog     => vr_idlog_ini_ger);
  
    -- Acumula os valores por agencia na tabela de informacoes gerenciais
    OPEN cr_crapger (pr_cdcooper,vr_dtdiault);
    FETCH cr_crapger
     INTO rw_crapger;
    CLOSE cr_crapger;
    vr_qtassoci := rw_crapger.qtassoci;
    vr_qtctacor := rw_crapger.qtctacor;
    vr_qtplanos := rw_crapger.qtplanos;
    vr_qtaplrda := rw_crapger.qtaplrda;
    vr_qtaplrdc := rw_crapger.qtaplrdc;
    vr_vlcaptal := rw_crapger.vlcaptal;
    vr_vlplanos := rw_crapger.vlplanos;
    vr_vlaplrda := rw_crapger.vlaplrda;
    vr_vlaplrdc := rw_crapger.vlaplrdc;
    vr_vlsmpmes := rw_crapger.vlsmpmes;
    vr_qtassepr := rw_crapger.qtassepr;
    vr_qtctrrpp := rw_crapger.qtctrrpp;
    vr_vlctrrpp := rw_crapger.vlctrrpp;
    vr_qtaplrpp := rw_crapger.qtaplrpp;
    vr_vlaplrpp := rw_crapger.vlaplrpp;
    vr_qtassapl := rw_crapger.qtassapl;
    
    -- Atualiza/ cria os totais calculados acima para a agencia 0 (total da cooperativa)
    begin
      update crapger
         set crapger.qtaplrda = crapger.qtaplrda + vr_qtaplrda,
             crapger.qtaplrdc = crapger.qtaplrdc + vr_qtaplrdc,
             crapger.qtassoci = crapger.qtassoci + vr_qtassoci,
             crapger.qtautent = crapger.qtautent + 0,
             crapger.qtctacor = crapger.qtctacor + vr_qtctacor,
             crapger.qtplanos = crapger.qtplanos + vr_qtplanos,
             crapger.vlaplrda = crapger.vlaplrda + vr_vlaplrda,
             crapger.vlaplrdc = crapger.vlaplrdc + vr_vlaplrdc,
             crapger.vlcaptal = crapger.vlcaptal + vr_vlcaptal,
             crapger.vlplanos = crapger.vlplanos + vr_vlplanos,
             crapger.vlsmpmes = crapger.vlsmpmes + vr_vlsmpmes,
             crapger.qtassepr = crapger.qtassepr + vr_qtassepr,
             crapger.qtaplrpp = crapger.qtaplrpp + vr_qtaplrpp,
             crapger.vlaplrpp = crapger.vlaplrpp + vr_vlaplrpp,
             crapger.qtctrrpp = crapger.qtctrrpp + vr_qtctrrpp,
             crapger.vlctrrpp = crapger.vlctrrpp + vr_vlctrrpp,
             crapger.qtassapl = crapger.qtassapl + vr_qtassapl
       where crapger.cdcooper = pr_cdcooper
         and crapger.dtrefere = vr_dtdiault
         and crapger.cdagenci = 0
         and crapger.cdempres = 0;
      if sql%rowcount = 0 then
        insert into crapger (cdcooper,
                             dtrefere,
                             cdempres,
                             cdagenci,
                             qtaplrda,
                             qtaplrdc,
                             qtassoci,
                             qtautent,
                             qtctacor,
                             qtplanos,
                             vlaplrda,
                             vlaplrdc,
                             vlcaptal,
                             vlplanos,
                             vlsmpmes,
                             qtassepr,
                             qtaplrpp,
                             vlaplrpp,
                             qtctrrpp,
                             vlctrrpp,
                             qtassapl,
                             qtrettal,
                             qtsoltal,
                             qtrttlct,
                             qtrttlbc,
                             qtsltlct,
                             qtsltlbc)
        values (pr_cdcooper,
                vr_dtdiault,
                0,
                0,
                vr_qtaplrda,
                vr_qtaplrdc,
                vr_qtassoci,
                0,
                vr_qtctacor,
                vr_qtplanos,
                vr_vlaplrda,
                vr_vlaplrdc,
                vr_vlcaptal,
                vr_vlplanos,
                vr_vlsmpmes,
                vr_qtassepr,
                vr_qtaplrpp,
                vr_vlaplrpp,
                vr_qtctrrpp,
                vr_vlctrrpp,
                vr_qtassapl,
                0,
                0,
                0,
                0,
                0,
                0);
      end if;
    exception
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapger para agencia 0: '||sqlerrm;
        raise vr_exc_saida;
    end;
  
    -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
    pc_log_programa(PR_DSTIPLOG           => 'O'
                   ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                   ,pr_cdcooper           => pr_cdcooper
                   ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_tpocorrencia       => 4
                   ,pr_dsmensagem         => 'Fim - Alimentação das tabelas.'
                   ,PR_IDPRGLOG           => vr_idlog_ini_ger);

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Caso seja o controlador
    if vr_idcontrole <> 0 then
      -- Atualiza finalização do batch na tabela de controle
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);
      -- Testar saida com erro
      if  vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;
    end if;

    -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    pc_log_programa(pr_dstiplog   => 'F'
                   ,pr_cdprograma => vr_cdprogra
                   ,pr_cdcooper   => pr_cdcooper
                   ,pr_tpexecucao => 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_idprglog   => vr_idlog_ini_ger
                   ,pr_flgsucesso => 1);
    -- Efetuar commit
    COMMIT;
  ELSE
    -- Gravar neste ponto também pois a encerra paralelo faz commit e poderia liberar o controlador antes de terminar de commitar essa sessão
    COMMIT;
    -- Atualiza finalização do batch na tabela de controle
    gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                       ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                       ,pr_dscritic     --pr_dscritic  OUT crapcri.dscritic%TYPE
                                       );

    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                ,pr_des_erro => vr_dscritic);

    -- Salvar informacoes no banco de dados
    COMMIT;
  END IF;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas Codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a Descricao
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas Codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a Descricao
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos Codigo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;

 WHEN OTHERS THEN
    -- Efetuar retorno do erro nao tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS168;
/
