CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS737 (pr_cdcooper  IN NUMBER             --> Cooperativa
                                              ,pr_cdcritic  OUT NUMBER            --> Código crítica
                                              ,pr_dscritic  OUT VARCHAR2) IS      --> Descrição crítica
BEGIN

/* ..........................................................................
   Programa: PC_CRPS737
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Anderson Fossa
   Data    : Janeiro/2019.                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Mensal
   Objetivo  : Emite relatorio mensal para contabilizacao da aplicacao programada.
               Roda no primeiro dia util de cada mes, atraves de JOB
               
               Adaptado da versão do crps737 original, que foi baseado no crps147.
               Originalmente tinha como responsabilidade provisionar as aplic. programadas.
               
............................................................................. */

  DECLARE
  
    --- ################################ Variáveis ################################# ----
  
    vr_exc_erro       EXCEPTION;                      --> Controle de exceção personalizada

    vr_res_qtrppati   NUMBER := 0;                    --> Quantidade de participação
    vr_res_qtrppati_a NUMBER := 0;                    --> Quantidade de participação auxiliar
    vr_res_qtrppati_n NUMBER := 0;                    --> Quantidade de participação por execução
    vr_res_qtrppnov   NUMBER := 0;                    --> Quantidade de participação
    vr_res_qtrppnov_a NUMBER := 0;                    --> Quantidade de participação auxiliar
    vr_res_qtrppnov_n NUMBER := 0;                    --> Quantidade de participação por execução
    vr_res_vlrppati   NUMBER(20,2) := 0;              --> Valor da participação
    vr_res_vlrppati_a NUMBER(20,2) := 0;              --> Valor da participação auxiliar
    vr_res_vlrppati_n NUMBER(20,2) := 0;              --> Valor da participação por execução
    vr_res_vlrppmes   NUMBER(20,2) := 0;              --> Valor mensal
    vr_res_vlrppmes_a NUMBER(20,2) := 0;              --> Valor mensal auxiliar
    vr_res_vlrppmes_n NUMBER(20,2) := 0;              --> Valor mensal por execução
    vr_res_vlresmes   NUMBER(20,2) := 0;              --> Valor resultado mensal
    vr_res_vlresmes_a NUMBER(20,2) := 0;              --> Valor resultado mensal auxiliar
    vr_res_vlresmes_n NUMBER(20,2) := 0;              --> Valor resultado mensal por execução
    vr_res_vlrppnov   NUMBER(20,2) := 0;              --> Valor de participação novo
    vr_res_vlrppnov_a NUMBER(20,2) := 0;              --> Valor de participação novo auxiliar
    vr_res_vlrppnov_n NUMBER(20,2) := 0;              --> Valor de participação novo por execução
    vr_res_vlrenmes   NUMBER(20,2) := 0;              --> Valor de resultado mês
    vr_res_vlrenmes_a NUMBER(20,2) := 0;              --> Valor de resultado mês auxiliar
    vr_res_vlrenmes_n NUMBER(20,2) := 0;              --> Valor de resultado mês por execução
    vr_res_vlprvmes   NUMBER(20,2) := 0;              --> Valor previsto mensal
    vr_res_vlprvmes_a NUMBER(20,2) := 0;              --> Valor previsto mensal auxiliar
    vr_res_vlprvmes_n NUMBER(20,2) := 0;              --> Valor previsto mensal por execução
    vr_res_vlprvlan   NUMBER(20,2) := 0;              --> Valor previsto lançamento
    vr_res_vlprvlan_a NUMBER(20,2) := 0;              --> Valor previsto lançamento auxiliar
    vr_res_vlprvlan_n NUMBER(20,2) := 0;              --> Valor previsto lançamento por execução
    vr_res_vlajuprv   NUMBER(20,2) := 0;              --> Valor previsto juros
    vr_res_vlajuprv_a NUMBER(20,2) := 0;              --> Valor previsto juros auxiliar
    vr_res_vlajuprv_n NUMBER(20,2) := 0;              --> Valor previsto juros por execução
    vr_res_vlrtirrf   NUMBER(20,2) := 0;              --> Valor IRRF
    vr_res_vlrtirrf_a NUMBER(20,2) := 0;              --> Valor IRRF auxiliar
    vr_res_vlrtirrf_n NUMBER(20,2) := 0;              --> Valor IRRF por execução
    vr_res_bsabcpmf   NUMBER(20,2) := 0;              --> Valor CPMF
    vr_res_bsabcpmf_a NUMBER(20,2) := 0;              --> Valor CPMF auxiliar
    vr_res_bsabcpmf_n NUMBER(20,2) := 0;              --> Valor CPMF por execução
    vr_res_vlrtirab   NUMBER(20,2) := 0;              --> Valor retido
    vr_res_vlrtirab_a NUMBER(20,2) := 0;              --> Valor retido auxiliar
    vr_res_vlrtirab_n NUMBER(20,2) := 0;              --> Valor retido por execução
    vr_dtinimes       DATE;                           --> Data inicial mes
    vr_dtfimmes       DATE;                           --> Data final mes
    vr_tot_vlacumul   NUMBER(20,2) := 0;              --> Valor acumulado total
    vr_rel_dsmesref   VARCHAR2(4000);                 --> Mês de referencia
    vr_nmformul       CONSTANT VARCHAR2(40) := '';    --> Nome do formulário
    vr_flgerar        CONSTANT VARCHAR2(1) := 'N';    --> Flag de execução dos relatórios não hora ou não
    vr_tipoapli       CHAR(1);

    vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS737'; --> Código do programa executor
    vr_exc_saida      EXCEPTION;                      --> Controle de exceção personalizada
    vr_dscritic       VARCHAR2(4000);
    vr_dtprodma       DATE;                           --> Data do proximo dia util depois do ultimo dia util do mes anterior 

    vr_nom_dir        VARCHAR2(100);                  --> Nome da pasta
    vr_cdcritic       NUMBER := 0;                    --> Código da crítica
    rw_dat            btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor genérico
    vr_clob_01        CLOB;                           --> Variável para armazenar XML de dados
    vr_text_01        VARCHAR2(32767);                --> Variável para armazenar Temporativamente texto do XML de dados
    vr_clob_02        CLOB;                           --> Variável para armazenar XML de dados
    vr_text_02        VARCHAR2(32767);                --> Variável para armazenar Temporativamente texto do XML de dados    vr_nrcopias       CONSTANT NUMBER := 1;           --> Número de cópias
    vr_nrcopias       CONSTANT NUMBER := 1;           --> Número de cópias
    vr_nom_dirs       VARCHAR2(400);                  --> Nome da pasta para arquivo de dados
    vr_nom_direto     VARCHAR2(400);                  --> Nome da pasta para arquivo de dados
    vr_nmarqtxt       VARCHAR2(100);                  --> Nome do arquivo TXT
    vr_setlinha       VARCHAR2(400);                  --> Linhas para o arquivo
    vr_clob_arq       CLOB;                           --> DAdos para o Arquivo APPPROG.txt
    vr_text_arq       VARCHAR2(32767);                --> Dados temporários para o arquivos APPPROG.txt
    vr_tot_rppagefis  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Fisicas
    vr_tot_rppagejur  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Juridica
    vr_tot_vlrprvfis  NUMBER := 0;                    --> Valor Total de Provisao Mensal de Pessoas Fisicas
    vr_tot_vlrprvjur  NUMBER := 0;                    --> Valor Total de Provisao Mensal de Pessoas Juridica
    
    --PJ307    
    vr_tot_vlrajusprv_fis NUMBER := 0;                 --> Valor Total Ajustes Provisão Pessoas Fisicas    
    vr_tot_vlrajusprv_jur NUMBER := 0;                 --> Valor Total Ajustes Provisão Pessoas Juridicas    
    vr_tot_vlrajudprv_fis NUMBER := 0;                 --> Valor Total de Ajustes Provisão Pessoas Fisicas  
    vr_tot_vlrajudprv_jur NUMBER := 0;                 --> Valor Total de Ajustes Provisão Pessoas Juridicas
    -- Aplicação programada
    vr_tot_vlrrend       NUMBER (20,2) := 0;          --> Valor Total de Rendimento Mensal
    vr_tot_vlrrend_fis   NUMBER := 0;                 --> Valor Total de Rendimento Mensal de Pessoas Fisica
    vr_tot_vlrrend_jur   NUMBER := 0;                 --> Valor Total de Rendimento Mensal de Pessoas Juridica
    --
    vr_dsprefix       CONSTANT VARCHAR2(15) := 'REVERSAO '; --> Constante de complemento inicial das mensagens de reversão
    
    -- Variaveis para diretórios de arquivos contábeis
    vr_dircon VARCHAR2(200);
    
    -- Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;

    --- ################################ Tipos e Registros de memória ################################# ----

    -- PL Table para armazenar dados diversos de arrays
    TYPE typ_reg_dados IS
      RECORD(valorapl NUMBER(20,2)
            ,vlacumul NUMBER(20,2)
            ,qtdaplic NUMBER);
    TYPE typ_tab_dados IS TABLE OF typ_reg_dados INDEX BY PLS_INTEGER;
    vr_tab_dados typ_tab_dados;
    
    -- PL Table para armazenar valores totais por PF e PJ
    TYPE typ_reg_total IS
      RECORD(qtrppati NUMBER(20,2) DEFAULT 0
            ,vlrppati NUMBER(20,2) DEFAULT 0
            ,vlrppmes NUMBER(20,2) DEFAULT 0
            ,vlresmes NUMBER(20,2) DEFAULT 0
            ,qtrppnov NUMBER(20,2) DEFAULT 0
            ,vlrppnov NUMBER(20,2) DEFAULT 0
            ,vlrenmes NUMBER(20,2) DEFAULT 0
            ,vlprvmes NUMBER(20,2) DEFAULT 0
            ,vlprvlan NUMBER(20,2) DEFAULT 0
            ,vlajuprv NUMBER(20,2) DEFAULT 0
            ,vlrtirrf NUMBER(20,2) DEFAULT 0
            ,vlrtirab NUMBER(20,2) DEFAULT 0
            ,vlrrendi NUMBER(20,2) DEFAULT 0
            ,bsabcpmf NUMBER(20,2) DEFAULT 0);
    TYPE typ_tab_total IS TABLE OF typ_reg_total INDEX BY PLS_INTEGER; -- index - 1-Fisico/2-Juridico
    vr_tab_total typ_tab_total;

    -- Instancia e indexa por agencia as poupacas ativas de pessoa fisica
    TYPE typ_tab_vlrppage_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_vlrppage_fis typ_tab_vlrppage_fis;
    
    -- Instancia e indexa por agencia as poupacas ativas de pessoa juridica
    TYPE typ_tab_vlrppage_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tab_vlrppage_jur typ_tab_vlrppage_jur;
    
    -- Instancia e indexa por agencia as provisoes mensais de pessoa fisica
    TYPE typ_tot_vlrprvmes_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrprvmes_fis typ_tot_vlrprvmes_fis;
    
    -- Instancia e indexa por agencia as provisoes mensais de pessoa juridica
    TYPE typ_tot_vlrprvmes_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrprvmes_jur typ_tot_vlrprvmes_jur;    
    
    -- Instancia e indexa por agencia as ajustes provisoes mensais de pessoa fisica
    TYPE typ_tot_vlrajusprvmes_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrajusprvmes_fis typ_tot_vlrajusprvmes_fis;
    
    -- Instancia e indexa por agencia as ajustes provisoes mensais de pessoa juridica
    TYPE typ_tot_vlrajusprvmes_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrajusprvmes_jur typ_tot_vlrajusprvmes_jur;    
    
    -- Instancia e indexa por agencia as ajustes de provisoes mensais de pessoa fisica
    TYPE typ_tot_vlrajudprvmes_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrajudprvmes_fis typ_tot_vlrajudprvmes_fis;
    
    -- Instancia e indexa por agencia as ajustes de provisoes mensais de pessoa juridica
    TYPE typ_tot_vlrajudprvmes_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrajudprvmes_jur typ_tot_vlrajudprvmes_jur;       

    -- Instancia e indexa por agencia as ajustes de rendimentos mensais de pessoa fisica
    TYPE typ_tot_vlrrendmes_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrrendmes_fis typ_tot_vlrrendmes_fis;
    
    -- Instancia e indexa por agencia as ajustes de rendimentos mensais de pessoa juridica
    TYPE typ_tot_vlrrendmes_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrrendmes_jur typ_tot_vlrrendmes_jur;

      -- Tabela temporaria CRAPCPC
      TYPE typ_reg_crapcpc IS
       RECORD(cdprodut crapcpc.cdprodut%TYPE --> Codigo do Produto
             ,cddindex crapcpc.cddindex%TYPE --> Codigo do Indexador       
             ,nmprodut crapcpc.nmprodut%TYPE --> Nome do Produto
             ,idsitpro crapcpc.idsitpro%TYPE --> Situação
             ,idtippro crapcpc.idtippro%TYPE --> Tipo
             ,idtxfixa crapcpc.idtxfixa%TYPE --> Taxa Fixa
             ,idacumul crapcpc.idacumul%TYPE --> Taxa Cumulativa              
             ,cdhscacc crapcpc.cdhscacc%TYPE --> Débito Aplicação
             ,cdhsvrcc crapcpc.cdhsvrcc%TYPE --> Crédito Resgate/Vencimento Aplicação
             ,cdhsraap crapcpc.cdhsraap%TYPE --> Crédito Renovação Aplicação
             ,cdhsnrap crapcpc.cdhsnrap%TYPE --> Crédito Aplicação Recurso Novo
             ,cdhsprap crapcpc.cdhsprap%TYPE --> Crédito Atualização Juros
             ,cdhsrvap crapcpc.cdhsrvap%TYPE --> Débito Reversão Atualização Juros
             ,cdhsrdap crapcpc.cdhsrdap%TYPE --> Crédito Rendimento
             ,cdhsirap crapcpc.cdhsirap%TYPE --> Débito IRRF
             ,cdhsrgap crapcpc.cdhsrgap%TYPE --> Débito Resgate
             ,cdhsvtap crapcpc.cdhsvtap%TYPE); --> Débito Vencimento


      TYPE typ_tab_crapcpc IS
        TABLE OF typ_reg_crapcpc
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados dos produtos de captacao
      vr_tab_crapcpc typ_tab_crapcpc;

    
    --- #################################### CURSORES ############################################## ----
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.nrctactl
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_cop cr_crapcop%ROWTYPE;
       
    -- Buscar lançamentos do mês
    CURSOR cr_craplac(pr_cdcooper IN craptab.cdcooper%TYPE        --> Código cooperativa
                     ,pr_dtinimes IN craplac.dtmvtolt%TYPE        --> Data inicial do mês
                     ,pr_dtfimmes IN craplac.dtmvtolt%TYPE) IS    --> Data final do mês
      SELECT lac.nrdconta
            ,rpp.flgctain
            ,DECODE(ass.inpessoa, 3, 2, ass.inpessoa) inpessoa
            ,ass.cdagenci
            ,rac.nrctrrpp
            ,lac.cdhistor
            ,lac.vllanmto
            ,lac.nrdolote
            ,rpp.cdprodut
      FROM craplac lac
          ,craprac rac
          ,crapass ass
          ,craprpp rpp
      WHERE rpp.cdcooper = rac.cdcooper
        AND rpp.nrdconta = rac.nrdconta
        AND rpp.nrctrrpp = rac.nrctrrpp
        AND rac.nraplica = lac.nraplica
        AND rac.nrdconta = lac.nrdconta
        AND rac.cdcooper = lac.cdcooper
        AND rpp.cdcooper = ass.cdcooper
        AND rpp.nrdconta = ass.nrdconta
        AND rpp.cdprodut > 0
        AND lac.cdcooper = pr_cdcooper
        AND lac.cdagenci = 1
        AND lac.cdbccxlt = 100     
        AND lac.dtmvtolt > pr_dtinimes
        AND lac.dtmvtolt < pr_dtfimmes;
    -- PLTABLE para fazer bulk collect e acelerar as leituras  
    TYPE typ_CRAPLAC IS TABLE OF cr_craplac%ROWTYPE INDEX BY PLS_INTEGER;
    rw_lac typ_CRAPLAC;

      -- cursor usado para carregar dados de produtos de captacao na PLTABLE
      CURSOR cr_crapcpc IS
      SELECT cdprodut
            ,cddindex
            ,nmprodut
            ,idsitpro
            ,idtippro
            ,idtxfixa
            ,idacumul
            ,cdhscacc
            ,cdhsvrcc 
            ,cdhsraap
            ,cdhsnrap
            ,cdhsprap
            ,cdhsrvap
            ,cdhsrdap
            ,cdhsirap
            ,cdhsrgap
            ,cdhsvtap
        FROM crapcpc cpc;
      
       rw_crapcpc cr_crapcpc%ROWTYPE;    
       
       CURSOR cr_craprpp IS
        select rpp.nrdconta
              ,rpp.nrctrrpp
              ,rpp.dtinirpp
              ,rpp.dtiniper
              ,rpp.dtfimper
              ,rpp.dtcalcul
              ,rpp.vlprerpp
              ,ass.cdagenci
              ,ass.inpessoa
              ,ass.nrcpfcgc
              ,ass.nmprimtl
              ,nvl(
               (select SUM(decode(his.indebcre,'D',-1,1) * lac.vllanmto) AS "Valor"
                 from craplac lac, CRAPHIS HIS, craprac rac         
                where lac.cdcooper  = pr_cdcooper
                  AND lac.dtmvtolt <= rw_dat.dtultdma -- Lancamentos ate ultimo dia do mes anterior.
                  and rac.cdcooper  = lac.cdcooper
                  and rac.nrdconta  = lac.nrdconta
                  and rac.nraplica  = lac.nraplica
                  and rac.cdcooper  = rpp.cdcooper
                  and rac.nrdconta  = rpp.nrdconta
                  and rac.nrctrrpp  = rpp.nrctrrpp
                  AND his.cdcooper = lac.cdcooper
                  AND his.cdhistor = lac.cdhistor),0) valor
          from craprpp rpp
          join crapass ass
            on ass.cdcooper = rpp.cdcooper
           and ass.nrdconta = rpp.nrdconta
         WHERE rpp.cdcooper = pr_cdcooper
           AND rpp.cdsitrpp <> 5
           AND rpp.cdprodut > 0
           AND rpp.dtmvtolt <= rw_dat.dtultdma; -- Planos cadastrados ate ultimo dia do mes anterior.

       -- PLTABLE para fazer bulk collect e acelerar as leituras  
       TYPE typ_CRAPRRP IS TABLE OF cr_craprpp%ROWTYPE INDEX BY PLS_INTEGER;
       rw_rpp typ_CRAPRRP;          

    --- ################################ SubRotinas ################################# ----

    -- Procedure para acumular valores de novas e antigas aplicações
    PROCEDURE pc_acumula_aplicacoes(pr_cdhistor  IN craplac.cdhistor%TYPE   --> Código do histórico
                                   ,pr_tipoapli  IN VARCHAR2                --> Indicar se aplicação é nova (N) ou antiga (A)
                                   ,pr_vllanmto  IN craplac.vllanmto%TYPE   --> Valor de movimento
                                   ,pr_nrdolote  IN craplac.nrdolote%TYPE   --> Número do lote
                                   ,pr_cdprodut  IN craprpp.cdprodut%TYPE   --> Número do Produto
                                   ,pr_desc_erro OUT VARCHAR2) AS           --> Descrição de erros no processo
    BEGIN
      BEGIN
        -- Faz o acumulo de acordo com o código do histórico
        -- Considera se irá gerar lançamentos em aplicações novas ou antigas

        CASE
          WHEN pr_cdhistor = vr_tab_crapcpc(pr_cdprodut).cdhsraap THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrppmes_n := vr_res_vlrppmes_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrppmes_a := vr_res_vlrppmes_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = vr_tab_crapcpc(pr_cdprodut).cdhsrgap THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlresmes_n := vr_res_vlresmes_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlresmes_a := vr_res_vlresmes_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = vr_tab_crapcpc(pr_cdprodut).cdhsrdap THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrenmes_n := vr_res_vlrenmes_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrenmes_a := vr_res_vlrenmes_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = vr_tab_crapcpc(pr_cdprodut).cdhsprap THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlprvmes_n := vr_res_vlprvmes_n + pr_vllanmto;
              vr_res_vlprvlan_n := vr_res_vlprvlan_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlprvmes_a := vr_res_vlprvmes_a + pr_vllanmto;
              vr_res_vlprvlan_a := vr_res_vlprvlan_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor IN (157,154) THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlajuprv_n := vr_res_vlajuprv_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlajuprv_a := vr_res_vlajuprv_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = vr_tab_crapcpc(pr_cdprodut).cdhsrvap THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlajuprv_n := vr_res_vlajuprv_n - pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlajuprv_a := vr_res_vlajuprv_a - pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = vr_tab_crapcpc(pr_cdprodut).cdhsirap THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrtirrf_n := vr_res_vlrtirrf_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrtirrf_a := vr_res_vlrtirrf_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = 870 THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrtirab_n := vr_res_vlrtirab_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrtirab_a := vr_res_vlrtirab_a + pr_vllanmto;
            END IF;
          ELSE
            NULL;  
        END CASE;
      EXCEPTION
        WHEN OTHERS THEN
          IF pr_tipoapli = 'N' THEN
            pr_desc_erro := 'Erro em pc_acumula_aplicacoes tipo N (cdhistor '|| nvl(pr_cdhistor,0) || '): ' || SQLERRM;
          ELSIF pr_tipoapli = 'A' THEN
            pr_desc_erro := 'Erro em pc_acumula_aplicacoes tipo A (cdhistor '|| nvl(pr_cdhistor,0) || '): ' || SQLERRM;
          END IF;
      END;
    END pc_acumula_aplicacoes;

  ---------------------------------------
  -- Inicio Bloco Principal pc_crps737
  ---------------------------------------
  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                             , pr_action => NULL);

    -- Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    vr_idlog_ini_ger := null;
    pc_log_programa(pr_dstiplog   => 'I'    
                   ,pr_cdprograma => vr_cdprogra          
                   ,pr_cdcooper   => pr_cdcooper
                   ,pr_tpexecucao => 2    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_idprglog   => vr_idlog_ini_ger);
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_cop;
    -- Se não encontrar registros montar mensagem de critica
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;

      vr_cdcritic := 651;

      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    vr_nom_dirs := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/salvar');

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_dat;
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    /* Carrega primeiro dia util 
       dtultdma = ultimo dia util do mes anterior
    */
    vr_dtprodma := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => (rw_dat.dtultdma + 1)
                                              ,pr_tipo => 'P');
  
    -- carregamento pltable usadas
    FOR rw_crapcpc IN cr_crapcpc
     LOOP        
        
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cddindex := rw_crapcpc.cddindex;
        vr_tab_crapcpc(rw_crapcpc.cdprodut).nmprodut := rw_crapcpc.nmprodut;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).idsitpro := rw_crapcpc.idsitpro;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).idtippro := rw_crapcpc.idtippro;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).idtxfixa := rw_crapcpc.idtxfixa;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).idacumul := rw_crapcpc.idacumul;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhscacc := rw_crapcpc.cdhscacc;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsvrcc := rw_crapcpc.cdhsvrcc;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsraap := rw_crapcpc.cdhsraap;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsnrap := rw_crapcpc.cdhsnrap;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsprap := rw_crapcpc.cdhsprap;   
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrvap := rw_crapcpc.cdhsrvap;
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrdap := rw_crapcpc.cdhsrdap;
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsirap := rw_crapcpc.cdhsirap;
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsrgap := rw_crapcpc.cdhsrgap;
        vr_tab_crapcpc(rw_crapcpc.cdprodut).cdhsvtap := rw_crapcpc.cdhsvtap;    
                  
    END LOOP;

    -- Inicializa Tabela de Memoria de Totais Separdos por PF e PJ
    FOR idx IN 1..2 LOOP
      vr_tab_total(idx).qtrppati := 0;
      vr_tab_total(idx).vlrppati := 0;
      vr_tab_total(idx).vlrppmes := 0;
      vr_tab_total(idx).vlresmes := 0;
      vr_tab_total(idx).qtrppnov := 0;
      vr_tab_total(idx).vlrppnov := 0;
      vr_tab_total(idx).vlrenmes := 0;
      vr_tab_total(idx).vlprvmes := 0;
      vr_tab_total(idx).vlprvlan := 0;
      vr_tab_total(idx).vlajuprv := 0;
      vr_tab_total(idx).vlrtirrf := 0;
      vr_tab_total(idx).vlrtirab := 0;
      vr_tab_total(idx).bsabcpmf  := 0;
    END LOOP;

    -- Inicializar PL Table de dados diversos
    FOR idx IN 1..19 LOOP
      vr_tab_dados(idx).valorapl := 0;
      vr_tab_dados(idx).vlacumul := 0;
      vr_tab_dados(idx).qtdaplic := 0;
    END LOOP;

    -- crrl737.dat
    dbms_lob.createtemporary(vr_clob_02, TRUE);
    dbms_lob.open(vr_clob_02, dbms_lob.lob_readwrite); 
    gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                           ,pr_texto_completo => vr_text_02
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><base>');
    
    
    OPEN cr_craprpp;      
    LOOP
      FETCH cr_craprpp BULK COLLECT INTO rw_rpp LIMIT 5000; 
      EXIT WHEN rw_rpp.COUNT = 0;            
      FOR idx IN rw_rpp.first..rw_rpp.last LOOP   
                
        IF rw_rpp(idx).valor <> 0 THEN                 
          
          -- conteudo crrl737.dat
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                                 ,pr_texto_completo => vr_text_02
                                 ,pr_texto_novo     => '<dados><nrdconta>' || to_char(rw_rpp(idx).nrdconta, 'FM999999G999G0') || '</nrdconta>'
                                                    || '<nrctrrpp>'|| to_char(rw_rpp(idx).nrctrrpp, 'FM999G999G999G990') || '</nrctrrpp>'
                                                    || '<vr_rpp_vlsdrdpp>' || to_char(rw_rpp(idx).valor, 'FM999G999G990D00') || '</vr_rpp_vlsdrdpp>'
                                                    || '<dtcalcul>' || to_char(rw_rpp(idx).dtcalcul,'DD/MM/RRRR') || '</dtcalcul>'
                                                    || '<dtiniper>' || to_char(rw_rpp(idx).dtiniper,'DD/MM/RRRR') || '</dtiniper>'
                                                    || '<dtfimper>' || to_char(rw_rpp(idx).dtfimper,'DD/MM/RRRR') || '</dtfimper></dados>');
      
          /* Totaliza planos para o crrl147 */
          vr_res_qtrppati_n := vr_res_qtrppati_n + 1;
          vr_res_vlrppati_n := vr_res_vlrppati_n + rw_rpp(idx).valor;
          IF rw_rpp(idx).inpessoa = 1 THEN                    
            vr_tab_total(1).qtrppati := vr_tab_total(1).qtrppati + 1;
            vr_tab_total(1).vlrppati := vr_tab_total(1).vlrppati + rw_rpp(idx).valor;
            
            /* Para arq. contabil */
            vr_tot_rppagefis := vr_tot_rppagefis + rw_rpp(idx).valor;
            -- Verifica se existe valor para agencia corrente de pessoa fisica
            IF vr_tab_vlrppage_fis.EXISTS(rw_rpp(idx).cdagenci) THEN
              -- Soma os valores por agencia de pessoa fisica
              vr_tab_vlrppage_fis(rw_rpp(idx).cdagenci) := vr_tab_vlrppage_fis(rw_rpp(idx).cdagenci) + rw_rpp(idx).valor;
            ELSE
              -- Inicializa o array com o valor inicial de pessoa fisica
              vr_tab_vlrppage_fis(rw_rpp(idx).cdagenci) := rw_rpp(idx).valor;
            END IF;

          ELSE
            vr_tab_total(2).qtrppati := vr_tab_total(2).qtrppati + 1;
            vr_tab_total(2).vlrppati := vr_tab_total(2).vlrppati + rw_rpp(idx).valor;
            
            /* Para arq. contabil */
            vr_tot_rppagejur := vr_tot_rppagejur + rw_rpp(idx).valor;            
            -- Verifica se existe valor para agencia corrente de pessoa juridica
            IF vr_tab_vlrppage_jur.EXISTS(rw_rpp(idx).cdagenci) THEN
               -- Soma os valores por agencia de pessoa juridica
               vr_tab_vlrppage_jur(rw_rpp(idx).cdagenci) := vr_tab_vlrppage_jur(rw_rpp(idx).cdagenci) + rw_rpp(idx).valor;
            ELSE
               -- Inicializa o array com o valor inicial de pessoa juridica
               vr_tab_vlrppage_jur(rw_rpp(idx).cdagenci) := rw_rpp(idx).valor;
            END IF;
            
          END IF;
        END IF;
        
        /* Se for um plano novo do mes */
        IF extract(month from rw_rpp(idx).dtinirpp) = extract(month from rw_dat.dtultdma) AND
           extract(year  from rw_rpp(idx).dtinirpp) = extract(year  from rw_dat.dtultdma) THEN
          vr_res_qtrppnov_n := vr_res_qtrppnov_n + 1;
          vr_res_vlrppnov_n := vr_res_vlrppnov_n + rw_rpp(idx).vlprerpp;
          IF rw_rpp(idx).inpessoa = 1 THEN                    
            vr_tab_total(1).qtrppnov := vr_tab_total(1).qtrppnov + 1;
            vr_tab_total(1).vlrppnov := vr_tab_total(1).vlrppnov + rw_rpp(idx).vlprerpp;
          ELSE
            vr_tab_total(2).qtrppnov := vr_tab_total(2).qtrppnov + 1;
            vr_tab_total(2).vlrppnov := vr_tab_total(2).vlrppnov + rw_rpp(idx).vlprerpp;
          END IF;
        END IF;
        
      END LOOP;      
    END LOOP;
    /* Totaliza */
    vr_res_qtrppati := vr_res_qtrppati_n;
    vr_res_vlrppati := vr_res_vlrppati_n;
    vr_res_qtrppnov := vr_res_qtrppnov_n;
    vr_res_vlrppnov := vr_res_vlrppnov_n;    
    
    -- Totaliza crrl737.dat
    gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                           ,pr_texto_completo => vr_text_02
                           ,pr_texto_novo     => '<total>' || to_char(vr_res_vlrppati, 'FM999G999G990D00') || '</total>');
    
    -- Finaliza crrl737.dat
    gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                           ,pr_texto_completo => vr_text_02
                           ,pr_texto_novo     => '</base>'
                           ,pr_fecha_xml      => TRUE);                       
                           


    -- Verificar se ocorreram críticas
    IF vr_cdcritic > 0 THEN
      RAISE vr_exc_saida;
    END IF;
      
      -- Monta periodo para considerar o mes anterior completo
      vr_dtinimes := trunc(rw_dat.dtultdma,'MM') -1;
      vr_dtfimmes := trunc(rw_dat.dtmvtolt,'MM');

      -- Formatar mês de referência
      vr_rel_dsmesref := gene0001.vr_vet_nmmesano(to_char(rw_dat.dtultdma, 'MM')) ||'/'||to_char(rw_dat.dtultdma, 'RRRR');
      
          -- Leitura dos lançamentos do mês
    OPEN cr_craplac(pr_cdcooper => pr_cdcooper
                   ,pr_dtinimes => vr_dtinimes 
                   ,pr_dtfimmes => vr_dtfimmes);
      
    LOOP
      FETCH cr_craplac BULK COLLECT INTO rw_lac LIMIT 5000; 
      EXIT WHEN rw_lac.COUNT = 0;            
      FOR idx IN rw_lac.first..rw_lac.last LOOP   
            -- Valida se será computado aplicações novas ou antigas
            IF rw_lac(idx).flgctain = 1 THEN
              vr_tipoapli := 'N';
            ELSE
              vr_tipoapli := 'A';
            END IF; 
            pc_acumula_aplicacoes (pr_cdhistor  => rw_lac(idx).cdhistor
                                  ,pr_tipoapli  => vr_tipoapli
                                  ,pr_vllanmto  => rw_lac(idx).vllanmto
                                  ,pr_nrdolote  => rw_lac(idx).nrdolote
                                  ,pr_cdprodut  => rw_lac(idx).cdprodut
                                  ,pr_desc_erro => vr_dscritic);
            -- Se ocorrer erros no processo
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Conta '||rw_lac(idx).nrdconta|| ' Poup '||rw_lac(idx).nrctrrpp|| ' --> '||vr_dscritic;
                RAISE vr_exc_saida;
            END IF;

            -- Valida histórico para fazer sumarização
            CASE
              WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsraap THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlrppmes := vr_res_vlrppmes + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlrppmes := vr_tab_total(rw_lac(idx).inpessoa).vlrppmes + rw_lac(idx).vllanmto;
              WHEN rw_lac(idx).cdhistor =  vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsrgap THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlresmes := vr_res_vlresmes + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlresmes := vr_tab_total(rw_lac(idx).inpessoa).vlresmes + rw_lac(idx).vllanmto;
              WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsprap THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlprvmes := vr_res_vlprvmes + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlprvmes := vr_tab_total(rw_lac(idx).inpessoa).vlprvmes + rw_lac(idx).vllanmto;
                IF rw_lac(idx).inpessoa = 1 THEN
                   -- Separando as opcoes de previsao mensal por agencia
                   IF vr_tot_vlrprvmes_fis.EXISTS(rw_lac(idx).cdagenci) THEN
                      vr_tot_vlrprvmes_fis(rw_lac(idx).cdagenci) := vr_tot_vlrprvmes_fis(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                   ELSE
                      vr_tot_vlrprvmes_fis(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                   END IF;
                   -- Gravando as informacoe para gerar o valor provisao mensal de pessoa fisica
                   vr_tot_vlrprvfis := vr_tot_vlrprvfis + rw_lac(idx).vllanmto;
                ELSE
                   -- Separando as opcoes de previsao mensal por agencia
                   IF vr_tot_vlrprvmes_jur.EXISTS(rw_lac(idx).cdagenci) THEN
                      vr_tot_vlrprvmes_jur(rw_lac(idx).cdagenci) := vr_tot_vlrprvmes_jur(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                   ELSE
                      vr_tot_vlrprvmes_jur(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                   END IF;
                   -- Gravando as informacoe para gerar o valor provisao mensal de pessoa fisica
                   vr_tot_vlrprvjur := vr_tot_vlrprvjur + rw_lac(idx).vllanmto;
                END IF;
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlprvlan := vr_res_vlprvlan + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlprvlan := vr_tab_total(rw_lac(idx).inpessoa).vlprvlan + rw_lac(idx).vllanmto;
              WHEN rw_lac(idx).cdhistor IN (157,154) THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlajuprv := vr_res_vlajuprv + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlajuprv := vr_tab_total(rw_lac(idx).inpessoa).vlajuprv + rw_lac(idx).vllanmto;
                IF rw_lac(idx).cdhistor = 154 THEN
                    IF rw_lac(idx).inpessoa = 1 THEN
                       -- Separando as opcoes de ajuste previsao mensal por agencia
                       IF vr_tot_vlrajusprvmes_fis.EXISTS(rw_lac(idx).cdagenci) THEN
                          vr_tot_vlrajusprvmes_fis(rw_lac(idx).cdagenci) := vr_tot_vlrajusprvmes_fis(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                       ELSE
                          vr_tot_vlrajusprvmes_fis(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                       END IF;
                       -- Gravando as informacoe para gerar o valor de ajuste provisao mensal de pessoa fisica
                       vr_tot_vlrajusprv_fis := vr_tot_vlrajusprv_fis + rw_lac(idx).vllanmto;
                    ELSE
                       -- Separando as opcoes de ajuste previsao mensal por agencia
                       IF vr_tot_vlrajusprvmes_jur.EXISTS(rw_lac(idx).cdagenci) THEN
                          vr_tot_vlrajusprvmes_jur(rw_lac(idx).cdagenci) := vr_tot_vlrajusprvmes_jur(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                       ELSE
                          vr_tot_vlrajusprvmes_jur(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                       END IF;
                       -- Gravando as informacoe para gerar o valor de ajuste provisao mensal de pessoa fisica
                       vr_tot_vlrajusprv_jur := vr_tot_vlrajusprv_jur + rw_lac(idx).vllanmto;
                    END IF;          
                END IF; -- histor 154
              WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsrvap THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlajuprv := vr_res_vlajuprv - rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlajuprv := vr_tab_total(rw_lac(idx).inpessoa).vlajuprv - rw_lac(idx).vllanmto;
                IF rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsrvap THEN
                    IF rw_lac(idx).inpessoa = 1 THEN
                        -- Separando as opcoes de ajuste de previsao mensal por agencia
                       IF vr_tot_vlrajudprvmes_fis.EXISTS(rw_lac(idx).cdagenci) THEN
                          vr_tot_vlrajudprvmes_fis(rw_lac(idx).cdagenci) := vr_tot_vlrajudprvmes_fis(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                       ELSE
                          vr_tot_vlrajudprvmes_fis(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                       END IF;
                       -- Gravando as informacoe para gerar o valor de ajuste de  provisao mensal de pessoa fisica
                       vr_tot_vlrajudprv_fis := vr_tot_vlrajudprv_fis + rw_lac(idx).vllanmto;
                    ELSE
                       -- Separando as opcoes de ajuste de previsao mensal por agencia
                       IF vr_tot_vlrajudprvmes_jur.EXISTS(rw_lac(idx).cdagenci) THEN
                          vr_tot_vlrajudprvmes_jur(rw_lac(idx).cdagenci) := vr_tot_vlrajudprvmes_jur(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                       ELSE
                          vr_tot_vlrajudprvmes_jur(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                       END IF;
                       -- Gravando as informacoe para gerar o valor de ajuste de provisao mensal de pessoa fisica
                       vr_tot_vlrajudprv_jur := vr_tot_vlrajudprv_jur + rw_lac(idx).vllanmto;
                    END IF;          
                END IF;          
              WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsirap THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlrtirrf := vr_res_vlrtirrf + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlrtirrf := vr_tab_total(rw_lac(idx).inpessoa).vlrtirrf + rw_lac(idx).vllanmto;
              WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsrdap THEN
			    -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlrenmes := vr_res_vlrenmes + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlrenmes := vr_tab_total(rw_lac(idx).inpessoa).vlrenmes + rw_lac(idx).vllanmto;

                vr_tot_vlrrend := vr_tot_vlrrend - rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlrrendi := vr_tab_total(rw_lac(idx).inpessoa).vlrrendi - rw_lac(idx).vllanmto;
                IF rw_lac(idx).inpessoa = 1 THEN
                   -- Separando os rendimentos mensais por agencia
                   IF vr_tot_vlrrendmes_fis.EXISTS(rw_lac(idx).cdagenci) THEN
                      vr_tot_vlrrendmes_fis(rw_lac(idx).cdagenci) := vr_tot_vlrrendmes_fis(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                   ELSE
                      vr_tot_vlrrendmes_fis(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                   END IF;
                   -- Gravando as informacoe para gerar o valor de rendimento mensal de pessoa fisica
                   vr_tot_vlrrend_fis := vr_tot_vlrrend_fis + rw_lac(idx).vllanmto;
                ELSE
                   -- Separando os rendimentos mensais por agencia
                   IF vr_tot_vlrrendmes_jur.EXISTS(rw_lac(idx).cdagenci) THEN
                      vr_tot_vlrrendmes_jur(rw_lac(idx).cdagenci) := vr_tot_vlrrendmes_jur(rw_lac(idx).cdagenci) + rw_lac(idx).vllanmto;
                   ELSE
                      vr_tot_vlrrendmes_jur(rw_lac(idx).cdagenci) := rw_lac(idx).vllanmto;
                   END IF;
                   -- Gravando as informacoe para gerar o valor de rendimento mensal de pessoa fisica
                   vr_tot_vlrrend_jur := vr_tot_vlrrend_jur + rw_lac(idx).vllanmto;
                END IF;          
              WHEN rw_lac(idx).cdhistor = 870 THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_vlrtirab := vr_res_vlrtirab + rw_lac(idx).vllanmto;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlrtirab := vr_tab_total(rw_lac(idx).inpessoa).vlrtirab + rw_lac(idx).vllanmto;
                
            END CASE;
      END LOOP; -- Loop do Bulk Collect
    END LOOP; -- Loop do fetch
    CLOSE cr_craplac;
    
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_clob_01, TRUE);
      dbms_lob.open(vr_clob_01, dbms_lob.lob_readwrite);

      -- Inicilizar as informações do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><base>');

      -- Escrever dados no XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '<aplicpoup>'
                                                || '<aplic>'
                                                || '<nomecampo>QUANTIDADE DE PLANOS COM SALDO:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_qtrppati_a, 0), 'FM999G999G990') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_qtrppati_n, 0), 'FM999G999G990') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_qtrppati, 0), 'FM999G999G990') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).qtrppati, 0), 'FM999G999G990') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).qtrppati, 0), 'FM999G999G990') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>SALDO TOTAL DOS PLANOS COM SALDO:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlrppati_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlrppati_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlrppati, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrppati, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrppati, 0), 'FM999G999G990D00') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>VALOR TOTAL APLICADO NO MES:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlrppmes_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlrppmes_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlrppmes, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrppmes, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrppmes, 0), 'FM999G999G990D00') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>VALOR TOTAL DOS RESGATES DO MES:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlresmes_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlresmes_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlresmes, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlresmes, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlresmes, 0), 'FM999G999G990D00') || '</vltotjur>'
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>QUANTIDADE DE PLANO NOVOS:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_qtrppnov_a, 0), 'FM999G999G990') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_qtrppnov_n, 0), 'FM999G999G990') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_qtrppnov, 0), 'FM999G999G990') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).qtrppnov, 0), 'FM999G999G990') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).qtrppnov, 0), 'FM999G999G990') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>VALOR DOS NOVOS PLANOS:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlrppnov_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlrppnov_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlrppnov, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrppnov, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrppnov, 0), 'FM999G999G990D00') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>RENDIMENTO CREDITADO NO MES:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlrenmes_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlrenmes_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlrenmes, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrenmes, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrenmes, 0), 'FM999G999G990D00') || '</vltotjur>'
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>VALOR TOTAL DA PROVISAO DO MES:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlprvmes_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlprvmes_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlprvmes, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlprvmes, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlprvmes, 0), 'FM999G999G990D00') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>PROVISAO DE APLICACOES A VENCER:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlprvlan_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlprvlan_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlprvlan, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlprvlan, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlprvlan, 0), 'FM999G999G990D00') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>AJUSTE DE PROVISAO:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlajuprv_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlajuprv_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlajuprv, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlajuprv, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlajuprv, 0), 'FM999G999G990D00') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>VALOR DO IR RETIDO NA FONTE:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlrtirrf_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlrtirrf_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlrtirrf, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrtirrf, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrtirrf, 0), 'FM999G999G990D00') || '</vltotjur>'    
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>VALOR DO IR SOBRE ABONO:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_vlrtirab_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_vlrtirab_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_vlrtirab, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrtirab, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrtirab, 0), 'FM999G999G990D00') || '</vltotjur>'
                                                || '</aplic>'
                                                || '<aplic>'
                                                || '<nomecampo>ABONOS ADIANTADOS A RECUPERAR:</nomecampo>'
                                                || '<antiga>' || to_char(nvl(vr_res_bsabcpmf_a, 0), 'FM999G999G990D00') || '</antiga>'
                                                || '<nova>' || to_char(nvl(vr_res_bsabcpmf_n, 0), 'FM999G999G990D00') || '</nova>'
                                                || '<saldo>' || to_char(nvl(vr_res_bsabcpmf, 0), 'FM999G999G990D00') || '</saldo>'
    -- Separando o saldo total por PF e PJ
                                                || '<vltotfis>' || to_char(nvl(vr_tab_total(1).bsabcpmf, 0), 'FM999G999G990D00') || '</vltotfis>'
                                                || '<vltotjur>' || to_char(nvl(vr_tab_total(2).bsabcpmf, 0), 'FM999G999G990D00') || '</vltotjur>'
                                                || '</aplic>'
                                                || '</aplicpoup>');

      -- Escrever dados de sumarização no XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '<prazoMedio vr_rel_dsmesref= "'||vr_rel_dsmesref||'">');
      /* Nao gera os dados do prazo medio e nem data dos debitos*/
      -- Enviar ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '</prazoMedio>'
                                                || '<prazoMedioTotal><total>' || to_char(nvl(vr_tot_vlacumul, 0), 'FM999G999G990D00') || '</total></prazoMedioTotal>'
                                                || '<debitos></debitos>'
                                                || '<totalDebito></totalDebito>');


    
    -----------------------------------------------
    -- Inicio de geracao de arquivo AAMMDD_APPPROG.txt
    -----------------------------------------------    
      
     -- Busca o caminho padrao do arquivo no unix + /integra
     vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'contab');

     -- Determinar o nome do arquivo baseado no ano, mes e dia da data movimento
       vr_nmarqtxt:= TO_CHAR(rw_dat.dtultdma,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_APPPROG.txt'; 

       -- Busca o diretório para contabilidade
       vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                             ,pr_cdcooper => 0
                                             ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
         
       -- Incializar CLOB do arquivo txt
       dbms_lob.createtemporary(vr_clob_arq, TRUE, dbms_lob.CALL);
       dbms_lob.open(vr_clob_arq, dbms_lob.lob_readwrite);
       
     -- Se o valro total é maior que zero
     IF nvl(vr_tot_rppagefis,0) > 0 THEN
       
       /*** Montando as informacoes de PESSOA FISICA ***/
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(4266, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_rppagefis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"SALDO TOTAL DE TITULOS COM SALDO APLICACAO PROGRAMADA - COOPERADOS PESSOA FISICA"';           --> Descricao

         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
             
       -- Verifica se existe valores       
         IF vr_tab_vlrppage_fis.COUNT > 0 THEN
               
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
             
            -- Gravas as informacoes de valores por agencia
              FOR vr_idx_agencia IN vr_tab_vlrppage_fis.FIRST()..vr_tab_vlrppage_fis.LAST() LOOP
                -- Verifica se existe a informacao
                  IF vr_tab_vlrppage_fis.EXISTS(vr_idx_agencia) THEN
                  -- Se valor é maior que zero
                    IF vr_tab_vlrppage_fis(vr_idx_agencia) > 0 THEN
                    -- Montar linha para gravar no arquivo
                      vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrppage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      -- Escreve no CLOB
                      gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                             ,pr_texto_completo => vr_text_arq
                                             ,pr_texto_novo     => vr_setlinha||chr(13));
                  END IF;
                END IF;
                -- Limpa variavel
                vr_setlinha := '';       
            END LOOP;
                
          END LOOP;
       END IF;

       -- Montando o cabecalho para fazer a reversao das
       -- conta para estornar os valores caso necessario
       vr_setlinha := '70'||                                                                                     --> Informacao inicial
                        TO_CHAR(vr_dtprodma,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                        TO_CHAR(vr_dtprodma,'DDMMYY')||','||                                               --> Data DDMMAA
                      gene0002.fn_mask(4266, pr_dsforma => '9999')||','||                                        --> Conta Destino
                      gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                        --> Conta Origem
                      TRIM(TO_CHAR(vr_tot_rppagefis,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                        --> Fixo
                      '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS COM SALDO APLICACAO PROGRAMADA - COOPERADOS PESSOA FISICA"';          --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
             
       -- Verifica se existe valores       
         IF vr_tab_vlrppage_fis.COUNT > 0 THEN               
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
             
           -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tab_vlrppage_fis.FIRST()..vr_tab_vlrppage_fis.LAST() LOOP
             -- Verifica se existe a informacao
               IF vr_tab_vlrppage_fis.EXISTS(vr_idx_agencia) THEN
               -- Se valor é maior que zero
                 IF vr_tab_vlrppage_fis(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrppage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
               
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       
     -- Se o valro total é maior que zero
     IF nvl(vr_tot_rppagejur,0) > 0 THEN
       
       /*** Montando as informacoes de PESSOA JURIDICA ***/       
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(4267, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_rppagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"SALDO TOTAL DE TITULOS COM SALDO APLICACAO PROGRAMADA - COOPERADOS PESSOA JURIDICA"';         --> Descricao

         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
             
       -- Verifica se existe valores       
         IF vr_tab_vlrppage_jur.COUNT > 0 THEN   
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tab_vlrppage_jur.FIRST()..vr_tab_vlrppage_jur.LAST() LOOP
             -- Verifica se existe a informacao
               IF vr_tab_vlrppage_jur.EXISTS(vr_idx_agencia) THEN       
               -- Se o valor é maior que zero
                 IF vr_tab_vlrppage_jur(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrppage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
         
       -- Montando o cabecalho para fazer a reversao das
       -- conta para estornar os valores caso necessario
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(vr_dtprodma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(vr_dtprodma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(4267, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      TRIM(TO_CHAR(vr_tot_rppagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS COM SALDO APLICACAO PROGRAMADA - COOPERADOS PESSOA JURIDICA"';         --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
         
       -- Verifica se existe valores       
         IF vr_tab_vlrppage_jur.COUNT > 0 THEN               
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tab_vlrppage_jur.FIRST()..vr_tab_vlrppage_jur.LAST() LOOP
             -- Verifica se existe a informacao
               IF vr_tab_vlrppage_jur.EXISTS(vr_idx_agencia) THEN
               -- Se o valor é maior que zero
                 IF vr_tab_vlrppage_jur(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrppage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       
     -- Se o valro total é maior que zero
     IF nvl(vr_tot_vlrprvfis,0) > 0 THEN
         
       /*** Montando as informacoes de PESSOA FISICA ***/
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8066, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_vlrprvfis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"PROVISAO DO MES - APLICACAO PROGRAMADA COOPERADOS PESSOA FISICA"';                         --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
         
       -- Verifica se existe valores       
       IF vr_tot_vlrprvmes_fis.COUNT > 0 THEN
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tot_vlrprvmes_fis.FIRST()..vr_tot_vlrprvmes_fis.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tot_vlrprvmes_fis.EXISTS(vr_idx_agencia) THEN
               -- Se o valor for maior que zero
               IF vr_tot_vlrprvmes_fis(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrprvmes_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       
     -- Se o valro total é maior que zero
     IF nvl(vr_tot_vlrprvjur,0) > 0 THEN
       
       /*** Montando as informacoes de PESSOA JURIDICA ***/       
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8067, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_vlrprvjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"PROVISAO DO MES - APLICACAO PROGRAMADA COOPERADOS PESSOA JURIDICA"';                       --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));             
       -- Verifica se existe valores       
       IF vr_tot_vlrprvmes_jur.COUNT > 0 THEN   
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tot_vlrprvmes_jur.FIRST()..vr_tot_vlrprvmes_jur.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tot_vlrprvmes_jur.EXISTS(vr_idx_agencia) THEN       
               -- Se o valor é maior que zero
               IF vr_tot_vlrprvmes_jur(vr_idx_agencia) > 0 THEN       
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrprvmes_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       
     --Histórico 154
     -- Se o valro total é maior que zero
     IF nvl(vr_tot_vlrajusprv_fis,0) > 0 THEN
         
       /*** Montando as informacoes de PESSOA FISICA ***/
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8066, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_vlrajusprv_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"AJUSTE PROVISAO APLICACAO PROGRAMADA – PESSOA FISICA"';                         --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
         
       -- Verifica se existe valores       
       IF vr_tot_vlrajusprvmes_fis.COUNT > 0 THEN
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tot_vlrajusprvmes_fis.FIRST()..vr_tot_vlrajusprvmes_fis.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tot_vlrajusprvmes_fis.EXISTS(vr_idx_agencia) THEN
               -- Se o valor for maior que zero
               IF vr_tot_vlrajusprvmes_fis(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrajusprvmes_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       
       -- Se o valor total é maior que zero
     IF nvl(vr_tot_vlrajusprv_jur,0) > 0 THEN
       
       /*** Montando as informacoes de PESSOA JURIDICA ***/       
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8067, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_vlrajusprv_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"AJUSTE PROVISAO APLICACAO PROGRAMADA – PESSOA JURIDICA"';                       --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
             
       -- Verifica se existe valores       
       IF vr_tot_vlrajusprvmes_jur.COUNT > 0 THEN   
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tot_vlrajusprvmes_jur.FIRST()..vr_tot_vlrajusprvmes_jur.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tot_vlrajusprvmes_jur.EXISTS(vr_idx_agencia) THEN       
               -- Se o valor é maior que zero
               IF vr_tot_vlrajusprvmes_jur(vr_idx_agencia) > 0 THEN       
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrajusprvmes_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       

     --Histórico 155
     -- Se o valro total é maior que zero
     IF nvl(vr_tot_vlrajudprv_fis,0) > 0 THEN
         
       /*** Montando as informacoes de PESSOA FISICA ***/
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8066, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_vlrajudprv_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"AJUSTE DE PROVISAO APLICACAO PROGRAMADA – PESSOA FISICA"';                         --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
         
       -- Verifica se existe valores       
       IF vr_tot_vlrajudprvmes_fis.COUNT > 0 THEN
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tot_vlrajudprvmes_fis.FIRST()..vr_tot_vlrajudprvmes_fis.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tot_vlrajudprvmes_fis.EXISTS(vr_idx_agencia) THEN
               -- Se o valor for maior que zero
               IF vr_tot_vlrajudprvmes_fis(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrajudprvmes_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       
     -- Se o valro total é maior que zero
     IF nvl(vr_tot_vlrajudprv_jur,0) > 0 THEN
       
       /*** Montando as informacoes de PESSOA JURIDICA ***/       
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_dat.dtultdma,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtultdma,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8067, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_vlrajudprv_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"AJUSTE DE PROVISAO APLICACAO PROGRAMADA – PESSOA JURIDICA"';                       --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
             
       -- Verifica se existe valores       
       IF vr_tot_vlrajudprvmes_jur.COUNT > 0 THEN   
         -- imprimir as informações para cada conta, ou seja, duplicado
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tot_vlrajudprvmes_jur.FIRST()..vr_tot_vlrajudprvmes_jur.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tot_vlrajudprvmes_jur.EXISTS(vr_idx_agencia) THEN       
               -- Se o valor é maior que zero
               IF vr_tot_vlrajudprvmes_jur(vr_idx_agencia) > 0 THEN       
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrajudprvmes_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escreve no CLOB
                   gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                          ,pr_texto_completo => vr_text_arq
                                          ,pr_texto_novo     => vr_setlinha||chr(13));
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; -- fim repete
       END IF;
     END IF; -- Se total maior que zero
       
     -- cdhsrdap - rendimento
     -- Se o valor total é maior que zero       
     IF nvl(vr_tot_vlrrend_fis,0) > 0 THEN
         
        /*** Montando as informacoes de PESSOA FISICA ***/
        -- Montando o cabecalho das contas do dia atual
        vr_setlinha := '70'||                                                                                          --> Informacao inicial
                        TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                       --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                       --> Data DDMMAA
                      gene0002.fn_mask(8066, pr_dsforma => '9999')||','||                                              --> Conta Origem
                      gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                              --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_vlrrend_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','||    --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                              --> Fixo
                      '"RENDIMENTO APLICACAO PROGRAMADA - PESSOA FISICA"';                                             --> Descricao
        -- Escreve no CLOB
        gene0002.pc_escreve_xml (pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
         
        -- Verifica se existe valores       
        IF vr_tot_vlrrendmes_fis.COUNT > 0 THEN
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
               -- Gravas as informacoes de valores por agencia
               FOR vr_idx_agencia IN vr_tot_vlrrendmes_fis.FIRST()..vr_tot_vlrrendmes_fis.LAST() LOOP
                   -- Verifica se existe a informacao
                   IF vr_tot_vlrrendmes_fis.EXISTS(vr_idx_agencia) THEN
                      -- Se o valor for maior que zero
                      IF vr_tot_vlrrendmes_fis(vr_idx_agencia) > 0 THEN
                         -- Montar linha para gravar no arquivo
                         vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrrendmes_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                         -- Escreve no CLOB
                         gene0002.pc_escreve_xml (pr_xml            => vr_clob_arq
                                                 ,pr_texto_completo => vr_text_arq
                                                 ,pr_texto_novo     => vr_setlinha||chr(13));
                      END IF;
                   END IF;
                   -- Limpa variavel
                   vr_setlinha := '';       
               END LOOP;
           END LOOP; -- fim repete
        END IF;
     END IF; -- Se total maior que zero

     -- Se o valor total é maior que zero
     IF nvl(vr_tot_vlrrend_jur,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA JURIDICA ***/       
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                           --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                       --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                       --> Data DDMMAA
                        gene0002.fn_mask(8067, pr_dsforma => '9999')||','||                                              --> Conta Origem
                        gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                              --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrrend_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','||    --> Total Valor PJ
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                              --> Fixo
                        '"RENDIMENTO APLICACAO PROGRAMADA - PESSOA JURIDICA"';                                           --> Descricao
         -- Escreve no CLOB
         gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                ,pr_texto_completo => vr_text_arq
                                ,pr_texto_novo     => vr_setlinha||chr(13));
               
         -- Verifica se existe valores       
         IF vr_tot_vlrrendmes_jur.COUNT > 0 THEN   
             -- imprimir as informações para cada conta, ou seja, duplicado
             FOR repete IN 1..2 LOOP
                 -- Gravas as informacoes de valores por agencia
                 FOR vr_idx_agencia IN vr_tot_vlrrendmes_jur.FIRST()..vr_tot_vlrrendmes_jur.LAST() LOOP
                     -- Verifica se existe a informacao
                     IF vr_tot_vlrrendmes_jur.EXISTS(vr_idx_agencia) THEN       
                        -- Se o valor é maior que zero
                        IF vr_tot_vlrrendmes_jur(vr_idx_agencia) > 0 THEN       
                           -- Montar linha para gravar no arquivo
                           vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrrendmes_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                           -- Escreve no CLOB
                           gene0002.pc_escreve_xml (pr_xml            => vr_clob_arq
                                                   ,pr_texto_completo => vr_text_arq
                                                   ,pr_texto_novo     => vr_setlinha||chr(13));
                        END IF;
                     END IF;
                     -- Limpa variavel
                     vr_setlinha := '';       
                 END LOOP;
             END LOOP; -- fim repete
         END IF;
     END IF; -- Se total maior que zero
          
     --Fechar Arquivo
       gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                              ,pr_texto_completo => vr_text_arq
                              ,pr_texto_novo     => ''
                              ,pr_fecha_xml      => TRUE);
         
       -- Submeter a geração do arquivo 
       gene0002.pc_solicita_relato_arquivo(pr_cdcooper   => pr_cdcooper                       --> Cooperativa conectada
                                          ,pr_cdprogra   => vr_cdprogra                       --> Programa chamador
                                          ,pr_dtmvtolt   => rw_dat.dtmvtolt                   --> Data do movimento atual
                                          ,pr_dsxml      => vr_clob_arq                       --> Arquivo XML de dados
                                          ,pr_cdrelato   => '737'                             --> Código do relatório
                                          ,pr_dsarqsaid  => vr_nom_direto||'/'||vr_nmarqtxt   --> Arquivo final com o path
                                          ,pr_flg_gerar  => vr_flgerar                        --> Não gerar na hora
                                          ,pr_dspathcop  => vr_dircon                         --> Copiar para o diretório
                                          ,pr_fldoscop   => 'S'                               --> Executar comando ux2dos
                                          ,pr_flgremarq  => 'N'                               --> Após cópia, remover arquivo de origem
                                          ,pr_des_erro   => vr_dscritic);
       -- Liberar memória alocada
       dbms_lob.close(vr_clob_arq);
       dbms_lob.freetemporary(vr_clob_arq);

       -- Se houve erro na geração
       IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
     END IF;
    -----------------------------------------------
    -- Fim de geracao de arquivo AAMMDD_APPPROG.txt       
    -----------------------------------------------

    -- Escrever total no XML
      

      -- Finalizar XMLs
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '</base>'
                             ,pr_fecha_xml      => TRUE);
      
    
    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_dat.dtultdma
                               ,pr_dsxml     => vr_clob_01
                               ,pr_dsxmlnode => '/base'
                               ,pr_dsjasper  => 'crrl123.jasper'
                               ,pr_dsparams  => NULL
                               ,pr_dsarqsaid => vr_nom_dir || '/crrl123appprog.lst'
                               ,pr_flg_gerar => vr_flgerar
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => vr_dscritic);
      -- Liberar dados do CLOB da memória
      dbms_lob.close(vr_clob_01);
      dbms_lob.freetemporary(vr_clob_01);
    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
        RAISE vr_exc_saida;
    END IF;
    
    -- Gerar relatório 737
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_dat.dtmvtolt
                                 ,pr_dsxml     => vr_clob_02
                               ,pr_dsxmlnode => '/base/dados'
                               ,pr_dsjasper  => 'crps147.jasper'
                               ,pr_dsparams  => NULL
                               ,pr_dsarqsaid => vr_nom_dirs || '/crps737.dat'
                                 ,pr_flg_gerar => vr_flgerar
                               ,pr_qtcoluna  => 80
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'N'
                               ,pr_nmformul  => NULL
                               ,pr_nrcopias  => NULL
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'S'
                               ,pr_des_erro  => vr_dscritic);

      -- Liberar dados do CLOB da memória
      dbms_lob.close(vr_clob_02);
      dbms_lob.freetemporary(vr_clob_02);
      
    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
        RAISE vr_exc_saida;
    END IF;
 
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F'   
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 1); 
      -- Efetuar commit
      COMMIT;
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      --Grava LOG da ocorrencia
      pc_log_programa(pr_dstiplog   => 'O'
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_cdmensagem => pr_cdcritic
                     ,pr_dsmensagem => pr_dscritic);
                     
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      
      --Grava LOG da ocorrencia
      pc_log_programa(pr_dstiplog   => 'O'
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_cdmensagem => pr_cdcritic
                     ,pr_dsmensagem => pr_dscritic);
                     
      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS737; 
/
