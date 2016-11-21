CREATE OR REPLACE PROCEDURE CECRED.pc_crps029 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Codigo Agencia
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
   Data    : Fevereiro/93.                       Ultima atualizacao: 04/07/2016

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
                      ,pr_nrdconta IN craplpp.nrdconta%TYPE) IS
    SELECT /*+ INDEX (lpp craplpp##craplpp4) */ 
           lpp.nrdconta
          ,lpp.nrctrrpp
          ,Count(*) qtlancmto
      FROM craplpp lpp
     WHERE lpp.cdcooper = pr_cdcooper
       AND lpp.cdhistor IN (158,496)
       AND lpp.dtmvtolt > pr_dtmvtolt
       AND lpp.nrdconta = pr_nrdconta
           GROUP BY lpp.nrdconta,lpp.nrctrrpp;
    rw_craplpp cr_craplpp%ROWTYPE;
                
    --Contar a quantidade de resgates das contas
    CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                            ,pr_nrdconta IN craplrg.nrdconta%TYPE) IS
    SELECT lrg.nrdconta
          ,lrg.nraplica
          ,COUNT(*) qtlancmto
      FROM craplrg lrg
     WHERE lrg.cdcooper = pr_cdcooper
       AND lrg.tpaplica = 4
       AND lrg.inresgat = 0
       AND lrg.nrdconta = pr_nrdconta      
           GROUP BY lrg.nrdconta,lrg.nraplica;
    rw_craplrg_saque cr_craplrg_saque%ROWTYPE;
    
    --Selecionar informacoes dos lancamentos de resgate
    CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                      ,pr_dtresgat IN craplrg.dtresgat%TYPE
                      ,pr_nrdconta IN craplrg.nrdconta%TYPE) IS
    SELECT lrg.nrdconta
          ,lrg.nraplica
          ,lrg.tpaplica
          ,lrg.tpresgat
          ,NVL(SUM(NVL(lrg.vllanmto,0)),0) vllanmto
      FROM craplrg lrg
     WHERE lrg.cdcooper = pr_cdcooper
       AND lrg.dtresgat <= pr_dtresgat
       AND lrg.inresgat = 0
       AND lrg.tpresgat = 1
       AND lrg.nrdconta = pr_nrdconta
       GROUP BY lrg.nrdconta
               ,lrg.nraplica
               ,lrg.tpaplica
               ,lrg.tpresgat;        
    rw_craplrg cr_craplrg%ROWTYPE;
        
    -- Cursor para busca de associados
    CURSOR cr_crapext (pr_cdcooper crapcop.cdcooper%TYPE) IS
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
       FROM crapext crapext
       WHERE crapext.cdcooper = pr_cdcooper
       AND   crapext.insitext = 0  
       ORDER BY crapext.cdcooper,crapext.tpextrat,crapext.nrdconta,crapext.progress_recid;
      
    
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
  
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
    -- habilitar CLOBs
    pc_habilita_clob(1);

    -- Busca do diretório base da cooperativa para a geração de relatórios
	  vr_nom_direto_rl:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
							    									   	    ,pr_cdcooper => pr_cdcooper   --> Cooperativa
							  	   									      ,pr_nmsubdir => 'rl');        --> Utilizaremos o rl
    

		/*  Leitura Arquivo de contas que deverao ter seus extratos impressos.  */
    FOR rw_crapext IN cr_crapext (pr_cdcooper => pr_cdcooper) LOOP   -- Cod. Cooperativa

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
                       ,pr_nrdconta => rw_crapext.nrdconta);
                       
        FETCH cr_craplpp INTO rw_craplpp;
        
        IF cr_craplpp%FOUND THEN              

			--Fechar o cursor
			CLOSE cr_craplpp;
        
			--Se possuir mais de 3 registros
			IF rw_craplpp.qtlancmto > 3 THEN                                     
			  -- Montar indice para acessar tabela
			  vr_index_craplpp:= LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
			  -- Atribuir quantidade encontrada de cada conta ao vetor
			  vr_tab_craplpp(vr_index_craplpp):= rw_craplpp.qtlancmto;
			END IF;               
        
		ELSE
			--Fechar o cursor
			CLOSE cr_craplpp;
        		               
		END IF;

        -- Busca registro com total de resgates na poupanca
        OPEN cr_craplrg_saque(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapext.nrdconta);
                       
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
                       ,pr_nrdconta => rw_crapext.nrdconta);
                       
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
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic:= 0;
      pr_dscritic:= SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps029;
/
