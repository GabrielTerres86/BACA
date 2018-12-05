CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS148 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                                ,pr_cdagenci  IN crapage.cdagenci%TYPE  --> Codigo Agencia
                                                ,pr_idparale  IN crappar.idparale%TYPE  --> Indicador de processoparalelo
                                                ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                                ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                                ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                                ,pr_dscritic OUT varchar2) is

/* ..........................................................................

   Programa: pc_crps148 (antigo Fontes/crps148.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                      Ultima atualizacao: 14/12/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 5 (Finalizacao do processo).
               Calcula as aplicacoes RPP aniversariantes.
               Nao gera relatorio.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/09/2004 - Aumentado nro digitos nrctrrpp(Mirtes)

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               04/06/2008 - Alterado para nao considerar cdsitrpp = 5 (poupanca
                            baixada pelo vencimento)  no for each na craprpp.
                            (Rosangela)

               28/06/2013 - Conversão Progress >> Oracle PL/SQL (Daniel-Supero)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               27/05/2015 - Realizando a retirada dos tratamentos de restart, pois o programa
                            apresentou erros no processo batch. Os códigos foram comentados e
                            podem ser removidos em futuras alterações do fonte. (Renato - Supero)

               14/12/2017 - Projeto Ligeirinho - Incluindo paralelismo para melhorar a performance
                            da rotina (Roberto Nunhes - AMCOM).

               29/12/2017 - Criação de função para atualizar craptrd - Projeto Ligeirinho -
                            Jonatas Jaqmam (AMcom)

               09/03/2018 - Ajuste na geração dos lançamentos de poupança programada, retirado
                            tratamento do crps148 e mantido na APLI0001 - Projeto Ligeirinho -
                            Jonatas Jaqmam (AMcom)

               02/04/2018 - Ajuste para não gravar lote quando não existirem lançamentos
                            de poupança programada - Projeto Ligeirinho -
                            Jonatas Jaqmam (AMcom)
............................................................................. */

  -- Agências por cooperativa, com poupança programada
  cursor cr_craprpp_age (pr_cdcooper in craprpp.cdcooper%type,
                         pr_dtmvtopr in craprpp.dtfimper%type,
                         pr_cdprogra in tbgen_batch_controle.cdprogra%type,
                         pr_qterro   in number,
                         pr_dtmvtolt in tbgen_batch_controle.dtmvtolt%type) is
    select distinct crapass.cdagenci
      from craprpp,
           crapass
     where craprpp.cdcooper = crapass.cdcooper
       and craprpp.nrdconta = crapass.nrdconta
       and craprpp.cdcooper  = pr_cdcooper
       and craprpp.dtfimper <= pr_dtmvtopr
       and craprpp.incalmes  = 0
       and craprpp.cdprodut < 1 -- apenas poupanças antigas
       and craprpp.cdsitrpp <> 5
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


  -- Poupança programada
  cursor cr_craprpp (pr_cdcooper in craprpp.cdcooper%type,
                     pr_dtmvtopr in craprpp.dtfimper%type,
                     pr_cdagenci in crapage.cdagenci%type) is
    select craprpp.nrdconta,
           craprpp.nrctrrpp,
           craprpp.rowid
      from craprpp,
           crapass
     where craprpp.cdcooper  = crapass.cdcooper
       and craprpp.nrdconta  = crapass.nrdconta
       and craprpp.cdcooper  = pr_cdcooper
       and crapass.cdagenci  = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
       and craprpp.dtfimper <= pr_dtmvtopr
       and craprpp.cdprodut <= 0 -- apenas poupanças antigas
       and craprpp.cdprodut > -2 -- apenas poupanças nao migradas
       and craprpp.incalmes  = 0
       and craprpp.cdsitrpp <> 5
     order by nrdconta,
              nrctrrpp;
  --Cursor para buscar rowid acumulado e atualizar tabela craptrd
  cursor cr_tbgen_relwrk_trd(pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type) is
    select distinct a.dschave rowid_trd
      from tbgen_batch_relatorio_wrk a
     where a.cdcooper    = pr_cdcooper
       and a.cdprograma  = 'CRPS148'
       and a.dsrelatorio = 'CRAPTRD'
       and a.dtmvtolt    = pr_dtmvtolt;

  --Cursor para buscar valores e atualizar a capa do lote na tabela craplot
  cursor cr_tbgen_relwrk_lot(pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type) is
    select nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))),0) vlinfocr,
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))),0) vlcompcr,
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))),0) vlinfodb,
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))),0) vlcompdb,
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,5)+1,instr(a.dscritic,';',1,6)-instr(a.dscritic,';',1,5)-1))),0) qtinfoln,
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,6)+1,instr(a.dscritic,';',1,7)-instr(a.dscritic,';',1,6)-1))),0) qtcompln,
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))),0) +
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))),0) +
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))),0) +
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))),0) +
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,5)+1,instr(a.dscritic,';',1,6)-instr(a.dscritic,';',1,5)-1))),0) +
           nvl(sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,6)+1,instr(a.dscritic,';',1,7)-instr(a.dscritic,';',1,6)-1))),0) vltotal
      from tbgen_batch_relatorio_wrk a
     where a.cdcooper    = pr_cdcooper
       and a.cdprograma  = 'CRPS148'
       and a.dsrelatorio = 'CRAPLOT'
       and a.dtmvtolt    = pr_dtmvtolt;

  --PL TABLE para armazenar indice para realizar update forall
  TYPE typ_tbgen_relwrk IS TABLE OF cr_tbgen_relwrk_trd%ROWTYPE INDEX BY PLS_INTEGER;
  vr_typ_tbgen_relwrk   typ_tbgen_relwrk;

  vr_tbgen_relwrk_lot cr_tbgen_relwrk_lot%rowtype;
  -- Registro para armazenar as datas
  rw_crapdat     btch0001.cr_crapdat%rowtype;
  -- Exception para tratamento de erros tratáveis sem abortar a execução
  vr_exc_mensagem  exception;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtopr      crapdat.dtmvtopr%type;
  vr_inproces      crapdat.inproces%type;
  --Informacoes tabelas genericas
  vr_prcaplic      craptab.dstextab%type;
  -- Saldo calculado da poupança
  vr_vlsdrdpp      craprpp.vlsdrdpp%type := 0;
  -- Tratamento de erros
  vr_exc_erro      exception;
  -- ID para o paralelismo
  vr_idparale      integer;
  --Variaveis de Excecao
  vr_exc_saida     exception;
  -- Qtde parametrizada de Jobs
  vr_qtdjobs       number;
  -- Job name dos processos criados
  vr_jobname       varchar2(30);
  -- Bloco PLSQL para chamar a execução paralela do pc_crps750
  vr_dsplsql       varchar2(4000);
  --Variaveis para retorno de erro
  vr_cdcritic      integer:= 0;
  vr_dscritic      varchar2(4000);
  --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
  vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
  vr_idlog_ini_ger tbgen_prglog.idprglog%type;
  vr_idlog_ini_par tbgen_prglog.idprglog%type;
  vr_tpexecucao    tbgen_prglog.tpexecucao%type;
  vr_qterro        number := 0;


