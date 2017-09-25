CREATE OR REPLACE PROCEDURE CECRED.pc_crps714 (pr_cdcooper IN crapcop.cdcooper%TYPE ) IS   --> Cooperativa solicitada
  /* .............................................................................

     Programa: pc_crps714
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Março/2017                     Ultima atualizacao: 20/03/2017

     Dados referentes ao programa:

     Frequencia: Executado via Job
     Objetivo  : Realizar importação do arquivo de Cessao de fatura de cartao

     Alteracoes: 12/09/2017 - Adicionar validacao para impedir a importacao de cessao
                              duplicada. Ajustado para nao abortar importacao quando
                              apresentar erro durante a execucao do shell (Anderson).

  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS714';
  vr_cdcooper   NUMBER  := 3;
  vr_qtlinha    PLS_INTEGER;
  vr_vltotal    NUMBER(14,2);

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_prox   EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop(pr_cdagebcb crapcop.cdagebcb%TYPE) IS
    SELECT cop.nmrescop
          ,cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdagebcb = pr_cdagebcb;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  
  -- buscar nome do programa
  CURSOR cr_crapprg IS
    SELECT lower(crapprg.dsprogra##1) dsprogra##1
      FROM crapprg 
     WHERE cdcooper = vr_cdcooper
       AND cdprogra = vr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;
  
  --> Buscar dados do cooperado
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                    pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta,
           ass.nmprimtl,
           ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta; 
  rw_crapass cr_crapass%ROWTYPE;
  
  --> Verificar se existe cartao cadastrado
  CURSOR cr_crawcrd (pr_cdcooper crapass.cdcooper%TYPE,
                     pr_nrdconta crapass.nrdconta%TYPE,
                     pr_nrcartao NUMBER)  IS  
    SELECT 1
      FROM crawcrd wcrd
     WHERE wcrd.cdcooper = pr_cdcooper
       AND wcrd.nrdconta = pr_nrdconta
       AND wcrd.nrcctitg = pr_nrcartao /* Conta Cartão */
       AND wcrd.cdadmcrd BETWEEN 10 AND 80; /* Bancoob */
       
  --> Verificar se existe cartao cadastrado - tabela relacionamento
  CURSOR cr_tbcrd_conta_cartao (pr_cdcooper crapass.cdcooper%TYPE,
                                pr_nrdconta crapass.nrdconta%TYPE,
                                pr_nrcartao NUMBER)  IS  
    SELECT 1
      FROM tbcrd_conta_cartao crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrdconta = pr_nrdconta
       AND crd.nrconta_cartao = pr_nrcartao;  
  
  --> Verificar se cessão foi criada
  CURSOR cr_cessao (pr_cdcooper tbcrd_cessao_credito.cdcooper%TYPE,
                    pr_nrdconta tbcrd_cessao_credito.nrdconta%TYPE,      
                    pr_nrcartao tbcrd_cessao_credito.nrconta_cartao%TYPE,
                    pr_dtvencto tbcrd_cessao_credito.dtvencto%TYPE,
                    pr_dtmvtolt crapepr.dtmvtolt%TYPE,
                    pr_vlemprst crapepr.vlemprst%TYPE)IS
    SELECT epr.vlemprst
      FROM tbcrd_cessao_credito ces
      JOIN crapepr epr
        ON epr.cdcooper       = ces.cdcooper
       AND epr.nrdconta       = ces.nrdconta
       AND epr.nrctremp       = ces.nrctremp
     WHERE ces.cdcooper       = pr_cdcooper
       AND ces.nrdconta       = pr_nrdconta
       AND ces.nrconta_cartao = pr_nrcartao
       AND ces.dtvencto       = pr_dtvencto
       AND epr.dtmvtolt       = pr_dtmvtolt
       AND epr.vlemprst       = pr_vlemprst;
  rw_cessao cr_cessao%ROWTYPE;

  --> Verificar se existe uma cessao ja importada
  CURSOR cr_cessao_cad (pr_cdcooper tbcrd_cessao_credito.cdcooper%TYPE,
                        pr_nrdconta tbcrd_cessao_credito.nrdconta%TYPE,      
                        pr_nrcartao tbcrd_cessao_credito.nrconta_cartao%TYPE,
                        pr_dtmvtolt crapepr.dtmvtolt%TYPE,
                        pr_vlemprst crapepr.vlemprst%TYPE)IS
    SELECT epr.nrctremp
      FROM tbcrd_cessao_credito ces
      JOIN crapepr epr
        ON epr.cdcooper       = ces.cdcooper
       AND epr.nrdconta       = ces.nrdconta
       AND epr.nrctremp       = ces.nrctremp
     WHERE ces.cdcooper       = pr_cdcooper
       AND ces.nrdconta       = pr_nrdconta
       AND ces.nrconta_cartao = pr_nrcartao
       AND epr.dtmvtolt       = pr_dtmvtolt
       AND epr.vlemprst       = pr_vlemprst;
  rw_cessao_cad cr_cessao_cad%ROWTYPE;
  
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  vr_tab_linhas gene0009.typ_tab_linhas;
  
  /* Estrutura de-para de código tipo cartão - Bancoob > Ayllos */
  TYPE typ_tab_tipo_cartao IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  vr_tab_tipo_cartao typ_tab_tipo_cartao;
  ------------------------------- VARIAVEIS -------------------------------
  
  -- Nome do arquivo para importação
  vr_nmarqimp     VARCHAR2(500);
  vr_listdarq     VARCHAR2(500);
  vr_dscomand     VARCHAR2(2000);
  vr_typ_saida    VARCHAR2(4000); 
  
  -- Nome do arquivo de log
  vr_nmarqlog     VARCHAR2(500);
  vr_nmlogtmp     VARCHAR2(500);
  
  -- Nome do diretorio da cooperativa  
  vr_dsdirarq     VARCHAR2(500);
  
  vr_cdfinali     crapepr.cdfinemp%TYPE;
  vr_cdlcremp     crapepr.cdlcremp%TYPE;
  vr_cdagebcb     crapcop.cdagebcb%TYPE;
  vr_nrdconta     crapass.nrdconta%TYPE;
  vr_vldevido     crapepr.vlemprst%TYPE;
  vr_nrcartao     NUMBER;
  vr_nrexiste     INTEGER;
  vr_dtvencto     DATE;
  vr_dtvencto_ori DATE;
  vr_cdadmcrd     NUMBER;
  vr_cdadmcrd_bcb NUMBER;
  vr_lsdparam     VARCHAR2(4000);
  vr_dsscript     VARCHAR2(4000);
  
  --------------------------- SUBROTINAS INTERNAS --------------------------

  vr_nomdojob    VARCHAR2(40) := 'JBCRD_IMPORTA_CESSAO';
  vr_flgerlog    BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --> Controlar geração de log de execução dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch;
  
  --> Gerar log do processo de importação
  PROCEDURE pc_gera_log(pr_dscritic IN VARCHAR2) IS
  
    vr_dscritic VARCHAR2(1000);
  BEGIN
    vr_dscritic := to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' --> '||
                   pr_dscritic;
                   
    btch0001.pc_gera_log_batch (pr_cdcooper     => pr_cdcooper, 
                                pr_cdprograma   => vr_nomdojob,
                                pr_ind_tipo_log => 1, 
                                pr_des_log      => vr_dscritic, 
                                pr_nmarqlog     => vr_nmlogtmp,                                 
                                pr_flfinmsg     => 'N', 
                                pr_dsdirlog     => vr_dsdirarq);
  
  
  END pc_gera_log;
  
  /* Carga da tabela de-para com os códigos do tipo de cartão - Bancoob > Ayllos 
       Codigo 950 => 16 - CECRED MASTERCARD DEBITO BANCOOB 
       Codigo 951 => 12 - CECRED MASTERCARD CLASSICO BANCOOB
       Codigo 952 => 13 - CECRED MASTERCARD GOLD BANCOOB
       Codigo 953 => 15 - CECRED MASTERCARD EMPRESAS BANCOOB
       Codigo 954 => 17 - CECRED MASTERCARD EMPRESAS DEBITO BANCOOB      
       Codigo 955 => 14 - CECRED MASTERCARD PLATINUM BANCOOB
       Codigo 756 => 11 - CECRED CABAL ESSENCIAL BANCOOB                    */
  PROCEDURE pc_carga_tabela_tipo_cartao(pr_dscritic OUT VARCHAR2) IS
    vr_dsparam   VARCHAR2(2000);
    vr_tbdados   gene0002.typ_split;
    vr_tbdepara  gene0002.typ_split;
    i            PLS_INTEGER := 0;
    vr_cdbancoob PLS_INTEGER;
    vr_cdadmcrd  PLS_INTEGER;
  BEGIN
   
    vr_dsparam := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                            pr_cdcooper => pr_cdcooper,
                                            pr_cdacesso => 'CRED_DEPARA_TIPOCARTAO');    

    vr_tbdados := gene0002.fn_quebra_string(pr_string  => vr_dsparam,
                                            pr_delimit => '#');  
                                            
    LOOP
      i := i + 1;
      EXIT WHEN NOT vr_tbdados.exists(i);
      EXIT WHEN i = 100;
      
      vr_tbdepara := gene0002.fn_quebra_string(pr_string  => vr_tbdados(i),
                                               pr_delimit => ';');
      IF (vr_tbdepara.exists(1) AND vr_tbdepara.exists(2)) THEN
        vr_cdbancoob := CAST(vr_tbdepara(1) as PLS_INTEGER);
        vr_cdadmcrd  := cast(vr_tbdepara(2) as PLS_INTEGER);
        vr_tab_tipo_cartao(vr_cdbancoob) := vr_cdadmcrd;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN      
      pr_dscritic := 'Erro durante a carga de tipo cartao! '|| nvl(pr_dscritic,' ')||' '||SQLERRM;
  END pc_carga_tabela_tipo_cartao;
  
  /* Procedimento para o DE-PARA dos codigos de tipo de cartao.
     Avaliar possibilidade de inclusao desses codigos na tela ADMCRD */
  PROCEDURE pc_tipo_cartao(pr_cdtipocartao IN NUMBER
                          ,pr_cdadmcrd    OUT crawcrd.cdadmcrd%TYPE) IS
    vr_cdcartao NUMBER;
  BEGIN    
    pr_cdadmcrd := 0;
    --> O codigo do tipo do cartao esta nas 3 primeiras posicoes.
    vr_cdcartao := substr(pr_cdtipocartao,0,3);
    IF (vr_tab_tipo_cartao.exists(vr_cdcartao)) THEN
      pr_cdadmcrd := vr_tab_tipo_cartao(vr_cdcartao);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
        pr_cdadmcrd := 0;
  END pc_tipo_cartao;    
  
