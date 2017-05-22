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

     Alteracoes: 

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
       AND wcrd.cdadmcrd BETWEEN 10 AND 80 /* Bancoob */
    UNION 
    SELECT 1
      FROM tbcrd_conta_cartao crd
     WHERE crd.cdcooper = pr_cdcooper
       AND crd.nrdconta = pr_nrdconta
       AND crd.nrconta_cartao = pr_nrcartao;
  
  --> Buscar codigo da adm do cartao
  CURSOR cr_crapadc (pr_cdcooper crapadc.cdcooper%TYPE, 
                     pr_nmadmcrd crapadc.nmadmcrd%TYPE )IS    
    SELECT adc.cdadmcrd
      FROM crapadc adc
     WHERE adc.cdcooper = pr_cdcooper
       AND upper(adc.nmadmcrd) LIKE '%'||pr_nmadmcrd||'%'
       AND upper(nmadmcrd) not like '%DEBITO%';
  rw_crapadc cr_crapadc%rowtype;
  
  
  --> Verificar se cessão foi criada
  CURSOR cr_cessao (pr_cdcooper tbcrd_cessao_credito.cdcooper%TYPE,
                    pr_nrdconta tbcrd_cessao_credito.nrdconta%TYPE,      
                    pr_nrcartao tbcrd_cessao_credito.nrconta_cartao%TYPE,
                    pr_dtvencto tbcrd_cessao_credito.dtvencto%TYPE,
                    pr_dtmvtolt crapepr.dtmvtolt%TYPE)IS
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
       and epr.dtmvtolt       = pr_dtmvtolt;
  rw_cessao cr_cessao%ROWTYPE;
  
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  vr_tab_linhas gene0009.typ_tab_linhas;
  
  ------------------------------- VARIAVEIS -------------------------------
  
  -- Nome do arquivo para importação
  vr_nmarqimp     VARCHAR2(500);
  vr_listdarq     VARCHAR2(500);
  vr_dscomand     VARCHAR2(2000);
  vr_typ_saida    VARCHAR2(4000); 
  
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
  vr_nrctremp     crapepr.nrctremp%TYPE;
  vr_nmadmcrd     VARCHAR2(100);
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
                                pr_ind_tipo_log => 1, 
                                pr_des_log      => vr_dscritic, 
                                pr_nmarqlog     => vr_nmarqimp,                                 
                                pr_flfinmsg     => 'N', 
                                pr_dsdirlog     => vr_dsdirarq);
  
  
  END pc_gera_log;
  
  
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
  
  vr_nmarqimp := to_char(SYSDATE,'RRRRMMDD');
  
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

  --> Inicializa variaveis totalizadoras
  vr_qtlinha := 0;
  vr_vltotal := 0;  
  
  --> ler linhas do arquivo
  FOR vr_idx IN vr_tab_linhas.first..vr_tab_linhas.last LOOP
    BEGIN
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
      vr_nmadmcrd := vr_tab_linhas(vr_idx)('TPCARTAO').TEXTO;
      vr_dtvencto_ori := vr_tab_linhas(vr_idx)('DTVENCTO').DATA;
      
      
      -- Caso valor for negativo
      IF vr_vldevido < 0 THEN
        vr_dscritic := 'Valor negativo não permitido.';
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
        vr_dscritic := 'Cooperado não encontrado nrdconta: '||vr_nrdconta;
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
        vr_dscritic := 'Cartão '||vr_nrcartao||' não encontrado para o cooperado '||vr_nrdconta;
        RAISE vr_exc_prox;
      END IF;
      CLOSE cr_crawcrd;            
      
      
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
      
      vr_nmadmcrd := REPLACE(REPLACE(vr_nmadmcrd,chr(10)),chr(13));
      vr_nmadmcrd := upper(gene0007.fn_caract_acento(vr_nmadmcrd));      
      
      rw_crapadc := NULL;
      --> Buscar codigo da adm do cartao
      OPEN cr_crapadc (pr_cdcooper => rw_crapcop.cdcooper,
                       pr_nmadmcrd => vr_nmadmcrd);
      FETCH cr_crapadc INTO rw_crapadc;
      IF cr_crapadc%NOTFOUND THEN
        CLOSE cr_crapadc;
        vr_dscritic := 'Administradora de Cartão '||vr_nmadmcrd||' não encontrado.';
        RAISE vr_exc_prox;
      END IF;
      CLOSE cr_crapadc;
      
      
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
                      rw_crapadc.cdadmcrd ||';'|| 
                      vr_dsdirarq||'/'||vr_nmarqimp||'.log';
      
      
      
      vr_dscomand := vr_dsscript || ' "'||vr_lsdparam||'"';
      
      -- Efetuar a execução do comando ls, para verificar se existe diretorio
      gene0001.pc_OScommand(pr_typ_comando  => 'SR'
                            ,pr_des_comando => vr_dscomand
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
      
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN        
        vr_dscritic:= 'Erro ao gerar cessao: '|| vr_dscritic;
        pc_gera_log(pr_dscritic => 'linha: '||vr_idx||' -> '||vr_dscritic);
      END IF; 
  
      ----------------->> FIM CHAMADA ROTINA PROGRESS <<----------------
      
      --> Verificar se cessao foi criada com sucesso
      OPEN cr_cessao (pr_cdcooper => rw_crapcop.cdcooper,
                      pr_nrdconta => rw_crapass.nrdconta,
                      pr_nrcartao => vr_nrcartao,
                      pr_dtvencto => vr_dtvencto_ori,
                      pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_cessao INTO rw_cessao;
      IF cr_cessao%NOTFOUND THEN
        vr_dscritic := 'Contrato de cessão de credito não foi criado';
        pc_gera_log(pr_dscritic => 'linha: '||vr_idx||' -> '||vr_dscritic);
      ELSE
        vr_qtlinha := vr_qtlinha + 1;
        vr_vltotal := vr_vltotal + rw_cessao.vlemprst;
      END IF;
      CLOSE cr_cessao;
            
      
    EXCEPTION  
      WHEN vr_exc_prox THEN
        pc_gera_log(pr_dscritic => 'linha: '||vr_idx||' -> '||vr_dscritic);
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
                             ' Valor Total: ' || to_char(vr_vltotal,'fm999g999g990d00') ););
  
  
  ----------------- ENCERRAMENTO DO PROGRAMA -------------------
  
  -- Log de fim da execução
  pc_controla_log_batch('F');
                 
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