begin

  vr_cdprogra := 'CRPS148';
  --
  if nvl(pr_idparale,0) = 0 then
    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    vr_idlog_ini_ger := null;
    pc_log_programa(pr_dstiplog   => 'I',
                    pr_cdprograma => vr_cdprogra,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_ger);
  end if;
  --

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS148',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);
  -- Se retornou algum erro
  if pr_cdcritic <> 0 then
    -- Buscar descrição do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    -- Envio centralizado de log de erro
    raise vr_exc_erro;
  end if;

  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
  fetch btch0001.cr_crapdat into rw_crapdat;
  if btch0001.cr_crapdat%notfound then
    -- Fechar o cursor pois haverá raise
    close btch0001.cr_crapdat;
    pr_cdcritic:= 1;
    -- Montar mensagem de critica
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    raise vr_exc_erro;
  else
    -- Atribuir a proxima data do movimento
    vr_dtmvtopr := rw_crapdat.dtmvtopr;
    -- Atribuir o indicador de processo
    vr_inproces := rw_crapdat.inproces;
  end if;
  close btch0001.cr_crapdat;

  -- Buscar o percentual de IR da aplicação
  vr_prcaplic := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                            pr_nmsistem => 'CRED',
                                            pr_tptabela => 'CONFIG',
                                            pr_cdempres => 0,
                                            pr_cdacesso => 'PERCIRAPLI',
                                            pr_tpregist => 0);

  -- Buscar quantidade parametrizada de Jobs
  vr_qtdjobs := gene0001.fn_retorna_qt_paralelo( pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                               , vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                               );

  /* Paralelismo visando performance Rodar Somente no processo Noturno */
  if vr_inproces         > 2 and
     vr_qtdjobs          > 0 and
     pr_cdagenci         = 0 then

    -- Gerar o ID para o paralelismo
    vr_idparale := gene0001.fn_gera_ID_paralelo;

    -- Se houver algum erro, o id vira zerado
    IF vr_idparale = 0 THEN
       -- Levantar exceção
       vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
       RAISE vr_exc_saida;
    END IF;

    -- Verifica se algum job paralelo executou com erro
    vr_qterro := 0;
    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                  pr_cdprogra    => vr_cdprogra,
                                                  pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                  pr_tpagrupador => 1,
                                                  pr_nrexecucao  => 1);

    -- Retorna as agências, com poupança programada
    for rw_craprpp_age in cr_craprpp_age (pr_cdcooper,
                                          vr_dtmvtopr,
                                          vr_cdprogra,
                                          vr_qterro,
                                          rw_crapdat.dtmvtolt) loop

      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := vr_cdprogra ||'_'|| rw_craprpp_age.cdagenci || '$';

      -- Cadastra o programa paralelo
      gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                ,pr_idprogra => LPAD(rw_craprpp_age.cdagenci,3,'0') --> Utiliza a agência como id programa
                                ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      -- Montar o bloco PLSQL que será executado
      -- Ou seja, executaremos a geração dos dados
      -- para a agência atual atraves de Job no banco
      vr_dsplsql := 'DECLARE' || chr(13) || --
                    '  wpr_stprogra NUMBER;' || chr(13) || --
                    '  wpr_infimsol NUMBER;' || chr(13) || --
                    '  wpr_cdcritic NUMBER;' || chr(13) || --
                    '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                    'BEGIN' || chr(13) || --
                    '  pc_crps148( '|| pr_cdcooper || ',' ||
                                       rw_craprpp_age.cdagenci || ',' ||
                                       vr_idparale || ',' ||
                                       'null' || ',' ||
                                       ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' ||
                    chr(13) || --
                    'END;'; --

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
    --dbms_output.put_line('Inicio pc_aguarda_paralelo GERAL - '||to_char(sysdate,'hh24:mi:ss'));
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
    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                  pr_cdprogra    => vr_cdprogra,
                                                  pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                  pr_tpagrupador => 1,
                                                  pr_nrexecucao  => 1);
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
    if  vr_dscritic is not null then
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;

    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    pc_log_programa(pr_dstiplog   => 'I',
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_par);

    -- Grava LOG de ocorrência inicial do cursor cr_craprpp
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Início - cursor cr_craprpp. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini_par);

    -- Processo antigo sem paralelismo
    -- Buscar informações da poupança programada
    for rw_craprpp in cr_craprpp (pr_cdcooper,
                                  vr_dtmvtopr,
                                  pr_cdagenci) loop

      --Executa cálculo de poupança (antigo poupanca.i)
      apli0001.pc_calc_poupanca (pr_cdcooper  => pr_cdcooper,          --> Cooperativa
                                 pr_dstextab  => vr_prcaplic,          --> Percentual de IR da aplicação
                                 pr_cdprogra  => vr_cdprogra,          --> Programa chamador
                                 pr_inproces  => vr_inproces,          --> Indicador do processo
                                 pr_dtmvtolt  => rw_crapdat.dtmvtolt,  --> Data do processo
                                 pr_dtmvtopr  => vr_dtmvtopr,          --> Próximo dia útil
                                 pr_rpp_rowid => rw_craprpp.rowid,     --> Identificador do registro da tabela CRAPRPP em processamento
                                 pr_vlsdrdpp  => vr_vlsdrdpp,          --> Saldo da poupança programada
                                 pr_cdcritic  => pr_cdcritic,          --> Código da critica de erro
                                 pr_des_erro  => pr_dscritic);         --> Descrição do erro encontrado
      if pr_dscritic is not null or pr_cdcritic is not null then
        raise vr_exc_erro;
      end if;
    
    --Executa migração de poupança (antigo poupanca.i)
    cecred.pc_migra_poupanca_prog (pr_cdcooper  => pr_cdcooper,          --> Cooperativa
                               pr_cdprogra  => vr_cdprogra,          --> Programa chamador
                               pr_inproces  => vr_inproces,          --> Indicador do processo
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,  --> Data do processo
                               pr_dtmvtopr  => vr_dtmvtopr,          --> Data do processo
                               pr_vlsdrdpp  => vr_vlsdrdpp,                     --> Valor de saldo da RPP
                               pr_rpp_rowid => rw_craprpp.rowid,     --> Identificador do registro da tabela CRAPRPP em processamento
                               pr_cdcritic  => pr_cdcritic,          --> Código da critica de erro
                               pr_dscritic  => pr_dscritic);         --> Descrição do erro encontrado
    if pr_dscritic is not null or pr_cdcritic is not null then
      raise vr_exc_erro;
    end if;
    end loop;

    -- Grava LOG de ocorrência final do cursor cr_craprpp
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim - cursor cr_craprpp. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini_par);

    --Grava data fim para o JOB na tabela de LOG
    pc_log_programa(pr_dstiplog   => 'F',
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_par,
                    pr_flgsucesso => 1);
  end if;

  --Se for o programa principal ou sem paralelismo
  if nvl(pr_idparale,0) = 0 then
    --
    -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra, --||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Inicio - Atualiza tabela craptrd.',
                    PR_IDPRGLOG           => vr_idlog_ini_ger);

    --Cursor com registros a serem atualizados na tabela craptrd
    open cr_tbgen_relwrk_trd(rw_crapdat.dtmvtolt);
    loop
      --fetch no cursor carregando 5 mil registros
      fetch cr_tbgen_relwrk_trd bulk collect into vr_typ_tbgen_relwrk limit 50000;
        --Sai após processar os registros.
        exit when vr_typ_tbgen_relwrk.count = 0;
        --Realiza update dos registros utilizando forall
        forall idx in 1 .. vr_typ_tbgen_relwrk.count
          update craptrd b
             set b.incalcul = 2
           where rowid = vr_typ_tbgen_relwrk(idx).rowid_trd;

    end loop;
    close cr_tbgen_relwrk_trd;


    -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra, --||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim - Atualiza tabela craptrd.',
                    PR_IDPRGLOG           => vr_idlog_ini_ger);


    -- Grava LOG de ocorrência inicial de atualização da tabela craplot
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra, --||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Inicio - Atualiza tabela craplot.',
                    PR_IDPRGLOG           => vr_idlog_ini_ger);

    --Cursor com registros a serem atualizados na tabela craplot
    open cr_tbgen_relwrk_lot(rw_crapdat.dtmvtolt);
    --Realiza fetch no cursor
    fetch cr_tbgen_relwrk_lot into vr_tbgen_relwrk_lot;
    --Verifica se existem registros
    if cr_tbgen_relwrk_lot%found then
      if vr_tbgen_relwrk_lot.vltotal <> 0 then
      begin
        update craplot
           set craplot.vlinfocr = vr_tbgen_relwrk_lot.vlinfocr,
               craplot.vlcompcr = vr_tbgen_relwrk_lot.vlcompcr,
               craplot.qtinfoln = vr_tbgen_relwrk_lot.qtinfoln,
               craplot.qtcompln = vr_tbgen_relwrk_lot.qtcompln,
               craplot.vlinfodb = vr_tbgen_relwrk_lot.vlinfodb,
               craplot.vlcompdb = vr_tbgen_relwrk_lot.vlcompdb,
               craplot.nrseqdig = CRAPLOT_8384_SEQ.NEXTVAL
         where craplot.dtmvtolt = rw_crapdat.dtmvtopr
           and craplot.cdagenci = 1
           and craplot.cdbccxlt = 100
           and craplot.nrdolote = 8384
           and craplot.tplotmov = 14
           and craplot.cdcooper = pr_cdcooper;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar tabela craplot: '||sqlerrm;
          raise vr_exc_saida;
      end;

        --Insere lote quando o mesmo não existe.
        if sql%rowcount = 0 then
          begin
            insert into craplot (dtmvtolt,
                                 cdagenci,
                                 cdbccxlt,
                                 nrdolote,
                                 tplotmov,
                                 nrseqdig,
                                 cdcooper,
                                 vlinfocr,
                                 vlcompcr,
                                 qtinfoln,
                                 qtcompln,
                                 vlinfodb,
                                 vlcompdb)
            values (rw_crapdat.dtmvtopr,
                    1,
                    100,
                    8384,
                    14,
                    CRAPLOT_8384_SEQ.NEXTVAL,
                    pr_cdcooper,
                    vr_tbgen_relwrk_lot.vlinfocr,
                    vr_tbgen_relwrk_lot.vlcompcr,
                    vr_tbgen_relwrk_lot.qtinfoln,
                    vr_tbgen_relwrk_lot.qtcompln,
                    vr_tbgen_relwrk_lot.vlinfodb,
                    vr_tbgen_relwrk_lot.vlcompdb);
          exception
            when others then
              vr_dscritic := 'Erro ao inserir informações da capa de lote: '||sqlerrm;
              vr_cdcritic := 0;
              raise vr_exc_erro;
          end;
        end if;
      end if;

  end if;
    --Fecha cursor
    close cr_tbgen_relwrk_lot;

    begin
      --Limpa os registros da tabela de trabalho
      delete from tbgen_batch_relatorio_wrk
        where cdcooper   = pr_cdcooper
          and cdprograma like 'CRPS148%'
          and dtmvtolt   = rw_crapdat.dtmvtolt;
    exception
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
        raise vr_exc_saida;
    end;

    -- Grava LOG de ocorrência inicial de atualização da tabela craptrd
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra, --||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim - Atualiza tabela craplot.',
                    PR_IDPRGLOG           => vr_idlog_ini_ger);


    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);

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

      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => vr_cdprogra,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_ger,
                    pr_flgsucesso => 1);

    --Salvar informacoes no banco de dados
    commit;
  else

    -- Atualiza finalização do batch na tabela de controle
    gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                       ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                       ,pr_dscritic     --pr_dscritic  OUT crapcri.dscritic%TYPE
                                       );

    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                ,pr_des_erro => vr_dscritic);

    --Salvar informacoes no banco de dados
    commit;
  end if;