BEGIN

  --------------- VALIDACOES INICIAIS -----------------
  
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
  
  -- Buscar nome do programa
  OPEN cr_crapprg;
  FETCH cr_crapprg INTO rw_crapprg;
  CLOSE cr_crapprg;
  
  -- Verificar se é para rodar para todas as cooperativas
  IF pr_cdcooper = 0 THEN
    vr_cdcooper := 3;
  ELSE
    vr_cdcooper := pr_cdcooper;
  END IF;
  

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  vr_dsdirarq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'NMDIRETO_CESSAO_CARTAO');
  
  
  
  IF vr_dsdirarq IS NULL THEN
    vr_dscritic := 'Diretorio do arquivo de cessao nao encontrado.';
    RAISE vr_exc_saida;  
  END IF;
  
  --> Nome do arquivo csv para importacao
  vr_nmarqimp := to_char(SYSDATE,'RRRRMMDD');  
  --> Nome do arquivo de log temporario
  vr_nmlogtmp := to_char(SYSDATE,'RRRRMMDD')||'temp';  
  --> Nome do arquivo de log oficial
  vr_nmarqlog := to_char(SYSDATE,'RRRRMMDD')||'_'||to_char(SYSDATE, 'hh24miss');
  
  gene0001.pc_lista_arquivos(pr_path     => vr_dsdirarq||'/Importar/', 
                             pr_pesq     => vr_nmarqimp||'.csv', 
                             pr_listarq  => vr_listdarq, 
                             pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  IF vr_listdarq IS NULL THEN
    --> Caso nao encontr o arquivo, apenas sai do processo
    --> arquivo poderá ser processado posteriormente
    --vr_dscritic := 'Arquivo '||vr_nmarqimp||' não encontrado.';
    RETURN;
  END IF;
  
  -- Log de inicio da execução
  pc_controla_log_batch('I');
  
  pc_gera_log(pr_dscritic => 'Inicio da importação do arquivo '||vr_nmarqimp||'.csv');
  
  --> Importar o arquivo texto
  gene0009.pc_importa_arq_layout(pr_nmlayout   => 'CESSAO_CARTAO', 
                                 pr_dsdireto   => vr_dsdirarq||'/Importar/', 
                                 pr_nmarquiv   => vr_nmarqimp||'.csv', 
                                 pr_dscritic   => vr_dscritic, 
                                 pr_tab_linhas => vr_tab_linhas);
  
  
  IF vr_tab_linhas.count = 0 THEN
    vr_dscritic := 'Arquivo ' || vr_nmarqimp || '.csv não possui conteúdo!';    
    RAISE vr_exc_saida;
  END IF;
  
  --> Buscar parametros gerais
  vr_cdfinali := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'CDFINALI_CESSAO_CARTAO');
                                           
  vr_cdlcremp := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'CDLINHA_CESSAO_CARTAO');                                           
  
  
  vr_dsscript := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'SHELL_CRPS714');                                           
  
  pc_carga_tabela_tipo_cartao(vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  --> Inicializa variaveis totalizadoras
  vr_qtlinha := 0;
  vr_vltotal := 0;
  vr_nrdconta := 0;
  
  --> ler linhas do arquivo
  FOR vr_idx IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
    BEGIN
      vr_nrdconta := 0;
      --> Ignorar Header 
      IF vr_idx = 1 THEN
        continue;
      END IF;
    
      --Problemas com importacao do layout
      IF vr_tab_linhas(vr_idx).exists('$ERRO$') THEN 
        vr_dscritic := 'Erro ao importar linha '|| vr_idx ||': '||
                        vr_tab_linhas(vr_idx)('$ERRO$').texto;
        RAISE vr_exc_prox;
      END IF;
      
      vr_cdagebcb := vr_tab_linhas(vr_idx)('CDAGEBCB').NUMERO;
      vr_nrdconta := vr_tab_linhas(vr_idx)('NRDCONTA').NUMERO;
      vr_nrcartao := vr_tab_linhas(vr_idx)('NRCARTAO').NUMERO;
      vr_vldevido := vr_tab_linhas(vr_idx)('VLDEVIDO').NUMERO;
      vr_cdadmcrd_bcb := vr_tab_linhas(vr_idx)('TPCARTAO').NUMERO;
      vr_dtvencto_ori := vr_tab_linhas(vr_idx)('DTVENCTO').DATA;
      
      -- Caso valor for negativo
      IF vr_vldevido < 0 THEN
        vr_dscritic := 'Valor negativo não permitido.';
        RAISE vr_exc_prox;
      END IF;
      
      -- Caso valor estiver zerado
      IF vr_vldevido = 0 THEN
        vr_dscritic := 'Valor zerado não permitido.';
        RAISE vr_exc_prox;
      END IF;
      
      -- Caso a data de vencimento esteja vazia
      IF vr_dtvencto_ori IS NULL THEN
        vr_dscritic := 'Data de Vencimento nula não permitido.';
        RAISE vr_exc_prox;
      END IF;
      
      -- Busca dos dados da cooperativa
      OPEN cr_crapcop(pr_cdagebcb => vr_cdagebcb);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_dscritic := 'Cooperativa não identificada cdagebcb: '||vr_cdagebcb;
        RAISE vr_exc_prox;
      END IF;
      CLOSE cr_crapcop;
      
      --> Buscar dados do cooperado
      OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper,
                      pr_nrdconta => vr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Cooperado não encontrado';
        RAISE vr_exc_prox;
      END IF;
      CLOSE cr_crapass;
      
      --> Verificar se existe cartao cadastrado
      OPEN cr_crawcrd (pr_cdcooper => rw_crapcop.cdcooper,
                       pr_nrdconta => rw_crapass.nrdconta,
                       pr_nrcartao => vr_nrcartao); 
      FETCH cr_crawcrd INTO vr_nrexiste;
      IF cr_crawcrd%NOTFOUND THEN
        CLOSE cr_crawcrd;
        vr_dscritic := 'Conta Cartão '||vr_nrcartao||' não encontrada';
        RAISE vr_exc_prox;
      END IF;
      CLOSE cr_crawcrd;            
      
      --> Verificar se existe cartao cadastrado - tabela relacionamento
      OPEN cr_tbcrd_conta_cartao (pr_cdcooper => rw_crapcop.cdcooper,
                                  pr_nrdconta => rw_crapass.nrdconta,
                                  pr_nrcartao => vr_nrcartao); 
      FETCH cr_tbcrd_conta_cartao INTO vr_nrexiste;
      IF cr_tbcrd_conta_cartao%NOTFOUND THEN
        CLOSE cr_tbcrd_conta_cartao;
        vr_dscritic := 'Relacionamento Conta Cartão '||vr_nrcartao||' não encontrada';
        RAISE vr_exc_prox;
      END IF;
      CLOSE cr_tbcrd_conta_cartao;
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN

        CLOSE btch0001.cr_crapdat;
        vr_dscritic := 'Data de movimento não encontrada';
        RAISE vr_exc_prox;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;

      --> Ignorar se o processo estiver rodando
      IF rw_crapdat.inproces > 1 THEN
        vr_dscritic := 'Cooperativa '|| rw_crapcop.cdcooper ||' está com o processo em execução.';
        RAISE vr_exc_prox;
      END IF;
            
      --> Definir data de vencimento do emprestimo
      vr_dtvencto := rw_crapdat.dtmvtolt + 1;
      IF to_char(vr_dtvencto,'DD') >= 28 THEN
        vr_dtvencto := trunc(add_months(vr_dtvencto,1),'MM');
      END IF;
      
      --> Busca codigo do tipo de cartao
      pc_tipo_cartao(vr_cdadmcrd_bcb, vr_cdadmcrd);
      IF vr_cdadmcrd = 0 THEN
        vr_dscritic := 'Administradora de Cartão '||vr_cdadmcrd_bcb||' não encontrada.';
        RAISE vr_exc_prox;
      END IF;

      --> Valida cessao importada em duplicidade
      OPEN cr_cessao_cad (pr_cdcooper => rw_crapcop.cdcooper,
                          pr_nrdconta => rw_crapass.nrdconta,
                          pr_nrcartao => vr_nrcartao,
                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                          pr_vlemprst => vr_vldevido);
      FETCH cr_cessao_cad INTO rw_cessao_cad;
      IF cr_cessao_cad%FOUND THEN
        CLOSE cr_cessao_cad;
        vr_dscritic := 'Cessão de Crédito já importada (Contrato: '|| rw_cessao_cad.nrctremp ||').';
        RAISE vr_exc_prox;
      END IF;
      CLOSE cr_cessao_cad;
      
      ----------------->> CHAMADA ROTINA PROGRESS <<----------------
      vr_lsdparam :=  rw_crapcop.cdcooper ||';'|| --> 'par_cdcooper' 
                      rw_crapass.cdagenci ||';'|| --> 'par_cdagenci'                      
                      rw_crapass.nrdconta ||';'|| --> 'par_nrdconta'                       
                      vr_vldevido         ||';'|| --> 'par_vlemprst' 
                      to_char(vr_dtvencto,'MMDDRRRR')         ||';'|| --> 'par_dtdpagto' 
                      vr_cdlcremp         ||';'|| --> 'par_cdlcremp' 
                      vr_cdfinali         ||';'|| --> 'par_cdfinemp' 
                      vr_nrcartao         ||';'|| 
                      to_char(vr_dtvencto_ori,'MMDDRRRR')     ||';'|| 
                      vr_cdadmcrd         ||';'|| 
                      vr_dsdirarq||'/'||vr_nmlogtmp||'.log';
      
      
      
      vr_dscomand := vr_dsscript || ' "'||vr_lsdparam||'"';
      
      -- Efetuar a execução do comando ls, para verificar se existe diretorio
      gene0001.pc_OScommand(pr_typ_comando  => 'SR'
                            ,pr_des_comando => vr_dscomand
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
      
      /* Nao vamos abortar caso apresente algum erro na chamada do Shell, pois em alguns 
         casos, o shell retorna erro mas executa normalmente o crps714, gerando o emprestimo 
         de cessao, porem marcando com erro no arquivo log. Dessa forma, a area de negocio 
         acaba por entendendo que nao importou e pode realizar a importacao em duplicidade da
         cessao. Caso for necessario consultar essa informacao, esta salva na crapcso.
      IF vr_typ_saida = 'ERR' THEN        
        vr_dscritic:= 'Erro ao gerar cessao: '|| vr_dscritic;
        RAISE vr_exc_prox;
      END IF; */
  
      ----------------->> FIM CHAMADA ROTINA PROGRESS <<----------------
      
      --> Verificar se cessao foi criada com sucesso
      OPEN cr_cessao (pr_cdcooper => rw_crapcop.cdcooper,
                      pr_nrdconta => rw_crapass.nrdconta,
                      pr_nrcartao => vr_nrcartao,
                      pr_dtvencto => vr_dtvencto_ori,
                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                      pr_vlemprst => vr_vldevido);
      FETCH cr_cessao INTO rw_cessao;
      IF cr_cessao%NOTFOUND THEN
        vr_dscritic := 'Contrato de cessão de credito não foi criado';
        pc_gera_log(pr_dscritic => 'Linha: '||vr_idx||' Conta: '||vr_nrdconta||' -> '||vr_dscritic);
      ELSE
        pc_gera_log(pr_dscritic => 'Linha: '||vr_idx||' Conta: '||vr_nrdconta||' -> Importada com sucesso!');
        vr_qtlinha := vr_qtlinha + 1;
        vr_vltotal := vr_vltotal + rw_cessao.vlemprst;
      END IF;
      CLOSE cr_cessao;
            
      
    EXCEPTION  
      WHEN vr_exc_prox THEN
        IF vr_nrdconta > 0 THEN
          pc_gera_log(pr_dscritic => 'Linha: '||vr_idx||' Conta: '||vr_nrdconta||' -> '||vr_dscritic);
        ELSE
          pc_gera_log(pr_dscritic => 'Linha: '||vr_idx||' -> '||vr_dscritic);
        END IF;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao processar a linha '|| vr_idx ||': '||SQLERRM;
        pc_gera_log(pr_dscritic => vr_dscritic);
    END;
  END LOOP;

  -- Montar Comando para mover o arquivo lido para o diretório importados
  vr_dscomand:= 'mv '|| vr_dsdirarq || '/Importar/' || vr_nmarqimp || '.csv ' ||
                 vr_dsdirarq || '/Importados/' || vr_nmarqimp || '_' || to_char(SYSDATE, 'hh24miss') ||'.csv ';
                                   
  -- Executar o comando no unix
  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                       ,pr_des_comando => vr_dscomand
                       ,pr_typ_saida   => vr_typ_saida
                       ,pr_des_saida   => vr_dscritic);
                             
  -- Se ocorreu erro dar RAISE
  IF vr_typ_saida = 'ERR' THEN        
    vr_dscritic:= 'Erro ao mover arquivo: '|| vr_dscritic;
    RAISE vr_exc_saida;
  END IF;
  
  pc_gera_log(pr_dscritic => 'Final da importação do arquivo '||vr_nmarqimp||'.csv -'||
                             ' Quantidade de Empréstimos criados: '|| to_char(vr_qtlinha,'fm000') || 
                             ' Valor Total: ' || to_char(vr_vltotal,'fm999g999g990d00') );

  --> Log de fim da execução
  pc_controla_log_batch('F');

  --> Converte log temporario para log oficial (DOS)
  vr_dscomand := 'ux2dos '|| vr_dsdirarq || '/' || vr_nmlogtmp || '.log > '
                          || vr_dsdirarq || '/' || vr_nmarqlog || '.log';

  -- Converter de UNIX para DOS o arquivo
  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                       ,pr_des_comando => vr_dscomand
                       ,pr_typ_saida   => vr_typ_saida
                       ,pr_des_saida   => vr_dscritic);

  IF vr_typ_saida = 'ERR' THEN
     -- O comando shell executou com erro, gerar log e sair do processo
     vr_dscritic := 'Erro ao converter arquivo de log: ' || vr_dscritic;
     RAISE vr_exc_saida;
  END IF;
  
  --> Remove arquivo de log temporario
  GENE0001.pc_OScommand(pr_typ_comando => 'S'
                       ,pr_des_comando => 'rm -f '|| vr_dsdirarq || '/' || vr_nmlogtmp || '.log'
                       ,pr_typ_saida   => vr_typ_saida
                       ,pr_des_saida   => vr_dscritic);

  IF vr_typ_saida = 'ERR' THEN
     -- O comando shell executou com erro, gerar log e sair do processo
     vr_dscritic := 'Erro ao remover arquivo de log: ' || vr_dscritic;
     RAISE vr_exc_saida;
  END IF;
                 
  -- Salvar informações atualizadas
  COMMIT;

EXCEPTION  
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    pc_controla_log_batch('E', vr_dscritic);
    pc_gera_log(pr_dscritic => vr_dscritic);
    
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := sqlerrm;
    
    -- Envio centralizado de log de erro
    vr_flgerlog := TRUE;
    pc_controla_log_batch('E', vr_dscritic);
    pc_gera_log(pr_dscritic => vr_dscritic);                                           
    -- Efetuar rollback
    ROLLBACK;

END pc_crps714;
/
