CREATE OR REPLACE PROCEDURE CECRED.pc_crps029 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Codigo Agencia
                                       --FM paralelismo
                                       ,pr_idparale  IN PLS_INTEGER DEFAULT 0  --> Identificador do job executando em paralelo.
                                       ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN

  /* ............................................................................

   Programa: pc_crps029                          Antigo: Fontes/crps029.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/93.                       Ultima atualizacao: 23/02/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Emitir extratos especiais diariamente, relatorio 40,44,73 e 88.
               Atende solicitacao 002.

   Alteracoes: 22/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               05/07/94 - Alterado para nao compor o saldo dos emprestimos nao
                          liquididados com data de contratacao inferior ao dia
                          01/07/94 (Conversao CR$ para R$) - (Edson).

               30/09/94 - Alterado para mostrar a alinea na descricao do histo-
                          rico 47 (Deborah).

               25/10/94 - Alterado para mostrar a alinea na descricao do histo-
                          rico 78 (Odair).

               03/11/94 - Alterado para incluir a comparacao do codigo de his-
                          torico 46 atraves de uma variavel (Odair).

               14/12/94 - Alterado para incluir o relatorio de extrato das
                          aplicacoes RDCA - 88 (Edson).

               02/02/95 - Alterado para reconverter o juros ao capital em
                          moeda fixa (Deborah).

               02/03/95 - Alterado para modificar o layout do extrato de empres-
                          timo, acrescentando o campo txjurepr (Odair).

               29/03/95 - Alterado para na leitura do craplap, desprezar os
                          historicos de provisao (Odair).

               03/08/95 - Alterar o layout do extrato para imposto de renda.
                          (Odair).

               14/08/95 - Alteracao total. A partir de hoje passara parametros
                          para os programas que gerarao os devidos extratos
                          especiais (Edson).

               28/03/96 - Alterado para tratar inisenta e insitext (Edson).

               23/02/99 - Incluir tipo 5 Poupanca Programada (Odair)

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               25/01/2000 - Chamar a rotina de impressao (Deborah).

               16/03/2000 - Tratar tpextrat = 6 - IR juridicas mensal
                            (Deborah).

               24/04/2002 - Tratar impressao dos cheques depositados (Edson).

               04/11/2003 - Substituido comando RETURN pelo QUIT(Mirtes).

               07/10/2004 - Efetuar impressao CI - Relatorio 370 (Mirtes).
               
               31/08/2005 - Passado parametro crapext.dtreffim para tipo
                            de extrato 1 (Diego).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               24/07/2008 - Incluido os parametros "crapext.dtrefere" e
                            "crapext.dtreffim" na chamada do programa
                            fontes/impextppr.p (Elton).
        
               16/01/2009 - Chamar programa de tarifas (Gabriel).  
               
               01/10/2009 - Tratamento para listar depositos identificados
                            no extrato de conta corrente (David).
                            
               09/02/2012 - Utilizar BO b1wgen0112.p (David).
               
               28/06/2013 - Retirar o USE-INDEX da crapext (Evandro).
                            
               19/09/2014 - Conversao Progress -> Oracle (Alisson - AMcom)
               
               29/01/2015 - Adicionado parametro pr_intpextr na chamada da extr0002.pc_gera_impressao
                            (Alisson - AMcom)

               25/01/2016 - Melhoria para alterar proc_batch pelo proc_message
                            na critica da EXTR0002.pc_gera_impressao. 
                            (Jaison/Diego - SD: 273526)

               10/06/2016 - Removido cursor cr_craptab_ctabloq e utilizado a procedure padrao
                            TABE0001.pc_carrega_ctablq (Douglas - Chamado 454248)
                            
               04/07/2016 - Ajuste para não popular PL_TABLE e buscar registro a registro
                            para melhorar a performance
                            (Adriano - SD 480339).
                            
               23/02/2018 - Projeto ligeirinho, alterações para paralelismo.
                            (Fernando Miranda - Amcom).             
                            
  ............................................................................. */

  DECLARE
  
    ------------------------ CONSTANTES  -------------------------------------
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS029';  -- Codigo do Programa

    ------------------------ VARIAVEIS PARA INDICES --------------------------  
    vr_index_craplpp VARCHAR2(20);
    vr_index_craplrg VARCHAR2(20);
    vr_index_resgate VARCHAR2(25);

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------  
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_des_reto   VARCHAR2(3);
    vr_dscritic   VARCHAR2(4000);
  
    --FM Paralelismo
    vr_inproces      crapdat.inproces%type; 
    vr_qtdjobs       number;
    vr_idparale      integer;
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;
    vr_qterro        number := 0;
    vr_dtmvtolt      DATE;
    vr_jobname       varchar2(30);
    vr_dsplsql       varchar2(4000); 
    vr_tpexecucao    tbgen_prglog.tpexecucao%type;
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
    vr_idlog_ini_par tbgen_prglog.idprglog%type;
  
    ------------------------------- CURSORES ---------------------------------
  
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.nmrescop
            ,crapcop.nmextcop
        FROM crapcop crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
    CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE
                      ,pr_nrdconta IN craplpp.nrdconta%TYPE
                      --FM paralelismo
                      ,pr_cdagenci IN craplpp.cdagenci%TYPE
                      ) IS
    SELECT /*+ INDEX (lpp craplpp##craplpp4) */ 
           lpp.nrdconta
          ,lpp.nrctrrpp
          ,Count(*) qtlancmto
      FROM craplpp lpp,
           crapass
     WHERE lpp.cdcooper = pr_cdcooper
       AND lpp.cdhistor IN (158,496)
       AND lpp.dtmvtolt > pr_dtmvtolt
       AND lpp.nrdconta = pr_nrdconta
       --FM paralelismo - Inclusão de filtro por agência para tratar o paralelismo
       AND lpp.nrdconta = crapass.nrdconta
       AND lpp.cdcooper = crapass.cdcooper
       AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
           GROUP BY lpp.nrdconta,lpp.nrctrrpp;
    rw_craplpp cr_craplpp%ROWTYPE;
                
    --Contar a quantidade de resgates das contas
    CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                            ,pr_nrdconta IN craplrg.nrdconta%TYPE
                            --FM paralelismo
                            ,pr_cdagenci IN craplrg.cdagenci%TYPE) IS
    SELECT lrg.nrdconta
          ,lrg.nraplica
          ,COUNT(*) qtlancmto
      FROM craplrg lrg,
           crapass
     WHERE lrg.cdcooper = pr_cdcooper
       AND lrg.tpaplica = 4
       AND lrg.inresgat = 0
       AND lrg.nrdconta = pr_nrdconta      
       --FM paralelismo - Inclusão de filtro por agência para tratar o paralelismo
       AND lrg.nrdconta = crapass.nrdconta
       AND lrg.cdcooper = crapass.cdcooper
       AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)     
           GROUP BY lrg.nrdconta,lrg.nraplica;
    rw_craplrg_saque cr_craplrg_saque%ROWTYPE;
    
    --Selecionar informacoes dos lancamentos de resgate
    CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                      ,pr_dtresgat IN craplrg.dtresgat%TYPE
                      ,pr_nrdconta IN craplrg.nrdconta%TYPE
                      --FM paralelismo
                      ,pr_cdagenci IN craplrg.cdagenci%TYPE) IS
    SELECT lrg.nrdconta
          ,lrg.nraplica
          ,lrg.tpaplica
          ,lrg.tpresgat
          ,NVL(SUM(NVL(lrg.vllanmto,0)),0) vllanmto
      FROM craplrg lrg,
           crapass
     WHERE lrg.cdcooper = pr_cdcooper
       AND lrg.dtresgat <= pr_dtresgat
       AND lrg.inresgat = 0
       AND lrg.tpresgat = 1
       AND lrg.nrdconta = pr_nrdconta
       --FM paralelismo - Inclusão de filtro por agência para tratar o paralelismo
       AND lrg.nrdconta = crapass.nrdconta
       AND lrg.cdcooper = crapass.cdcooper
       AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
       GROUP BY lrg.nrdconta
               ,lrg.nraplica
               ,lrg.tpaplica
               ,lrg.tpresgat;        
    rw_craplrg cr_craplrg%ROWTYPE;
        
    -- Cursor para busca de associados
    CURSOR cr_crapext (pr_cdcooper crapcop.cdcooper%TYPE
                       --FM paralelismo
                      ,pr_cdagenci IN crapext.cdagenci%TYPE) IS
      SELECT /*+ index (crapext crapext##crapext6) */ 
             crapext.nrdconta
            ,crapext.tpextrat 
            ,crapext.dtrefere 
            ,crapext.dtreffim 
            ,crapext.inisenta
            ,crapext.inselext 
            ,crapext.nrctremp 
            ,crapext.nraplica 
            ,crapext.nranoref 
       FROM crapext crapext,
            crapass
       WHERE crapext.cdcooper = pr_cdcooper
       AND   crapext.insitext = 0  
       --FM paralelismo - Inclusão de filtro por agência para tratar o paralelismo
       AND crapext.nrdconta = crapass.nrdconta
       AND crapext.cdcooper = crapass.cdcooper
       AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
       ORDER BY crapext.cdcooper,crapext.tpextrat,crapext.nrdconta,crapext.progress_recid;
      
    -- Cursor para busca de associados para paralelismo
    CURSOR cr_crapext_para (pr_cdcooper crapcop.cdcooper%TYPE,
                            pr_qterro   IN number,
                            pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                            pr_cdprogra IN tbgen_batch_controle.cdprogra%TYPE) IS
      SELECT /*+ index (crapext crapext##crapext6) */ 
             -- FM paralelismo
            DISTINCT crapass.cdagenci
       FROM crapext crapext,
            crapass 
       WHERE crapext.cdcooper = pr_cdcooper
         AND crapext.insitext = 0  
         AND crapext.nrdconta = crapass.nrdconta
         AND crapext.cdcooper = crapass.cdcooper
         AND (pr_qterro = 0 OR 
             (pr_qterro > 0 AND EXISTS (SELECT 1
                                         FROM tbgen_batch_controle
                                        WHERE tbgen_batch_controle.cdcooper    = pr_cdcooper
                                          AND tbgen_batch_controle.cdprogra    = pr_cdprogra
                                          AND tbgen_batch_controle.tpagrupador = 1
                                          AND tbgen_batch_controle.cdagrupador = crapass.cdagenci
                                          AND tbgen_batch_controle.insituacao  = 1
                                          AND tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)))
       ORDER BY crapass.cdagenci;   
    
    
    ---------------------------- ESTRUTURAS DE TABELA ---------------------

    --Estrutura para Nome dos arquivos que serao gerados
    TYPE typ_tab_nmarqimp IS VARRAY(9) OF VARCHAR2(7);
    --Tabela com o nomes dos arquivos que serao gerados
    vr_tab_nmarqimp typ_tab_nmarqimp:= typ_tab_nmarqimp('crrl040','crrl044',   
                                                        'crrl073','crrl088',
                                                        'crrl209','crrl370',
                                                        'crrl499','crrl143',
                                                        'crrl143');
    vr_tab_erro     GENE0001.typ_tab_erro;     --> Armazenar Erros da subrotina
    vr_tab_craptab  APLI0001.typ_tab_ctablq;   --> Armazenar tabela de Conta Bloqueada
    vr_tab_craplpp  APLI0001.typ_tab_craplpp;  --> Armazenar tabela com lancamento poupanca
    vr_tab_craplrg  APLI0001.typ_tab_craplpp;  --> Armazenar tabela com resgates
    vr_tab_resgate  APLI0001.typ_tab_resgate;  --> Armazenar resgates das contas por aplicacao

    ------------------------------- VARIAVEIS -------------------------------
  
	  -- Variaveis para controle de arquivos/diretorios
    vr_nom_direto_rl  VARCHAR2(100);                 -- Diretório onde será gerado o relatório
    vr_nmarqimp       VARCHAR2(100);                 -- Nome Arquivo Impressao
    vr_nmarqpdf       VARCHAR2(100);                 -- Nome Arquivo PDF
    vr_nmformul       VARCHAR2(10);                  -- Nome do Formulario
    vr_flgimpri       VARCHAR2(1);                   -- Indicador Impressao
    vr_qtcoluna       INTEGER;                       -- Quantidade Colunas do Relatorio 
    vr_dsjasper       VARCHAR2(100);                 -- Nome do Arquivo Jasper
    vr_dsnoxml        VARCHAR2(100);                 -- Nome do Nodo XML
	  -- Variaveis utilizadas para o relatório
    vr_clobxml    CLOB;                              -- Clob para conter o XML de dados    
    vr_clobxml1   CLOB;                              -- Clob para conter o XML de dados    
    vr_clobxml2   CLOB;                              -- Clob para conter o XML de dados    
    vr_clobxml3   CLOB;                              -- Clob para conter o XML de dados    
    vr_clobxml4   CLOB;                              -- Clob para conter o XML de dados    
    vr_clobxml5   CLOB;                              -- Clob para conter o XML de dados    
    vr_clobxml6   CLOB;                              -- Clob para conter o XML de dados    
    vr_clobxml7   CLOB;                              -- Clob para conter o XML de dados
    vr_clobxml8   CLOB;                              -- Clob para conter o XML de dados                                
    vr_clobxml9   CLOB;                              -- Clob para conter o XML de dados                                    
    vr_dstexto1   VARCHAR2(32600);                   -- Texto para conter o XML de dados    
    vr_dstexto2   VARCHAR2(32600);                   -- Texto para conter o XML de dados    
    vr_dstexto3   VARCHAR2(32600);                   -- Texto para conter o XML de dados    
    vr_dstexto4   VARCHAR2(32600);                   -- Texto para conter o XML de dados    
    vr_dstexto5   VARCHAR2(32600);                   -- Texto para conter o XML de dados    
    vr_dstexto6   VARCHAR2(32600);                   -- Texto para conter o XML de dados    
    vr_dstexto7   VARCHAR2(32600);                   -- Texto para conter o XML de dados                            
    vr_dstexto8   VARCHAR2(32600);                   -- Texto para conter o XML de dados                                
    vr_dstexto9   VARCHAR2(32600);                   -- Texto para conter o XML de dados                                    
    vr_nrcopias   INTEGER;                           -- Numero Copias do Relatorio
   
    -- Variaveis Locais
    vr_flgtarif   BOOLEAN:= FALSE;
    vr_flgcarga   BOOLEAN:= FALSE;
    --------------------------- SUBROTINAS INTERNAS --------------------------
  
    -- Subrotina para popular os nomes dos relatorios no Clob
    PROCEDURE pc_habilita_clob (pr_tipo IN INTEGER) IS
      vr_texto VARCHAR2(100);  
    BEGIN
      --Habilitar CLOBs
      IF pr_tipo = 1 THEN
        --Montar texto fixo
        vr_texto:= '<?xml version="1.0" encoding="UTF-8"?><';
        -- Inicializar as informações do XML de dados para o relatório
	      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
        dbms_lob.createtemporary(vr_clobxml1, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml1, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml1,vr_dstexto1,vr_texto||vr_tab_nmarqimp(1)||'><contas>');
	      dbms_lob.createtemporary(vr_clobxml2, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml2, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml2,vr_dstexto2,vr_texto||vr_tab_nmarqimp(2)||'><contas>');
	      dbms_lob.createtemporary(vr_clobxml3, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml3, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml3,vr_dstexto3,vr_texto||vr_tab_nmarqimp(3)||'><contas>');
	      dbms_lob.createtemporary(vr_clobxml4, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml4, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml4,vr_dstexto4,vr_texto||vr_tab_nmarqimp(4)||'><contas>');
	      dbms_lob.createtemporary(vr_clobxml5, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml5, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml5,vr_dstexto5,vr_texto||vr_tab_nmarqimp(5)||'><contas>');
	      dbms_lob.createtemporary(vr_clobxml6, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml6, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml6,vr_dstexto6,vr_texto||vr_tab_nmarqimp(6)||'><contas>');
	      dbms_lob.createtemporary(vr_clobxml7, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml7, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml7,vr_dstexto7,vr_texto||vr_tab_nmarqimp(7)||'><contas>');
        dbms_lob.createtemporary(vr_clobxml8, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml8, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml8,vr_dstexto8,vr_texto||vr_tab_nmarqimp(8)||'><contas>');
        dbms_lob.createtemporary(vr_clobxml9, TRUE, dbms_lob.CALL);
  	    dbms_lob.open(vr_clobxml9, dbms_lob.lob_readwrite);
        gene0002.pc_escreve_xml(vr_clobxml9,vr_dstexto9,vr_texto||vr_tab_nmarqimp(9)||'b><contas>');
      ELSIF pr_tipo = 2 THEN
        --Montar texto fixo
        vr_texto:= '</contas></';
        gene0002.pc_escreve_xml(vr_clobxml1,vr_dstexto1,vr_texto||vr_tab_nmarqimp(1)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml2,vr_dstexto2,vr_texto||vr_tab_nmarqimp(2)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml3,vr_dstexto3,vr_texto||vr_tab_nmarqimp(3)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml4,vr_dstexto4,vr_texto||vr_tab_nmarqimp(4)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml5,vr_dstexto5,vr_texto||vr_tab_nmarqimp(5)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml6,vr_dstexto6,vr_texto||vr_tab_nmarqimp(6)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml7,vr_dstexto7,vr_texto||vr_tab_nmarqimp(7)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml8,vr_dstexto8,vr_texto||vr_tab_nmarqimp(8)||'>',TRUE);
        gene0002.pc_escreve_xml(vr_clobxml9,vr_dstexto9,vr_texto||vr_tab_nmarqimp(9)||'b>',TRUE);
      END IF;    
    EXCEPTION
      WHEN OTHERS THEN
        --Descricao do Erro
        vr_dscritic:= 'Erro ao habilitar/fechar Clob. '||sqlerrm;
        --Sair
        RAISE vr_exc_saida;  
    END;    

  PROCEDURE pc_inserir_tbgen_batch(pr_cdcooper    IN tbgen_batch_relatorio_wrk.cdcooper%TYPE
                                  ,pr_cdprograma  IN tbgen_batch_relatorio_wrk.cdprograma%TYPE 
                                  ,pr_dsrelatorio IN tbgen_batch_relatorio_wrk.dsrelatorio%TYPE
                                  --,pr_dtmvtolt    IN tbgen_batch_relatorio_wrk.dtmvtolt%TYPE
                                  ,pr_cdagenci    IN tbgen_batch_relatorio_wrk.cdagenci%TYPE
                                  ,pr_nrdconta    IN tbgen_batch_relatorio_wrk.nrdconta%TYPE
                                  ,pr_dschave     IN tbgen_batch_relatorio_wrk.dschave%TYPE
                                  ,pr_dsxml       IN tbgen_batch_relatorio_wrk.dsxml%TYPE
                                  ,p_ds_erro      OUT VARCHAR2
                                  ) IS
    
  BEGIN
      IF pr_dsxml IS NOT NULL THEN
        insert into tbgen_batch_relatorio_wrk 
            (cdcooper
            ,cdprograma 
            ,dsrelatorio
            ,dtmvtolt
            ,cdagenci
            ,nrdconta
            ,dschave
            ,dsxml) 
          values 
           (pr_cdcooper
           ,pr_cdprograma
           ,pr_dsrelatorio
           ,SYSDATE
           ,pr_cdagenci
           ,pr_nrdconta
           ,pr_dschave
           ,pr_dsxml);         
    END IF;     
  EXCEPTION
     WHEN OTHERS THEN
      --Montar mensagem de erro
      p_ds_erro:= 'Erro ao inserir na tabela tbgen_batch_relatorio_wrk. Rotina pc_crps029.pc_inserir_tbgen_batch. '||SQLERRM;
  END;
    
  PROCEDURE pc_popular_valor_wrk ( pr_cdcooper IN tbgen_batch_relatorio_wrk.cdcooper%TYPE
                                  ,pr_cdagenci IN tbgen_batch_relatorio_wrk.cdagenci%TYPE
                                  ,pr_dtmvtolt IN tbgen_batch_relatorio_wrk.dtmvtolt%TYPE
                                  ,pr_nrdconta IN tbgen_batch_relatorio_wrk.nrdconta%TYPE
                                  ,pr_vlindice IN tbgen_batch_relatorio_wrk.dschave%TYPE
                                  ,pr_idcontrole IN NUMBER
                                  ,pr_clobxml1 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl040
                                  ,pr_dstexto1 IN OUT NOCOPY VARCHAR2    --Texto para Clob 1
                                  ,pr_clobxml2 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl044
                                  ,pr_dstexto2 IN OUT NOCOPY VARCHAR2    --Texto para Clob 2
                                  ,pr_clobxml3 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl073
                                  ,pr_dstexto3 IN OUT NOCOPY VARCHAR2    --Texto para Clob 3
                                  ,pr_clobxml4 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl088
                                  ,pr_dstexto4 IN OUT NOCOPY VARCHAR2    --Texto para Clob 4
                                  ,pr_clobxml5 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl209
                                  ,pr_dstexto5 IN OUT NOCOPY VARCHAR2    --Texto para Clob 5
                                  ,pr_clobxml6 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl370
                                  ,pr_dstexto6 IN OUT NOCOPY VARCHAR2    --Texto para Clob 6
                                  ,pr_clobxml7 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl499
                                  ,pr_dstexto7 IN OUT NOCOPY VARCHAR2    --Texto para Clob 7
                                  ,pr_clobxml8 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl143
                                  ,pr_dstexto8 IN OUT NOCOPY VARCHAR2    --Texto para Clob 8
                                  ,pr_clobxml9 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl143b
                                  ,pr_dstexto9 IN OUT NOCOPY VARCHAR2    --Texto para Clob 9
                                  ,pr_dscritic OUT VARCHAR2
                                  ) IS
    
  BEGIN
            
    --pr_clobxml1
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml1', pr_clobxml1||pr_dstexto1, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml1';
      RETURN;
    END IF;
    
    --pr_clobxml2
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml2', pr_clobxml2||pr_dstexto2, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml2';
      RETURN;
    END IF;
    
    --pr_clobxml3
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml3', pr_clobxml3||pr_dstexto3, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml3';
      RETURN;
    END IF;
    
    --pr_clobxml4
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml4', pr_clobxml4||pr_dstexto4, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml4';
      RETURN;
    END IF;
    
    --pr_clobxml5
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml5', pr_clobxml5||pr_dstexto5, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml5';
      RETURN;
    END IF;
    
    --pr_clobxml6
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml6', pr_clobxml6||pr_dstexto6, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml6';
      RETURN;
    END IF;
    
    --pr_clobxml7
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml7', pr_clobxml7||pr_dstexto7, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml7';
      RETURN;
    END IF;
    
    --pr_clobxml8
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml8', pr_clobxml8||pr_dstexto8, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml8';
      RETURN;
    END IF;
    
    --pr_clobxml9
    pc_inserir_tbgen_batch(pr_cdcooper, 'CRPS029', 'EXTRATO', pr_cdagenci, pr_nrdconta, 'clobxml9', pr_clobxml9||pr_dstexto9, pr_dscritic);
    
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := pr_dscritic ||'. pr_clobxml9';
      RETURN;
    END IF;
    
  END pc_popular_valor_wrk;
  
  PROCEDURE pc_carregar_valor_wrk( pr_cdcooper IN tbgen_batch_relatorio_wrk.cdcooper%TYPE
                                  ,pr_idcontrole IN NUMBER
                                  ,pr_clobxml1 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl040
                                  ,pr_dstexto1 IN OUT NOCOPY VARCHAR2    --Texto para Clob 1
                                  ,pr_clobxml2 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl044
                                  ,pr_dstexto2 IN OUT NOCOPY VARCHAR2    --Texto para Clob 2
                                  ,pr_clobxml3 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl073
                                  ,pr_dstexto3 IN OUT NOCOPY VARCHAR2    --Texto para Clob 3
                                  ,pr_clobxml4 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl088
                                   ,pr_dstexto4 IN OUT NOCOPY VARCHAR2    --Texto para Clob 4
                                  ,pr_clobxml5 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl209
                                  ,pr_dstexto5 IN OUT NOCOPY VARCHAR2    --Texto para Clob 5
                                  ,pr_clobxml6 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl370
                                  ,pr_dstexto6 IN OUT NOCOPY VARCHAR2    --Texto para Clob 6
                                  ,pr_clobxml7 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl499
                                  ,pr_dstexto7 IN OUT NOCOPY VARCHAR2    --Texto para Clob 7
                                  ,pr_clobxml8 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl143
                                  ,pr_dstexto8 IN OUT NOCOPY VARCHAR2    --Texto para Clob 8
                                  ,pr_clobxml9 IN OUT NOCOPY CLOB        --Clob arquivo de dados crrl143b
                                  ,pr_dstexto9 IN OUT NOCOPY VARCHAR2    --Texto para Clob 9
                                  ,pr_dscritic OUT VARCHAR2
                                  ) IS
    
  CURSOR c_dados IS
    SELECT a.dschave,
           a.dsxml
      FROM tbgen_batch_relatorio_wrk a
     WHERE a.cdcooper = pr_cdcooper
       AND a.cdprograma = 'CRPS029'
       AND a.dsrelatorio = 'EXTRATO'
       AND a.dsxml IS NOT NULL
       AND a.dschave NOT LIKE '%dstexto%'
       ORDER BY a.dtmvtolt;
  
  BEGIN
       
    FOR r_dados IN c_dados LOOP
      
      IF r_dados.dschave = 'clobxml1' THEN
        pr_clobxml1 := pr_clobxml1 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto1' THEN
        pr_dstexto1 := pr_dstexto1 || r_dados.dsxml;
      END IF; 
      
      IF r_dados.dschave = 'clobxml2' THEN
        pr_clobxml2 := pr_clobxml2 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto2' THEN
        pr_dstexto2 := pr_dstexto2 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'clobxml3' THEN
        pr_clobxml3 := pr_clobxml3 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto3' THEN
        pr_dstexto3 := pr_dstexto3 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'clobxml4' THEN
        pr_clobxml4 := pr_clobxml4 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto4' THEN
        pr_dstexto4 := pr_dstexto4 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'clobxml5' THEN
        pr_clobxml5 := pr_clobxml5 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto5' THEN
        pr_dstexto5 := pr_dstexto5 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'clobxml6' THEN
        pr_clobxml6 := pr_clobxml6 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto6' THEN
        pr_dstexto6 := pr_dstexto6 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'clobxml7' THEN
        pr_clobxml7 := pr_clobxml7 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto7' THEN
        pr_dstexto7 := pr_dstexto7 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'clobxml8' THEN
        pr_clobxml8 := pr_clobxml8 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto8' THEN
        pr_dstexto8 := pr_dstexto8 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'clobxml9' THEN
        pr_clobxml9 := pr_clobxml9 || r_dados.dsxml;
      END IF;
      
      IF r_dados.dschave = 'dstexto9' THEN
        pr_dstexto9 := pr_dstexto9 || r_dados.dsxml;
      END IF;             
    
    END LOOP;
    
    pr_clobxml1 := replace(pr_clobxml1,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(1)||'><contas>','');
    pr_clobxml1 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(1)||'><contas>'||pr_clobxml1;
    
    pr_clobxml2 := replace(pr_clobxml2,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(2)||'><contas>','');
    pr_clobxml2 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(2)||'><contas>'||pr_clobxml2;
    
    pr_clobxml3 := replace(pr_clobxml3,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(3)||'><contas>','');
    pr_clobxml3 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(3)||'><contas>'||pr_clobxml3;
    
    pr_clobxml4 := replace(pr_clobxml4,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(4)||'><contas>','');
    pr_clobxml4 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(4)||'><contas>'||pr_clobxml4;
    
    pr_clobxml5 := replace(pr_clobxml5,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(5)||'><contas>','');
    pr_clobxml5 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(5)||'><contas>'||pr_clobxml5;
    
    pr_clobxml6 := replace(pr_clobxml6,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(6)||'><contas>','');
    pr_clobxml6 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(6)||'><contas>'||pr_clobxml6;
    
    pr_clobxml7 := replace(pr_clobxml7,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(7)||'><contas>','');
    pr_clobxml7 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(7)||'><contas>'||pr_clobxml7;
    
    pr_clobxml8 := replace(pr_clobxml8,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(8)||'><contas>','');
    pr_clobxml8 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(8)||'><contas>'||pr_clobxml8;
    
    pr_clobxml9 := replace(pr_clobxml9,'<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(9)||'b'||'><contas>','');
    pr_clobxml9 := '<?xml version="1.0" encoding="UTF-8"?><'||vr_tab_nmarqimp(9)||'b'||'><contas>'||pr_clobxml9;
                
    DELETE tbgen_batch_relatorio_wrk a
     WHERE a.cdcooper = pr_cdcooper
       AND a.cdprograma = 'CRPS029'
       AND a.dsrelatorio = 'EXTRATO';
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao processa carregamento de dados crps029.pc_carregar_valor_wrk '||SQLERRM;  
  END pc_carregar_valor_wrk;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);
                               
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
  
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
      
      --FM paralelismo
      --Atribui o inproces
       vr_inproces:= rw_crapdat.inproces;  
       --Atribuir a data do movimento
       vr_dtmvtolt:= rw_crapdat.dtmvtolt;
    END IF;
  
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 0,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
  
    --FM - Inicio paralelismo
    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                                 ,pr_cdprogra => vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                                 ); 
  
  
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
	--Apenas inicia clob quando é um job paralelo ou quando nãom roda em paralelo
    IF pr_idparale <> 0 OR vr_qtdjobs  = 0 THEN
      --habilitar CLOBs
    pc_habilita_clob(1);
    END IF;

    -- Busca do diretório base da cooperativa para a geração de relatórios
	  vr_nom_direto_rl:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
							    									   	    ,pr_cdcooper => pr_cdcooper   --> Cooperativa
							  	   									      ,pr_nmsubdir => 'rl');        --> Utilizaremos o rl
    

    if vr_inproces  > 2 and
       vr_qtdjobs   > 0 and 
       pr_cdagenci  = 0 then  
    
      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_id_paralelo;
        
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
         -- Levantar exceção
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
         RAISE vr_exc_saida;
      END IF;
        
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);
                        
        
      -- Verifica se algum job paralelo executou com erro
      vr_qterro := 0;
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => vr_dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);
                                                    
                                                    
      --monta as chamadas das rotinas para paralelismo
      FOR rw_crapext_para IN cr_crapext_para (pr_cdcooper => pr_cdcooper,
                                              pr_qterro   => vr_qterro,
                                              pr_dtmvtolt => vr_dtmvtolt,
                                              pr_cdprogra => vr_cdprogra) LOOP -- Cod. Cooperativa
          
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := vr_cdprogra ||'_'|| rw_crapext_para.cdagenci || '$'; 
          
          -- Cadastra o programa paralelo
          gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(rw_crapext_para.cdagenci,3,'0') --> Utiliza a agência como id programa
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
                        '  pc_crps029( '|| pr_cdcooper             || ',' ||
                                           rw_crapext_para.cdagenci     || ',' ||
                                           vr_idparale             || ',' ||
                                           ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' || chr(13) ||
                        'END;';
                        
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
        END LOOP;                                              
        
        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- até que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => vr_dscritic);
                                    

        -- Verifica se algum job paralelo executou com erro
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => vr_cdprogra,
                                                      pr_dtmvtolt    => vr_dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);
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
      
      -- Grava controle de batch por agência
      gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                      ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                      ,pr_dtmvtolt    => vr_dtmvtolt               -- Data de Movimento
                                      ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                      ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                      ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                      ,pr_dscritic    => vr_dscritic );      
      
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => vr_tpexecucao,     -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par); 
                          
      -- Grava LOG de ocorrência inicial do cursor cr_crapext
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Início - cursor cr_crapext. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 
    
		/*  Leitura Arquivo de contas que deverao ter seus extratos impressos.  */
      FOR rw_crapext IN cr_crapext (pr_cdcooper => pr_cdcooper, -- Cod. Cooperativa
                                    pr_cdagenci => pr_cdagenci) LOOP   

      --Se for Poupanca Programada (tpextrat = 5) carregar tabelas de memoria
      IF rw_crapext.tpextrat IN (5,10) AND NOT vr_flgcarga THEN
        --Rodou a carga
        vr_flgcarga:= TRUE;
        
        --Popular tabelas de Memoria para a procedure                                               
        vr_tab_craptab.DELETE;
        vr_tab_craplpp.DELETE;
        vr_tab_craplrg.DELETE;
        vr_tab_resgate.DELETE;

        -- Carregar tabela de memoria de contas bloqueadas
        -- (Nao informa a conta para carregar todos os registros)
        TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_crapext.nrdconta
                                  ,pr_tab_cta_bloq => vr_tab_craptab);

        -- Busca registro de lancamentos na poupanca
        OPEN cr_craplpp(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180
                         ,pr_nrdconta => rw_crapext.nrdconta
                         ,pr_cdagenci => pr_cdagenci);
                       
        FETCH cr_craplpp INTO rw_craplpp;
        
			--Fechar o cursor
			CLOSE cr_craplpp;
        
			--Se possuir mais de 3 registros
			IF rw_craplpp.qtlancmto > 3 THEN                                     
			  -- Montar indice para acessar tabela
			  vr_index_craplpp:= LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
			  -- Atribuir quantidade encontrada de cada conta ao vetor
			  vr_tab_craplpp(vr_index_craplpp):= rw_craplpp.qtlancmto;
			END IF;               
        
        -- Busca registro com total de resgates na poupanca
        OPEN cr_craplrg_saque(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapext.nrdconta
                               ,pr_cdagenci => pr_cdagenci);
                       
        FETCH cr_craplrg_saque INTO rw_craplrg_saque;
        
        IF cr_craplrg_saque%FOUND THEN
        
          -- Montar Indice para acesso quantidade lancamentos de resgate
          vr_index_craplrg:= LPad(rw_craplrg_saque.nrdconta,10,'0')||LPad(rw_craplrg_saque.nraplica,10,'0');
          -- Popular tabela de memoria
          vr_tab_craplrg(vr_index_craplrg):= rw_craplrg_saque.qtlancmto;        
                  
        END IF;
          
        --Fechar o cursor
        CLOSE cr_craplrg_saque;          
        
        -- Busca registro com total resgatado por conta e aplicacao
        OPEN cr_craplrg(pr_cdcooper => pr_cdcooper
                       ,pr_dtresgat => rw_crapdat.dtmvtopr
                         ,pr_nrdconta => rw_crapext.nrdconta
                         ,pr_cdagenci => pr_cdagenci);
                       
        FETCH cr_craplrg INTO rw_craplrg;
        
        IF cr_craplrg%FOUND THEN
        
          -- Montar indice para selecionar total dos resgates na tabela auxiliar
          vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0') ||
                              LPad(rw_craplrg.tpaplica,05,'0') ||
                              LPad(rw_craplrg.nraplica,10,'0');
          -- Popular a tabela de memoria com a soma dos lancamentos de resgate
          vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
          vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;       
                  
        END IF;
          
        --Fechar o cursor
        CLOSE cr_craplrg;          
        
      END IF;  --rw_crapext.tpextrat = 5 AND NOT vr_flgcarga
      
      --Tarifa
      vr_flgtarif:= rw_crapext.inisenta = 0;

      --Gerar Impressao
      EXTR0002.pc_gera_impressao(pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                ,pr_cdagenci => pr_cdagenci           --Codigo Agencia
                                ,pr_nrdcaixa => 0                     --Numero do Caixa
                                ,pr_idorigem => 1                     --Origem dos Dados
                                ,pr_nmdatela => UPPER(vr_cdprogra)    --Nome da Tela
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --Data Movimento
                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr   --Data Proximo Movimento
                                ,pr_cdprogra => vr_cdprogra           --Codigo Programa
                                ,pr_inproces => rw_crapdat.inproces   --Indicador Processo
                                ,pr_cdoperad => '1'                   --Codigo Operador
                                ,pr_dsiduser => NULL                  --Identificador Usuario
                                ,pr_flgrodar => FALSE                 --Flag Executar
                                ,pr_nrdconta => rw_crapext.nrdconta   --Numero da Conta do Associado
                                ,pr_idseqttl => 1                     --Sequencial do Titular
                                ,pr_tpextrat => rw_crapext.tpextrat   --Tipo de Extrato
                                ,pr_dtrefere => rw_crapext.dtrefere   --Data de Referencia
                                ,pr_dtreffim => rw_crapext.dtreffim   --Data Referencia Final
                                ,pr_flgtarif => vr_flgtarif           --Indicador Cobra tarifa
                                ,pr_inrelext => rw_crapext.inselext   --Indicador Relatorio Extrato
                                ,pr_inselext => rw_crapext.inselext   --Indicador Selecao Extrato
                                ,pr_nrctremp => rw_crapext.nrctremp   --Numero Contrato Emprestimo
                                ,pr_nraplica => rw_crapext.nraplica   --Numero Aplicacao
                                ,pr_nranoref => rw_crapext.nranoref   --Ano de Referencia
                                ,pr_flgerlog => TRUE                  --Escreve erro Log
                                ,pr_clobxml1 => vr_clobxml1           --Clob arquivo de dados crrl040
                                ,pr_dstexto1 => vr_dstexto1           --Texto para Clob 1
                                ,pr_clobxml2 => vr_clobxml2           --Clob arquivo de dados crrl044
                                ,pr_dstexto2 => vr_dstexto2           --Texto para Clob 2
                                ,pr_clobxml3 => vr_clobxml3           --Clob arquivo de dados crrl073
                                ,pr_dstexto3 => vr_dstexto3           --Texto para Clob 3
                                ,pr_clobxml4 => vr_clobxml4           --Clob arquivo de dados crrl088
                                ,pr_dstexto4 => vr_dstexto4           --Texto para Clob 4
                                ,pr_clobxml5 => vr_clobxml5           --Clob arquivo de dados crrl209
                                ,pr_dstexto5 => vr_dstexto5           --Texto para Clob 5
                                ,pr_clobxml6 => vr_clobxml6           --Clob arquivo de dados crrl370
                                ,pr_dstexto6 => vr_dstexto6           --Texto para Clob 6
                                ,pr_clobxml7 => vr_clobxml7           --Clob arquivo de dados crrl499
                                ,pr_dstexto7 => vr_dstexto7           --Texto para Clob 7
                                ,pr_clobxml8 => vr_clobxml8           --Clob arquivo de dados crrl143
                                ,pr_dstexto8 => vr_dstexto8           --Texto para Clob 8
                                ,pr_clobxml9 => vr_clobxml9           --Clob arquivo de dados crrl143b
                                ,pr_dstexto9 => vr_dstexto9           --Texto para Clob 9
                                ,pr_tab_craptab => vr_tab_craptab     --Tabela de Conta Bloqueada
                                ,pr_tab_craplpp => vr_tab_craplpp     --Tabela com lancamento poupanca
                                ,pr_tab_craplrg => vr_tab_craplrg     --Tabela com resgates
                                ,pr_tab_resgate => vr_tab_resgate     --Tabela com valores dos resgates das contas por aplicacao
                                ,pr_intpextr => 2                     --Tipo Extrato (1-Simplificado 2-Detalhado)
                                ,pr_nmarqimp => vr_nmarqimp           --Nome Arquivo Impressao
                                ,pr_nmarqpdf => vr_nmarqpdf           --Nome Arquivo PDF
                                ,pr_tab_erro => vr_tab_erro           --Tabela de Erros
                                ,pr_des_reto => vr_des_reto);         --Descricao Erro
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Se tem erro no vetor
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE    
          --Adicionar a conta na mensagem erro
          vr_dscritic:= 'Erro na geracao do extrato. '||vr_dscritic||' CONTA = '||rw_crapext.nrdconta;
        END IF;  
                      
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => GENE0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                  ,pr_des_log      => to_char(SYSDATE,
                                                          'hh24:mi:ss') ||
                                                  ' - ' || vr_cdprogra ||
                                                  ' --> ' || vr_dscritic);
        
      END IF;

    END LOOP; --cr_crapext

     --FM paralelismo
     --Gravar resultado da geração dos textos e das variaveis clob em tabela work
     if pr_idparale <> 0 then
       pc_popular_valor_wrk( pr_cdcooper   => pr_cdcooper
                            ,pr_cdagenci   => pr_cdagenci
                            ,pr_dtmvtolt   => vr_dtmvtolt
                            ,pr_nrdconta   => 9999999999
                            ,pr_vlindice   => vr_index_resgate     
                            ,pr_idcontrole => vr_idcontrole
                            ,pr_clobxml1   => vr_clobxml1
                            ,pr_dstexto1   => vr_dstexto1
                            ,pr_clobxml2   => vr_clobxml2
                            ,pr_dstexto2   => vr_dstexto2
                            ,pr_clobxml3   => vr_clobxml3
                            ,pr_dstexto3   => vr_dstexto3
                            ,pr_clobxml4   => vr_clobxml4
                            ,pr_dstexto4   => vr_dstexto4
                            ,pr_clobxml5   => vr_clobxml5
                            ,pr_dstexto5   => vr_dstexto5
                            ,pr_clobxml6   => vr_clobxml6
                            ,pr_dstexto6   => vr_dstexto6
                            ,pr_clobxml7   => vr_clobxml7
                            ,pr_dstexto7   => vr_dstexto7
                            ,pr_clobxml8   => vr_clobxml8
                            ,pr_dstexto8   => vr_dstexto8
                            ,pr_clobxml9   => vr_clobxml9
                            ,pr_dstexto9   => vr_dstexto9
                            ,pr_dscritic   => vr_dscritic
                            );
     
     
       IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;
     
     end if;
     
     commit;
     
     --Grava data fim para o JOB na tabela de LOG 
     pc_log_programa(pr_dstiplog   => 'F',    
                     pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                     pr_cdcooper   => pr_cdcooper, 
                     pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     pr_idprglog   => vr_idlog_ini_par,
                     pr_flgsucesso => 1);
    
    end if;--
    
    IF pr_idparale = 0 THEN
      
      IF vr_qtdjobs  > 0 THEN
        pc_carregar_valor_wrk( pr_cdcooper   => pr_cdcooper
                              ,pr_idcontrole => vr_idcontrole
                              ,pr_clobxml1   => vr_clobxml1
                              ,pr_dstexto1   => vr_dstexto1
                              ,pr_clobxml2   => vr_clobxml2
                              ,pr_dstexto2   => vr_dstexto2
                              ,pr_clobxml3   => vr_clobxml3
                              ,pr_dstexto3   => vr_dstexto3
                              ,pr_clobxml4   => vr_clobxml4
                              ,pr_dstexto4   => vr_dstexto4
                              ,pr_clobxml5   => vr_clobxml5
                              ,pr_dstexto5   => vr_dstexto5
                              ,pr_clobxml6   => vr_clobxml6
                              ,pr_dstexto6   => vr_dstexto6
                              ,pr_clobxml7   => vr_clobxml7
                              ,pr_dstexto7   => vr_dstexto7
                              ,pr_clobxml8   => vr_clobxml8
                              ,pr_dstexto8   => vr_dstexto8
                              ,pr_clobxml9   => vr_clobxml9
                              ,pr_dstexto9   => vr_dstexto9
                              ,pr_dscritic   => vr_dscritic
                              );
        
        IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;
      END IF;
      
    -- Fechar CLOBs
    pc_habilita_clob(2);

    --Gerar os relatorios
    FOR idx IN 1..9 LOOP 
      --Formulario Padrao
      vr_nmformul:= '80col';
      vr_qtcoluna:= 80;
      --Indicar se deve imprimir
      vr_flgimpri:= 'S';
      --Nodo Base para o XMl
      vr_dsnoxml:= '/'||vr_tab_nmarqimp(idx)||'/contas/conta';
      --Nome Arquivo Jasper
      vr_dsjasper:= vr_tab_nmarqimp(idx)||'.jasper';

      --Limpar o CLOB final responsavel pela impressao
      vr_clobxml:= empty_clob;
      --Copiar dados do Clob do relatorio para o Clob de impressao
      CASE idx 
        WHEN 1 THEN --crrl040
          vr_clobxml:= vr_clobxml1;
        WHEN 2 THEN --crrl044
          vr_clobxml:= vr_clobxml2;
        WHEN 3 THEN --crrl073
          vr_clobxml:= vr_clobxml3;
        WHEN 4 THEN --crrl088
          vr_clobxml:= vr_clobxml4;
        WHEN 5 THEN --crrl209
          vr_clobxml:= vr_clobxml5;
        WHEN 6 THEN --crrl370
          vr_clobxml:= vr_clobxml6;
        WHEN 7 THEN --crrl499
          vr_clobxml:= vr_clobxml7;
          vr_nmformul:= '132col';
          vr_qtcoluna:= 132;
        WHEN 8 THEN --crrl143
          vr_clobxml:= vr_clobxml8;
          --Nao deve imprimir
          vr_flgimpri:= 'N';
        WHEN 9 THEN --crrl143b
          vr_clobxml:= vr_clobxml9;
          --Nao deve imprimir
          vr_flgimpri:= 'N';
          --Path XML
          vr_dsnoxml:= '/'||vr_tab_nmarqimp(idx)||'b/contas/conta';
          --Nome do Jasper
          vr_dsjasper:= vr_tab_nmarqimp(idx)||'b.jasper';
      END CASE; 

      --Executar Relatorios
  		gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
	  	 												   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
		  												   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
			  											   ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
				  										   ,pr_dsxmlnode => vr_dsnoxml          --> Nó base do XML para leitura dos dados
					  									   ,pr_dsjasper  => vr_dsjasper         --> Arquivo de layout do iReport
						  								   ,pr_dsparams  => NULL                --> Sem parâmetros
							  							   ,pr_dsarqsaid => vr_nom_direto_rl||'/'||vr_tab_nmarqimp(idx)||'.lst' --> Arquivo final 
								  						   ,pr_qtcoluna  => vr_qtcoluna         --> 132/80 colunas
									  					   ,pr_flg_gerar => 'N'                 --> Geraçao na hora
										  				   ,pr_flg_impri => vr_flgimpri         --> Chamar a impressão (Imprim.p)
											  			   ,pr_nmformul  => vr_nmformul         --> Nome do formulário para impressão
												  		   ,pr_nrcopias  => vr_nrcopias         --> Número de cópias
													  	   ,pr_cdrelato  => to_number(substr(vr_tab_nmarqimp(idx),5,3)) --> Codigo do Relatorio
                                 ,pr_flappend  => 'S'                 --> Fazer append do relatorio se ja existir
													  	   ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF; 
    END LOOP; -- Imprimir os 9 arquivos

   
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
															
    ELSE
       -- Atualiza finalização do batch na tabela de controle 
       gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                           ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                           ,pr_dscritic   => vr_dscritic);  
                                               
       -- Encerrar o job do processamento paralelo dessa agência
       gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);
    
    END IF;
		-- commit final
		COMMIT;
    
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar COMMIT;
      COMMIT;
      
      if pr_idparale <> 0 then 
        --Grava LOG
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)

                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'WHEN OTHERS - pr_cdcritic:'||pr_cdcritic||CHR(13)||
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
      
      
      
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic:= NVL(vr_cdcritic, 0);
      pr_dscritic:= vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
      
      if pr_idparale <> 0 then 
        --Grava LOG
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'WHEN OTHERS - pr_cdcritic:'||pr_cdcritic||CHR(13)||
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
      
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic:= 0;
      pr_dscritic:= SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
      
      if pr_idparale <> 0 then 
        --Grava LOG
        pc_log_programa(PR_DSTIPLOG           => 'E',
                        PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => vr_tpexecucao,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_tpocorrencia       => 2,
                        pr_dsmensagem         => 'WHEN OTHERS - pr_cdcritic:'||pr_cdcritic||CHR(13)||
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
  END;

END pc_crps029;
/
