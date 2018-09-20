CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS737 (pr_cdcooper  IN NUMBER             --> Cooperativa
                                              ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo Agencia 
                                              ,pr_idparale  IN crappar.idparale%TYPE --> Indicador de processoparalelo
                                              ,pr_stprogra  OUT PLS_INTEGER        --> Sa�da de termino da execu��o
                                              ,pr_infimsol  OUT PLS_INTEGER        --> Sa�da de termino da solicita��o
                                              ,pr_cdcritic  OUT NUMBER            --> C�digo cr�tica
                                              ,pr_dscritic  OUT VARCHAR2) IS      --> Descri��o cr�tica
BEGIN

/* ..........................................................................
   Programa: PC_CRPS737  (Antigo: Fontes/crps737.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : CIS
   Data    : Julho/2018.                       Ultima atualizacao: 20/07/2018

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular a provisao mensal e emitir resumo da aplica��o programda.
               Relatorio 123.
............................................................................. */

  DECLARE
  
    --- ################################ Vari�veis ################################# ----
  
    rw_dat            btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor gen�rico 
        
  
    vr_exc_p1         EXCEPTION;                      --> Controle de exce��o de LOOP interno
    vr_exc_p2         EXCEPTION;                      --> Controle de exce��o de LOOP externo
    vr_exc_erro       EXCEPTION;                      --> Controle de exce��o personalizada

    vr_rel_dtdebito   DATE;                           --> Data de d�bito
    vr_rel_qtdebito   NUMBER := 0;                    --> Quantidade de d�bitos
    vr_rel_vldebito   NUMBER(20,2) := 0;              --> Valor do d�bito
    vr_res_qtrppati   NUMBER := 0;                    --> Quantidade de participa��o
    vr_res_qtrppati_a NUMBER := 0;                    --> Quantidade de participa��o auxiliar
    vr_res_qtrppati_n NUMBER := 0;                    --> Quantidade de participa��o por execu��o
    vr_res_qtrppnov   NUMBER := 0;                    --> Quantidade de participa��o
    vr_res_qtrppnov_a NUMBER := 0;                    --> Quantidade de participa��o auxiliar
    vr_res_qtrppnov_n NUMBER := 0;                    --> Quantidade de participa��o por execu��o
    vr_res_vlrppati   NUMBER(20,2) := 0;              --> Valor da participa��o
    vr_res_vlrppati_a NUMBER(20,2) := 0;              --> Valor da participa��o auxiliar
    vr_res_vlrppati_n NUMBER(20,2) := 0;              --> Valor da participa��o por execu��o
    vr_res_vlrppmes   NUMBER(20,2) := 0;              --> Valor mensal
    vr_res_vlrppmes_a NUMBER(20,2) := 0;              --> Valor mensal auxiliar
    vr_res_vlrppmes_n NUMBER(20,2) := 0;              --> Valor mensal por execu��o
    vr_res_vlresmes   NUMBER(20,2) := 0;              --> Valor resultado mensal
    vr_res_vlresmes_a NUMBER(20,2) := 0;              --> Valor resultado mensal auxiliar
    vr_res_vlresmes_n NUMBER(20,2) := 0;              --> Valor resultado mensal por execu��o
    vr_res_vlrppnov   NUMBER(20,2) := 0;              --> Valor de participa��o novo
    vr_res_vlrppnov_a NUMBER(20,2) := 0;              --> Valor de participa��o novo auxiliar
    vr_res_vlrppnov_n NUMBER(20,2) := 0;              --> Valor de participa��o novo por execu��o
    vr_res_vlrenmes   NUMBER(20,2) := 0;              --> Valor de resultado m�s
    vr_res_vlrenmes_a NUMBER(20,2) := 0;              --> Valor de resultado m�s auxiliar
    vr_res_vlrenmes_n NUMBER(20,2) := 0;              --> Valor de resultado m�s por execu��o
    vr_res_vlprvmes   NUMBER(20,2) := 0;              --> Valor previsto mensal
    vr_res_vlprvmes_a NUMBER(20,2) := 0;              --> Valor previsto mensal auxiliar
    vr_res_vlprvmes_n NUMBER(20,2) := 0;              --> Valor previsto mensal por execu��o
    vr_res_vlprvlan   NUMBER(20,2) := 0;              --> Valor previsto lan�amento
    vr_res_vlprvlan_a NUMBER(20,2) := 0;              --> Valor previsto lan�amento auxiliar
    vr_res_vlprvlan_n NUMBER(20,2) := 0;              --> Valor previsto lan�amento por execu��o
    vr_res_vlajuprv   NUMBER(20,2) := 0;              --> Valor previsto juros
    vr_res_vlajuprv_a NUMBER(20,2) := 0;              --> Valor previsto juros auxiliar
    vr_res_vlajuprv_n NUMBER(20,2) := 0;              --> Valor previsto juros por execu��o
    vr_res_vlrtirrf   NUMBER(20,2) := 0;              --> Valor IRRF
    vr_res_vlrtirrf_a NUMBER(20,2) := 0;              --> Valor IRRF auxiliar
    vr_res_vlrtirrf_n NUMBER(20,2) := 0;              --> Valor IRRF por execu��o
    vr_res_bsabcpmf   NUMBER(20,2) := 0;              --> Valor CPMF
    vr_res_bsabcpmf_a NUMBER(20,2) := 0;              --> Valor CPMF auxiliar
    vr_res_bsabcpmf_n NUMBER(20,2) := 0;              --> Valor CPMF por execu��o
    vr_res_vlrtirab   NUMBER(20,2) := 0;              --> Valor retido
    vr_res_vlrtirab_a NUMBER(20,2) := 0;              --> Valor retido auxiliar
    vr_res_vlrtirab_n NUMBER(20,2) := 0;              --> Valor retido por execu��o
    vr_tot_qtdebito   NUMBER(20)   := 0;              --> Quantidade total de d�bito
    vr_tot_vldebito   NUMBER(20,2) := 0;              --> Valor total d�bito
    vr_dtinimes       DATE;                           --> Data inicial mes
    vr_dtfimmes       DATE;                           --> Data final mes
    vr_vlsdextr       craprpp.vlsdextr%TYPE := 0;     --> Valor de descri��o
    vr_vlslfmes       craprpp.vlslfmes%TYPE := 0;     --> Valor fixo mes
    vr_tot_vlacumul   NUMBER(20,2) := 0;              --> Valor acumulado total
    vr_prazodia       NUMBER := 0;                    --> Dias de prazo
    vr_posicao        NUMBER := 0;                    --> Valor da posi��o
    vr_cddprazo       crapprb.cddprazo%TYPE;          --> C�digo do prazo
    vr_rel_dsmesref   VARCHAR2(4000);                 --> M�s de referencia
    vr_nmformul       CONSTANT VARCHAR2(40) := '';    --> Nome do formul�rio
    vr_flgerar        CONSTANT VARCHAR2(1) := 'N';    --> Flag de execu��o dos relat�rios n�o hora ou n�o
    vr_tipoapli       CHAR(1);

    vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS737'; --> C�digo do programa executor
    vr_exc_saida      EXCEPTION;                      --> Controle de exce��o personalizada
    vr_dscritic       VARCHAR2(4000);

    vr_nom_dir        VARCHAR2(100);                  --> Nome da pasta
    vr_cdcritic       NUMBER := 0;                    --> C�digo da cr�tica
    vr_rpp_vlsdrdpp   craprpp.vlsdrdpp%type := 0;     --> Valor de poupan�a acumulado
    vr_clob_01        CLOB;                           --> Vari�vel para armazenar XML de dados
    vr_text_01        VARCHAR2(32767);                --> Vari�vel para armazenar Temporativamente texto do XML de dados
    vr_clob_02        CLOB;                           --> Vari�vel para armazenar XML de dados
    vr_text_02        VARCHAR2(32767);                --> Vari�vel para armazenar Temporativamente texto do XML de dados
    vr_dtctr          DATE;                           --> Data de controle para quebra de itera��o
    vr_count          NUMBER := 0;                    --> Contador para itera��o do LOOP
    vr_nrcopias       CONSTANT NUMBER := 1;           --> N�mero de c�pias
    vr_dextabi        craptab.dstextab%TYPE;          --> Armazenar execu��o para c�lculo de poupan�a
    vr_idx_bndes      VARCHAR2(10);                   --> �ndice para PL Table
    vr_valortexto     NUMBER := 0;                    --> Valor para preencher dinamicamente faixa de dias
    vr_texto          VARCHAR2(200);                  --> Texto da mensagem dinamica
    vr_nom_dirs       VARCHAR2(400);                  --> Nome da pasta para arquivo de dados
    vr_nom_direto     VARCHAR2(400);                  --> Nome da pasta para arquivo de dados
    vr_nmarqtxt       VARCHAR2(100);                  --> Nome do arquivo TXT
    vr_setlinha       VARCHAR2(400);                  --> Linhas para o arquivo
    vr_clob_arq       CLOB;                           --> DAdos para o Arquivo APPPROG.txt
    vr_text_arq       VARCHAR2(32767);                --> Dados tempor�rios para o arquivos APPPROG.txt
    vr_tot_rppagefis  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Fisicas
    vr_tot_rppagejur  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Juridica
    vr_tot_vlrprvfis  NUMBER := 0;                    --> Valor Total de Provisao Mensal de Pessoas Fisicas
    vr_tot_vlrprvjur  NUMBER := 0;                    --> Valor Total de Provisao Mensal de Pessoas Juridica
    
    --PJ307    
    vr_tot_vlrajusprv_fis NUMBER := 0;                 --> Valor Total Ajustes Provis�o Pessoas Fisicas    
    vr_tot_vlrajusprv_jur NUMBER := 0;                 --> Valor Total Ajustes Provis�o Pessoas Juridicas    
    vr_tot_vlrajudprv_fis NUMBER := 0;                 --> Valor Total de Ajustes Provis�o Pessoas Fisicas  
    vr_tot_vlrajudprv_jur NUMBER := 0;                 --> Valor Total de Ajustes Provis�o Pessoas Juridicas
    -- Aplica��o programada
    vr_tot_vlrrend       NUMBER (20,2) := 0;          --> Valor Total de Rendimento Mensal
    vr_tot_vlrrend_fis   NUMBER := 0;                 --> Valor Total de Rendimento Mensal de Pessoas Fisica
    vr_tot_vlrrend_jur   NUMBER := 0;                 --> Valor Total de Rendimento Mensal de Pessoas Juridica
    --
    vr_dsprefix       CONSTANT VARCHAR2(15) := 'REVERSAO '; --> Constante de complemento inicial das mensagens de revers�o
    
    -- Variaveis para diret�rios de arquivos cont�beis
    vr_dircon VARCHAR2(200);

    -- ID para o paralelismo
    vr_idparale      integer;
    -- Qtde parametrizada de Jobs
    vr_qtdjobs       number;
    -- Job name dos processos criados
    vr_jobname       varchar2(30);
    -- Bloco PLSQL para chamar a execu��o paralela do pc_crps750
    vr_dsplsql       varchar2(4000);
    

   
    -- C�digo de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;
    vr_idlog_ini_par tbgen_prglog.idprglog%type;
    vr_tpexecucao    tbgen_prglog.tpexecucao%type; 
    vr_qterro        number := 0; 

    --- ################################ Tipos e Registros de mem�ria ################################# ----

    -- PL Table para armazenar dados diversos de arrays
    TYPE typ_reg_dados IS
      RECORD(valorapl NUMBER(20,2)
            ,vlacumul NUMBER(20,2)
            ,qtdaplic NUMBER);
    TYPE typ_tab_dados IS TABLE OF typ_reg_dados INDEX BY PLS_INTEGER;
    vr_tab_dados typ_tab_dados;

    -- PL Table para armazenar valores de conta e aplica��o BNDES
    TYPE typ_reg_cta_bndes IS
      RECORD(nrdconta  NUMBER
            ,vlaplica  NUMBER(20,8));
    TYPE typ_tab_cta_bndes IS TABLE OF typ_reg_cta_bndes INDEX BY VARCHAR2(10);
    vr_tab_cta_bndes typ_tab_cta_bndes;
    
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
             ,idsitpro crapcpc.idsitpro%TYPE --> Situa��o
             ,idtippro crapcpc.idtippro%TYPE --> Tipo
             ,idtxfixa crapcpc.idtxfixa%TYPE --> Taxa Fixa
             ,idacumul crapcpc.idacumul%TYPE --> Taxa Cumulativa              
             ,cdhscacc crapcpc.cdhscacc%TYPE --> D�bito Aplica��o
             ,cdhsvrcc crapcpc.cdhsvrcc%TYPE --> Cr�dito Resgate/Vencimento Aplica��o
             ,cdhsraap crapcpc.cdhsraap%TYPE --> Cr�dito Renova��o Aplica��o
             ,cdhsnrap crapcpc.cdhsnrap%TYPE --> Cr�dito Aplica��o Recurso Novo
             ,cdhsprap crapcpc.cdhsprap%TYPE --> Cr�dito Atualiza��o Juros
             ,cdhsrvap crapcpc.cdhsrvap%TYPE --> D�bito Revers�o Atualiza��o Juros
             ,cdhsrdap crapcpc.cdhsrdap%TYPE --> Cr�dito Rendimento
             ,cdhsirap crapcpc.cdhsirap%TYPE --> D�bito IRRF
             ,cdhsrgap crapcpc.cdhsrgap%TYPE --> D�bito Resgate
             ,cdhsvtap crapcpc.cdhsvtap%TYPE); --> D�bito Vencimento


      TYPE typ_tab_crapcpc IS
        TABLE OF typ_reg_crapcpc
          INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os dados dos produtos de captacao
      vr_tab_crapcpc typ_tab_crapcpc;

    
    --- #################################### CURSORES ############################################## ----
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> C�digo da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.nrctactl
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_cop cr_crapcop%ROWTYPE;
    
    -- Lista das ag�ncias da Cooperativa
    CURSOR cr_crapage(pr_cdcooper in craprpp.cdcooper%type
                     ,pr_cdprogra in tbgen_batch_controle.cdprogra%type
                     ,pr_qterro   in number
                     ,pr_dtmvtolt in tbgen_batch_controle.dtmvtolt%type) IS
      select distinct crapass.cdagenci
        from crapass
       where crapass.cdcooper  = pr_cdcooper
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
    
    -- Buscar dados do cadastro de poupan�a programada
    CURSOR cr_craprpp(pr_cdcooper IN craptab.cdcooper%TYPE --> C�digo da cooperativa
                     ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
      SELECT cp.nrdconta
            ,ass.cdagenci
            ,DECODE(ass.inpessoa, 3, 2, ass.inpessoa) inpessoa
            ,cp.nrctrrpp
            ,cp.dtinirpp
            ,cp.dtiniper
            ,cp.flgctain
            ,cp.vlsdrdpp
            ,cp.dtcalcul
            ,cp.cdsitrpp
            ,cp.rowid
            ,cp.dtfimper
            ,cp.vlprerpp
            ,cp.dtdebito
            ,cp.vlsdextr
            ,cp.dtslfmes
            ,cp.vlslfmes
            ,cp.vlabcpmf
            ,cp.dtvctopp
            ,cp.qtmesext
      FROM craprpp cp
          ,crapass ass
      WHERE cp.cdcooper = ass.cdcooper
        AND cp.nrdconta = ass.nrdconta
        AND ass.cdagenci = DECODE(pr_cdagenci,0,ass.cdagenci,pr_cdagenci)
        AND cp.cdcooper = pr_cdcooper
        AND cp.cdsitrpp <> 5        
        AND cp.cdprodut > 0
      ORDER BY cp.nrdconta, cp.nrctrrpp;
    -- PLTABLE para fazer bulk collect e acelerar as leituras  
    TYPE typ_CRAPRRP IS TABLE OF cr_craprpp%ROWTYPE INDEX BY PLS_INTEGER;
    rw_rpp typ_CRAPRRP;          

    --Cursor para buscar rowid acumulado e atualizar tabela craptrd            
    cursor cr_work_trd(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                      ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                      ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                      ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
      select distinct a.dschave rowid_trd
        from tbgen_batch_relatorio_wrk a
       where a.cdcooper    = pr_cdcooper
         and a.cdprograma  = pr_cdprograma
         and a.dsrelatorio = pr_dsrelatorio
         and a.dtmvtolt    = pr_dtmvtolt; 
    --PL TABLE para armazenar indice para realizar update forall
    TYPE typ_tbgen_relwrk_trd IS TABLE OF cr_work_trd%ROWTYPE INDEX BY PLS_INTEGER;
    vr_tab_work_trd typ_tbgen_relwrk_trd; 
            
                
    --Cursor para buscar valores e atualizar a capa do lote na tabela l            
    cursor cr_work_lot(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                      ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                      ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                      ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) is
      select sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,1)+1,instr(a.dscritic,';',1,2)-instr(a.dscritic,';',1,1)-1))) vlinfocr,
             sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,2)+1,instr(a.dscritic,';',1,3)-instr(a.dscritic,';',1,2)-1))) vlcompcr,
             sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,3)+1,instr(a.dscritic,';',1,4)-instr(a.dscritic,';',1,3)-1))) vlinfodb,
             sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,4)+1,instr(a.dscritic,';',1,5)-instr(a.dscritic,';',1,4)-1))) vlcompdb,
             sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,5)+1,instr(a.dscritic,';',1,6)-instr(a.dscritic,';',1,5)-1))) qtinfoln,
             sum(to_number(substr(a.dscritic,instr(a.dscritic,';',1,6)+1,instr(a.dscritic,';',1,7)-instr(a.dscritic,';',1,6)-1))) qtcompln
        from tbgen_batch_relatorio_wrk a
       where a.cdcooper    = pr_cdcooper
         and a.cdprograma  = pr_cdprograma
         and a.dsrelatorio = pr_dsrelatorio
         and a.dtmvtolt    = pr_dtmvtolt;    
    vr_tab_work_lot cr_work_lot%rowtype;            
      
    -- Dados das tabela de trabalho de PRAZOS
    cursor cr_work_prazos(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                         ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                         ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                         ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT dschave
            ,sum(to_number(gene0002.fn_busca_entrada(1,dscritic,';'),'fm999g999g999g999g990d00')) valorapl
            ,sum(to_number(gene0002.fn_busca_entrada(2,dscritic,';'),'fm999g999g999g999g990d00')) vlacumul
            ,sum(to_number(gene0002.fn_busca_entrada(3,dscritic,';'),'fm999g999g999g999g990')) qtdaplic
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt 
       GROUP BY dschave
       ORDER BY dschave;        
    
    -- Dados das tabela de trabalho de dados BNDES
    cursor cr_work_bndes(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                        ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                        ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                        ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT dschave
            ,nrdconta
            ,SUM(vlacumul) vlaplica
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt 
       GROUP BY dschave
               ,nrdconta
       ORDER BY dschave;  
    
    -- Dados das tabela de trabalho de dados TAB_TOTAL
    cursor cr_work_total(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                        ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                        ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                        ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%type) IS
      SELECT dschave inpessoa
            ,sum(to_number(gene0002.fn_busca_entrada(01,dscritic,';'),'fm999g999g999g999g990d00')) qtrppati
            ,sum(to_number(gene0002.fn_busca_entrada(02,dscritic,';'),'fm999g999g999g999g990d00')) vlrppati
            ,sum(to_number(gene0002.fn_busca_entrada(03,dscritic,';'),'fm999g999g999g999g990d00')) vlrppmes
            ,sum(to_number(gene0002.fn_busca_entrada(04,dscritic,';'),'fm999g999g999g999g990d00')) vlresmes
            ,sum(to_number(gene0002.fn_busca_entrada(05,dscritic,';'),'fm999g999g999g999g990d00')) qtrppnov
            ,sum(to_number(gene0002.fn_busca_entrada(06,dscritic,';'),'fm999g999g999g999g990d00')) vlrppnov
            ,sum(to_number(gene0002.fn_busca_entrada(07,dscritic,';'),'fm999g999g999g999g990d00')) vlrenmes
            ,sum(to_number(gene0002.fn_busca_entrada(08,dscritic,';'),'fm999g999g999g999g990d00')) vlprvmes
            ,sum(to_number(gene0002.fn_busca_entrada(09,dscritic,';'),'fm999g999g999g999g990d00')) vlprvlan
            ,sum(to_number(gene0002.fn_busca_entrada(10,dscritic,';'),'fm999g999g999g999g990d00')) vlajuprv
            ,sum(to_number(gene0002.fn_busca_entrada(11,dscritic,';'),'fm999g999g999g999g990d00')) vlrtirrf
            ,sum(to_number(gene0002.fn_busca_entrada(12,dscritic,';'),'fm999g999g999g999g990d00')) vlrtirab
            ,sum(to_number(gene0002.fn_busca_entrada(13,dscritic,';'),'fm999g999g999g999g990d00')) bsabcpmf
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt 
       GROUP BY dschave
       ORDER BY dschave; 
    
    -- Dados das tabela de trabalho de dados Gerais por Agencia
    cursor cr_work_crrl737_agenci(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                                 ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                                 ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                                 ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%TYPE) IS
      SELECT cdagenci
            ,SUM(nvl(vldpagto,0)) vr_tab_vlrppage_fis
            ,SUM(nvl(vltitulo,0)) vr_tab_vlrppage_jur
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt 
       GROUP BY cdagenci
       ORDER BY cdagenci;     
       
    -- Dados das tabela de trabalho de dados Gerais XML por Agencia
    cursor cr_work_crrl737_poup(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                               ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                               ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                               ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%TYPE) IS
      SELECT nrdconta
            ,nrctremp
            ,vldpagto
            ,dscritic
            ,gene0002.fn_busca_entrada(01,dscritic,';') dtcalcul
            ,gene0002.fn_busca_entrada(02,dscritic,';') dtiniper
            ,gene0002.fn_busca_entrada(03,dscritic,';') dtfimper
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt 
       ORDER BY nrdconta      
               ,nrctremp;
               
    -- Dados das tabela de trabalho de dados Gerais
    cursor cr_work_crrl737(pr_cdcooper    tbgen_batch_relatorio_wrk.cdcooper%type  
                          ,pr_cdprograma  tbgen_batch_relatorio_wrk.cdprograma%type 
                          ,pr_dsrelatorio tbgen_batch_relatorio_wrk.dsrelatorio%type
                          ,pr_dtmvtolt    tbgen_batch_relatorio_wrk.dtmvtolt%TYPE) IS
      SELECT sum(to_number(gene0002.fn_busca_entrada(01,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_qtrppati
            ,sum(to_number(gene0002.fn_busca_entrada(02,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_vlrppati
            ,sum(to_number(gene0002.fn_busca_entrada(03,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_qtrppati_n
            ,sum(to_number(gene0002.fn_busca_entrada(04,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_vlrppati_n
            ,sum(to_number(gene0002.fn_busca_entrada(05,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_qtrppati_a
            ,sum(to_number(gene0002.fn_busca_entrada(06,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_vlrppati_a
            ,sum(to_number(gene0002.fn_busca_entrada(07,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_tot_rppagejur
            ,sum(to_number(gene0002.fn_busca_entrada(08,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_qtrppnov
            ,sum(to_number(gene0002.fn_busca_entrada(09,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_vlrppnov
            ,sum(to_number(gene0002.fn_busca_entrada(10,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_qtrppnov_n
            ,sum(to_number(gene0002.fn_busca_entrada(11,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_vlrppnov_n
            ,sum(to_number(gene0002.fn_busca_entrada(12,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_qtrppnov_a
            ,sum(to_number(gene0002.fn_busca_entrada(13,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_vlrppnov_a
            ,sum(to_number(gene0002.fn_busca_entrada(14,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_bsabcpmf
            ,sum(to_number(gene0002.fn_busca_entrada(15,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_bsabcpmf_n
            ,sum(to_number(gene0002.fn_busca_entrada(16,dscritic,';'),'fm999g999g999g999g999g999g990d00')) vr_res_bsabcpmf_a
        FROM tbgen_batch_relatorio_wrk
       WHERE cdcooper    = pr_cdcooper   
         AND cdprograma  = pr_cdprograma 
         AND dsrelatorio = pr_dsrelatorio
         AND dtmvtolt    = pr_dtmvtolt;  
       
    -- Buscar lan�amentos do m�s
    CURSOR cr_craplac(pr_cdcooper IN craptab.cdcooper%TYPE        --> C�digo cooperativa
                     ,pr_dtinimes IN craplac.dtmvtolt%TYPE        --> Data inicial do m�s
                     ,pr_dtfimmes IN craplac.dtmvtolt%TYPE) IS    --> Data final do m�s
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
    
          -- valida a existencia de registros de provisao
      CURSOR cr_craplot(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT lot.cdcooper
             ,lot.nrseqdig
             ,lot.qtinfoln
             ,lot.qtcompln
             ,lot.vlinfocr
             ,lot.vlcompcr  
             ,lot.nrdolote
             ,lot.cdbccxlt 
             ,lot.cdagenci
             ,lot.dtmvtolt 
             ,lot.rowid
             ,lot.tplotmov
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = 1
         AND lot.cdbccxlt = 100
         AND lot.nrdolote = 8506;

       rw_craplot cr_craplot%ROWTYPE;

    -- Buscar dados de rejeitados
    CURSOR cr_craprej (pr_cdcooper IN craptab.cdcooper%TYPE         --> C�digo cooperativa
                      ,pr_cdprogra IN crapres.cdprogra%TYPE) IS     --> C�digo do programa
      SELECT cj.dtmvtolt
            ,cj.vllanmto
            ,COUNT(1) OVER() contagem
            ,cj.rowid
      FROM craprej cj
      WHERE cj.cdcooper = pr_cdcooper
        AND cj.cdpesqbb = pr_cdprogra
      ORDER BY cj.dtmvtolt; 
    
      -- Selecionar dados de aplicacao
      CURSOR cr_craprac (pr_cdcooper craplrg.cdcooper%TYPE,
                       pr_nrdconta craprac.nrdconta%TYPE,
                       pr_nrctrrpp craprac.nrctrrpp%TYPE) IS
                       
      SELECT
        rac.cdcooper, rac.nrdconta,
        rac.nraplica, rac.cdprodut,
        rac.cdnomenc, rac.dtmvtolt,
        rac.dtvencto, rac.dtatlsld,
        rac.vlaplica, rac.vlbasapl,
        rac.vlsldatl, rac.vlslfmes,
        rac.vlsldacu, rac.qtdiacar,
        rac.qtdiaprz, rac.qtdiaapl,
        rac.txaplica, rac.idsaqtot,
        rac.idblqrgt, rac.idcalorc,
        rac.cdoperad, rac.progress_recid,
        rac.iddebcti, rac.vlbasant,
        rac.vlsldant, rac.dtsldant,
        rac.rowid,
        cpc.nmprodut, cpc.idsitpro,
        cpc.cddindex, cpc.idtippro,
        cpc.idtxfixa, cpc.idacumul,
        cpc.cdhscacc, cpc.cdhsvrcc,
        cpc.cdhsraap, cpc.cdhsnrap, 
        cpc.cdhsprap, cpc.cdhsrvap,
        cpc.cdhsrdap, cpc.cdhsirap,
        cpc.cdhsrgap, cpc.cdhsvtap
      FROM 
        craprac rac,
        crapcpc cpc 
      WHERE
        rac.cdcooper = pr_cdcooper  AND
        rac.nrdconta = pr_nrdconta AND
        rac.nrctrrpp = pr_nrctrrpp AND
        cpc.cdprodut = rac.cdprodut;
    rw_craprac     cr_craprac%rowtype;

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

    --- ################################ SubRotinas ################################# ----

      -- PROCESSOA AS APLICACOES DA APLICA�AO PROGRAMADA
      PROCEDURE pc_processa_aplicacao(pr_cdcooper IN craprac.cdcooper%TYPE
                                           ,pr_nrdconta IN craprac.nrdconta%TYPE
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE
                                      ,pr_idxrpp IN NUMBER
                                           ,pr_vlsdapprpp OUT NUMBER) IS


        BEGIN

         /*..............................................................................

           Programa: pc_processa_aplicacao
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : CIS
           Data    : Julho/2018                       Ultima atualizacao: 20/07/2018

           Dados referentes ao programa:

           Frequencia: Mensal.

           Objetivo  : Realiza a provis�o para cada uma das aplica��es associada a aplica��o programada da RPP.

         ...............................................................................*/

        DECLARE
      -- variaveis de retorno do calculo de provisao

      vr_idtipbas NUMBER := 2; -- tipo base de calculo
      vr_vlbascal NUMBER := 0; -- valor base de calculo
      vr_vlsldtot NUMBER := 0;
      vr_vlsldrgt NUMBER := 0;
      vr_vlultren NUMBER := 0;
      vr_vlrentot NUMBER := 0;
      vr_vlrevers NUMBER := 0;
      vr_vlrdirrf NUMBER := 0;
      vr_percirrf NUMBER := 0;
      vr_qtmesext NUMBER := 0;
      vr_vlrenrpp NUMBER := 0;
      vr_vlrirrpp NUMBER := 0;

      -- valor de saldo anterior
      vr_vlsldant craprac.vlsldant%TYPE;
      -- data do saldo anterior
      vr_dtsldant craprac.dtsldant%TYPE;
    
      vr_dtrefere DATE := rw_rpp(pr_idxrpp).dtfimper;

    BEGIN
    pr_vlsdapprpp := 0;
         
          -- filtra as aplicacoes da cooperativa     
         FOR rw_craprac IN cr_craprac(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => pr_nrdconta,
                                     pr_nrctrrpp => pr_nrctrrpp)
           LOOP      
    
           -- valida o cadastro do historico para o produto da aplicacao
           IF rw_craprac.cdhsprap <= 0 THEN
             
             -- Gerar log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr HH:mm:ss') || ' - crps685 --> ' ||
                                                           'Campo de historico (cdhsprap) nao informado. ' ||
                                                           'Conta: ' || trim(gene0002.fn_mask_conta(rw_craprac.nrdconta)) || 
                                                           ', Aplic.: ' || trim(gene0002.fn_mask(rw_craprac.nraplica,'zzz.zz9')) ||
                                                           ', Prod.: ' || trim(rw_craprac.cdprodut));                                                        
             CONTINUE;       
           
           END IF;
           IF (rw_craprac.dtmvtolt = rw_dat.dtmvtolt) THEN
              vr_vlultren := 0;
              vr_vlrentot := 0;
              vr_vlrdirrf := 0;
           ELSE
                  APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper, 
                                                          pr_nrdconta => rw_craprac.nrdconta,
                                                          pr_nraplica => rw_craprac.nraplica, 
                                                          pr_dtiniapl => rw_craprac.dtmvtolt,
                                                          pr_txaplica => rw_craprac.txaplica, 
                                                          pr_idtxfixa => rw_craprac.idtxfixa,
                                                          pr_cddindex => rw_craprac.cddindex, 
                                                          pr_qtdiacar => rw_craprac.qtdiacar,
                                                          pr_idgravir => 0, 
                                                          pr_dtinical => rw_craprac.dtatlsld,
                                                          pr_dtfimcal => rw_dat.dtmvtolt, 
                                                          pr_idtipbas => vr_idtipbas,
                                                          pr_vlbascal => vr_vlbascal, 
                                                          pr_vlsldtot => vr_vlsldtot,
                                                          pr_vlsldrgt => vr_vlsldrgt, 
                                                          pr_vlultren => vr_vlultren,
                                                          pr_vlrentot => vr_vlrentot, 
                                                          pr_vlrevers => vr_vlrevers,
                                                          pr_vlrdirrf => vr_vlrdirrf, 
                                                          pr_percirrf => vr_percirrf,
                                                          pr_cdcritic => vr_cdcritic, 
                                                          pr_dscritic => vr_dscritic);
    
                    -- tratamento para possiveis erros gerados pelas rotinas anteriores
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       RAISE vr_exc_erro;
                    END IF;
                -- valida o ultimo rendimento
           END IF; 
        pr_vlsdapprpp := pr_vlsdapprpp + (rw_craprac.vlsldatl + vr_vlultren);
           vr_vlrenrpp := vr_vlrenrpp + vr_vlrentot;
           vr_vlrirrpp := vr_vlrirrpp + vr_vlrdirrf;
        
                IF vr_vlultren > 0 THEN    
    
                  OPEN cr_craplot(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => rw_dat.dtmvtolt);
                  
                  FETCH cr_craplot INTO rw_craplot;
                  
                  CLOSE cr_craplot;
                  
                  -- de acordo com o INSERT executado no inicio deste script 
                  -- nao ha necessidade de verificacao de existencia do registro 
                  -- na CRAPLOT entao atualiza o registro ja criado na CRAPLOT              
                  BEGIN
                    UPDATE craplot SET tplotmov = 9
                                      ,nrseqdig = rw_craplot.nrseqdig + 1
                                      ,qtinfoln = rw_craplot.qtinfoln + 1
                                      ,qtcompln = rw_craplot.qtcompln + 1
                                      ,vlinfocr = rw_craplot.vlinfocr + vr_vlultren
                                      ,vlcompcr = rw_craplot.vlcompcr + vr_vlultren
                                 WHERE cdcooper = rw_craprac.cdcooper
                                   AND dtmvtolt = rw_dat.dtmvtolt
                                   AND cdagenci = 1
                                   AND cdbccxlt = 100
                                   AND nrdolote = 8506 
                                   AND craplot.rowid = rw_craplot.rowid
                             RETURNING tplotmov, nrseqdig, qtinfoln, qtcompln, vlinfocr, vlcompcr, ROWID
                                  INTO rw_craplot.tplotmov, rw_craplot.nrseqdig, rw_craplot.qtinfoln,
                                       rw_craplot.qtcompln, rw_craplot.vlinfocr, rw_craplot.vlcompcr, rw_craplot.rowid;                                
                  EXCEPTION 
                    WHEN OTHERS THEN
                      -- Gerar erro e fazer rollback
                      vr_dscritic := 'Erro ao atualizar valores do lote(craplot). Detalhes: '||sqlerrm;
                      RAISE vr_exc_erro;
                  END;
                          
                  -- consulta dados recem-alterados acima
                  OPEN cr_craplot(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => rw_dat.dtmvtolt);
                  FETCH cr_craplot INTO rw_craplot;                        
                  CLOSE cr_craplot;
                              
                  -- armazena o lancamento de provisao
                  BEGIN
                    INSERT INTO craplac(cdcooper
                                       ,dtmvtolt
                                       ,cdagenci
                                       ,cdbccxlt
                                       ,nrdolote
                                       ,nrdconta
                                       ,nraplica
                                       ,nrdocmto
                                       ,nrseqdig
                                       ,vllanmto
                                       ,cdhistor)
                                 VALUES(rw_craprac.cdcooper
                                       ,rw_craplot.dtmvtolt
                                       ,rw_craplot.cdagenci
                                       ,rw_craplot.cdbccxlt
                                       ,rw_craplot.nrdolote
                                       ,rw_craprac.nrdconta
                                       ,rw_craprac.nraplica
                                       ,rw_craplot.nrseqdig
                                       ,rw_craplot.nrseqdig
                                       ,vr_vlultren
                                       ,rw_craprac.cdhsprap);
                  EXCEPTION 
                    WHEN OTHERS THEN
                      -- Gerar erro e fazer rollback
                      vr_dscritic := 'Erro ao inserir lancamentos(craplac). Detalhes: '||sqlerrm;
                      RAISE vr_exc_erro;
                  END;
                
                END IF;
    
                -- valida a execucao da ultima atualizacao da aplicacao
                IF rw_craprac.dtatlsld <> rw_dat.dtmvtolt THEN
                 -- atualiza os campos valor saldo anterior e data saldo anterior, com os dados atuais na craprac
                  vr_vlsldant := rw_craprac.vlsldatl;
                  vr_dtsldant := rw_craprac.dtatlsld;
                ELSE -- caso ja tenha atualizado no dia mantem os mesmos valores ja cadastrados
                  vr_vlsldant := rw_craprac.vlsldant;
                  vr_dtsldant := rw_craprac.dtsldant;
                END IF;
    
                -- atualiza valor atual da aplicacao e a data da ultima atualizacao
                BEGIN
                  UPDATE craprac SET vlsldatl = rw_craprac.vlsldatl + vr_vlultren
                                    ,dtatlsld = rw_dat.dtmvtolt
                                    ,vlslfmes = rw_craprac.vlsldatl + vr_vlultren
                                    ,vlsldant = vr_vlsldant
                                    ,dtsldant = vr_dtsldant
                               WHERE cdcooper = rw_craprac.cdcooper
                                 AND nrdconta = rw_craprac.nrdconta
                                 AND nraplica = rw_craprac.nraplica
                                 AND craprac.rowid = rw_craprac.rowid
                           RETURNING vlsldatl, dtatlsld, vlslfmes, vlsldant, dtsldant, ROWID
                                INTO rw_craprac.vlsldatl, rw_craprac.dtatlsld, rw_craprac.vlslfmes,
                                     rw_craprac.vlsldant, rw_craprac.dtsldant, rw_craprac.rowid;                                                             

                EXCEPTION 
                  WHEN OTHERS THEN
                    -- Gerar erro e fazer rollback
                    vr_dscritic := 'Erro ao atualizar aplica��o(craprac). Detalhes: '||sqlerrm;
                    RAISE vr_exc_erro;
                END;
            END LOOP;

        --
        vr_qtmesext := rw_rpp(pr_idxrpp).qtmesext + 1;
        if vr_qtmesext = 4 then
          vr_qtmesext := 1;
        end if;
        if to_char(rw_rpp(pr_idxrpp).dtfimper, 'mm') = '12' then
          vr_qtmesext := 3;
        end if;

        -- Atualiza poupan�a programada
        begin
          update craprpp
             set craprpp.qtmesext = vr_qtmesext,
                 craprpp.dtiniext = decode(vr_qtmesext,
                                           1, craprpp.dtfimext,
                                           craprpp.dtiniext),
                 craprpp.dtsdppan = decode(vr_qtmesext,
                                           1, craprpp.dtiniper,
                                           craprpp.dtsdppan),
                 craprpp.vlsdppan = decode(vr_qtmesext,
                                           1, craprpp.vlsdrdpp,
                                           craprpp.vlsdppan),
                 craprpp.incalmes = 0,
                 indebito = 0,
                 craprpp.dtfimext = craprpp.dtfimper,
                 craprpp.dtiniper = craprpp.dtfimper,
                 craprpp.dtfimper = add_months(craprpp.dtfimper, 1),
                 craprpp.vlsdrdpp = pr_vlsdapprpp - vr_vlrirrpp,
                 craprpp.dtcalcul = rw_dat.dtmvtopr
           where craprpp.rowid = rw_rpp(pr_idxrpp).rowid;

          update crapspp
             set crapspp.vlsldrpp = pr_vlsdapprpp - vr_vlrirrpp,
                 crapspp.dtmvtolt = rw_dat.dtmvtolt
           where crapspp.cdcooper = pr_cdcooper
             and crapspp.nrdconta = pr_nrdconta
             and crapspp.nrctrrpp = pr_nrctrrpp
             and crapspp.dtsldrpp = rw_rpp(pr_idxrpp).dtfimper;
          --
          if sql%rowcount = 0 then
            -- N�o encontrou registro para atualizar, portanto deve incluir um novo
              insert into crapspp (cdcooper,
                                   nrdconta,
                                   nrctrrpp,
                                   dtsldrpp,
                                   vlsldrpp,
                                   dtmvtolt)
              values (pr_cdcooper,
                      pr_nrdconta,
                      pr_nrctrrpp,
                      rw_rpp(pr_idxrpp).dtfimper,
                      pr_vlsdapprpp - vr_vlrirrpp,
                      rw_dat.dtmvtolt);
    end if;
        if vr_vlrenrpp > 0 then
          -- Atualiza os juros acumulados da poupan�a programada
            update craprpp
               set craprpp.vljuracu = craprpp.vljuracu + vr_vlrenrpp
             where craprpp.rowid = rw_rpp(pr_idxrpp).rowid;

          -- Atualiza cotas e recursos (somente os campos correspondentes ao m�s de refer�ncia)
            update crapcot
               set crapcot.vlrenrpp = crapcot.vlrenrpp + vr_vlrenrpp,
                   crapcot.vlrenrpp_ir##1 = crapcot.vlrenrpp_ir##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '01', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##1 = crapcot.vlrentot##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '01', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##2 = crapcot.vlrenrpp_ir##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '02', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##2 = crapcot.vlrentot##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '02', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##3 = crapcot.vlrenrpp_ir##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '03', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##3 = crapcot.vlrentot##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '03', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##4 = crapcot.vlrenrpp_ir##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '04', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##4 = crapcot.vlrentot##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '04', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##5 = crapcot.vlrenrpp_ir##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '05', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##5 = crapcot.vlrentot##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '05', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##6 = crapcot.vlrenrpp_ir##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '06', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##6 = crapcot.vlrentot##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '06', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##7 = crapcot.vlrenrpp_ir##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '07', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##7 = crapcot.vlrentot##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '07', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##8 = crapcot.vlrenrpp_ir##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '08', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##8 = crapcot.vlrentot##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '08', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##9 = crapcot.vlrenrpp_ir##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '09', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##9 = crapcot.vlrentot##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '09', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##10 = crapcot.vlrenrpp_ir##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '10', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##10 = crapcot.vlrentot##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '10', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##11 = crapcot.vlrenrpp_ir##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '11', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##11 = crapcot.vlrentot##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '11', vr_vlrenrpp,
                                                                      0),
                   crapcot.vlrenrpp_ir##12 = crapcot.vlrenrpp_ir##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '12', vr_vlrenrpp,
                                                                            0),
                   crapcot.vlrentot##12 = crapcot.vlrentot##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '12', vr_vlrentot,
                                                                      0)
             where crapcot.cdcooper = pr_cdcooper
                   and crapcot.nrdconta = pr_nrdconta;
        end if;

        exception
          when others then
            vr_dscritic := 'Erro ao atualizar informa��es da aplica��o programada: '||sqlerrm;
            raise vr_exc_erro;
        end;

         

      EXCEPTION
       WHEN vr_exc_p1 THEN
         vr_cdcritic := 0;
         RAISE vr_exc_p2;
       when vr_exc_erro then
         vr_cdcritic := 0;
         raise vr_exc_erro;
       WHEN OTHERS THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Erro ao validar dados: ' || SQLERRM;
         RAISE vr_exc_p2;
      END;

      END pc_processa_aplicacao;

    -- Procedure para consistir e gravar dados na CRAPPRB
    PROCEDURE pc_cria_crapprb (pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa
                       ,pr_prazodia  IN NUMBER                  --> Prazo de dias
                              ,pr_vlretorn  IN crapprb.vlretorn%TYPE   --> Valor de retorno
                              ,pr_nrctactl  IN crapcop.nrctactl%TYPE   --> N�mero da conta
                              ,pr_desc_erro OUT VARCHAR2) AS           --> Sa�da de erro
      BEGIN
        DECLARE
          vr_cddprazo   crapprb.cddprazo%TYPE;               --> C�digo do prazo de pagamento
       CURSOR cr_crapprb(pr_nrctactl IN crapcop.nrctactl%TYPE
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                              ,pr_cddprazo IN NUMBER
                              ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    
              SELECT * FROM crapprb
                      WHERE cdcooper = pr_cdcooper
                        AND nrdconta = pr_nrctactl
                        AND dtmvtolt = pr_dtmvtolt
                        AND cdorigem = 9
                        AND cddprazo = pr_cddprazo;

         rw_crapprb cr_crapprb%ROWTYPE;

        BEGIN
          -- Definir c�digo de prazo de pagamento
          CASE pr_prazodia
            WHEN 0  THEN vr_cddprazo := 0;
            WHEN 1  THEN vr_cddprazo := 90;
            WHEN 2  THEN vr_cddprazo := 180;
            WHEN 3  THEN vr_cddprazo := 270;
            WHEN 4  THEN vr_cddprazo := 360;
            WHEN 5  THEN vr_cddprazo := 720;
            WHEN 6  THEN vr_cddprazo := 1080;
            WHEN 7  THEN vr_cddprazo := 1440;
            WHEN 8  THEN vr_cddprazo := 1800;
            WHEN 9  THEN vr_cddprazo := 2160;
            WHEN 10 THEN vr_cddprazo := 2520;
            WHEN 11 THEN vr_cddprazo := 2880;
            WHEN 12 THEN vr_cddprazo := 3240;
            WHEN 13 THEN vr_cddprazo := 3600;
            WHEN 14 THEN vr_cddprazo := 3960;
            WHEN 15 THEN vr_cddprazo := 4320;
            WHEN 16 THEN vr_cddprazo := 4680;
            WHEN 17 THEN vr_cddprazo := 5040;
            WHEN 18 THEN vr_cddprazo := 5400;
            WHEN 19 THEN vr_cddprazo := 5401;
          END CASE;

            --consulta a existencia de um resgistro na crapprb
            OPEN cr_crapprb(pr_nrctactl => pr_nrctactl
                           ,pr_dtmvtolt => rw_dat.dtmvtolt
                           ,pr_cddprazo => vr_cddprazo
                           ,pr_cdcooper => pr_cdcooper);

            FETCH cr_crapprb INTO rw_crapprb;
         
            IF cr_crapprb%NOTFOUND THEN
               BEGIN

          -- Realizar INSERT na CRAPPRB
          INSERT INTO crapprb (cdcooper
                              ,dtmvtolt
                              ,nrdconta
                              ,cdorigem
                              ,cddprazo
                              ,vlretorn)
                        VALUES(pr_cdcooper
                              ,rw_dat.dtmvtolt
                              ,pr_nrctactl
                              ,9
                              ,vr_cddprazo
                              ,pr_vlretorn);
                 EXCEPTION 
                   WHEN OTHERS THEN
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro ao inserir saldo das aplicacoes (crapprb). Detalhes: '||sqlerrm;
                     RAISE vr_exc_erro;
               END;          
            ELSE
               BEGIN
                 UPDATE crapprb SET vlretorn = vlretorn + pr_vlretorn
                           WHERE cdcooper = pr_cdcooper
                             AND nrdconta = pr_nrctactl
                             AND dtmvtolt = rw_dat.dtmvtolt
                             AND cdorigem = 10
                             AND cddprazo = vr_cddprazo;
                 EXCEPTION 
                   WHEN OTHERS THEN
                     -- Gerar erro e fazer rollback
                     vr_dscritic := 'Erro em pc_cria_crapprb. Detalhes: '||sqlerrm;
                     RAISE vr_exc_erro;
                 END;
            
            END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_desc_erro := 'Erro em pc_cria_crapprb: ' || SQLERRM;
      END;
    END pc_cria_crapprb;

    -- Procedure para acumular valores de novas e antigas aplica��es
    PROCEDURE pc_acumula_aplicacoes(pr_cdhistor  IN craplac.cdhistor%TYPE   --> C�digo do hist�rico
                                   ,pr_tipoapli  IN VARCHAR2                --> Indicar se aplica��o � nova (N) ou antiga (A)
                                   ,pr_vllanmto  IN craplac.vllanmto%TYPE   --> Valor de movimento
                                   ,pr_nrdolote  IN craplac.nrdolote%TYPE   --> N�mero do lote
                                   ,pr_cdprodut  IN craprpp.cdprodut%TYPE   --> N�mero do Produto
                                   ,pr_desc_erro OUT VARCHAR2) AS           --> Descri��o de erros no processo
    BEGIN
      BEGIN
        -- Faz o acumulo de acordo com o c�digo do hist�rico
        -- Considera se ir� gerar lan�amentos em aplica��es novas ou antigas

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
          WHEN pr_cdhistor = vr_tab_crapcpc(pr_cdprodut).cdhsrvap THEN
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
            pr_desc_erro := 'Erro em pc_acumula_aplicacoes tipo N: ' || SQLERRM;
          ELSIF pr_tipoapli = 'A' THEN
            pr_desc_erro := 'Erro em pc_acumula_aplicacoes tipo A: ' || SQLERRM;
          END IF;
      END;
    END pc_acumula_aplicacoes;

  ---------------------------------------
  -- Inicio Bloco Principal pc_crps737
  ---------------------------------------
  BEGIN

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                             , pr_action => NULL);

    -- Na execu��o principal
    if nvl(pr_idparale,0) = 0 then
      -- Grava LOG sobre o �nicio da execu��o da procedure na tabela tbgen_prglog
      vr_idlog_ini_ger := null;
      pc_log_programa(pr_dstiplog   => 'I'    
                     ,pr_cdprograma => vr_cdprogra          
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => 1    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger);
    end if;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_cop;
    -- Se n�o encontrar registros montar mensagem de critica
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

    -- Valida��es iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1--TRUE
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

    -- Caso retorno cr�tica busca a descri��o
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_dat;
    CLOSE btch0001.cr_crapdat;
    
    -- Apenas quando for o programa principal  
    if nvl(pr_idparale,0) = 0 then

      -- Grava LOG de ocorr�ncia final de atualiza��o da craplot
      pc_log_programa(pr_dstiplog           => 'O',
                      pr_cdprograma         => vr_cdprogra,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => 1,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Inicio inser��o ou atualiza��o lote 8383 padr�o',
                      pr_idprglog           => vr_idlog_ini_ger); 
      
      begin
        update craplot
           set craplot.tplotmov = 14,
               craplot.nrseqdig = CRAPLOT_8383_SEQ.NEXTVAL
         where craplot.cdcooper = pr_cdcooper
           and craplot.dtmvtolt = rw_dat.dtmvtolt
           and craplot.cdagenci = 1
           and craplot.cdbccxlt = 100
           and craplot.nrdolote = 8383;              
      exception
        when others then
          vr_dscritic := 'Erro ao verificar informa��es da capa de lote: '||sqlerrm;
          vr_cdcritic := 0;
          raise vr_exc_saida;
      END;
      if sql%rowcount = 0 then
        begin
          insert into craplot (dtmvtolt,
                               cdagenci,
                               cdbccxlt,
                               nrdolote,
                               tplotmov,
                               cdcooper,
                               nrseqdig)
          values (rw_dat.dtmvtolt,
                  1,
                  100,
                  8383,
                  14,
                  pr_cdcooper,
                  CRAPLOT_8383_SEQ.NEXTVAL);
        exception
          when others then
            vr_dscritic := 'Erro ao inserir informa��es da capa de lote: '||sqlerrm;
            vr_cdcritic := 0;
            raise vr_exc_saida;
        end;
      end if; 
      -- Grava LOG de ocorr�ncia final da atualiza��o da craplot
      pc_log_programa(pr_dstiplog           => 'O',
                      pr_cdprograma         => vr_cdprogra,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => 1,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim inser��o ou atualiza��o lote 8383 padr�o',
                      pr_idprglog           => vr_idlog_ini_ger); 
      
      commit;
    end if;
    
    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper   --> C�digo da coopertiva
                                                 ,vr_cdprogra); --> C�digo do programa
    
    /* Paralelismo visando performance Rodar Somente no processo Noturno */
    if rw_dat.inproces > 2 and vr_qtdjobs > 0 and pr_cdagenci = 0 then  
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_ID_paralelo;
      
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
         -- Levantar exce��o
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
         RAISE vr_exc_saida;
      END IF;
                                            
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                   ,pr_cdprogra    => vr_cdprogra
                                                   ,pr_dtmvtolt    => rw_dat.dtmvtolt
                                                   ,pr_tpagrupador => 1
                                                   ,pr_nrexecucao  => 1);     
                                            
      -- Retorna todas as ag�ncias da Cooperativa 
      for rw_age in cr_crapage (pr_cdcooper
                                   ,vr_cdprogra
                                   ,vr_qterro
                                   ,rw_dat.dtmvtolt) loop
                                            
        -- Montar o prefixo do c�digo do programa para o jobname
        vr_jobname := vr_cdprogra ||'_'|| rw_age.cdagenci || '$';  
      
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_age.cdagenci,3,'0') --> Utiliza a ag�ncia como id programa
                                  ,pr_des_erro => vr_dscritic);
                                  
        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exce�ao
          raise vr_exc_saida;
        end if;     
        
        -- Montar o bloco PLSQL que ser� executado
        -- Ou seja, executaremos a gera��o dos dados
        -- para a ag�ncia atual atraves de Job no banco
        vr_dsplsql := 'DECLARE' || chr(13) 
                   || '  wpr_stprogra NUMBER;' || chr(13) 
                   || '  wpr_infimsol NUMBER;' || chr(13) 
                   || '  wpr_cdcritic NUMBER;' || chr(13) 
                   || '  wpr_dscritic VARCHAR2(1500);' || chr(13) 
                   || 'BEGIN' || chr(13) 
                     || '  PC_CRPS737('|| pr_cdcooper 
                   || '            ,'|| rw_age.cdagenci 
                   || '            ,'|| vr_idparale 
                   || '            ,wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' 
                   || chr(13) 
                   || 'END;'; --  
         
         -- Faz a chamada ao programa paralelo atraves de JOB
         gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> C�digo da cooperativa
                               ,pr_cdprogra => vr_cdprogra  --> C�digo do programa
                               ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                               ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                               ,pr_interva  => NULL         --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                               ,pr_jobname  => vr_jobname   --> Nome randomico criado
                               ,pr_des_erro => vr_dscritic);    
                               
         -- Testar saida com erro
         if vr_dscritic is not null then 
           -- Levantar exce�ao
           raise vr_exc_saida;
         end if;

         -- Chama rotina que ir� pausar este processo controlador
         -- caso tenhamos excedido a quantidade de JOBS em execu�ao
         gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                     ,pr_qtdproce => vr_qtdjobs --> M�ximo de 10 jobs neste processo
                                     ,pr_des_erro => vr_dscritic);

         -- Testar saida com erro
         if  vr_dscritic is not null then 
           -- Levantar exce�ao
           raise vr_exc_saida;
         end if;
         
      end loop;
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- at� que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic);
                                  
      -- Testar saida com erro
      if  vr_dscritic is not null then 
        -- Levantar exce�ao
        raise vr_exc_saida;
      end if;    

      -- Verifica se algum job executou com erro
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                   ,pr_cdprogra    => vr_cdprogra
                                                   ,pr_dtmvtolt    => rw_dat.dtmvtolt
                                                   ,pr_tpagrupador => 1
                                                   ,pr_nrexecucao  => 1);
      if vr_qterro > 0 then 
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        raise vr_exc_saida;
      end if;    
    ELSE
    
      if pr_cdagenci <> 0 then
        vr_tpexecucao := 2;
      else
        vr_tpexecucao := 1;
      end if;    
      
      -- Grava controle de batch por ag�ncia
      gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper      -- Codigo da Cooperativa
                                      ,pr_cdprogra    => vr_cdprogra      -- Codigo do Programa
                                      ,pr_dtmvtolt    => rw_dat.dtmvtolt  -- Data de Movimento
                                      ,pr_tpagrupador => 1                -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador => pr_cdagenci      -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_cdrestart   => null             -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_nrexecucao  => 1                -- Numero de identificacao da execucao do programa
                                      ,pr_idcontrole  => vr_idcontrole    -- ID de Controle
                                      ,pr_cdcritic    => pr_cdcritic      -- Codigo da critica
                                      ,pr_dscritic    => vr_dscritic);    -- Descricao da critica
      -- Testar saida com erro
      if vr_dscritic is not null then 
        -- Levantar exce�ao
        raise vr_exc_saida;
      end if;    
      
      --Grava LOG sobre o �nicio da execu��o da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I'  
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci          
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => vr_tpexecucao    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par);  
    
    -- Buscar informa��es para c�lculo de poupan�a
    vr_dextabi:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'CONFIG'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'PERCIRAPLI'
                                           ,pr_tpregist => 0);

      -- carregamento pltable usadas
      FOR rw_crapcpc IN cr_crapcpc LOOP        
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

      -- Quando execu��o paralela, n�o � trabalhado com XML neste ponto
      IF pr_cdagenci = 0 THEN
    -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_clob_02, TRUE);
        dbms_lob.open(vr_clob_02, dbms_lob.lob_readwrite); 
    -- Inicilizar as informa��es do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                               ,pr_texto_completo => vr_text_02
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><base>');
      END IF;

        -- Verifica se lote j� existe
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                     ,pr_dtmvtolt => rw_dat.dtmvtolt --> data de movimento
                     );

      FETCH cr_craplot INTO rw_craplot;

      IF cr_craplot%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craplot;

        -- Insere registro de lote
        BEGIN
          -- Insere registro de lote
          INSERT INTO
            craplot(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,tplotmov
             ,nrseqdig
             ,qtinfoln
             ,qtcompln
            )VALUES(
               pr_cdcooper
              ,rw_dat.dtmvtolt
              ,1
              ,100
              ,8506
              ,9
              ,0
              ,0
              ,0)
            RETURNING
              cdcooper, dtmvtolt, cdagenci, cdbccxlt,
              nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln, ROWID 
            INTO
              rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, 
              rw_craplot.cdbccxlt, rw_craplot.nrdolote, rw_craplot.tplotmov,
              rw_craplot.nrseqdig, rw_craplot.qtinfoln, rw_craplot.qtcompln, rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
        END;
      ELSE
        CLOSE cr_craplot;
      END IF;               

    -- Trazer todas as poupan�as programadas
      OPEN cr_craprpp(pr_cdcooper,pr_cdagenci);
      LOOP
        FETCH cr_craprpp BULK COLLECT INTO rw_rpp LIMIT 5000;
        EXIT WHEN rw_rpp.COUNT = 0;            
        FOR idx IN rw_rpp.first..rw_rpp.last LOOP   
    
        BEGIN
          -- Zerar valores de vari�veis
          vr_cdcritic := 0;
          vr_vlsdextr := 0;
          vr_vlslfmes := 0;

          -- Validar data do cursor com a data global da movimenta��o
            IF rw_rpp(idx).dtinirpp <= rw_dat.dtmvtolt THEN
            -- Validar data inicial do per�odo do cursor com a data global da movimenta��o
              IF (extract(month from rw_rpp(idx).dtiniper) = extract(month from rw_dat.dtmvtolt)) OR (rw_rpp(idx).dtiniper<=rw_dat.dtmvtolt) THEN
              -- C�lculo da aplica��o
                vr_rpp_vlsdrdpp :=0;
                vr_cdcritic := null;
                vr_dscritic := null;

                pc_processa_aplicacao(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => rw_rpp(idx).nrdconta
                                           ,pr_nrctrrpp => rw_rpp(idx).nrctrrpp
                                      ,pr_idxrpp => idx
                                           ,pr_vlsdapprpp => vr_rpp_vlsdrdpp);

              -- Verificar se ocorreram erros no c�lculo de poupan�a
              IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
                IF vr_cdcritic >0 AND vr_dscritic IS NOT NULL THEN
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                END IF;
                vr_dscritic := 'Rowid RPP '||rw_rpp(idx).rowid||' --> '||vr_dscritic;
                  RAISE vr_exc_saida;
              END IF;

              -- Dados para o resumo
              IF vr_rpp_vlsdrdpp > 0 THEN
                -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
                vr_res_qtrppati := vr_res_qtrppati + 1;
                vr_res_vlrppati := vr_res_vlrppati + vr_rpp_vlsdrdpp;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                  vr_tab_total(rw_rpp(idx).inpessoa).qtrppati := vr_tab_total(rw_rpp(idx).inpessoa).qtrppati + 1;
                  vr_tab_total(rw_rpp(idx).inpessoa).vlrppati := vr_tab_total(rw_rpp(idx).inpessoa).vlrppati + vr_rpp_vlsdrdpp;
                vr_vlsdextr := vr_rpp_vlsdrdpp;
                vr_vlslfmes := vr_rpp_vlsdrdpp;

                -- Valida flag de execu��o
                  IF rw_rpp(idx).flgctain = 1 THEN
                  vr_res_qtrppati_n := vr_res_qtrppati_n + 1;
                  vr_res_vlrppati_n := vr_res_vlrppati_n + vr_rpp_vlsdrdpp;
                ELSE
                  vr_res_qtrppati_a := vr_res_qtrppati_a + 1;
                  vr_res_vlrppati_a := vr_res_vlrppati_a + vr_rpp_vlsdrdpp;
                END IF;
                
                -- Guarda as informacoes de poup ativas por agencia. Dados para Contabilidade
                  IF rw_rpp(idx).inpessoa = 1 THEN
                   -- Verifica se existe valor para agencia corrente de pessoa fisica
                     IF vr_tab_vlrppage_fis.EXISTS(rw_rpp(idx).cdagenci) THEN
                      -- Soma os valores por agencia de pessoa fisica
                        vr_tab_vlrppage_fis(rw_rpp(idx).cdagenci) := vr_tab_vlrppage_fis(rw_rpp(idx).cdagenci) + vr_rpp_vlsdrdpp;
                   ELSE
                      -- Inicializa o array com o valor inicial de pessoa fisica
                        vr_tab_vlrppage_fis(rw_rpp(idx).cdagenci) := vr_rpp_vlsdrdpp;
                   END IF;
                   -- Gravando as informacoe para gerar o valor total de poup ativas de pessoa fisica
                   vr_tot_rppagefis := vr_tot_rppagefis + vr_rpp_vlsdrdpp;
                ELSE
                   -- Verifica se existe valor para agencia corrente de pessoa juridica
                     IF vr_tab_vlrppage_jur.EXISTS(rw_rpp(idx).cdagenci) THEN
                      -- Soma os valores por agencia de pessoa juridica
                        vr_tab_vlrppage_jur(rw_rpp(idx).cdagenci) := vr_tab_vlrppage_jur(rw_rpp(idx).cdagenci) + vr_rpp_vlsdrdpp;
                   ELSE
                      -- Inicializa o array com o valor inicial de pessoa juridica
                        vr_tab_vlrppage_jur(rw_rpp(idx).cdagenci) := vr_rpp_vlsdrdpp;
                   END IF;
                   -- Gravando as informacoe para gerar o valor total de poup ativas de pessoa juridica
                   vr_tot_rppagejur := vr_tot_rppagejur + vr_rpp_vlsdrdpp;
                END IF;

                  -- Escrever dados no XML do arquivo de dados somente quando n�o for uma execu��o paralela
                  IF pr_cdagenci = 0 THEN 
                    gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                                           ,pr_texto_completo => vr_text_02
                                           ,pr_texto_novo     => '<dados><nrdconta>' || to_char(rw_rpp(idx).nrdconta, 'FM999999G999G0') || '</nrdconta>'
                                                              || '<nrctrrpp>'|| to_char(rw_rpp(idx).nrctrrpp, 'FM999G999G999G990') || '</nrctrrpp>'
                                                              || '<vr_rpp_vlsdrdpp>' || to_char(vr_rpp_vlsdrdpp, 'FM999G999G990D00') || '</vr_rpp_vlsdrdpp>'
                                                              || '<dtcalcul>' || to_char(rw_rpp(idx).dtcalcul,'DD/MM/RRRR') || '</dtcalcul>'
                                                              || '<dtiniper>' || to_char(rw_rpp(idx).dtiniper,'DD/MM/RRRR') || '</dtiniper>'
                                                              || '<dtfimper>' || to_char(rw_rpp(idx).dtfimper,'DD/MM/RRRR') || '</dtfimper></dados>');
                  ELSE
                    -- Trabalharemos com grava��o na tabela tempor�ria, pois depois precisaremos das
                    -- informa��es ordenadas por Conta e Contrato 
                    BEGIN
                      -- Insere
                      insert into tbgen_batch_relatorio_wrk
                                 (cdcooper
                                 ,cdprograma
                                 ,dsrelatorio
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,nrdconta
                                 ,nrctremp
                                 ,vldpagto
                                 ,dscritic)
                           values(pr_cdcooper
                                 ,vr_cdprogra
                                 ,'crrl737'
                                 ,rw_dat.dtmvtolt
                                 ,pr_cdagenci
                                 ,rw_rpp(idx).nrdconta
                                 ,rw_rpp(idx).nrctrrpp
                                 ,vr_rpp_vlsdrdpp
                                 ,to_char(rw_rpp(idx).dtcalcul,'DD/MM/RRRR')||';'
                                 ||to_char(rw_rpp(idx).dtiniper,'DD/MM/RRRR')||';'
                                 ||to_char(rw_rpp(idx).dtfimper,'DD/MM/RRRR')||';');
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[CRRL737] Conta '||rw_rpp(idx).nrdconta||' Aplicacao '||rw_rpp(idx).nrctrrpp||' --> ' || SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                  END IF; --pr_cdagenci = 0
              END IF;
            END IF;
          END IF;

          -- Validar valores de datas
            IF to_char(rw_rpp(idx).dtinirpp, 'MMRRRR') = to_char(rw_dat.dtmvtolt, 'MMRRRR') AND
                rw_rpp(idx).cdsitrpp IN (1,2) THEN
            -- Zerar vari�veis
            -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
            vr_res_qtrppnov := vr_res_qtrppnov + 1;
            -- Atribuir valores para Pl-Table separando por PF e PJ
              vr_tab_total(rw_rpp(idx).inpessoa).qtrppnov := vr_tab_total(rw_rpp(idx).inpessoa).qtrppnov + 1;
            -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
              vr_res_vlrppnov := vr_res_vlrppnov + rw_rpp(idx).vlprerpp;
            -- Atribuir valores para Pl-Table separando por PF e PJ
              vr_tab_total(rw_rpp(idx).inpessoa).vlrppnov := vr_tab_total(rw_rpp(idx).inpessoa).vlrppnov + rw_rpp(idx).vlprerpp;
              vr_vlsdextr := rw_rpp(idx).vlprerpp;
            -- Valida flag de execu��o
              IF rw_rpp(idx).flgctain = 1 THEN
              vr_res_qtrppnov_n := vr_res_qtrppnov_n + 1;
                vr_res_vlrppnov_n := vr_res_vlrppnov_n + rw_rpp(idx).vlprerpp;
            ELSE
              vr_res_qtrppnov_a := vr_res_qtrppnov_a + 1;
                vr_res_vlrppnov_a := vr_res_vlrppnov_a + rw_rpp(idx).vlprerpp;
            END IF;
          END IF;

          -- Validar dados para realizar INSERT
            IF rw_rpp(idx).cdsitrpp = 1 OR rw_rpp(idx).cdsitrpp = 2 THEN
            BEGIN
              INSERT INTO craprej (dtmvtolt, vllanmto, cdpesqbb, cdcooper)
                  VALUES(rw_rpp(idx).dtdebito, rw_rpp(idx).vlprerpp, vr_cdprogra, pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar CRAPRPP IDX '||idx||'--> ' || SQLERRM;
                  RAISE vr_exc_saida;
            END;
          END IF;

          -- Realizar update no registro corrente do cursor
          BEGIN
            UPDATE craprpp cr
            SET cr.vlsdextr = vr_vlsdextr
                    ,cr.dtslfmes = rw_dat.dtmvtolt
               ,cr.vlslfmes = vr_vlslfmes
               WHERE cr.rowid = rw_rpp(idx).rowid
             RETURNING cr.vlsdextr, cr.dtslfmes, cr.vlslfmes
                    INTO rw_rpp(idx).vlsdextr, rw_rpp(idx).dtslfmes, rw_rpp(idx).vlslfmes;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar CRAPRPP Rowid '||rw_rpp(idx).rowid||'--> ' || SQLERRM;
                RAISE vr_exc_saida;
          END;

          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
            vr_res_bsabcpmf := vr_res_bsabcpmf + rw_rpp(idx).vlabcpmf;
          -- Atribuir valores para Pl-Table separando por PF e PJ
            vr_tab_total(rw_rpp(idx).inpessoa).bsabcpmf := vr_tab_total(rw_rpp(idx).inpessoa).bsabcpmf + rw_rpp(idx).vlabcpmf;

          -- Verificar flag para c�lcular CPMF
            IF rw_rpp(idx).flgctain = 1 THEN
              vr_res_bsabcpmf_n := vr_res_bsabcpmf_n + rw_rpp(idx).vlabcpmf;
          ELSE
              vr_res_bsabcpmf_a := vr_res_bsabcpmf_a + rw_rpp(idx).vlabcpmf;
          END IF;

          -- Atribuir valor para a vari�vel
            vr_prazodia := rw_rpp(idx).dtvctopp - rw_dat.dtmvtolt;

          -- Atualiza valores de acordo com o prazo estipulado
          CASE
            WHEN vr_prazodia <= 90 THEN
                vr_tab_dados(1).qtdaplic := vr_tab_dados(1).qtdaplic + 1;
                vr_tab_dados(1).valorapl := vr_tab_dados(1).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 90 AND vr_prazodia <= 180 THEN
                vr_tab_dados(2).qtdaplic := vr_tab_dados(2).qtdaplic + 1;
                vr_tab_dados(2).valorapl := vr_tab_dados(2).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 180 AND vr_prazodia <= 270 THEN
                vr_tab_dados(3).qtdaplic := vr_tab_dados(3).qtdaplic + 1;
                vr_tab_dados(3).valorapl := vr_tab_dados(3).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 270 AND vr_prazodia <= 360 THEN
                vr_tab_dados(4).qtdaplic := vr_tab_dados(4).qtdaplic + 1;
                vr_tab_dados(4).valorapl := vr_tab_dados(4).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 360 AND vr_prazodia <= 720 THEN
                vr_tab_dados(5).qtdaplic := vr_tab_dados(5).qtdaplic + 1;
                vr_tab_dados(5).valorapl := vr_tab_dados(5).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 720 AND vr_prazodia <= 1080 THEN
                vr_tab_dados(6).qtdaplic := vr_tab_dados(6).qtdaplic + 1;
                vr_tab_dados(6).valorapl := vr_tab_dados(6).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 1080 AND vr_prazodia <= 1440 THEN
                vr_tab_dados(7).qtdaplic := vr_tab_dados(7).qtdaplic + 1;
                vr_tab_dados(7).valorapl := vr_tab_dados(7).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 1440 AND vr_prazodia <= 1800 THEN
                vr_tab_dados(8).qtdaplic := vr_tab_dados(8).qtdaplic + 1;
                vr_tab_dados(8).valorapl := vr_tab_dados(8).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 1800 AND vr_prazodia <= 2160 THEN
                vr_tab_dados(9).qtdaplic := vr_tab_dados(9).qtdaplic + 1;
                vr_tab_dados(9).valorapl := vr_tab_dados(9).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 2160 AND vr_prazodia <= 2520 THEN
                vr_tab_dados(10).qtdaplic := vr_tab_dados(10).qtdaplic + 1;
                vr_tab_dados(10).valorapl := vr_tab_dados(10).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 2520 AND vr_prazodia <= 2880 THEN
                vr_tab_dados(11).qtdaplic := vr_tab_dados(11).qtdaplic + 1;
                vr_tab_dados(11).valorapl := vr_tab_dados(11).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 2880 AND vr_prazodia <= 3240 THEN
                vr_tab_dados(12).qtdaplic := vr_tab_dados(12).qtdaplic + 1;
                vr_tab_dados(12).valorapl := vr_tab_dados(12).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 3240 AND vr_prazodia <= 3600 THEN
                vr_tab_dados(13).qtdaplic := vr_tab_dados(13).qtdaplic + 1;
                vr_tab_dados(13).valorapl := vr_tab_dados(13).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 3600 AND vr_prazodia <= 3960 THEN
                vr_tab_dados(14).qtdaplic := vr_tab_dados(14).qtdaplic + 1;
                vr_tab_dados(14).valorapl := vr_tab_dados(14).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 3960 AND vr_prazodia <= 4320 THEN
                vr_tab_dados(15).qtdaplic := vr_tab_dados(15).qtdaplic + 1;
                vr_tab_dados(15).valorapl := vr_tab_dados(15).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 4320 AND vr_prazodia <= 4680 THEN
                vr_tab_dados(16).qtdaplic := vr_tab_dados(16).qtdaplic + 1;
                vr_tab_dados(16).valorapl := vr_tab_dados(16).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 4680 AND vr_prazodia <= 5040 THEN
                vr_tab_dados(17).qtdaplic := vr_tab_dados(17).qtdaplic + 1;
                vr_tab_dados(17).valorapl := vr_tab_dados(17).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 5040 AND vr_prazodia <= 5400 THEN
                vr_tab_dados(18).qtdaplic := vr_tab_dados(18).qtdaplic + 1;
                vr_tab_dados(18).valorapl := vr_tab_dados(18).valorapl + rw_rpp(idx).vlslfmes;
            WHEN vr_prazodia > 5400 THEN
                vr_tab_dados(19).qtdaplic := vr_tab_dados(19).qtdaplic + 1;
                vr_tab_dados(19).valorapl := vr_tab_dados(19).valorapl + rw_rpp(idx).vlslfmes;
          END CASE;

          -- Valida se existe registro de conta BNDES para atualizar, sen�o insere
            IF vr_tab_cta_bndes.exists(lpad(rw_rpp(idx).nrdconta, 10, '0')) THEN
              vr_tab_cta_bndes(lpad(rw_rpp(idx).nrdconta, 10, '0')).vlaplica :=
                       vr_tab_cta_bndes(lpad(rw_rpp(idx).nrdconta, 10, '0')).vlaplica + rw_rpp(idx).vlslfmes;
          ELSE
              vr_tab_cta_bndes(lpad(rw_rpp(idx).nrdconta, 10, '0')).nrdconta := rw_rpp(idx).nrdconta;
              vr_tab_cta_bndes(lpad(rw_rpp(idx).nrdconta, 10, '0')).vlaplica := rw_rpp(idx).vlslfmes;
          END IF;

        EXCEPTION
            WHEN vr_exc_saida then
              CLOSE cr_craprpp;
              raise vr_exc_saida;
          WHEN OTHERS THEN
              CLOSE cr_craprpp;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao validar dados: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP; -- loop do bulk collect
      END LOOP; -- loop do fetch
      CLOSE cr_craprpp;
      
      -- Caso execu��o paralela -- Converter as informa��es das PLTABLES em tabela de Banco para commitar e ler depois
      IF pr_cdagenci > 0 THEN
        -- PRAZOS
        FOR vr_posicao IN 1..19 LOOP
          -- Inserir na tabela tempor�ria
          BEGIN
            insert into tbgen_batch_relatorio_wrk
                       (cdcooper
                       ,cdprograma
                       ,dsrelatorio
                       ,dtmvtolt
                       ,cdagenci
                       ,nrdconta
                       ,dschave
                       ,dscritic)
                 values(pr_cdcooper
                       ,vr_cdprogra
                       ,'prazos'
                       ,rw_dat.dtmvtolt
                       ,pr_cdagenci
                       ,vr_posicao
                       ,vr_posicao
                       -- Aproveitar dscritic para montar um registro gen�rico com o restante das informa��es
                       , to_char(vr_tab_dados(vr_posicao).valorapl,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_dados(vr_posicao).vlacumul,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_dados(vr_posicao).qtdaplic,'fm999g999g999g999g990')||';');
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[prazos]: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END LOOP;
        
        -- BNDES
        vr_idx_bndes := vr_tab_cta_bndes.first;
        LOOP
          EXIT WHEN vr_idx_bndes IS NULL;
          -- Verificar se o valor aplicado � maior que zero
          IF vr_tab_cta_bndes(vr_idx_bndes).vlaplica > 0 THEN
            -- Inserir na tabela tempor�ria
            BEGIN
              insert into tbgen_batch_relatorio_wrk
                         (cdcooper
                         ,cdprograma
                         ,dsrelatorio
                         ,dtmvtolt
                         ,cdagenci
                         ,nrdconta
                         ,dschave
                         ,vlacumul)
                   values(pr_cdcooper
                         ,vr_cdprogra
                         ,'bndes'
                         ,rw_dat.dtmvtolt
                         ,pr_cdagenci
                         ,vr_tab_cta_bndes(vr_idx_bndes).nrdconta
                         ,vr_idx_bndes
                         ,round(vr_tab_cta_bndes(vr_idx_bndes).vlaplica,8));
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[BNDES]: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
          vr_idx_bndes := vr_tab_cta_bndes.next(vr_idx_bndes);
        END LOOP;
        
        -- vr_tab_total
        FOR vr_posicao IN 1..2 LOOP
          -- Inserir na tabela tempor�ria
          BEGIN
            insert into tbgen_batch_relatorio_wrk
                       (cdcooper
                       ,cdprograma
                       ,dsrelatorio
                       ,dtmvtolt
                       ,cdagenci
                       ,dschave
                       ,dscritic)
                 values(pr_cdcooper
                       ,vr_cdprogra
                       ,'total'
                       ,rw_dat.dtmvtolt
                       ,pr_cdagenci
                       ,vr_posicao -- inpessoa
                       -- Aproveitar dscritic para montar um registro gen�rico com o restante das informa��es
                       , to_char(vr_tab_total(vr_posicao).qtrppati,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlrppati,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlrppmes,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlresmes,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).qtrppnov,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlrppnov,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlrenmes,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlprvmes,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlprvlan,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlajuprv,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlrtirrf,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).vlrtirab,'fm999g999g999g999g990d00')||';'
                       ||to_char(vr_tab_total(vr_posicao).bsabcpmf,'fm999g999g999g999g990d00')||';');
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[TOTAL]: ' || SQLERRM;
              RAISE vr_exc_saida;
        END;
      END LOOP;
        
        -- Acumuladores totais por agencia
        DECLARE
          vr_total_fis NUMBER(25,2);
          vr_total_jur NUMBER(25,2);
        BEGIN
          IF vr_tab_vlrppage_fis.exists(pr_cdagenci) THEN
            vr_total_fis := vr_tab_vlrppage_fis(pr_cdagenci);
          ELSE
            vr_total_fis := 0;
          END IF;
          IF vr_tab_vlrppage_jur.exists(pr_cdagenci) THEN
            vr_total_jur := vr_tab_vlrppage_jur(pr_cdagenci);
          ELSE
            vr_total_jur := 0;
          END IF;
          -- Insere
          insert into tbgen_batch_relatorio_wrk
                     (cdcooper
                     ,cdprograma
                     ,dsrelatorio
                     ,dtmvtolt
                     ,cdagenci
                     ,dschave
                     ,vldpagto
                     ,vltitulo
                     ,dscritic)
               values(pr_cdcooper
                     ,vr_cdprogra
                     ,'crrl737'
                     ,rw_dat.dtmvtolt
                     ,pr_cdagenci
                     ,pr_cdagenci
                     ,vr_total_fis
                     ,vr_total_jur
                     -- Aproveitar dscritic para montar um registro gen�rico com o restante das informa��es
                     , to_char(vr_res_qtrppati,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_vlrppati,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_qtrppati_n,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_vlrppati_n,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_qtrppati_a,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_vlrppati_a,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_tot_rppagejur,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_qtrppnov,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_vlrppnov,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_qtrppnov_n,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_vlrppnov_n,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_qtrppnov_a,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_vlrppnov_a,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_bsabcpmf,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_bsabcpmf_n,'fm999g999g999g999g999g999g990d00')||';'
                     ||to_char(vr_res_bsabcpmf_a,'fm999g999g999g999g999g999g990d00')||';');
    EXCEPTION
      WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir dados na tbgen_batch_relatorio_wrk[CRRL737]: ' || SQLERRM;
            RAISE vr_exc_saida;
    END;
      END IF; -- Execu��o paralela

      -- Grava data fim para o JOB na tabela de LOG 
      pc_log_programa(pr_dstiplog   => 'F'  
                     ,pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci           
                     ,pr_cdcooper   => pr_cdcooper
                     ,pr_tpexecucao => vr_tpexecucao -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_par
                     ,pr_flgsucesso => 1); 
      
    END IF; --Paralelismo
    
    -- Verificar se ocorreram cr�ticas
    IF vr_cdcritic > 0 THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Se for o programa principal ou sem paralelismo
    if nvl(pr_idparale,0) = 0 then
      
      -- Caso execu��o paralela
      IF vr_idparale > 0 THEN
              
        -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
        pc_log_programa(pr_dstiplog     => 'O'
                       ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                       ,pr_cdcooper     => pr_cdcooper
                       ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia => 4
                       ,pr_dsmensagem   => 'Inicio - Restaura��o valores das execu��es anteriores.'
                       ,pr_idprglog     => vr_idlog_ini_ger); 
        
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
        
        -- Restaurar as informa��es da tabela de Banco para para as PLTABLES 
        -- PRAZOS
        FOR rw_work IN cr_work_prazos(pr_cdcooper    => pr_cdcooper
                                     ,pr_cdprograma  => vr_cdprogra
                                     ,pr_dsrelatorio => 'prazos' 
                                     ,pr_dtmvtolt    => rw_dat.dtmvtolt) LOOP
          -- Cada registro � um prazo acumulado
          vr_tab_dados(rw_work.dschave).valorapl := rw_work.valorapl;
          vr_tab_dados(rw_work.dschave).vlacumul := rw_work.vlacumul;
          vr_tab_dados(rw_work.dschave).qtdaplic := rw_work.qtdaplic;
        END LOOP;
        -- BNDES
        FOR rw_work IN cr_work_bndes(pr_cdcooper    => pr_cdcooper
                                    ,pr_cdprograma  => vr_cdprogra
                                    ,pr_dsrelatorio => 'bndes' 
                                    ,pr_dtmvtolt    => rw_dat.dtmvtolt) LOOP
          -- Cada registro � um prazo acumulado
          vr_tab_cta_bndes(rw_work.dschave).nrdconta := rw_work.nrdconta;
          vr_tab_cta_bndes(rw_work.dschave).vlaplica := rw_work.vlaplica;
        END LOOP;
        -- VR_TAB_TOTAL
        FOR rw_work IN cr_work_total(pr_cdcooper    => pr_cdcooper
                                    ,pr_cdprograma  => vr_cdprogra
                                    ,pr_dsrelatorio => 'total' 
                                    ,pr_dtmvtolt    => rw_dat.dtmvtolt) LOOP
          -- Cada registro � um prazo acumulado
          vr_tab_total(rw_work.inpessoa).qtrppati := rw_work.qtrppati;
          vr_tab_total(rw_work.inpessoa).vlrppati := rw_work.vlrppati;
          vr_tab_total(rw_work.inpessoa).vlrppmes := rw_work.vlrppmes;
          vr_tab_total(rw_work.inpessoa).vlresmes := rw_work.vlresmes;
          vr_tab_total(rw_work.inpessoa).qtrppnov := rw_work.qtrppnov;
          vr_tab_total(rw_work.inpessoa).vlrppnov := rw_work.vlrppnov;
          vr_tab_total(rw_work.inpessoa).vlrenmes := rw_work.vlrenmes;
          vr_tab_total(rw_work.inpessoa).vlprvmes := rw_work.vlprvmes;
          vr_tab_total(rw_work.inpessoa).vlprvlan := rw_work.vlprvlan;
          vr_tab_total(rw_work.inpessoa).vlajuprv := rw_work.vlajuprv;
          vr_tab_total(rw_work.inpessoa).vlrtirrf := rw_work.vlrtirrf;
          vr_tab_total(rw_work.inpessoa).vlrtirab := rw_work.vlrtirab;
          vr_tab_total(rw_work.inpessoa).bsabcpmf := rw_work.bsabcpmf;
        END LOOP;
        -- Acumuladores por Ag�ncia
        vr_tot_rppagefis := 0;
        vr_tot_rppagejur := 0;
        FOR rw_work IN cr_work_crrl737_agenci(pr_cdcooper    => pr_cdcooper
                                             ,pr_cdprograma  => vr_cdprogra
                                             ,pr_dsrelatorio => 'crrl737' 
                                             ,pr_dtmvtolt    => rw_dat.dtmvtolt) LOOP
          -- Recriar as tabs
          vr_tab_vlrppage_fis(rw_work.cdagenci) := rw_work.vr_tab_vlrppage_fis;
          vr_tab_vlrppage_jur(rw_work.cdagenci) := rw_work.vr_tab_vlrppage_jur;
          -- Acumular totais
          vr_tot_rppagefis := vr_tot_rppagefis + nvl(rw_work.vr_tab_vlrppage_fis,0);
          vr_tot_rppagejur := vr_tot_rppagejur + nvl(rw_work.vr_tab_vlrppage_jur,0); 
        END LOOP;
                
        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_clob_02, TRUE);
        dbms_lob.open(vr_clob_02, dbms_lob.lob_readwrite);
        
        -- Inicilizar as informa��es do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                               ,pr_texto_completo => vr_text_02
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><base>');
        -- XMLs por agencia
        FOR rw_work IN cr_work_crrl737_poup(pr_cdcooper    => pr_cdcooper
                                           ,pr_cdprograma  => vr_cdprogra
                                           ,pr_dsrelatorio => 'crrl737' 
                                           ,pr_dtmvtolt    => rw_dat.dtmvtolt) LOOP
          -- Recriar o CLOB do relat�rio
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                                 ,pr_texto_completo => vr_text_02
                                 ,pr_texto_novo     => '<dados><nrdconta>' || to_char(rw_work.nrdconta, 'FM999999G999G0') || '</nrdconta>'
                                                    || '<nrctrrpp>'|| to_char(rw_work.nrctremp, 'FM999G999G999G990') || '</nrctrrpp>'
                                                    || '<vr_rpp_vlsdrdpp>' || to_char(rw_work.vldpagto, 'FM999G999G990D00') || '</vr_rpp_vlsdrdpp>'
                                                    || '<dtcalcul>' || rw_work.dtcalcul || '</dtcalcul>'
                                                    || '<dtiniper>' || rw_work.dtiniper || '</dtiniper>'
                                                    || '<dtfimper>' || rw_work.dtfimper || '</dtfimper></dados>');
        END LOOP;
        
        -- Acumuladores total
        FOR rw_work IN cr_work_crrl737(pr_cdcooper    => pr_cdcooper
                                      ,pr_cdprograma  => vr_cdprogra
                                      ,pr_dsrelatorio => 'crrl737' 
                                      ,pr_dtmvtolt    => rw_dat.dtmvtolt) LOOP
          -- Recriar as variaveis
          vr_res_qtrppati := rw_work.vr_res_qtrppati;
          vr_res_vlrppati := rw_work.vr_res_vlrppati;
          vr_res_qtrppati_n := rw_work.vr_res_qtrppati_n;
          vr_res_vlrppati_n := rw_work.vr_res_vlrppati_n;
          vr_res_qtrppati_a := rw_work.vr_res_qtrppati_a;
          vr_res_vlrppati_a := rw_work.vr_res_vlrppati_a;
          vr_tot_rppagejur := rw_work.vr_tot_rppagejur;
          vr_res_qtrppnov := rw_work.vr_res_qtrppnov;
          vr_res_vlrppnov := rw_work.vr_res_vlrppnov;
          vr_res_qtrppnov_n := rw_work.vr_res_qtrppnov_n;
          vr_res_vlrppnov_n := rw_work.vr_res_vlrppnov_n;
          vr_res_qtrppnov_a := rw_work.vr_res_qtrppnov_a;
          vr_res_vlrppnov_a := rw_work.vr_res_vlrppnov_a;
          vr_res_bsabcpmf := rw_work.vr_res_bsabcpmf;
          vr_res_bsabcpmf_n := rw_work.vr_res_bsabcpmf_n;
          vr_res_bsabcpmf_a := rw_work.vr_res_bsabcpmf_a;
        END LOOP;
      
        -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
        pc_log_programa(PR_DSTIPLOG           => 'O'
                       ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                       ,pr_cdcooper           => pr_cdcooper
                       ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                       ,pr_tpocorrencia       => 4
                       ,pr_dsmensagem         => 'Fim - Restaura��o valores das execu��es anteriores.'
                       ,PR_IDPRGLOG           => vr_idlog_ini_ger);         
      END IF;  
    
      -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
      pc_log_programa(pr_dstiplog     => 'O'
                     ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                     ,pr_cdcooper     => pr_cdcooper
                     ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia => 4
                     ,pr_dsmensagem   => 'Inicio - Alimenta��o Tabelas Gerenciais.'
                     ,pr_idprglog     => vr_idlog_ini_ger); 

    -- Inserir informa��es na CRAPPRB
    -- Iterar sob os registros gerados
    FOR vr_posicao IN 1..19 LOOP
      -- Validar o valor de aplica��o
        IF vr_tab_dados(vr_posicao).valorapl > 0 THEN
        pc_cria_crapprb (pr_cdcooper     => 3
                         ,pr_prazodia  => vr_posicao
                          ,pr_vlretorn  => vr_tab_dados(vr_posicao).valorapl
                          ,pr_nrctactl  => rw_cop.nrctactl
                        ,pr_desc_erro => vr_dscritic);
      END IF;
    END LOOP;

    -- Percorrer PL Table de contas do BNDES
    vr_idx_bndes := vr_tab_cta_bndes.first;

    LOOP
      EXIT WHEN vr_idx_bndes IS NULL;
      -- Verificar se o valor aplicado � maior que zero
      IF vr_tab_cta_bndes(vr_idx_bndes).vlaplica > 0 THEN
    BEGIN
            pc_cria_crapprb (pr_cdcooper     => pr_cdcooper
                             ,pr_prazodia  => 0
                              ,pr_vlretorn  => vr_tab_cta_bndes(vr_idx_bndes).vlaplica
                              ,pr_nrctactl  => vr_tab_cta_bndes(vr_idx_bndes).nrdconta
                            ,pr_desc_erro => vr_dscritic);
        IF (vr_dscritic != '') THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar CRAPRPP Conta '||vr_tab_cta_bndes(vr_idx_bndes).nrdconta||'--> ' || vr_dscritic;
                  RAISE vr_exc_saida;
        END IF;    
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar CRAPRPP Conta '||vr_tab_cta_bndes(vr_idx_bndes).nrdconta||'--> ' || SQLERRM;
                  RAISE vr_exc_saida;
        END;
      END IF;

      vr_idx_bndes := vr_tab_cta_bndes.next(vr_idx_bndes);
    END LOOP;

    -- Verifica se foram encontradas cr�ticas no processo
    IF vr_cdcritic > 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Inicio - Atualiza tabela craptrd.',
                      PR_IDPRGLOG           => vr_idlog_ini_ger); 
                      
      -- Cursor com registros a serem atualizados na tabela craptrd
      BEGIN
        open cr_work_trd(pr_cdcooper    => pr_cdcooper
                        ,pr_cdprograma  => vr_cdprogra
                        ,pr_dsrelatorio => 'CRAPTRD' 
                        ,pr_dtmvtolt    => rw_dat.dtmvtolt); 
        loop 
          --fetch no cursor carregando 50 mil registros
          fetch cr_work_trd bulk collect into vr_tab_work_trd limit 50000; 
            --Sai ap�s processar os registros.
            exit when vr_tab_work_trd.count = 0; 
            --Realiza update dos registros utilizando forall
            forall idx in 1 .. vr_tab_work_trd.count 
              update craptrd b 
                 set b.incalcul = 1 
               where rowid = vr_tab_work_trd(idx).rowid_trd; 
        end loop;
        close cr_work_trd; 
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_work_trd%ISOPEN THEN
            CLOSE cr_work_trd;
    END IF;
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPRPP: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - Atualiza tabela craptrd.',
                      PR_IDPRGLOG           => vr_idlog_ini_ger); 
      
      -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craplot
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Inicio - Atualiza tabela craplot.',
                      PR_IDPRGLOG           => vr_idlog_ini_ger); 

      -- Cursor com registros a serem atualizados na tabela craplot    
      open cr_work_lot(pr_cdcooper    => pr_cdcooper
                      ,pr_cdprograma  => vr_cdprogra
                      ,pr_dsrelatorio => 'CRAPLOT' 
                      ,pr_dtmvtolt    => rw_dat.dtmvtolt);

      -- Realiza fetch no cursor
      fetch cr_work_lot into vr_tab_work_lot;
      -- Verifica se existem registros
      if cr_work_lot%found then
        begin
          update craplot
             set craplot.vlinfocr = vr_tab_work_lot.vlinfocr,
                 craplot.vlcompcr = vr_tab_work_lot.vlcompcr,
                 craplot.qtinfoln = vr_tab_work_lot.qtinfoln,
                 craplot.qtcompln = vr_tab_work_lot.qtcompln,
                 craplot.vlinfodb = vr_tab_work_lot.vlinfodb,
                 craplot.vlcompdb = vr_tab_work_lot.vlcompdb,
                 craplot.nrseqdig = CRAPLOT_8383_SEQ.NEXTVAL
           where craplot.dtmvtolt = rw_dat.dtmvtolt
             and craplot.cdagenci = 1
             and craplot.cdbccxlt = 100
             and craplot.nrdolote = 8383
             and craplot.tplotmov = 14
             and craplot.cdcooper = pr_cdcooper;             
        exception
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar tabela craplot: '||sqlerrm;
            raise vr_exc_saida;            
        END;
      end if;    
      --Fecha cursor
      close cr_work_lot;
    
      -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - Atualiza tabela craplot.',
                      PR_IDPRGLOG           => vr_idlog_ini_ger); 
      
      -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
      pc_log_programa(pr_dstiplog     => 'O'
                     ,pr_cdprograma   => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                     ,pr_cdcooper     => pr_cdcooper
                     ,pr_tpexecucao   => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia => 4
                     ,pr_dsmensagem   => 'Inicio - Busca Informa��es e Gera��o Relat�rios e Arquivo Cont�bil'
                     ,pr_idprglog     => vr_idlog_ini_ger); 
      
      -- Definir dias do m�s
      vr_dtinimes := add_months(last_day(rw_dat.dtmvtolt), -1);
      vr_dtfimmes := to_date('01' || to_char(add_months(rw_dat.dtmvtolt, 1), 'MM/RRRR'), 'DD/MM/RRRR');

      -- Formatar m�s de refer�ncia
      vr_rel_dsmesref := gene0001.vr_vet_nmmesano(to_char(rw_dat.dtmvtolt, 'MM')) ||'/'||to_char(rw_dat.dtmvtolt, 'RRRR');
      
    -- Leitura dos lan�amentos do m�s
      OPEN cr_craplac(pr_cdcooper => pr_cdcooper
                                  ,pr_dtinimes => vr_dtinimes 
                     ,pr_dtfimmes => vr_dtfimmes);
      
      LOOP
        FETCH cr_craplac BULK COLLECT INTO rw_lac LIMIT 5000;
        EXIT WHEN rw_lac.COUNT = 0;            
        FOR idx IN rw_lac.first..rw_lac.last LOOP   
      -- Valida se ser� computado aplica��es novas ou antigas
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

      -- Valida hist�rico para fazer sumariza��o
      CASE
            WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsraap THEN
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
              vr_res_vlrppmes := vr_res_vlrppmes + rw_lac(idx).vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
              vr_tab_total(rw_lac(idx).inpessoa).vlrppmes := vr_tab_total(rw_lac(idx).inpessoa).vlrppmes + rw_lac(idx).vllanmto;
            WHEN rw_lac(idx).cdhistor =  vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsrgap THEN
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
              vr_res_vlresmes := vr_res_vlresmes + rw_lac(idx).vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
              vr_tab_total(rw_lac(idx).inpessoa).vlresmes := vr_tab_total(rw_lac(idx).inpessoa).vlresmes + rw_lac(idx).vllanmto;
            WHEN rw_lac(idx).cdhistor = 151 THEN
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
              vr_res_vlrenmes := vr_res_vlrenmes + rw_lac(idx).vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
              vr_tab_total(rw_lac(idx).inpessoa).vlrenmes := vr_tab_total(rw_lac(idx).inpessoa).vlrenmes + rw_lac(idx).vllanmto;
            WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsprap THEN
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
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
            -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
                vr_res_vlprvlan := vr_res_vlprvlan + rw_lac(idx).vllanmto;
            -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(rw_lac(idx).inpessoa).vlprvlan := vr_tab_total(rw_lac(idx).inpessoa).vlprvlan + rw_lac(idx).vllanmto;
            WHEN rw_lac(idx).cdhistor IN (157,154) THEN
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
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
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
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
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
              vr_res_vlrtirrf := vr_res_vlrtirrf + rw_lac(idx).vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
              vr_tab_total(rw_lac(idx).inpessoa).vlrtirrf := vr_tab_total(rw_lac(idx).inpessoa).vlrtirrf + rw_lac(idx).vllanmto;
              WHEN rw_lac(idx).cdhistor = vr_tab_crapcpc(rw_lac(idx).cdprodut).cdhsrdap THEN
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
          -- Atribuir valores para as vari�veis agrupando por tipo de pessoa
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

    -- Inicilizar as informa��es do XML
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

    -- Acumular valores para totaliza��o
    FOR idx IN 1..vr_tab_dados.count() LOOP
      -- Controlar fluxo dos registros (primeiro registro)
      IF idx = 1 THEN
          vr_tab_dados(idx).vlacumul := vr_tab_dados(idx).valorapl;
      ELSE
          vr_tab_dados(idx).vlacumul := vr_tab_dados(idx - 1).vlacumul + vr_tab_dados(idx).valorapl;
      END IF;

      -- Para totalizar demais registros
      IF idx = 19 THEN
          vr_tot_vlacumul := vr_tab_dados(idx).vlacumul;
      END IF;
    END LOOP;

    -- Escrever dados de sumariza��o no XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '<prazoMedio vr_rel_dsmesref= "'||vr_rel_dsmesref||'">');

    FOR idx IN 1..vr_tab_dados.count() LOOP
      IF idx <= 4 THEN
        vr_valortexto := vr_valortexto + 90;
        vr_texto := 'ATE ' || vr_valortexto;
      ELSE
        IF idx = 19 THEN
          vr_texto := 'MAIS DE ' || vr_valortexto;
        ELSE
          vr_valortexto := vr_valortexto + 360;
          vr_texto := 'ATE ' || vr_valortexto;
        END IF;
      END IF;
        -- Enviar ao XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                               ,pr_texto_completo => vr_text_01
                               ,pr_texto_novo     => '<prazo>'
                                                  || '<vr_texto>' || vr_texto || '</vr_texto>'
                                                  || '<vr_valorapl>' || to_char(nvl(vr_tab_dados(idx).valorapl, 0), 'FM999G999G990D00') ||'</vr_valorapl>'
                                                  || '<vr_vlacumul>' || to_char(nvl(vr_tab_dados(idx).vlacumul, 0), 'FM999G999G990D00') ||'</vr_vlacumul>'
                                                  || '<vr_qtdaplic>' || to_char(nvl(vr_tab_dados(idx).qtdaplic, 0), 'FM999G999G990') || '</vr_qtdaplic>'
                                                  || '</prazo>');
      END LOOP;
      
      -- Enviar ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '</prazoMedio>'
                                                || '<prazoMedioTotal><total>' || to_char(nvl(vr_tot_vlacumul, 0), 'FM999G999G990D00') || '</total></prazoMedioTotal>'
                                                || '<debitos>');

    -- Consultar dados de rejeitados
      FOR rw_rej IN cr_craprej(pr_cdcooper, vr_cdprogra) LOOP
      -- Atribuir contador
      vr_count := vr_count + 1;

      -- Atribuir valores para as vari�veis
        vr_rel_dtdebito := rw_rej.dtmvtolt;
      vr_rel_qtdebito := vr_rel_qtdebito + 1;
        vr_rel_vldebito := vr_rel_vldebito + rw_rej.vllanmto;
      vr_tot_qtdebito := vr_tot_qtdebito + 1;
        vr_tot_vldebito := vr_tot_vldebito + rw_rej.vllanmto;

      -- Identifica se a data � diferente da anterior
        IF ( rw_rej.dtmvtolt <> nvl(vr_dtctr, rw_rej.dtmvtolt) ) THEN

          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                                 ,pr_texto_completo => vr_text_01
                                 ,pr_texto_novo     => '<debito><vr_rel_dtdebito>' || to_char(vr_dtctr, 'DD/MM/RRRR') ||'</vr_rel_dtdebito>'
                                                    || '<vr_rel_qtdebito>' || to_char(nvl(vr_rel_qtdebito - 1, 0), 'FM999G999G990') || '</vr_rel_qtdebito>'
                                                    || '<vr_rel_vldebito>' || to_char(nvl(vr_rel_vldebito - rw_rej.vllanmto, 0), 'FM999G999G990D00') ||'</vr_rel_vldebito></debito>');

        -- reiniciar valores de vari�veis
          vr_rel_dtdebito := rw_rej.dtmvtolt;
        vr_rel_qtdebito := 1;
          vr_rel_vldebito := rw_rej.vllanmto;
      END IF;

      -- SE FOR O ULTIMO imprimir valores correntes
        IF ( vr_count = rw_rej.contagem ) THEN
          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                                 ,pr_texto_completo => vr_text_01
                                 ,pr_texto_novo     => '<debito><vr_rel_dtdebito>' || to_char(vr_rel_dtdebito, 'DD/MM/RRRR') || '</vr_rel_dtdebito>'
                                                    || '<vr_rel_qtdebito>' || to_char(nvl(vr_rel_qtdebito , 0), 'FM999G999G990') || '</vr_rel_qtdebito>'
                                                    || '<vr_rel_vldebito>' || to_char(nvl(vr_rel_vldebito, 0), 'FM999G999G990D00') || '</vr_rel_vldebito></debito>');
      END IF;
      -- Atribui o valor da data em execu��o
        vr_dtctr := rw_rej.dtmvtolt;

      -- Deletar dados de rejeitados
        DELETE craprej ce WHERE ce.rowid = rw_rej.rowid;
    END LOOP;

    --Senao existir registros apenas envia a tag para montar rel no ireport
    IF vr_count = 0 then
        gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                               ,pr_texto_completo => vr_text_01
                               ,pr_texto_novo     => '<debito></debito>');
    END IF;
    
    -----------------------------------------------
    -- Inicio de geracao de arquivo AAMMDD_APPPROG.txt
    -----------------------------------------------    

    -- Arquivo gerado somente no processo mensal
      IF TRUNC(rw_dat.dtmvtopr,'MM') <> TRUNC(rw_dat.dtmvtolt,'MM') THEN
      
       -- Busca o caminho padrao do arquivo no unix + /integra
       vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'contab');

       -- Determinar o nome do arquivo baseado no ano, mes e dia da data movimento
         vr_nmarqtxt:= TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_APPPROG.txt'; 

         -- Busca o diret�rio para contabilidade
         vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => 0
                                               ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
         
         -- Incializar CLOB do arquivo txt
         dbms_lob.createtemporary(vr_clob_arq, TRUE, dbms_lob.CALL);
         dbms_lob.open(vr_clob_arq, dbms_lob.lob_readwrite);
       
       -- Se o valor total � maior que zero
       IF nvl(vr_tot_rppagefis,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA FISICA ***/
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                           --> Conta Origem
                        gene0002.fn_mask(4266, pr_dsforma => '9999')||','||                                           --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_rppagefis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"SALDO TOTAL DE TITULOS COM SALDO APLICA�AO PROGRAMADA - COOPERADOS PESSOA FISICA"';         --> Descricao

           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
             
         -- Verifica se existe valores       
           IF vr_tab_vlrppage_fis.COUNT > 0 THEN
               
           -- imprimir as informa��es para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             
              -- Gravas as informacoes de valores por agencia
                FOR vr_idx_agencia IN vr_tab_vlrppage_fis.FIRST()..vr_tab_vlrppage_fis.LAST() LOOP
                  -- Verifica se existe a informacao
                    IF vr_tab_vlrppage_fis.EXISTS(vr_idx_agencia) THEN
                    -- Se valor � maior que zero
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
                          TO_CHAR(rw_dat.dtmvtopr,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtopr,'DDMMYY')||','||                                               --> Data DDMMAA
                        gene0002.fn_mask(4266, pr_dsforma => '9999')||','||                                                     --> Conta Destino
                        gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                                     --> Conta Origem
                        TRIM(TO_CHAR(vr_tot_rppagefis,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                        --> Fixo
                        '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS COM SALDO APLICA�AO PROGRAMADA - COOPERADOS PESSOA FISICA"';  --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
             
         -- Verifica se existe valores       
           IF vr_tab_vlrppage_fis.COUNT > 0 THEN               
           -- imprimir as informa��es para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
               FOR vr_idx_agencia IN vr_tab_vlrppage_fis.FIRST()..vr_tab_vlrppage_fis.LAST() LOOP
               -- Verifica se existe a informacao
                 IF vr_tab_vlrppage_fis.EXISTS(vr_idx_agencia) THEN
                 -- Se valor � maior que zero
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
       
       -- Se o valor total � maior que zero
       IF nvl(vr_tot_rppagejur,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA JURIDICA ***/       
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                          gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                         --> Conta Origem
                          gene0002.fn_mask(4267, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_rppagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                          '"SALDO TOTAL DE TITULOS COM SALDO APLICA�AO PROGRAMADA - COOPERADOS PESSOA JURIDICA"';     --> Descricao

           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
             
         -- Verifica se existe valores       
           IF vr_tab_vlrppage_jur.COUNT > 0 THEN   
           -- imprimir as informa��es para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
               FOR vr_idx_agencia IN vr_tab_vlrppage_jur.FIRST()..vr_tab_vlrppage_jur.LAST() LOOP
               -- Verifica se existe a informacao
                 IF vr_tab_vlrppage_jur.EXISTS(vr_idx_agencia) THEN       
                 -- Se o valor � maior que zero
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
                          TO_CHAR(rw_dat.dtmvtopr,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtopr,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(4267, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        gene0002.fn_mask(4268, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        TRIM(TO_CHAR(vr_tot_rppagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS COM SALDO APLICA�AO PROGRAMADA - COOPERADOS PESSOA JURIDICA"';         --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
         
         -- Verifica se existe valores       
           IF vr_tab_vlrppage_jur.COUNT > 0 THEN               
           -- imprimir as informa��es para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
               FOR vr_idx_agencia IN vr_tab_vlrppage_jur.FIRST()..vr_tab_vlrppage_jur.LAST() LOOP
               -- Verifica se existe a informacao
                 IF vr_tab_vlrppage_jur.EXISTS(vr_idx_agencia) THEN
                 -- Se o valor � maior que zero
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
       
       -- Se o valor total � maior que zero
       IF nvl(vr_tot_vlrprvfis,0) > 0 THEN
         
         /*** Montando as informacoes de PESSOA FISICA ***/
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8066, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrprvfis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"PROVISAO DO MES - APLICA�AO PROGRAMADA COOPERADOS PESSOA FISICA"';                        --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
         
         -- Verifica se existe valores       
         IF vr_tot_vlrprvmes_fis.COUNT > 0 THEN
           -- imprimir as informa��es para cada conta, ou seja, duplicado
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
       
       -- Se o valro total � maior que zero
       IF nvl(vr_tot_vlrprvjur,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA JURIDICA ***/       
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8067, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrprvjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"PROVISAO DO MES - APLICA�AO PROGRAMADA COOPERADOS PESSOA JURIDICA"';                       --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));             
         -- Verifica se existe valores       
         IF vr_tot_vlrprvmes_jur.COUNT > 0 THEN   
           -- imprimir as informa��es para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tot_vlrprvmes_jur.FIRST()..vr_tot_vlrprvmes_jur.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_tot_vlrprvmes_jur.EXISTS(vr_idx_agencia) THEN       
                 -- Se o valor � maior que zero
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
       
       --Hist�rico 154
       -- Se o valor total � maior que zero
       IF nvl(vr_tot_vlrajusprv_fis,0) > 0 THEN
         
         /*** Montando as informacoes de PESSOA FISICA ***/
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8066, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrajusprv_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"AJUSTE PROVISAO APLICA��O PROGRAMADA � PESSOA FISICA"';                         --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
         
         -- Verifica se existe valores       
         IF vr_tot_vlrajusprvmes_fis.COUNT > 0 THEN
           -- imprimir as informa��es para cada conta, ou seja, duplicado
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
       
         -- Se o valor total � maior que zero
       IF nvl(vr_tot_vlrajusprv_jur,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA JURIDICA ***/       
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8067, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrajusprv_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"AJUSTE PROVISAO APLICA��O PROGRAMADA � PESSOA JURIDICA"';                       --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
             
         -- Verifica se existe valores       
         IF vr_tot_vlrajusprvmes_jur.COUNT > 0 THEN   
           -- imprimir as informa��es para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tot_vlrajusprvmes_jur.FIRST()..vr_tot_vlrajusprvmes_jur.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_tot_vlrajusprvmes_jur.EXISTS(vr_idx_agencia) THEN       
                 -- Se o valor � maior que zero
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
       
       --Hist�rico 155
       -- Se o valor total � maior que zero
       IF nvl(vr_tot_vlrajudprv_fis,0) > 0 THEN
         
         /*** Montando as informacoes de PESSOA FISICA ***/
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8066, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrajudprv_fis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"AJUSTE DE PROVISAO APLICA�AO PROGRAMADA � PESSOA FISICA"';                         --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
         
         -- Verifica se existe valores       
         IF vr_tot_vlrajudprvmes_fis.COUNT > 0 THEN
           -- imprimir as informa��es para cada conta, ou seja, duplicado
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
       
       -- Se o valor total � maior que zero
       IF nvl(vr_tot_vlrajudprv_jur,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA JURIDICA ***/       
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                          gene0002.fn_mask(8068, pr_dsforma => '9999')||','||                                              --> Conta Origem
                        gene0002.fn_mask(8067, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrajudprv_jur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                          '"AJUSTE DE PROVISAO APLICA�AO PROGRAMADA � PESSOA JURIDICA"';                                   --> Descricao
           -- Escreve no CLOB
           gene0002.pc_escreve_xml(pr_xml            => vr_clob_arq
                                  ,pr_texto_completo => vr_text_arq
                                  ,pr_texto_novo     => vr_setlinha||chr(13));
             
         -- Verifica se existe valores       
         IF vr_tot_vlrajudprvmes_jur.COUNT > 0 THEN   
           -- imprimir as informa��es para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tot_vlrajudprvmes_jur.FIRST()..vr_tot_vlrajudprvmes_jur.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_tot_vlrajudprvmes_jur.EXISTS(vr_idx_agencia) THEN       
                 -- Se o valor � maior que zero
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
       -- Se o valor total � maior que zero       
       IF nvl(vr_tot_vlrrend_fis,0) > 0 THEN
         
          /*** Montando as informacoes de PESSOA FISICA ***/
          -- Montando o cabecalho das contas do dia atual
          vr_setlinha := '70'||                                                                                          --> Informacao inicial
                          TO_CHAR(rw_dat.dtmvtolt,'YYMMDD')||','||                                                       --> Data AAMMDD do Arquivo
                          TO_CHAR(rw_dat.dtmvtolt,'DDMMYY')||','||                                                       --> Data DDMMAA
                        gene0002.fn_mask(8086, pr_dsforma => '9999')||','||                                              --> Conta Origem
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
             -- imprimir as informa��es para cada conta, ou seja, duplicado
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

       -- Se o valor total � maior que zero
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
               -- imprimir as informa��es para cada conta, ou seja, duplicado
               FOR repete IN 1..2 LOOP
                   -- Gravas as informacoes de valores por agencia
                   FOR vr_idx_agencia IN vr_tot_vlrrendmes_jur.FIRST()..vr_tot_vlrrendmes_jur.LAST() LOOP
                       -- Verifica se existe a informacao
                       IF vr_tot_vlrrendmes_jur.EXISTS(vr_idx_agencia) THEN       
                          -- Se o valor � maior que zero
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
         
         -- Submeter a gera��o do arquivo 
         gene0002.pc_solicita_relato_arquivo(pr_cdcooper   => pr_cdcooper                       --> Cooperativa conectada
                                            ,pr_cdprogra   => vr_cdprogra                       --> Programa chamador
                                            ,pr_dtmvtolt   => rw_dat.dtmvtolt                   --> Data do movimento atual
                                            ,pr_dsxml      => vr_clob_arq                       --> Arquivo XML de dados
                                            ,pr_cdrelato   => '737'                             --> C�digo do relat�rio
                                            ,pr_dsarqsaid  => vr_nom_direto||'/'||vr_nmarqtxt   --> Arquivo final com o path
                                            ,pr_flg_gerar  => vr_flgerar                        --> N�o gerar na hora
                                            ,pr_dspathcop  => vr_dircon                         --> Copiar para o diret�rio
                                            ,pr_fldoscop   => 'S'                               --> Executar comando ux2dos
                                            ,pr_flgremarq  => 'N'                               --> Ap�s c�pia, remover arquivo de origem
                                            ,pr_des_erro   => vr_dscritic);
         -- Liberar mem�ria alocada
         dbms_lob.close(vr_clob_arq);
         dbms_lob.freetemporary(vr_clob_arq);

         -- Se houve erro na gera��o
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
       END IF;
    END IF;

    -----------------------------------------------
    -- Fim de geracao de arquivo AAMMDD_APPPROG.txt       
    -----------------------------------------------

    -- Escrever totais no XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '</debitos>'
                                                || '<totalDebito><vr_tot_qtdebito>' || to_char(nvl(vr_tot_qtdebito, 0), 'FM999G999G990') || '</vr_tot_qtdebito>'
                                                || '<vr_tot_vldebito>' || to_char(nvl(vr_tot_vldebito, 0), 'FM999G999G990D00') ||'</vr_tot_vldebito></totalDebito>');

    -- Escrever total no XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                             ,pr_texto_completo => vr_text_02
                             ,pr_texto_novo     => '<total>' || to_char(vr_res_vlrppati, 'FM999G999G990D00') || '</total>');

      -- Finalizar XMLs
      gene0002.pc_escreve_xml(pr_xml            => vr_clob_01
                             ,pr_texto_completo => vr_text_01
                             ,pr_texto_novo     => '</base>'
                             ,pr_fecha_xml      => TRUE);

      gene0002.pc_escreve_xml(pr_xml            => vr_clob_02
                             ,pr_texto_completo => vr_text_02
                             ,pr_texto_novo     => '</base>'
                             ,pr_fecha_xml      => TRUE);                       
    
    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_dat.dtmvtolt
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
      -- Liberar dados do CLOB da mem�ria
      dbms_lob.close(vr_clob_01);
      dbms_lob.freetemporary(vr_clob_01);
    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
        RAISE vr_exc_saida;
    END IF;
    
      -- Gerar relat�rio 737
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

      -- Liberar dados do CLOB da mem�ria
      dbms_lob.close(vr_clob_02);
      dbms_lob.freetemporary(vr_clob_02);
      
    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
        RAISE vr_exc_saida;
    END IF;

      -- Limpa os registros da tabela de trabalho 
      begin    
        delete from tbgen_batch_relatorio_wrk
         where cdcooper    = pr_cdcooper
           and cdprograma  = vr_cdprogra
           AND dsrelatorio IN('crrl737','crrl737_appprog','bndes','total','prazos','CRAPTRD','CRAPLOT')
           and dtmvtolt    = rw_dat.dtmvtolt;    
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao deletar tabela tbgen_batch_relatorio_wrk: '||sqlerrm;
          raise vr_exc_saida;            
      end;
           
      -- Grava LOG de ocorr�ncia inicial de atualiza��o da tabela craptrd
      pc_log_programa(PR_DSTIPLOG           => 'O'
                     ,PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$'
                     ,pr_cdcooper           => pr_cdcooper
                     ,pr_tpexecucao         => vr_tpexecucao   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_tpocorrencia       => 4
                     ,pr_dsmensagem         => 'Fim - Busca Informa��es e Gera��o Relat�rios e Arquivo Cont�bil.'
                     ,PR_IDPRGLOG           => vr_idlog_ini_ger); 

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Caso seja o controlador 
      if vr_idcontrole <> 0 then
        -- Atualiza finaliza��o do batch na tabela de controle 
        gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exce�ao
          raise vr_exc_saida;
        end if;                                       
      end if; 
 
      --Grava LOG sobre o �nicio da execu��o da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F'   
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 1); 
      -- Efetuar commit
      COMMIT;
    ELSE
      -- Atualiza finaliza��o do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                         ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                         ,pr_dscritic);   --pr_dscritic  OUT crapcri.dscritic%TYPE

      -- Encerrar o job do processamento paralelo dessa ag�ncia
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);  
    
      -- Salvar informacoes no banco de dados
      COMMIT;
    END IF;  
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas c�digo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descri��o
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Devolvemos c�digo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      -- Na execu��o paralela
      IF nvl(pr_idparale,0) <> 0 THEN

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);                                     
        
        -- Grava LOG de erro com as cr�ticas retornadas                           
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
                        
        -- Gera Log no Batch cfme solicita��o Rodrigo Siewert
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||vr_cdprogra||'_'||pr_cdagenci||' --> '||pr_cdcritic||' - '||pr_dscritic);
        
        -- Encerrar o job do processamento paralelo dessa ag�ncia
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);                        
                                    
      END IF;

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Na execu��o paralela
      if nvl(pr_idparale,0) <> 0 then 
        -- Grava LOG de ocorr�ncia final da procedure apli0001.pc_calc_poupanca
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
        
        -- Gera Log no Batch cfme solicita��o Rodrigo Siewert
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||vr_cdprogra||'_'||pr_cdagenci||' --> '||pr_cdcritic||' - '||pr_dscritic);
        
        -- Encerrar o job do processamento paralelo dessa ag�ncia
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
      end if; 
      
      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS737; 
/