exception
  when vr_exc_erro then
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;

    if nvl(pr_idparale,0) <> 0 then
      -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'E',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 3,
                      pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                               'pr_dscritic:'||pr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini_par);

      --Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 0);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
    end if;
    -- Desfazer as alterações
    rollback;
  WHEN vr_exc_saida THEN
      -- Se foi retornado apenas codigo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descricao
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos codigo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF nvl(pr_idparale,0) <> 0 THEN

        --Grava data fim para o JOB na tabela de LOG
        pc_log_programa(pr_dstiplog   => 'F',
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper   => pr_cdcooper,
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);

        -- Grava LOG de erro com as críticas retornadas
        pc_log_programa(pr_dstiplog      => 'E',
                        pr_cdprograma    => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper      => pr_cdcooper,
                        pr_tpexecucao    => vr_tpexecucao,
                        pr_tpocorrencia  => 3,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => pr_cdcritic,
                        pr_dsmensagem    => pr_dscritic,
                        pr_flgsucesso    => 0,
                        pr_idprglog      => vr_idlog_ini_par);

        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);

      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
      END IF;
      -- Efetuar rollback
      ROLLBACK;

  when others then

    if nvl(pr_idparale,0) <> 0 then
      -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'E',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 2,
                      pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                               'pr_dscritic:'||pr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini_par);

      --Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 0);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
    end if;


    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Desfazer as alterações
    rollback;
END; 
/
