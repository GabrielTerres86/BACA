CREATE OR REPLACE PACKAGE CECRED.TELA_ADITIV IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ADITIV
  --  Sistema  : Rotinas utilizadas pela Tela ADITIV
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  --
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ADITIV
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  --> Descricao dos tipo de aditivos
  TYPE typ_dsaditiv IS VARRAY(8) OF VARCHAR2(40);
  vr_tab_dsaditiv typ_dsaditiv := typ_dsaditiv('1- Alteracao Data do Debito',
                                               '2- Aplicacao Vinculada',
                                               '3- Aplicacao Vinculada Terceiro',
                                               '4- Inclusao de Fiador/Avalista',
                                               '5- Substituicao de Veiculo',
                                               '6- Interveniente Garantidor Veiculo',
                                               '7- Sub-rogacao - C/ Nota Promissoria',
                                               '8- Sub-rogacao - S/ Nota Promissoria');
  
  
  TYPE typ_rec_promis 
       IS RECORD(nrpromis crapadi.nrpromis%TYPE,
                 vlpromis crapadi.vlpromis%TYPE);
  TYPE typ_tab_promis IS TABLE OF typ_rec_promis 
       INDEX BY PLS_INTEGER; 
  
  --  type para armazenar dados do aditivo (antiga b1wgen0115tt.i - tt-aditiv)
  TYPE typ_rec_aditiv 
       IS RECORD ( cdaditiv crapadt.cdaditiv%TYPE,
                   nraditiv crapadt.nraditiv%TYPE,
                   nrdconta crapadt.nrdconta%TYPE,
                   nrctremp crapadt.nrctremp%TYPE,
                   dsaditiv VARCHAR2(40),
                   dtmvtolt crapadt.dtmvtolt%TYPE,
                   nrctagar crapadt.nrctagar%TYPE,
                   nrcpfgar crapadt.nrcpfgar%TYPE,
                   nrdocgar crapadt.nrdocgar%TYPE,
                   nmdgaran crapadt.nmdgaran%TYPE,
                   promis   typ_tab_promis,
                   flgpagto crapadi.flgpagto%TYPE,
                   dtdpagto crapadi.dtdpagto%TYPE,
                   dsbemfin crapadi.dsbemfin%TYPE,
                   dschassi crapadi.dschassi%TYPE,
                   nrdplaca crapadi.nrdplaca%TYPE,
                   dscorbem crapadi.dscorbem%TYPE,
                   nranobem crapadi.nranobem%TYPE,
                   nrmodbem crapadi.nrmodbem%TYPE,
                   nrrenava crapadi.nrrenava%TYPE,
                   tpchassi crapadi.tpchassi%TYPE,
                   ufdplaca crapadi.ufdplaca%TYPE,
                   uflicenc crapadi.uflicenc%TYPE,
                   nmdavali crapadi.nmdavali%TYPE,
                   tpdescto crapepr.tpdescto%TYPE,
                   dscpfavl VARCHAR2(50),
                   nrcpfcgc crapadi.nrcpfcgc%TYPE,
                   nrsequen INTEGER,
                   idseqbem crapbpr.idseqbem%TYPE);
  TYPE typ_tab_aditiv IS TABLE OF typ_rec_aditiv
       INDEX BY PLS_INTEGER;
            
  --  type para armazenar dados da aplicacoes (antiga b1wgen0115tt.i - tt-aplicacoes)
  TYPE typ_rec_aplicacoes 
       IS RECORD (nraplica craprda.nraplica%TYPE,
                  dtmvtolt craprda.dtmvtolt%TYPE,
                  dshistor craphis.dshistor%TYPE,
                  nrdocmto craplap.nrdocmto%TYPE,
                  dtvencto craprda.dtvencto%TYPE,
                  vlsldapl craprda.vlsdrdca%TYPE,
                  sldresga craprda.vlsdrdca%TYPE,
                  flgselec INTEGER,
                  tpaplica craprda.tpaplica%TYPE,
                  vlaplica craprda.vlaplica%TYPE,
                  tpproapl INTEGER);
  TYPE typ_tab_aplicacoes IS TABLE OF typ_rec_aplicacoes
       INDEX BY PLS_INTEGER;
       
  TYPE typ_tab_clausula IS TABLE OF VARCHAR2(4000)
       INDEX BY PLS_INTEGER;
       
  TYPE typ_rec_clausula 
      IS RECORD (clausula typ_tab_clausula);
      
  TYPE typ_tab_clau_adi IS TABLE OF typ_rec_clausula
       INDEX BY PLS_INTEGER;
       
       
  ----------------------------------- ROTINAS -------------------------------
  --> Gerar a impressao do contrato de aditivo
  PROCEDURE pc_gera_impressao_aditiv 
                          ( pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                           ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                           ,pr_idorigem   IN INTEGER               --> Origem 
                           ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo do programa
                           ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                           ,pr_dsiduser   IN VARCHAR2              --> id do usuario
                           ,pr_cdaditiv   IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                           ,pr_nraditiv   IN crapadt.nraditiv%TYPE --> Numero do aditivo
                           ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                           ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                           --------> OUT <--------
                           ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                           ,pr_cdcritic  OUT PLS_INTEGER           --> C�digo da cr�tica
                           ,pr_dscritic  OUT VARCHAR2    );        --> Descri��o da cr�tica
END TELA_ADITIV;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ADITIV IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ADITIV
  --  Sistema  : Rotinas utilizadas pela Tela ADITIV
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ADITIV
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  --> Retornar QRcode para digitaliza��o
  FUNCTION fn_qrcode_digitaliz (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                pr_nrdconta IN crapass.nrdconta%TYPE,
                                pr_cdagenci IN crapage.cdagenci%TYPE,
                                pr_nrborder IN NUMBER,
                                pr_nrcontra IN NUMBER,
                                pr_nraditiv IN NUMBER,
                                pr_cdtipdoc IN INTEGER )RETURN VARCHAR2 IS
  /*
    O QR Code possui a seguinte estrutura:
      � Cooperativa;
      � PA onde a opera��o de cr�dito foi efetivada; (epr.cdagenci, lim.cdageori)
      � ContaCorrente do Cooperado;
      � N�mero do Border�, possui o valor 0 (zero) quando o tipo de documento for um contrato (1,3,5,19)
      e/ou aditivo (18), conforme c�digos cadastrados na tela TAB093.
      � N�mero do Contrato, possui o valor 0 (zero) quando o tipo de documento for um border� (2,4);
      � N�mero do Aditivo, possui o valor 0 (zero) quando o tipo de documento for um border� (2,4) ou
      contrato de limite de cr�dito (19). Quando tiver valor obrigatoriamente tem um contrato. 
      � Tipo do Documento
      
      Valor a serem utilizados no campo Tipo de Documento:
      84 - Limite de Cr�dito;
      85 - Limite de Desconto de T�tulo;
      86 - Limite de Desconto de Cheque;
      87 - Border� de Cheque
      88 - Border� de T�tulo
      89 - Empr�stimo/Financiamento;
      102 - Aditivos de Contrato de Empr�stimo */
  
    vr_qrcode VARCHAR2(100);
  BEGIN
  
    vr_qrcode := pr_cdcooper ||'_'||
                 pr_cdagenci ||'_'||
                 TRIM(gene0002.fn_mask_conta(pr_nrdconta))   ||'_'||
                 TRIM(gene0002.fn_mask_contrato(pr_nrborder))||'_'||
                 TRIM(gene0002.fn_mask_contrato(pr_nrcontra))||'_'||
                 pr_nraditiv ||'_'||
                 pr_cdtipdoc;
    RETURN vr_qrcode;
  END;
  
  --> buscar as aplicacooes do aditivo
  PROCEDURE pc_buscar_aplicacoes (pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                                 ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                                 ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                                 ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                                 ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                                 ,pr_idorigem   IN INTEGER               --> Origem 
                                 ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                 ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                                 ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                                 ,pr_cddopcao   IN VARCHAR2              --> Codigo da opcao
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta                                 
                                 ,pr_tpaplica   IN craprda.tpaplica%TYPE --> tipo de aplicacao
                                 ,pr_nraplica   IN crapadi.nraplica%TYPE --> Numero da aplicacao
                                 --------> OUT <--------
                                 ,pr_tab_aplicacoes IN OUT typ_tab_aplicacoes  --> Retornar dados das aplica��es 
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> C�digo da cr�tica
                                 ,pr_dscritic  OUT VARCHAR2    ) IS      --> Descri��o da cr�tica
  
  
    ------------>> CURSORES <<-----------
    
    -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
    CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE
                      ,pr_nrdconta IN crapcop.nrdconta%TYPE) IS
      SELECT lpp.nrdconta
            ,lpp.nrctrrpp
            ,Count(*) qtlancmto
      FROM craplpp lpp
      WHERE lpp.cdcooper = pr_cdcooper
      AND lpp.cdhistor IN (158,496)
      AND lpp.dtmvtolt > pr_dtmvtolt
      AND lpp.nrdconta = pr_nrdconta
      GROUP BY lpp.nrdconta,lpp.nrctrrpp;

    --Contar a quantidade de resgates das contas
    CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                            ,pr_nrdconta IN crapcop.nrdconta%TYPE) IS
      SELECT lrg.nrdconta
            ,lrg.nraplica
            ,COUNT(*) qtlancmto
      FROM craplrg lrg
      WHERE lrg.cdcooper = pr_cdcooper
      AND lrg.tpaplica = 4
      AND lrg.inresgat = 0
      AND lrg.nrdconta = pr_nrdconta
      GROUP BY lrg.nrdconta,lrg.nraplica;

    --Selecionar informacoes dos lancamentos de resgate
    CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                      ,pr_dtresgat IN craplrg.dtresgat%TYPE
                      ,pr_nrdconta IN crapcop.nrdconta%TYPE) IS
      SELECT lrg.nrdconta
            ,lrg.nraplica
            ,lrg.tpaplica
            ,lrg.tpresgat
            ,NVL(SUM(NVL(lrg.vllanmto,0)),0) vllanmto
      FROM craplrg lrg
      WHERE lrg.cdcooper = pr_cdcooper
      AND   lrg.dtresgat <= pr_dtresgat
      AND   lrg.inresgat = 0
      AND   lrg.tpresgat = 1
      AND lrg.nrdconta = pr_nrdconta
      GROUP BY lrg.nrdconta
              ,lrg.nraplica
              ,lrg.tpaplica
              ,lrg.tpresgat;
         
      
    ----------->>> VARIAVEIS <<<--------    
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_des_reto        VARCHAR2(1000);        --> Retorno
    vr_tab_erro        gene0001.typ_tab_erro;
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;
    
    vr_tab_saldo_rdca  APLI0001.typ_tab_saldo_rdca; 
    vr_vlsldapl        NUMBER;
    vr_tab_aplica      apli0005.typ_tab_aplicacao;
    vr_idxrdca         PLS_INTEGER;
    vr_idxaplic        PLS_INTEGER;
    
    -- TempTables para APLI0001.pc_consulta_poupanca
    vr_tab_ctablq      APLI0001.typ_tab_ctablq;
    vr_tab_craplpp     APLI0001.typ_tab_craplpp;
    vr_tab_craplrg     APLI0001.typ_tab_craplpp;
    vr_tab_resgate     APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp   APLI0001.typ_tab_dados_rpp;
    vr_index_craplpp   VARCHAR2(20);
    vr_index_craplrg   VARCHAR2(20);
    vr_index_resgate   VARCHAR2(25);
    vr_percenir        NUMBER;
    vr_vlsldppr        NUMBER;
    
    
    
  BEGIN
    IF pr_tpaplica = 0 THEN
      -- apensa sair do programa
      RAISE vr_exc_sucesso;
          
    ELSIF pr_tpaplica = 1 THEN
          
      -- limpa as PLTABLES
      vr_tab_ctablq.DELETE;
      vr_tab_craplpp.DELETE;
      vr_tab_craplrg.DELETE;
      vr_tab_resgate.DELETE;

      -- Carregar tabela de memoria de contas bloqueadas
      TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_tab_cta_bloq => vr_tab_ctablq);

      -- Carregar tabela de memoria de lancamentos na poupanca
      FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => pr_dtmvtolt - 180
                                   ,pr_nrdconta => pr_nrdconta) LOOP
        --Se possuir mais de 3 registros
        IF rw_craplpp.qtlancmto > 3 THEN
          -- Montar indice para acessar tabela
          vr_index_craplpp:= LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
          -- Atribuir quantidade encontrada de cada conta ao vetor
          vr_tab_craplpp(vr_index_craplpp):= rw_craplpp.qtlancmto;
        END IF;
      END LOOP;

      -- Carregar tabela de memoria com total de resgates na poupanca
      FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta) LOOP
        -- Montar Indice para acesso quantidade lancamentos de resgate
        vr_index_craplrg:= LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
        -- Popular tabela de memoria
        vr_tab_craplrg(vr_index_craplrg):= rw_craplrg.qtlancmto;
      END LOOP;

      -- Carregar tabela de mem�ria com total resgatado por conta e aplicacao
      FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                   ,pr_dtresgat => pr_dtmvtopr
                                   ,pr_nrdconta => pr_nrdconta) LOOP
        -- Montar indice para selecionar total dos resgates na tabela auxiliar
        vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0') ||
                            LPad(rw_craplrg.tpaplica,05,'0') ||
                            LPad(rw_craplrg.nraplica,10,'0');
        -- Popular a tabela de memoria com a soma dos lancamentos de resgate
        vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
        vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
      END LOOP;
          
      -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
      vr_percenir:= GENE0002.fn_char_para_number
                          (TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'CONFIG'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'PERCIRAPLI'
                                                     ,pr_tpregist => 0));
        
      --Executar rotina consulta poupanca
      apli0001.pc_consulta_poupanca (pr_cdcooper => pr_cdcooper            --> Cooperativa 
                                    ,pr_cdagenci => pr_cdagenci            --> Codigo da Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa            --> Numero do caixa 
                                    ,pr_cdoperad => pr_cdoperad            --> Codigo do Operador
                                    ,pr_idorigem => pr_idorigem            --> Identificador da Origem
                                    ,pr_nrdconta => pr_nrdconta            --> Nro da conta associado
                                    ,pr_idseqttl => 1                      --> Identificador Sequencial
                                    ,pr_nrctrrpp => pr_nraplica            --> Contrato Poupanca Programada 
                                    ,pr_dtmvtolt => pr_dtmvtolt            --> Data do movimento atual
                                    ,pr_dtmvtopr => pr_dtmvtopr            --> Data do proximo movimento
                                    ,pr_inproces => pr_inproces            --> Indicador de processo
                                    ,pr_cdprogra => pr_nmdatela            --> Nome do programa chamador
                                    ,pr_flgerlog => FALSE                  --> Flag erro log
                                    ,pr_percenir => vr_percenir            --> % IR para Calculo Poupanca
                                    ,pr_tab_craptab   => vr_tab_ctablq     --> Tipo de tabela de Conta Bloqueada
                                    ,pr_tab_craplpp   => vr_tab_craplpp    --> Tipo de tabela com lancamento poupanca
                                    ,pr_tab_craplrg   => vr_tab_craplrg    --> Tipo de tabela com resgates
                                    ,pr_tab_resgate   => vr_tab_resgate    --> Tabela com valores dos resgates das contas por aplicacao
                                    ,pr_vlsldrpp      => vr_vlsldppr       --> Valor saldo poupanca programada
                                    ,pr_retorno       => vr_des_reto       --> Descricao de erro ou sucesso OK/NOK 
                                    ,pr_tab_dados_rpp => vr_tab_dados_rpp  --> Poupancas Programadas
                                    ,pr_tab_erro      => vr_tab_erro);     --> Saida com erros;
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
            
        RAISE vr_exc_erro;      
      END IF;
          
      --Ler valores de retorno
      IF vr_tab_dados_rpp.count > 0 THEN
        FOR idx IN vr_tab_dados_rpp.first..vr_tab_dados_rpp.last LOOP
            
          -- Buscar as aplica��es que possua saldo e nao estejam bloqueadas
          IF vr_tab_dados_rpp(idx).vlsdrdpp > 0 AND
             vr_tab_dados_rpp(idx).dsblqrpp <> 'SIM' THEN
                
            vr_idxaplic := pr_tab_aplicacoes.count + 1;
            pr_tab_aplicacoes(vr_idxaplic).nraplica := vr_tab_dados_rpp(idx).nrctrrpp;
            pr_tab_aplicacoes(vr_idxaplic).dtmvtolt := vr_tab_dados_rpp(idx).dtmvtolt;
            pr_tab_aplicacoes(vr_idxaplic).dshistor := 'P.PROG ';
            pr_tab_aplicacoes(vr_idxaplic).vlaplica := vr_tab_dados_rpp(idx).vlprerpp;
            pr_tab_aplicacoes(vr_idxaplic).nrdocmto := vr_tab_dados_rpp(idx).nrctrrpp;
            pr_tab_aplicacoes(vr_idxaplic).dtvencto := vr_tab_dados_rpp(idx).dtvctopp;
            
            IF pr_cddopcao = 'I' THEN
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_dados_rpp(idx).vlsdrdpp;
              pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_dados_rpp(idx).vlrgtrpp;
              pr_tab_aplicacoes(vr_idxaplic).tpaplica := 1;
              pr_tab_aplicacoes(vr_idxaplic).tpproapl := 2;   
            ELSE
              IF vr_tab_dados_rpp(idx).vlsdrdpp > 0 THEN
                pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_dados_rpp(idx).vlsdrdpp;
              ELSE
                pr_tab_aplicacoes(vr_idxaplic).vlsldapl := 0;
              END IF;
              
              IF vr_tab_dados_rpp(idx).vlrgtrpp > 0 THEN
                pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_dados_rpp(idx).vlrgtrpp;
              ELSE
                pr_tab_aplicacoes(vr_idxaplic).sldresga := 0;
              END IF;
            END IF;
            
          END IF;                           
        END LOOP;
      END IF;
        
    ELSE
  
      --Obtem Dados Aplicacoes
      APLI0002.pc_obtem_dados_aplicacoes (pr_cdcooper    => pr_cdcooper          --Codigo Cooperativa
                                         ,pr_cdagenci    => pr_cdagenci          --Codigo Agencia
                                         ,pr_nrdcaixa    => pr_nrdcaixa          --Numero do Caixa
                                         ,pr_cdoperad    => pr_cdoperad          --Codigo Operador
                                         ,pr_nmdatela    => pr_nmdatela          --Nome da Tela
                                         ,pr_idorigem    => pr_idorigem          --Origem dos Dados
                                         ,pr_nrdconta    => pr_nrdconta          --Numero da Conta do Associado
                                         ,pr_idseqttl    => 1                    --Sequencial do Titular
                                         ,pr_nraplica    => pr_nraplica          --Numero da Aplicacao
                                         ,pr_cdprogra    => pr_nmdatela          --Nome da Tela
                                         ,pr_flgerlog    => 0 /*FALSE*/          --Imprimir log
                                         ,pr_dtiniper    => NULL                 --Data Inicio periodo   
                                         ,pr_dtfimper    => NULL                 --Data Final periodo
                                         ,pr_vlsldapl    => vr_vlsldapl          --Saldo da Aplicacao
                                         ,pr_tab_saldo_rdca  => vr_tab_saldo_rdca    --Tipo de tabela com o saldo RDCA
                                         ,pr_des_reto    => vr_des_reto          --Retorno OK ou NOK
                                         ,pr_tab_erro    => vr_tab_erro);        --Tabela de Erros
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        --Se possuir erro na temp-table
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Nao foi possivel carregar o aplicacoes.';      
        END IF; 
              
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
              
        RAISE vr_exc_erro;
      END IF; 
            
      IF pr_tpaplica IN (7 ,8) THEN
        -- Consulta de novas aplicacoes
        apli0005.pc_busca_aplicacoes(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
                                    ,pr_cdoperad   => pr_cdoperad     --> C�digo do Operador
                                    ,pr_nmdatela   => pr_nmdatela     --> Nome da Tela
                                    ,pr_idorigem   => pr_idorigem     --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                    ,pr_nrdconta   => pr_nrdconta     --> N�mero da Conta
                                    ,pr_idseqttl   => 1               --> Titular da Conta
                                    ,pr_nraplica   => pr_nraplica     --> N�mero da Aplica��o - Par�metro Opcional
                                    ,pr_cdprodut   => 0               --> C�digo do Produto � Par�metro Opcional 
                                    ,pr_dtmvtolt   => pr_dtmvtolt     --> Data de Movimento
                                    ,pr_idconsul   => 0               --> Identificador de Consulta (0 � Ativas / 1 � Encerradas / 2 � Todas)
                                    ,pr_idgerlog   => 0               --> Identificador de Log (0 � N�o / 1 � Sim) 																 
                                    ,pr_cdcritic   => vr_cdcritic     --> C�digo da cr�tica
                                    ,pr_dscritic   => vr_dscritic     --> Descri��o da cr�tica
                                    ,pr_tab_aplica => vr_tab_aplica); --> Tabela com os dados da aplica��o );

        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        IF vr_tab_aplica.count > 0 THEN
          FOR idx in vr_tab_aplica.first..vr_tab_aplica.last LOOP
            IF pr_cddopcao = 'I'  AND 
               vr_tab_aplica(idx).idblqrgt > 0 THEN
              continue;
            END IF;  
          
            vr_idxrdca := vr_tab_saldo_rdca.count + 1;
            vr_tab_saldo_rdca(vr_idxrdca).dsaplica := vr_tab_aplica(idx).dsnomenc;
            vr_tab_saldo_rdca(vr_idxrdca).vlsdrdad := vr_tab_aplica(idx).vlsldrgt;
            vr_tab_saldo_rdca(vr_idxrdca).vllanmto := vr_tab_aplica(idx).vlsldtot;
            vr_tab_saldo_rdca(vr_idxrdca).vlaplica := vr_tab_aplica(idx).vlaplica;
            vr_tab_saldo_rdca(vr_idxrdca).dtvencto := vr_tab_aplica(idx).dtvencto;
            vr_tab_saldo_rdca(vr_idxrdca).indebcre := vr_tab_aplica(idx).dsblqrgt;
            vr_tab_saldo_rdca(vr_idxrdca).cdoperad := vr_tab_aplica(idx).cdoperad;
            vr_tab_saldo_rdca(vr_idxrdca).sldresga := vr_tab_aplica(idx).vlsldrgt;
            vr_tab_saldo_rdca(vr_idxrdca).qtdiaapl := vr_tab_aplica(idx).qtdiaapl;
            vr_tab_saldo_rdca(vr_idxrdca).qtdiauti := vr_tab_aplica(idx).qtdiacar;
            vr_tab_saldo_rdca(vr_idxrdca).txaplmax := vr_tab_aplica(idx).txaplica;
            vr_tab_saldo_rdca(vr_idxrdca).txaplmin := vr_tab_aplica(idx).txaplica;
            vr_tab_saldo_rdca(vr_idxrdca).tpaplrdc := vr_tab_aplica(idx).idtippro;
            IF vr_tab_aplica(idx).idtippro = 1 THEN
              vr_tab_saldo_rdca(vr_idxrdca).tpaplica := 7;
            ELSE
              vr_tab_saldo_rdca(vr_idxrdca).tpaplica := 8;
            END IF;  
            vr_tab_saldo_rdca(vr_idxrdca).dtmvtolt := vr_tab_aplica(idx).dtmvtolt;
            vr_tab_saldo_rdca(vr_idxrdca).nrdocmto := vr_tab_aplica(idx).nraplica;
            vr_tab_saldo_rdca(vr_idxrdca).nraplica := vr_tab_aplica(idx).nraplica;
            vr_tab_saldo_rdca(vr_idxrdca).idtipapl := 'N';
            vr_tab_saldo_rdca(vr_idxrdca).dshistor := vr_tab_aplica(idx).dsnomenc;
          
          END LOOP;
        END IF;                    
      END IF; --> Fim IF pr_tpaplica IN (7 ,8) 
      
      IF vr_tab_saldo_rdca.count > 0 THEN
        FOR idx IN vr_tab_saldo_rdca.first..vr_tab_saldo_rdca.last LOOP
          -- Inclusao apresenta todos que possuen valor saldo
          IF pr_cddopcao = 'I' THEN
            IF vr_tab_saldo_rdca(idx).tpaplica = pr_tpaplica AND
               vr_tab_saldo_rdca(idx).vllanmto > 0           AND
               vr_tab_saldo_rdca(idx).indebcre <> 'B'        THEN
               
              vr_idxaplic := pr_tab_aplicacoes.count + 1;
              pr_tab_aplicacoes(vr_idxaplic).nraplica := vr_tab_saldo_rdca(idx).nraplica;
              pr_tab_aplicacoes(vr_idxaplic).dtmvtolt := vr_tab_saldo_rdca(idx).dtmvtolt;
              pr_tab_aplicacoes(vr_idxaplic).dshistor := vr_tab_saldo_rdca(idx).dsaplica;
              pr_tab_aplicacoes(vr_idxaplic).vlaplica := vr_tab_saldo_rdca(idx).vlaplica;
              pr_tab_aplicacoes(vr_idxaplic).nrdocmto := vr_tab_saldo_rdca(idx).nrdocmto;
              pr_tab_aplicacoes(vr_idxaplic).dtvencto := vr_tab_saldo_rdca(idx).dtvencto;
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_saldo_rdca(idx).vllanmto;
              pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_saldo_rdca(idx).sldresga;
              pr_tab_aplicacoes(vr_idxaplic).tpaplica := pr_tpaplica;
              IF vr_tab_saldo_rdca(idx).idtipapl = 'N' THEN
                pr_tab_aplicacoes(vr_idxaplic).tpproapl := 1;
              ELSE
                pr_tab_aplicacoes(vr_idxaplic).tpproapl := 2; 
              END if;  
            END IF;
          -- demais apresenta a aplicacao idependente do valor
          ELSE
            vr_idxaplic := pr_tab_aplicacoes.count + 1;
            pr_tab_aplicacoes(vr_idxaplic).nraplica := vr_tab_saldo_rdca(idx).nraplica;
            pr_tab_aplicacoes(vr_idxaplic).dtmvtolt := vr_tab_saldo_rdca(idx).dtmvtolt;
            pr_tab_aplicacoes(vr_idxaplic).dshistor := vr_tab_saldo_rdca(idx).dsaplica;
            pr_tab_aplicacoes(vr_idxaplic).vlaplica := vr_tab_saldo_rdca(idx).vlaplica;
            pr_tab_aplicacoes(vr_idxaplic).nrdocmto := vr_tab_saldo_rdca(idx).nrdocmto;
            pr_tab_aplicacoes(vr_idxaplic).dtvencto := vr_tab_saldo_rdca(idx).dtvencto;
            IF vr_tab_saldo_rdca(idx).vllanmto > 0 THEN 
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_saldo_rdca(idx).vllanmto;
            ELSE
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := 0;
            END IF;
            
            IF vr_tab_saldo_rdca(idx).sldresga > 0 THEN
              pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_saldo_rdca(idx).sldresga;
            ELSE
              pr_tab_aplicacoes(vr_idxaplic).sldresga := 0;
            END IF;
            
          END IF;           
        END LOOP;
      END IF;
    END IF;  
    
    
  EXCEPTION   
    WHEN vr_exc_sucesso THEN
      NULL; --> Apenas retornar para programa chamador 
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
            
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na pc_buscar_aplicacoes: ' || SQLERRM;  
  END pc_buscar_aplicacoes;
  
  --> Carregar clausulas do contrato
  PROCEDURE pc_carrega_clausulas (pr_ddmvtolt IN VARCHAR2,
                                  pr_dsddmvto IN VARCHAR2,
                                  pr_dtdpagto IN DATE,
                                  pr_nrctremp IN NUMBER, 
                                  pr_cdc      IN VARCHAR2,
                                  pr_dsaplica IN VARCHAR2,
                                  pr_nmprimtl IN VARCHAR2,
                                  pr_nrdconta IN NUMBER ,
                                  pr_dscpfgar IN VARCHAR2,
                                  pr_nmprigar IN VARCHAR2,
                                  pr_nrctagar IN NUMBER,
                                  pr_nmdavali IN VARCHAR2,
                                  pr_dscpfavl IN VARCHAR2,
                                  pr_nrctaavl IN NUMBER,
                                  --> automovel
                                  pr_dsbemfin IN VARCHAR2,
                                  pr_nrrenava IN VARCHAR2,
                                  pr_tpchassi IN VARCHAR2,
                                  pr_nrdplaca IN VARCHAR2,
                                  pr_ufdplaca IN VARCHAR2,
                                  pr_dscorbem IN VARCHAR2,
                                  pr_nranobem IN VARCHAR2,
                                  pr_nrmodbem IN VARCHAR2,
                                  pr_uflicenc IN VARCHAR2,
                                  pr_dscpfpro IN VARCHAR2,
                                  pr_tab_clau_adi OUT typ_tab_clau_adi) IS
  
    vr_tab_clau_adi typ_tab_clau_adi;
    vr_dscontra VARCHAR2(100);
  BEGIN
    
    IF pr_cdc = 'N' THEN
      vr_dscontra := '/Contrato de Credito Simplificado';    
    END IF;
  
    vr_tab_clau_adi.delete;
    
    --> Tipo 1 - Alteracao Data do Debito
    vr_tab_clau_adi(1).clausula(1) 
                       := 'CLAUSULA PRIMEIRA - Altera��o da data de pagamento, prevista no item 1.9. da ' ||
                          'C�dula de Credito Banc�rio ou item 4.3. do Termo de Ades�o ao Contrato de ' ||
                          'Credito Simplificado, que passa a vigorar com a seguinte reda��o: debito em '||
                          'conta corrente sempre no dia '|| pr_ddmvtolt || pr_dsddmvto;
                          
    vr_tab_clau_adi(1).clausula(2) 
                       := 'CLAUSULA SEGUNDA - Altera��o da data de vencimento da primeira parcela/debito, '||
                          'prevista no item 1.10. da C�dula de Credito Banc�rio ou item 4.4. do '||
                          'Termo de Ades�o ao Contrato de Credito Simplificado, que passa a ser '||
                          to_char(pr_dtdpagto,'DD/MM/RRRR') ||'.';
  
    vr_tab_clau_adi(1).clausula(3) 
                       := 'CLAUSULA TERCEIRA - Em fun��o da altera��o da data do vencimento fica '||
                          'automaticamente prorrogado o prazo de vig�ncia e o numero de presta��es estabelecidas '||
                          'no item 1.7. da C�dula de Credito Banc�rio ou item 4.2. do Termo de Ades�o ao '||
                          'Contrato de Credito Simplificado, gerando saldo remanescente a ser liquidado pelo ' ||
                          'Emitente/Cooperado(a) e Devedores Solid�rios.';
                       
    vr_tab_clau_adi(1).clausula(4) 
                       := 'CLAUSULA QUARTA - Ficam ratificadas todas as demais condi��es da C�dula de Credito ' ||
                          'Banc�rio/Contrato de Credito Simplificado ora aditado (a), em ' ||
                          'tudo o que n�o expressamente modificado no presente termo.';

                      
  
    --> Tipo 2- Aplicacao Vinculada
    vr_tab_clau_adi(2).clausula(1) 
                       := 'CLAUSULA PRIMEIRA - O Emitente/Cooperado(a) compromete-se a manter em aplica��o(�es) '||
                          'financeiras perante esta Cooperativa de Credito, valor que somado ao saldo das '||
                          'cotas de capital do mesmo, atinjam no m�nimo o equivalente ao saldo da divida em '||
                          'dinheiro, certa, liquida e exig�vel emprestado na C�dula de Credito Banc�rio'||vr_dscontra ||
                          ' n. '|| pr_nrctremp || ', ate a sua total liquida��o.';
    
    vr_tab_clau_adi(2).clausula(2) 
                       := 'CLAUSULA SEGUNDA - A(s) aplica��o(�es) com o(s) numero(s) '||
                          pr_dsaplica ||', mantida(s) pelo Emitente/Cooperado(a) junto a Cooperativa, '||
                          'tornar-se-�(ao) aplica��o(�es) vinculada(s) ate que se cumpram todas as '||
                          'obriga��es assumidas na C�dula de Credito Banc�rio'||vr_dscontra ||' original.';
                       
    vr_tab_clau_adi(2).clausula(3) 
                       := 'CLAUSULA TERCEIRA - O n�o cumprimento das obrigacoes assumidas no presente termo '||
                          'aditivo e na C�dula de Credito Banc�rio'|| vr_dscontra ||' principal, '||
                          'bem com o inadimplemento de 02 (duas) presta��es mensais consecutivas '||
                          'ou alternadas, independentemente de qualquer notifica��o judicial ou ' ||
                          'extrajudicial, implicara no vencimento antecipado de todo o saldo devedor do '||
                          'empr�stimo/financiamento servindo a(s) referida(s) aplica��o(�es) vinculada(s) para a '||
                          'imediata liquida��o do saldo devedor.';
  
    vr_tab_clau_adi(2).clausula(4) 
                       := 'CLAUSULA QUARTA - Caso a(s) aplica��o(�es) venham a ser utilizada(s) para liquida��o ' ||
                          'do saldo devedor do empr�stimo/financiamento, a(s) mesma(s) poder�o '||
                          'ser movimentada(s) livremente pela Cooperativa, a qualquer tempo, independente de '||
                          'notifica��o judicial ou extrajudicial.';
    
    vr_tab_clau_adi(2).clausula(5) 
                       := 'CLAUSULA QUINTA - A(s) aplica��o(�es) acima enumarada(s), podera(�o) ser liberada(s) '||
                          'parcialmente, e se poss�vel, a medida que o  saldo devedor do ' ||
                          'empr�stimo/financiamento for sendo liquidado.'; 
  
    vr_tab_clau_adi(2).clausula(6) 
                       := 'CLAUSULA SEXTA - Ficam ratificadas todas as demais condi��es da C�dula de Credito ' ||
                          'Bancario'||vr_dscontra ||' ora aditado(a), em tudo o que n�o expressamente modificado no presente termo.';
 
  
  
    --> Tipo 3- Aplicacao Vinculada Terceiro
    vr_tab_clau_adi(3).clausula(1) 
                       := 'CLAUSULA PRIMEIRA - Para garantir o cumprimento das obriga��es assumidas na C�dula de '||
                          'Credito Banc�rio'||vr_dscontra ||' ora aditado(a), '||
                          'comparece como Interveniente Garantidor(a) '|| pr_nmprigar || 
                          ', inscrito no CPF/CNPJ sob o n. '|| pr_dscpfgar ||', titular da conta corrente '|| pr_nrctagar ||
                          ', mantida perante esta Cooperativa.';
      
    vr_tab_clau_adi(3).clausula(2) 
                       := 'CLAUSULA SEGUNDA - O(A) Interveniente Garantidor(a) compromete-se a manter em '||
                          'aplica��o(�es) financeiras perante esta Cooperativa de Credito, valor ' ||
                          'que somado ao saldo das cotas de capital do mesmo, atinjam no m�nimo ' ||
                          'o equivalente ao saldo da divida em dinheiro, certa, liquida e exig�vel emprestado ' ||
                          'na C�dula de Credito Banc�rio'||vr_dscontra ||', ate a sua total ' ||
                          'liquida��o.';
  
    vr_tab_clau_adi(3).clausula(3) 
                      := 'CLAUSULA TERCEIRA - A(s) aplica��o(�es) com o(s) numero(s) '||
                         pr_dsaplica ||', mantida(s) pelo Interveniente '||     
                         'Garantidor(a) junto a Cooperativa, tornar-se-�(�o) aplica��o(�es) '||
                         'vinculada(s) ate que se cumpram todas as obriga��es assumidas na C�dula de Credito '||
                         'Banc�rio'||vr_dscontra ||' original.';
                         
    vr_tab_clau_adi(3).clausula(4) 
                      := 'CLAUSULA QUARTA - O n�o cumprimento das obriga��es assumidas no presente termo '||
                         'aditivo e na C�dula de Credito Banc�rio'||vr_dscontra ||' principal, '||
                         'bem com o inadimplemento de 02(duas) presta��es mensais consecutivas '||
                         'ou alternadas, independentemente de qualquer notifica��o judicial ou '||
                         'extrajudicial, implicara no vencimento antecipado de todo o saldo devedor do '||
                         'empr�stimo/financiamento servindo a(s) referida(s) aplica��o(�es) vinculada(s) para a '||
                         'imediata liquida��o do saldo devedor.';
                      
    vr_tab_clau_adi(3).clausula(5) 
                      := 'CLAUSULA QUINTA - Caso a(s) aplica��o(�es) venham a ser utilizada(s) para liquida��o ' ||
                         'do saldo devedor do empr�stimo/financiamento, a(s) mesma(s) poder�o '||
                         'ser movimentada(s) livremente pela Cooperativa, a qualquer tempo, sem qualquer '||
                         'notifica��o judicial ou extrajudicial, independentemente de notifica��o judicial '||
                         'ou extrajudicial.';
                      
    vr_tab_clau_adi(3).clausula(6) 
                      := 'CLAUSULA SEXTA - A(s) aplica��o(�es) acima enumarada(s), podera(ao) ser liberada(s) '||
                         'parcialmente, e se poss�vel, a medida que o saldo devedor do ' ||
                         'empr�stimo/financiamento for sendo liquidado.';                   
                      
    vr_tab_clau_adi(3).clausula(7) 
                      := 'CLAUSULA SETIMA - Ficam ratificadas todas as demais condi��es da C�dula de Credito ' ||
                         'Banc�rio'||vr_dscontra ||' ora aditado(a), em tudo o que n�o expressamente modificado no presente termo.';                   

                      
    --> Tipo 4 - Inclusao de Fiador/Avalista
      
    vr_tab_clau_adi(4).clausula(1) 
                      := 'CLAUSULA PRIMEIRA - Para garantir o cumprimento das obriga��es assumidas na C�dula '||
                         'de Credito Banc�rio'||vr_dscontra ||' ora aditado(a), '||
                         'comparece como Devedor Solid�rio/Fiador '|| pr_nmdavali ||
                         ', inscrito no CPF/CNPJ sob n. '|| pr_dscpfavl ||', titular da conta corrente n. '||
                         gene0002.fn_mask_conta(pr_nrctaavl) ||', mantida perante esta Cooperativa.';
                      
    vr_tab_clau_adi(4).clausula(2) 
                      := 'CLAUSULA SEGUNDA - O Devedor Solid�rio/Fiador declara-se solidariamente respons�veis '||
                         'com o(a) Emitente/Cooperado pela integral e pontual liquida��o de '||
                         'todas as suas obriga��es, principais e acessorias, decorrentes deste ajuste, nos '||
                         'termos dos artigos 275 e seguintes do C�digo Civil Brasileiro, renunciando expressamente, '||
                         'os benef�cios de ordem que trata o artigo 827, em conformidade com o artigo 282, incisos '||
                         ' I e II, todos tamb�m do C�digo Civil Brasileiro.';                  
                      
    vr_tab_clau_adi(4).clausula(3) 
                      := 'CLAUSULA TERCEIRA - O Devedor Solid�rio, ao assinar o presente termo aditivo declara '||
                         'ter lido previamente e ter conhecimento das Condi��es Especificas da C�dula de '||
                         'Credito Banc�rio';
    IF pr_cdc = 'N' THEN                      
      vr_tab_clau_adi(4).clausula(3) := vr_tab_clau_adi(4).clausula(3) ||
                                        '/Termo de Ades�o ao contrato de Credito Simplificado original(naria), ';
    END IF;                     
    vr_tab_clau_adi(4).clausula(3) := vr_tab_clau_adi(4).clausula(3) || 
                         'cujas disposi��es se aplicam completamente a este instrumento, com as '||
                         'quais concorda incondicionalmente, ratificando-as integralmente neste ato, n�o '||
                         'possuindo duvidas com rela��o a quaisquer de suas clausulas.';
        
    
    --> Tipo 5- Substituicao de Veiculo
    vr_tab_clau_adi(5).clausula(1) 
                      := 'CLAUSULA PRIMEIRA - Altera��o/Substitui��o do bem deixado em garantia com aliena��o '||
                         'fiduci�ria na C�dula de Credito Banc�rio'||vr_dscontra ||' original, que passa a ser:';
                      
    vr_tab_clau_adi(5).clausula(1) 
                      := vr_tab_clau_adi(5).clausula(1) ||'<br>'||
                      'AUTOM�VEL   : '  || pr_dsbemfin  ||'<br>'||
                      'RENAVAN    : '   || pr_nrrenava  ||'<br>'||
                      'TIPO CHASSI  : ' || pr_tpchassi  ||'<br>'||
                      'PLACA     : '    || pr_nrdplaca  ||'<br>'||
                      'UF PLACA   : '   || pr_ufdplaca  ||'<br>'||
                      'COR      : '     || pr_dscorbem  ||'<br>'||
                      'ANO      : '     || pr_nranobem  ||'<br>'||
                      'MODELO    : '    || pr_nrmodbem  ||'<br>'||
                      'UF LICENCI.  : ' || pr_uflicenc  ||'<br>'||
                      'NOME DO PROPRIET�RIO : ' || pr_nmdavali   ||'<br>'||
                      'CPF/CNPJ PROPRIET�RIO :' || pr_dscpfpro ;

    
    vr_tab_clau_adi(5).clausula(2) 
                      := 'CLAUSULA SEGUNDA - Ficam ratificadas todas as demais condi��es da C�dula de Credito '||
                         'Banc�rio'||vr_dscontra ||' ora aditado (a), em '||
                         'tudo o que n�o expressamente modificado no presente termo.';
                      
                          
    pr_tab_clau_adi := vr_tab_clau_adi;
  END;
  
  --> Buscar dados do aditivo do emprestimo
  PROCEDURE pc_busca_dados_aditiv 
                          ( pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                           ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                           ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                           ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_idorigem   IN INTEGER               --> Origem 
                           ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                           ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                           ,pr_cddopcao   IN VARCHAR2              --> Codigo da opcao
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                           ,pr_dtmvtolx   IN crapdat.dtmvtolt%TYPE --> Data de consulta
                           ,pr_nraditiv   IN crapadt.nraditiv%TYPE --> Numero do aditivo
                           ,pr_cdaditiv   IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                           ,pr_tpaplica   IN craprda.tpaplica%TYPE --> tipo de aplicacao
                           ,pr_nrctagar   IN crapass.nrdconta%TYPE --> conta garantia
                           ,pr_flgpagin   IN INTEGER               --> Flag (0-false 1-true)
                           ,pr_nrregist   IN INTEGER               --> Numero de registros a serem retornados
                           ,pr_nriniseq   IN INTEGER               --> Registro inicial
                           ,pr_flgerlog   IN INTEGER               --> Gerar log(0-false 1-true)
                           --------> OUT <--------
                           ,pr_qtregist       OUT INTEGER             --> Retornar quantidad de registros
                           ,pr_tab_aditiv     OUT typ_tab_aditiv      --> Retornar dados do aditivo
                           ,pr_tab_aplicacoes OUT typ_tab_aplicacoes  --> Retornar dados das aplica��es 
                           ,pr_cdcritic  OUT PLS_INTEGER           --> C�digo da cr�tica
                           ,pr_dscritic  OUT VARCHAR2    ) IS      --> Descri��o da cr�tica
                                    
    /* .............................................................................
    
        Programa: pc_busca_dados_aditiv    (antiga: b1wgen0115.p/Busca_Dados)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Julho/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em buscar dados do aditivo do emprestimo
    
        Observacao: -----
    
        Alteracoes: 23/01/2017 - Quando garantia do aditivo � aplica��o de
                                 terceiros, passar n�mero da conta como par�metro
                                 ao inv�s de zero. (AJFink SD#597917)

    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;
        
    
    vr_cdaditiv        crapadt.cdaditiv%TYPE;    
    vr_nrdconta        crapass.nrdconta%TYPE;
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrregist        INTEGER;
    vr_nrdrowid        ROWID;
    
    vr_idxaditv        PLS_INTEGER;
    vr_fcrapadt        BOOLEAN;    
    vr_fcrapadi        BOOLEAN;
    
    vr_contador        INTEGER;    
            
    ---------->> CURSORES <<--------   
    
    --> Buscar aditivo
    CURSOR cr_crapadi IS
      SELECT *
        FROM crapadi
       WHERE crapadi.cdcooper = pr_cdcooper
         AND crapadi.nrdconta = pr_nrdconta
         AND crapadi.nrctremp = pr_nrctremp
         AND crapadi.nraditiv = pr_nraditiv;
    rw_crapadi cr_crapadi%ROWTYPE;
    
    --> Buscar aditivo
    CURSOR cr_crapadi2 IS
      SELECT *
        FROM crapadi
       WHERE crapadi.cdcooper = pr_cdcooper
         AND crapadi.nrdconta = pr_nrdconta
         AND crapadi.nrctremp = pr_nrctremp
         AND crapadi.nraditiv = pr_nraditiv
         AND crapadi.nrsequen = 1;
    
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;  
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta
        FROM crawepr epr            
       WHERE epr.cdcooper = pr_cdcooper
         AND ((nvl(pr_nrdconta,0) <> 0 AND epr.nrdconta = pr_nrdconta) OR
              (nvl(pr_nrdconta,0) = 0))
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;   
    
    --> Buscar dados emprestimo
    CURSOR cr_crapepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta,
             epr.flgpagto,
             epr.tpdescto
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;     
    
    --> Buscar aditivos contratuais
    CURSOR cr_crapadt IS
      SELECT *
        FROM crapadt adt
       WHERE adt.cdcooper = pr_cdcooper
         AND adt.nrdconta = nvl(nullif(pr_nrdconta,0),adt.nrdconta)
         AND adt.nrctremp = nvl(nullif(pr_nrctremp,0),adt.nrctremp) 
         AND adt.dtmvtolt >= nvl(pr_dtmvtolx,adt.dtmvtolt);
    
    --> Buscar aditivos contratuais
    CURSOR cr_crapadt2 IS
      SELECT *
        FROM crapadt adt
       WHERE adt.cdcooper = pr_cdcooper
         AND adt.nrdconta = pr_nrdconta
         AND adt.nrctremp = pr_nrctremp
         AND adt.nraditiv =  pr_nraditiv;
    rw_crapadt cr_crapadt2%ROWTYPE;
    
    --> Buscar bens da proposta de emprestimo do cooperado.
    CURSOR cr_crapbpr IS
      SELECT bpr.idseqbem,
             bpr.dsbemfin,
             bpr.nrcpfbem,
             bpr.dschassi,
             bpr.nrdplaca,
             bpr.dscorbem,
             bpr.nranobem,
             bpr.nrmodbem,
             bpr.nrrenava,
             bpr.tpchassi,
             bpr.ufdplaca,
             bpr.uflicenc             
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = pr_nrctremp
         AND bpr.flgalien = 1; --TRUE
         
    --> Buscar bens da proposta de emprestimo do cooperado.
    CURSOR cr_crapbpr2 IS
      SELECT bpr.idseqbem,
             bpr.dsbemfin,
             bpr.nrcpfbem
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = pr_nrctremp
         AND bpr.flgalien = 1--TRUE
         AND NOT EXISTS ( SELECT 1
                            FROM crapadt adt
                                ,crapadi adi
                           WHERE adt.cdcooper = bpr.cdcooper
                             AND adt.nrdconta = bpr.nrdconta
                             AND adt.nrctremp = bpr.nrctrpro
                             AND adi.cdcooper = adt.cdcooper
                             AND adi.nrdconta = adt.nrdconta
                             AND adi.nrctremp = adt.nrctremp
                             AND adi.nraditiv = adt.nraditiv
                             AND adi.dsbemfin = bpr.dsbemfin
                             AND adi.dschassi = bpr.dschassi
                             AND adi.nrdplaca = bpr.nrdplaca
                             AND adi.dscorbem = bpr.dscorbem
                             AND adi.nranobem = bpr.nranobem
                             AND adi.nrmodbem = bpr.nrmodbem
                             AND adi.nrrenava = bpr.nrrenava
                             AND adi.tpchassi = bpr.tpchassi
                             AND adi.ufdplaca = bpr.ufdplaca
                             AND adi.uflicenc = bpr.uflicenc); 
   
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  BEGIN
  
    vr_dscritic := NULL;
    vr_cdcritic := 0;
    vr_nrdconta := 0;
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Busca Aditivo Contratual de Emprestimo.';
    vr_nrregist := pr_nrregist;
    vr_cdaditiv := pr_cdaditiv;
    
    pr_tab_aditiv.delete;
    pr_tab_aplicacoes.delete;
    
    --> Validar op��es existentes
    IF pr_cddopcao NOT IN ('C','E','I','V','X') THEN
      vr_cdcritic := 14; -- 014 - Opcao errada.
      RAISE vr_exc_erro;
    END IF;
    
    --> Visualizar
    IF pr_cddopcao = 'V' THEN
      IF pr_nrdconta <> 0 THEN
        --> Validar associado
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN 
          CLOSE cr_crapass;
          vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapass;
        END IF;      
      END IF;
      
      IF pr_nrctremp <> 0 THEN
        --> Validar emprestimo
        OPEN cr_crawepr;
        FETCH cr_crawepr INTO rw_crawepr;
        IF cr_crawepr%NOTFOUND THEN
          CLOSE cr_crawepr;
          vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crawepr;
        END IF;
      END IF;
      
      --> Buscar aditivos contratuais
      FOR rw_crapadt IN cr_crapadt LOOP
        pr_qtregist := pr_qtregist + 1;
        
        --> Controlar paginacao
        IF pr_flgpagin =1                 AND
           ((pr_qtregist < pr_nriniseq) OR
            (pr_qtregist > (pr_nriniseq + pr_nrregist))) THEN
          continue;
        END IF;
        
        IF vr_nrregist > 0 or
           pr_flgpagin = 0 THEN
          
          vr_idxaditv := pr_tab_aditiv.COUNT + 1;
          pr_tab_aditiv(vr_idxaditv).nrdconta := rw_crapadt.nrdconta;
          pr_tab_aditiv(vr_idxaditv).nrctremp := rw_crapadt.nrctremp;
          pr_tab_aditiv(vr_idxaditv).dsaditiv := vr_tab_dsaditiv(rw_crapadt.cdaditiv);
          pr_tab_aditiv(vr_idxaditv).nraditiv := rw_crapadt.nraditiv;
          pr_tab_aditiv(vr_idxaditv).dtmvtolt := rw_crapadt.dtmvtolt;          
        END IF;   
        
      END LOOP;
      
    -- C-Consulta, E-Exclusao e I-Inclusao 
    ELSIF pr_cddopcao IN ('C','E','I') THEN
      
      --> Validar associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN 
        CLOSE cr_crapass;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;       
      
      --> Validar emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crawepr;
      END IF;
      
      --> Buscar aditivos contratuais
      OPEN cr_crapadt2;
      FETCH cr_crapadt2 INTO rw_crapadt;
      vr_fcrapadt := cr_crapadt2%FOUND;
      CLOSE cr_crapadt2;
      
      vr_idxaditv := pr_tab_aditiv.COUNT + 1;
      pr_tab_aditiv(vr_idxaditv).nrdconta := pr_nrdconta;
      pr_tab_aditiv(vr_idxaditv).nrctremp := pr_nrctremp;
      pr_tab_aditiv(vr_idxaditv).nraditiv := pr_nraditiv;
      pr_tab_aditiv(vr_idxaditv).cdaditiv := vr_cdaditiv;
      
      -- Se nao encontrouo registro e n�o � inclusao
      IF vr_fcrapadt = FALSE AND
         pr_cddopcao NOT IN ('I') THEN
        vr_cdcritic := 816; --> 816 - Aditivo nao encontrado.
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_fcrapadt = TRUE THEN
        vr_cdaditiv                         := rw_crapadt.cdaditiv;
        pr_tab_aditiv(vr_idxaditv).cdaditiv := rw_crapadt.cdaditiv;
        pr_tab_aditiv(vr_idxaditv).nrctagar := rw_crapadt.nrctagar;
        pr_tab_aditiv(vr_idxaditv).nrcpfgar := rw_crapadt.nrcpfgar;
        pr_tab_aditiv(vr_idxaditv).nrdocgar := rw_crapadt.nrdocgar;
        pr_tab_aditiv(vr_idxaditv).nmdgaran := rw_crapadt.nmdgaran;
        pr_tab_aditiv(vr_idxaditv).dtmvtolt := rw_crapadt.dtmvtolt;
        pr_tab_aditiv(vr_idxaditv).cdaditiv := vr_cdaditiv;
            
      END IF;
      
      IF vr_cdaditiv > 9 OR vr_cdaditiv < 1 THEN
        vr_cdcritic := 814; -- 814 - Tipo de Aditivo errado.
      END IF;  
      
      -- '2- Aplicacao Vinculada',
      -- '3- Aplicacao Vinculada Terceiro',
      IF vr_cdaditiv IN ('2','3') THEN
        
        IF pr_cdaditiv = 3 THEN
          if pr_nrctagar <> 0 then --SD#597917
            vr_nrdconta := pr_nrctagar;
          else
            vr_nrdconta := rw_crapadt.nrctagar;
          end if;
        ELSE 
          vr_nrdconta := pr_nrdconta;
        END IF;
          
        IF pr_cddopcao = 'I' THEN
        
          IF pr_tpaplica = 0 THEN
            -- apensa sair do programa
            RAISE vr_exc_sucesso;        
          ELSE
            --> buscar as aplicacooes do aditivo
            pc_buscar_aplicacoes (pr_cdcooper   => pr_cdcooper  --> Codigo da cooperativa            
                                 ,pr_cdagenci   => pr_cdagenci  --> Codigo da agencia
                                 ,pr_nrdcaixa   => pr_nrdcaixa  --> Numero do caixa 
                                 ,pr_cdoperad   => pr_cdoperad  --> Codigo do operador
                                 ,pr_nmdatela   => pr_nmdatela  --> Nome da tela
                                 ,pr_idorigem   => pr_idorigem  --> Origem 
                                 ,pr_dtmvtolt   => pr_dtmvtolt  --> Data de movimento
                                 ,pr_dtmvtopr   => pr_dtmvtopr  --> Data do prox. movimento
                                 ,pr_inproces   => pr_inproces  --> Indicador de processo
                                 ,pr_cddopcao   => pr_cddopcao  --> Codigo da opcao
                                 ,pr_nrdconta   => vr_nrdconta  --> Numero da conta                                 
                                 ,pr_tpaplica   => pr_tpaplica  --> tipo de aplicacao
                                 ,pr_nraplica   => 0            --> Numero da aplicacao    
                                 --------> OUT <--------
                                 ,pr_tab_aplicacoes => pr_tab_aplicacoes  --> Retornar dados das aplica��es 
                                 ,pr_cdcritic  => vr_cdcritic           --> C�digo da cr�tica
                                 ,pr_dscritic  => vr_dscritic );        --> Descri��o da cr�tica
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro; 
            END IF;   
          END IF;
        
        ELSE
          --> Buscar itens do aditivo contratual
          FOR rw_crapadi IN cr_crapadi LOOP
          
            --> buscar as aplicacooes do aditivo
            pc_buscar_aplicacoes (pr_cdcooper   => pr_cdcooper  --> Codigo da cooperativa            
                                 ,pr_cdagenci   => pr_cdagenci  --> Codigo da agencia
                                 ,pr_nrdcaixa   => pr_nrdcaixa  --> Numero do caixa 
                                 ,pr_cdoperad   => pr_cdoperad  --> Codigo do operador
                                 ,pr_nmdatela   => pr_nmdatela  --> Nome da tela
                                 ,pr_idorigem   => pr_idorigem  --> Origem 
                                 ,pr_dtmvtolt   => pr_dtmvtolt  --> Data de movimento
                                 ,pr_dtmvtopr   => pr_dtmvtopr  --> Data do prox. movimento
                                 ,pr_inproces   => pr_inproces  --> Indicador de processo
                                 ,pr_cddopcao   => pr_cddopcao  --> Codigo da opcao
                                 ,pr_nrdconta   => vr_nrdconta  --> Numero da conta                                 
                                 ,pr_tpaplica   => rw_crapadi.tpaplica  --> tipo de aplicacao
                                 ,pr_nraplica   => rw_crapadi.nraplica  --> Numero da aplicacao    
                                 --------> OUT <--------
                                 ,pr_tab_aplicacoes => pr_tab_aplicacoes  --> Retornar dados das aplica��es 
                                 ,pr_cdcritic  => vr_cdcritic           --> C�digo da cr�tica
                                 ,pr_dscritic  => vr_dscritic );        --> Descri��o da cr�tica
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro; 
            END IF; 
          END LOOP; --> Fim loop cr_crapadi
        
        END IF;
      
      -- 7- Sub-rogacao - C/ Nota Promissoria
      ELSIF vr_cdaditiv = 7 THEN
        --> Buscar itens do aditivo contratual
        FOR rw_crapadi IN cr_crapadi LOOP
          pr_tab_aditiv(vr_idxaditv).promis(rw_crapadi.nrsequen).nrpromis := rw_crapadi.nrpromis;
          pr_tab_aditiv(vr_idxaditv).promis(rw_crapadi.nrsequen).vlpromis := rw_crapadi.vlpromis;
          pr_tab_aditiv(vr_idxaditv).nrcpfgar := rw_crapadi.nrcpfcgc;
          pr_tab_aditiv(vr_idxaditv).nmdgaran := rw_crapadi.nmdavali;          
        END LOOP;  
      
      ELSE
        --> Buscar iten do aditivo contratual
        OPEN cr_crapadi;
        FETCH cr_crapadi INTO rw_crapadi;
        vr_fcrapadi := cr_crapadi%FOUND;
        CLOSE cr_crapadi;
        
      END IF; --> Fim IF vr_cdaditiv IN ('2','3')  
      
      IF vr_fcrapadi = TRUE THEN
        pr_tab_aditiv(vr_idxaditv).flgpagto := rw_crapadi.flgpagto;
        pr_tab_aditiv(vr_idxaditv).dtdpagto := rw_crapadi.dtdpagto;
        pr_tab_aditiv(vr_idxaditv).dsbemfin := rw_crapadi.dsbemfin;
        pr_tab_aditiv(vr_idxaditv).dschassi := rw_crapadi.dschassi;
        pr_tab_aditiv(vr_idxaditv).nrdplaca := rw_crapadi.nrdplaca;
        pr_tab_aditiv(vr_idxaditv).dscorbem := rw_crapadi.dscorbem;
        pr_tab_aditiv(vr_idxaditv).nranobem := rw_crapadi.nranobem;
        pr_tab_aditiv(vr_idxaditv).nrmodbem := rw_crapadi.nrmodbem;
        pr_tab_aditiv(vr_idxaditv).nrrenava := rw_crapadi.nrrenava;
        pr_tab_aditiv(vr_idxaditv).tpchassi := rw_crapadi.tpchassi;
        pr_tab_aditiv(vr_idxaditv).ufdplaca := rw_crapadi.ufdplaca;
        pr_tab_aditiv(vr_idxaditv).uflicenc := rw_crapadi.uflicenc;
        pr_tab_aditiv(vr_idxaditv).nmdavali := rw_crapadi.nmdavali;
        
        IF vr_cdaditiv IN ( 7,8) THEN
          pr_tab_aditiv(vr_idxaditv).nrcpfgar := rw_crapadi.nrcpfcgc;
          pr_tab_aditiv(vr_idxaditv).nmdgaran := rw_crapadi.nmdavali;
        END IF;
        
        IF vr_cdaditiv = 8 THEN  
          pr_tab_aditiv(vr_idxaditv).promis(1).vlpromis := rw_crapadi.vlpromis;
        ELSE
          pr_tab_aditiv(vr_idxaditv).promis(1).vlpromis := 0;
        END IF;  
      
      END IF;
      
      CASE vr_cdaditiv
        WHEN 1 THEN -- 1- Alteracao Data do Debito
        
          --> Validar emprestimo
          OPEN cr_crapepr;
          FETCH cr_crapepr INTO rw_crapepr;
          IF cr_crapepr%NOTFOUND THEN
            CLOSE cr_crapepr;
            vr_cdcritic := 356; -- 356 - Contrato de emprestimo nao encontrado.
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_crapepr;
          END IF;
          
          IF pr_cddopcao = 'E' THEN
            vr_dscritic := 'Tipo de aditivo nao permite EXCLUSAO';
            RAISE vr_exc_erro;
          ELSIF pr_cddopcao <> 'C' THEN
            pr_tab_aditiv(vr_idxaditv).flgpagto := rw_crapepr.flgpagto;
            pr_tab_aditiv(vr_idxaditv).tpdescto := rw_crapepr.tpdescto;
          END IF;
          
      WHEN 4 THEN --> 4- Inclusao de Fiador/Avalista
        IF pr_cddopcao IN ('E','I') THEN
          vr_dscritic := 'Tipo de aditivo permite somente CONSULTA';
          RAISE vr_exc_erro;
        END IF;      
        
        --> Buscar iten do aditivo contratual
        OPEN cr_crapadi2;
        FETCH cr_crapadi2 INTO rw_crapadi;
        vr_fcrapadi := cr_crapadi2%FOUND;
        CLOSE cr_crapadi2;  
        
        IF vr_fcrapadi = TRUE THEN
          pr_tab_aditiv(vr_idxaditv).dscpfavl := gene0002.fn_mask_cpf_cnpj(rw_crapadi.nrcpfcgc,1);
          pr_tab_aditiv(vr_idxaditv).nmdavali := rw_crapadi.nmdavali;
        END IF;
                
      WHEN 5 THEN --> 5 - Substituicao de Veiculo   
        vr_contador := 0;
        IF  pr_cddopcao <> 'I' THEN
          pr_tab_aditiv(vr_idxaditv).nrcpfcgc := rw_crapadi.nrcpfcgc;
          pr_tab_aditiv(vr_idxaditv).nmdavali := rw_crapadi.nmdavali;
        END IF;  

        --> Buscar bens da proposta de emprestimo do cooperado.
        FOR rw_crapbpr IN cr_crapbpr LOOP
          vr_idxaditv := pr_tab_aditiv.COUNT + 1;
          pr_tab_aditiv(vr_idxaditv).nrsequen := vr_contador;
          pr_tab_aditiv(vr_idxaditv).idseqbem := rw_crapbpr.idseqbem;
          pr_tab_aditiv(vr_idxaditv).dsbemfin := rw_crapbpr.dsbemfin;
          pr_tab_aditiv(vr_idxaditv).nrcpfcgc := rw_crapbpr.nrcpfbem;
        END LOOP;
        
      WHEN 6 THEN --> 6- Interveniente Garantidor Veiculo
        IF pr_cddopcao = 'I' THEN
          vr_dscritic := 'TIPO DE ADITIVO NAO PERMITIDO';
          RAISE vr_exc_erro;
        END IF;          
      ELSE
        NULL;    
      END CASE;
          
    ELSIF pr_cddopcao = 'X' THEN
    
      --> Validar associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN 
        CLOSE cr_crapass;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;       
      
      --> Validar emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crawepr;
      END IF;
      
      ---->> BENS ALIENADOS <<----
      --> Buscar bens da proposta de emprestimo do cooperado.
      FOR rw_crapbpr IN cr_crapbpr LOOP
        vr_idxaditv := pr_tab_aditiv.COUNT + 1;
        pr_tab_aditiv(vr_idxaditv).dsbemfin := rw_crapbpr.dsbemfin;
        pr_tab_aditiv(vr_idxaditv).dschassi := rw_crapbpr.dschassi;
        pr_tab_aditiv(vr_idxaditv).nrdplaca := rw_crapbpr.nrdplaca;
        pr_tab_aditiv(vr_idxaditv).dscorbem := rw_crapbpr.dscorbem;
        pr_tab_aditiv(vr_idxaditv).nranobem := rw_crapbpr.nranobem;
        pr_tab_aditiv(vr_idxaditv).nrmodbem := rw_crapbpr.nrmodbem;
        pr_tab_aditiv(vr_idxaditv).nrrenava := rw_crapbpr.nrrenava;
        pr_tab_aditiv(vr_idxaditv).tpchassi := rw_crapbpr.tpchassi;
        pr_tab_aditiv(vr_idxaditv).ufdplaca := rw_crapbpr.ufdplaca;
        pr_tab_aditiv(vr_idxaditv).uflicenc := rw_crapbpr.uflicenc;
        pr_tab_aditiv(vr_idxaditv).idseqbem := rw_crapbpr.idseqbem;
        pr_tab_aditiv(vr_idxaditv).nrcpfcgc := rw_crapbpr.nrcpfbem;
        pr_tab_aditiv(vr_idxaditv).nrdconta := pr_nrdconta;
        pr_tab_aditiv(vr_idxaditv).nrctremp := pr_nrctremp;
        pr_tab_aditiv(vr_idxaditv).nraditiv := pr_nraditiv;
        pr_tab_aditiv(vr_idxaditv).cdaditiv := pr_cdaditiv;
      END LOOP;
      
    ELSE
      vr_cdcritic := 14; -- 014 - Opcao errada.
      RAISE vr_exc_erro;
    END IF; --> Fim IF pr_cddopcao
    
           
  EXCEPTION
    WHEN vr_exc_sucesso THEN
      NULL; --> Apenas retornar para programa chamador
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      -- Verifica se deve gerar log
      IF pr_flgerlog = 1 AND pr_nrdconta > 0 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => pr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> false
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
      
            
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao buscar dados aditivo: ' || SQLERRM;         
  END pc_busca_dados_aditiv;  
  
  --> Rotina responsavel em buscar dados para assinatura do contrato
  PROCEDURE pc_Trata_Dados_Assinatura ( pr_cdcooper     IN crapavl.cdcooper%TYPE,
                                        pr_nrdconta     IN crapavl.nrdconta%TYPE,
                                        pr_nrctremp     IN crapepr.nrctremp%TYPE,
                                        pr_nrctacon     IN crapavl.nrdconta%TYPE,
                                        pr_nrctaava     IN crapavt.nrdconta%TYPE,
                                        pr_nmdavali     IN crapavt.nmdavali%TYPE,
                                        pr_iddoaval     IN INTEGER,
                                        pr_tpdconsu     IN INTEGER,
                                        pr_linhatra IN OUT VARCHAR2,
                                        pr_nmdevsol IN OUT VARCHAR2,
                                        pr_dscpfcgc IN OUT VARCHAR2,
                                        pr_dsendere IN OUT VARCHAR2,
                                        pr_dstelefo IN OUT VARCHAR2,
                                        pr_cdcritic    OUT PLS_INTEGER,          --> C�digo da cr�tica
                                        pr_dscritic    OUT VARCHAR2    ) IS      --> Descri��o da cr�tica
    /* .............................................................................
    
        Programa: pc_Trata_Dados_Assinatura    (antiga: b1wgen0115.p/Trata_Dados_Assinatura)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Julho/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em buscar dados para assinatura do contrato
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    
    ---------->>> CURSORES <<<--------
    
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%ROWTYPE; 
    
    --> Buscar dados do endere�o
    CURSOR cr_crapenc (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT enc.cdcooper,
             enc.dsendere,
             enc.nrendere,
             enc.nmcidade
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1;
    rw_crapenc cr_crapenc%ROWTYPE;
    
    --> Buscar dados do telefone
    CURSOR cr_craptfc (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT tfc.nrdddtfc,
             tfc.nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.idseqttl = 1;
    rw_craptfc cr_craptfc%ROWTYPE;
    
    --> Buscar dados avalista
    CURSOR cr_crapavt(pr_cdcooper  crapavt.cdcooper%TYPE,
                      pr_nrdconta  crapavt.nrdconta%TYPE,
                      pr_nrctremp  crapavt.nrctremp%TYPE,
                      pr_nmdavali  crapavt.nmdavali%TYPE) IS
      SELECT avt.cdcooper
            ,avt.dsendres##1
            ,avt.nrendere
            ,avt.nmcidade
            ,avt.nmdavali
            ,avt.nrfonres
            ,avt.inpessoa
            ,avt.nrcpfcgc
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.tpctrato = 1
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrctremp = pr_nrctremp
         AND avt.nmdavali = pr_nmdavali;
    rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar dodos do conjuge do Avalista
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cje.nmconjug,
             cje.nrcpfcjg,
             cje.dsendcom,
             cje.nrfonemp
        FROM crapcje cje
       WHERE cje.cdcooper = pr_cdcooper
         AND cje.nrdconta = pr_nrdconta
         AND cje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    
    
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_exc_erro        EXCEPTION;
    
    vr_inpessoa        VARCHAR2(1);
    vr_nmdevsol        VARCHAR2(100);
    vr_dscpfcgc        VARCHAR2(20);
    vr_dsendere        VARCHAR2(100);
    vr_dstelefo        VARCHAR2(100);
    
        
    
  BEGIN
    IF pr_nrctacon <> 0  THEN --> Dados do cooperado
    
      --> Buscar dados do cooperado
      OPEN cr_crapass(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrctacon);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN        
        CLOSE cr_crapass;
        vr_dscritic := 'Associado n�o encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      --> Buscar dados de endere�o do cooperado
      OPEN cr_crapenc(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrctacon);
      FETCH cr_crapenc INTO rw_crapenc;
      IF cr_crapenc%NOTFOUND THEN        
        CLOSE cr_crapenc;
        vr_dscritic := 'Endere�o do associado n�o encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapenc;
      END IF;
      
      --> Buscar dados de telefones do cooperado
      OPEN cr_craptfc(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrctacon);
      FETCH cr_craptfc INTO rw_craptfc;
      IF cr_craptfc%NOTFOUND THEN        
        CLOSE cr_craptfc;
        vr_dscritic := 'Telefone do associado n�o encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptfc;
      END IF;
      
      vr_inpessoa := rw_crapass.inpessoa;
      vr_nmdevsol := rw_crapass.nmprimtl;
      vr_dscpfcgc := rw_crapass.nrcpfcgc;
      vr_dsendere := rw_crapenc.dsendere ||' '|| rw_crapenc.nrendere|| ', '||rw_crapenc.nmcidade;
      vr_dstelefo := '('|| rw_craptfc.nrdddtfc||') '|| rw_craptfc.nrtelefo;
      
    ELSE --> Avalista terceiro ou Conjuge terceiro
      --> Avalista
      IF pr_tpdconsu = 1 THEN 
        --> Buscar dados avalista
        OPEN cr_crapavt(pr_cdcooper  => pr_cdcooper,
                        pr_nrdconta  => pr_nrdconta,
                        pr_nrctremp  => pr_nrctremp,
                        pr_nmdavali  => pr_nmdavali); 
        FETCH cr_crapavt INTO rw_crapavt;
        IF cr_crapavt%NOTFOUND THEN
          CLOSE cr_crapavt;
        ELSE
          CLOSE cr_crapavt;
          
          vr_inpessoa := rw_crapavt.inpessoa;
          vr_nmdevsol := rw_crapavt.nmdavali;
          vr_dscpfcgc := rw_crapavt.nrcpfcgc;
          vr_dsendere := rw_crapavt.dsendres##1 ||' '|| rw_crapavt.nrendere|| ', '||rw_crapavt.nmcidade;
          vr_dstelefo := rw_crapavt.nrfonres;
          
        END IF;
      
      --> Conjuge do Avalista
      ELSE
        --> Buscar dados do conjuge
        OPEN cr_crapcje(pr_cdcooper  => pr_cdcooper,
                        pr_nrdconta  => pr_nrctaava);
        FETCH cr_crapcje INTO rw_crapcje;
        IF cr_crapcje%NOTFOUND THEN        
          CLOSE cr_crapcje;
        ELSE
          CLOSE cr_crapcje;
          vr_inpessoa := 1;
          vr_nmdevsol := rw_crapcje.nmconjug;
          vr_dscpfcgc := rw_crapcje.nrcpfcjg;
          vr_dsendere := rw_crapcje.dsendcom;
          vr_dstelefo := rw_crapcje.nrfonemp;
          
          --Se nao localizou o endere�o
          IF TRIM(vr_dsendere) IS NULL THEN
          
            --> Buscar dados de endere�o do cooperado
            OPEN cr_crapenc(pr_cdcooper  => pr_cdcooper,
                            pr_nrdconta  => pr_nrctaava);
            FETCH cr_crapenc INTO rw_crapenc;
            IF cr_crapenc%FOUND THEN              
              vr_dsendere := rw_crapenc.dsendere ||' '|| rw_crapenc.nrendere|| ', '||rw_crapenc.nmcidade;
            END IF;
            CLOSE cr_crapenc;
          END IF; 
          
          IF trim(vr_dstelefo) IS NULL THEN
            --> Buscar dados de telefones do cooperado
            OPEN cr_craptfc(pr_cdcooper  => pr_cdcooper,
                            pr_nrdconta  => pr_nrctaava);
            FETCH cr_craptfc INTO rw_craptfc;
            IF cr_craptfc%FOUND THEN        
              vr_dstelefo := '('|| rw_craptfc.nrdddtfc||') '|| rw_craptfc.nrtelefo;
            END IF;
            CLOSE cr_craptfc;
          END IF;
          
        END IF;
      END IF;
    END IF;
    
    --> Assinatura, nome, Endereco , telefone e CPF 
    pr_linhatra := pr_linhatra || pr_iddoaval || ')';
    pr_nmdevsol := pr_nmdevsol || 'Nome: '    || vr_nmdevsol;
    pr_dsendere := pr_dsendere || 'Endereco: '|| vr_dsendere;
    pr_dstelefo := pr_dstelefo || 'Telefone: '|| vr_dstelefo;

    IF vr_inpessoa = 1 THEN
      pr_dscpfcgc := pr_dscpfcgc || 'CPF: ';
    ELSE
      pr_dscpfcgc := pr_dscpfcgc || 'CNPJ: ';
    END IF;
    
    pr_dscpfcgc := pr_dscpfcgc || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_dscpfcgc, 
                                                            pr_inpessoa => vr_inpessoa);
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na pc_Trata_Dados_Assinatura: ' || SQLERRM;   
  END pc_Trata_Dados_Assinatura;
  
  PROCEDURE pc_Trata_Assinatura ( pr_cdcooper       IN crapavl.cdcooper%TYPE,
                                  pr_nrdconta       IN crapavl.nrdconta%TYPE,
                                  pr_nrctremp       IN crapepr.nrctremp%TYPE,
                                  pr_nrctaava       IN crapavt.nrdconta%TYPE,
                                  pr_nmdavali       IN crapavt.nmdavali%TYPE,
                                  pr_iddoaval       IN INTEGER,              
                                  pr_cdaditiv       IN crapadt.cdaditiv%TYPE,
                                  pr_linhatra      OUT VARCHAR2,
                                  pr_nmdevsol      OUT VARCHAR2,
                                  pr_dscpfcgc      OUT VARCHAR2,
                                  pr_dsendere      OUT VARCHAR2,
                                  pr_dstelefo      OUT VARCHAR2,
                                  pr_linhatra_cje  OUT VARCHAR2,
                                  pr_nmdevsol_cje  OUT VARCHAR2,
                                  pr_dscpfcgc_cje  OUT VARCHAR2,
                                  pr_dsendere_cje  OUT VARCHAR2,
                                  pr_dstelefo_cje  OUT VARCHAR2,
                                  pr_cdcritic      OUT PLS_INTEGER,          --> C�digo da cr�tica
                                  pr_dscritic      OUT VARCHAR2    ) IS      --> Descri��o da cr�tica
    /* .............................................................................
    
        Programa: pc_Trata_Assinatura    (antiga: b1wgen0115.p/Trata_Assinatura)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Agosto/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em montar os dados para assinatura do contrato
    
        Observacao: -----
    
        Alteracoes:

		22/05/2017 - Atera��o na chamada da procedure pc_trata_dados_assinatura
                     o parametro pr_tpdconsu de 1 para 2 com o objetivo de buscar 
                     o conjuge do avalista(663707 - Mateus Zimmermann - Mouts)	
    ..............................................................................*/
    
    ---------->>> CURSORES <<<--------
    --> Buscar dodos do conjuge do Avalista
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cje.nmconjug,
             cje.nrcpfcjg,
             cje.dsendcom,
             cje.nrfonemp,
             cje.nrctacje
        FROM crapcje cje
       WHERE cje.cdcooper = pr_cdcooper
         AND cje.nrdconta = pr_nrdconta
         AND cje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_exc_erro        EXCEPTION;
    
  BEGIN
  
    --> Dados do avalista
    pc_Trata_Dados_Assinatura ( pr_cdcooper    => pr_cdcooper,
                                pr_nrdconta    => pr_nrdconta,
                                pr_nrctremp    => pr_nrctremp,
                                pr_nrctacon    => pr_nrctaava,
                                pr_nrctaava    => pr_nrctaava,
                                pr_nmdavali    => pr_nmdavali,
                                pr_iddoaval    => pr_iddoaval,
                                pr_tpdconsu    => 1,
                                pr_linhatra    => pr_linhatra,
                                pr_nmdevsol    => pr_nmdevsol,
                                pr_dscpfcgc    => pr_dscpfcgc,
                                pr_dsendere    => pr_dsendere,
                                pr_dstelefo    => pr_dstelefo,
                                pr_cdcritic    => vr_cdcritic,
                                pr_dscritic    => vr_dscritic );
         
    
    --> Buscar dados do conjuge
    OPEN cr_crapcje(pr_cdcooper  => pr_cdcooper,
                    pr_nrdconta  => pr_nrctaava);
    FETCH cr_crapcje INTO rw_crapcje;
    IF cr_crapcje%FOUND THEN        
      CLOSE cr_crapcje;
      
      --> Dados do avalista
      pc_Trata_Dados_Assinatura ( pr_cdcooper    => pr_cdcooper,
                                  pr_nrdconta    => pr_nrdconta,
                                  pr_nrctremp    => pr_nrctremp,
                                  pr_nrctacon    => rw_crapcje.nrctacje,
                                  pr_nrctaava    => pr_nrctaava,
                                  pr_nmdavali    => NULL,
                                  pr_iddoaval    => pr_iddoaval,
                                  pr_tpdconsu    => 2,
                                  pr_linhatra    => pr_linhatra_cje,
                                  pr_nmdevsol    => pr_nmdevsol_cje,
                                  pr_dscpfcgc    => pr_dscpfcgc_cje,
                                  pr_dsendere    => pr_dsendere_cje,
                                  pr_dstelefo    => pr_dstelefo_cje,
                                  pr_cdcritic    => vr_cdcritic,
                                  pr_dscritic    => vr_dscritic);      
    ELSE  
      CLOSE cr_crapcje;
    END IF;  
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na pc_Trata_Assinatura: ' || SQLERRM; 
  END pc_Trata_Assinatura;
  
  --> Gerar a impressao do contrato de aditivo
  PROCEDURE pc_gera_impressao_aditiv 
                          ( pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                           ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                           ,pr_idorigem   IN INTEGER               --> Origem 
                           ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo do programa
                           ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                           ,pr_dsiduser   IN VARCHAR2              --> id do usuario
                           ,pr_cdaditiv   IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                           ,pr_nraditiv   IN crapadt.nraditiv%TYPE --> Numero do aditivo
                           ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                           ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                           --------> OUT <--------
                           ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                           ,pr_cdcritic  OUT PLS_INTEGER           --> C�digo da cr�tica
                           ,pr_dscritic  OUT VARCHAR2    ) IS      --> Descri��o da cr�tica
                                    
    /* .............................................................................
    
        Programa: pc_gera_impressao_aditiv    (antiga: b1wgen0115.p/Gera_Impressao)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Julho/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em gerar a impressao do contrato de aditivo
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------->>> CURSORES <<<--------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.nmcidade
            ,cop.cdufdcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;   
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta,
             epr.cdlcremp,
             epr.cdagenci,
             epr.nmdaval1,
             epr.nrctaav1,
             epr.nmdaval2,
             epr.nrctaav2
        FROM crawepr epr            
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE; 
    
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%ROWTYPE;
    rw_crapass_gar cr_crapass%ROWTYPE;
    
    --> buscar operador
    CURSOR cr_crapope IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE; 
    
    --> Verificar se linha
    CURSOR cr_craplcr (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_cdlcremp crawepr.cdlcremp%TYPE) IS
      SELECT craplcr.dslcremp
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper 
         AND craplcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;
    
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        gene0001.typ_tab_erro;
        
    vr_dstextab        craptab.dstextab%TYPE; 
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);   
    
    vr_qtregist        INTEGER;
    vr_tab_aditiv      typ_tab_aditiv;
    vr_tab_aplicacoes  typ_tab_aplicacoes;
    
    vr_idxaditi        PLS_INTEGER; 
    vr_idxpromi        PLS_INTEGER; 
    
    vr_tpdocged        INTEGER; 
    vr_dsqrcode        VARCHAR2(100);
    
    vr_nmoperad        VARCHAR2(100);
    vr_cdc             CHAR;
    vr_dtmvtolt        DATE;
    vr_rel_nrcpfgar    VARCHAR2(100);
    vr_rel_nmcidade    VARCHAR2(100);
    vr_totpromi        NUMBER;
    vr_rel_vlpromis    VARCHAR2(1000);
    vr_rel_nrcpfcgc    VARCHAR2(25);
    vr_dsddpagt        VARCHAR2(100);
    vr_dsaplica        VARCHAR2(1000);
    vr_dscpfgar        VARCHAR2(100);
    vr_nmprigar        crapass.nmprimtl%TYPE;
    vr_nrctaavl        crapass.nrdconta%TYPE;
    vr_tpchassi        VARCHAR2(100);
    
    vr_linhatra        VARCHAR2(100);
    vr_nmdevsol        VARCHAR2(100);
    vr_dscpfcgc        VARCHAR2(100);
    vr_dsendere        VARCHAR2(200);
    vr_dstelefo        VARCHAR2(100);
    vr_linhatra_cje    VARCHAR2(100);
    vr_nmdevsol_cje    VARCHAR2(100);
    vr_dscpfcgc_cje    VARCHAR2(100);
    vr_dsendere_cje    VARCHAR2(200);
    vr_dstelefo_cje    VARCHAR2(100);
    
    vr_tab_clau_adi    typ_tab_clau_adi;
    vr_tab_clausulas   typ_tab_clausula;
    
    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    vr_dsjasper  VARCHAR2(100);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN  
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN   
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
    
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    vr_nmendter := vr_dsdireto ||'/rl/'||pr_dsiduser;
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    pr_nmarqpdf := pr_dsiduser || gene0002.fn_busca_time || '.pdf';
    
    --> Buscar dados do aditivo do emprestimo
    pc_busca_dados_aditiv ( pr_cdcooper   => pr_cdcooper --> Codigo da cooperativa            
                           ,pr_cdagenci   => 0 --> Codigo da agencia
                           ,pr_nrdcaixa   => 0 --> Numero do caixa 
                           ,pr_cdoperad   => pr_cdoperad --> Codigo do operador
                           ,pr_nmdatela   => pr_nmdatela --> Nome da tela
                           ,pr_idorigem   => pr_idorigem --> Origem 
                           ,pr_dtmvtolt   => pr_dtmvtolt --> Data de movimento
                           ,pr_dtmvtopr   => pr_dtmvtopr --> Data do prox. movimento
                           ,pr_inproces   => pr_inproces --> Indicador de processo
                           ,pr_cddopcao   => 'C' --> Codigo da opcao
                           ,pr_nrdconta   => pr_nrdconta --> Numero da conta
                           ,pr_nrctremp   => pr_nrctremp --> Numero do contrato
                           ,pr_dtmvtolx   => NULL --> Data de consulta
                           ,pr_nraditiv   => pr_nraditiv  --> Numero do aditivo
                           ,pr_cdaditiv   => pr_cdaditiv --> Codigo do aditivo
                           ,pr_tpaplica   => 0 --> tipo de aplicacao
                           ,pr_nrctagar   => 0 --> conta garantia
                           ,pr_flgpagin   => 0 --> Flag (0-false 1-true)
                           ,pr_nrregist   => 0 --> Numero de registros a serem retornados
                           ,pr_nriniseq   => 0 --> Registro inicial
                           ,pr_flgerlog   => 0 --> Gerar log(0-false 1-true)
                           --------> OUT <--------
                           ,pr_qtregist       => vr_qtregist        --> Retornar quantidad de registros
                           ,pr_tab_aditiv     => vr_tab_aditiv      --> Retornar dados do aditivo
                           ,pr_tab_aplicacoes => vr_tab_aplicacoes  --> Retornar dados das aplica��es 
                           ,pr_cdcritic       => vr_cdcritic                --> C�digo da cr�tica
                           ,pr_dscritic       => vr_dscritic      );     --> Descri��o da cr�tica
      
    --> Validar emprestimo
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;
    CLOSE cr_crawepr;
    
    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED'      , 
                                               pr_tptabela => 'GENERI'    , 
                                               pr_cdempres => 00          , 
                                               pr_cdacesso => 'DIGITALIZA' , 
                                               pr_tpregist => 18 ); --> Aditivo Emprestimo/Financiamento (GED)
     
    vr_tpdocged :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                              pr_dstext  => vr_dstextab, 
                                              pr_delimitador => ';');
    
    --> Montar o qrcode para digitaliza��o
    vr_dsqrcode := fn_qrcode_digitaliz (pr_cdcooper => pr_cdcooper,
                                        pr_cdagenci => rw_crawepr.cdagenci,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrborder => 0,
                                        pr_nrcontra => pr_nrctremp,
                                        pr_nraditiv => pr_nraditiv,
                                        pr_cdtipdoc => vr_tpdocged);
                                    
    vr_idxaditi := vr_tab_aditiv.first;
    vr_dtmvtolt := vr_tab_aditiv(vr_idxaditi).dtmvtolt;
    
    --> Pegar o nome do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    --> buscar dados do operador                                              
    OPEN cr_crapope; 
    FETCH cr_crapope INTO rw_crapope;    
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_nmoperad := 'NAO ENCONTRADO!';
    ELSE
      CLOSE cr_crapope;
      vr_nmoperad := TRIM(rw_crapope.nmoperad);
    END IF;
    
    vr_cdc := 'N';
    --> Verificar se linha � CDC        
    OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                    pr_cdlcremp => rw_crawepr.cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;
    CLOSE cr_craplcr;
    
    vr_cdc := empr0003.fn_verifica_cdc(pr_cdcooper => pr_cdcooper, 
                                       pr_dslcremp => rw_craplcr.dslcremp);
    
    -- Montar mascara CNPJ/CPF
    vr_rel_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,
                                                 rw_crapass.inpessoa);
    
    --Definir dia de pagamento
    vr_dsddpagt := gene0002.fn_valor_extenso(pr_idtipval => 'I', 
                                             pr_valor    => to_char(vr_tab_aditiv(vr_idxaditi).dtdpagto,'DD') );    
    vr_dsddpagt := '(' || TRIM(vr_dsddpagt)|| ')'||' de cada mes.';
    
    --> Concatenar aplica��es
    IF vr_tab_aplicacoes.count > 0 THEN
      FOR idx IN vr_tab_aplicacoes.first..vr_tab_aplicacoes.last LOOP
        IF vr_dsaplica IS NOT NULL THEN
          vr_dsaplica := vr_dsaplica ||','||
                         TRIM(gene0002.fn_mask_contrato(vr_tab_aplicacoes(idx).nraplica));
        ELSE
          vr_dsaplica := TRIM(gene0002.fn_mask_contrato(vr_tab_aplicacoes(idx).nraplica));
        END IF;
      END LOOP;    
    END IF;
    
    IF pr_cdaditiv = 3 THEN
      --> dados do interveniente garantidor 
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => vr_tab_aditiv(vr_idxaditi).nrctagar);
      FETCH cr_crapass INTO rw_crapass_gar;
      CLOSE cr_crapass;
      
      vr_dscpfgar := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass_gar.nrcpfcgc,
                                               pr_inpessoa => rw_crapass_gar.inpessoa);
      vr_nmprigar := rw_crapass_gar.nmprimtl;
        
    ELSIF pr_cdaditiv = 4 THEN
    
      IF rw_crawepr.nmdaval1 = vr_tab_aditiv(vr_idxaditi).nmdavali   THEN
        vr_nrctaavl := rw_crawepr.nrctaav1;
      ELSIF rw_crawepr.nmdaval2 = vr_tab_aditiv(vr_idxaditi).nmdavali    THEN
        vr_nrctaavl := rw_crawepr.nrctaav2;
      ELSE
        vr_nrctaavl := 0;
      END IF;  
    ELSIF pr_cdaditiv = 5 THEN
      
      IF vr_tab_aditiv(vr_idxaditi).tpchassi = 1 THEN
        vr_tpchassi := '1 - Remarcado';
      ELSE
        vr_tpchassi := '2 - Normal';
      END IF;
        
    END IF;
    
    --> Carregar clausulas do contrato
    pc_carrega_clausulas ( pr_ddmvtolt => to_char(vr_tab_aditiv(vr_idxaditi).dtdpagto,'DD'),
                           pr_dsddmvto => vr_dsddpagt,
                           pr_dtdpagto => vr_tab_aditiv(vr_idxaditi).dtdpagto,
                           pr_nrctremp => pr_nrctremp, 
                           pr_cdc      => vr_cdc,
                           pr_dsaplica => vr_dsaplica,
                           pr_nmprimtl => rw_crapass.nmprimtl,
                           pr_nrdconta => pr_nrdconta,
                           pr_dscpfgar => vr_dscpfgar,
                           pr_nmprigar => vr_nmprigar,
                           pr_nrctagar => vr_tab_aditiv(vr_idxaditi).nrctagar,
                           pr_nmdavali => vr_tab_aditiv(vr_idxaditi).nmdavali,
                           pr_dscpfavl => vr_tab_aditiv(vr_idxaditi).dscpfavl,
                           pr_nrctaavl => vr_nrctaavl,
                           --> automovel
                           pr_dsbemfin => vr_tab_aditiv(vr_idxaditi).dsbemfin,
                           pr_nrrenava => vr_tab_aditiv(vr_idxaditi).nrrenava,
                           pr_tpchassi => vr_tpchassi,
                           pr_nrdplaca => vr_tab_aditiv(vr_idxaditi).nrdplaca,
                           pr_ufdplaca => vr_tab_aditiv(vr_idxaditi).ufdplaca,
                           pr_dscorbem => vr_tab_aditiv(vr_idxaditi).dscorbem,
                           pr_nranobem => vr_tab_aditiv(vr_idxaditi).nranobem,
                           pr_nrmodbem => vr_tab_aditiv(vr_idxaditi).nrmodbem,
                           pr_uflicenc => vr_tab_aditiv(vr_idxaditi).uflicenc,
                           pr_dscpfpro => vr_tab_aditiv(vr_idxaditi).nrcpfcgc,
                           pr_tab_clau_adi => vr_tab_clau_adi);
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
    
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><termo>');    
    pc_escreve_xml('<cdaditiv>' || pr_cdaditiv               || '</cdaditiv>'||
                   '<dsqrcode>' || vr_dsqrcode               || '</dsqrcode>'||
                   '<nrctremp>' || TRIM(gene0002.fn_mask_contrato(pr_nrctremp))|| '</nrctremp>' ||
                   '<nraditiv>' || pr_nraditiv               || '</nraditiv>'||
                   '<nrcpfcgc>' || rw_crapass.nrcpfcgc       || '</nrcpfcgc>'||
                   '<nrcpfcgc_adit>'|| vr_tab_aditiv(vr_idxaditi).nrcpfcgc||'</nrcpfcgc_adit>'||
                   '<dtmvtolt>' || to_char(vr_dtmvtolt,'DD/MM/RRRR')  || '</dtmvtolt>' ||
                   '<nrdconta>' || trim(gene0002.fn_mask_conta(pr_nrdconta)) || '</nrdconta>' ||
                   '<nmprimtl>' || rw_crapass.nmprimtl       || '</nmprimtl>' ||
                   '<nmrescop>' || rw_crapcop.nmextcop       || '</nmrescop>' );    
        
    IF pr_cdaditiv < 7 THEN
      pc_escreve_xml('<flctrcdc>' || vr_cdc                || '</flctrcdc>' );
    ELSE

      --Listar promissorias
      vr_totpromi     := 0;
      IF pr_cdaditiv = 7 THEN
        pc_escreve_xml('<promissorias>');
        vr_idxpromi := vr_tab_aditiv(vr_idxaditi).promis.first;
        WHILE vr_idxpromi IS NOT NULL LOOP
          vr_totpromi := vr_totpromi + 
                           vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).vlpromis;
                           
          pc_escreve_xml('<promis>
                            <nrpromis>'|| vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).nrpromis ||'</nrpromis>
                            <vlpromis>'|| to_char(vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).vlpromis,'FM999G999G999G990D00')   ||'</vlpromis>
                          </promis>');                       

          vr_idxpromi := vr_tab_aditiv(vr_idxaditi).promis.next(vr_idxpromi);
        END LOOP;                    
        pc_escreve_xml('</promissorias>');      
      ELSE
        vr_idxpromi := vr_tab_aditiv(vr_idxaditi).promis.first;
        IF vr_idxpromi IS NOT NULL THEN
          vr_totpromi := vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).vlpromis;
        END IF;
      END IF;  
      vr_rel_vlpromis := gene0002.fn_valor_extenso(pr_idtipval => 'M', 
                                                   pr_valor    => vr_totpromi );      
      
      vr_rel_nrcpfgar := gene0002.fn_mask_cpf_cnpj(vr_tab_aditiv(vr_idxaditi).nrcpfgar,1);
              
      pc_escreve_xml('<nmdgaran>'     || vr_tab_aditiv(vr_idxaditi).nmdgaran  || '</nmdgaran>' ||
                     '<nrcpfgar>'     || vr_rel_nrcpfgar                      || '</nrcpfgar>' ||
                     '<totpromi>'     || to_char(vr_totpromi,'FM999G999G999G990D00') || '</totpromi>' ||
                     '<totpromi_ext>' || vr_rel_vlpromis                      || '</totpromi_ext>' ||                                         
                     '<dscpfcgc>'     || vr_rel_nrcpfcgc                      || '</dscpfcgc>');
    END IF;
    
    --> EXIBIR CLAUSULAS DO CONTRATO
    IF vr_tab_clau_adi.count > 0 THEN
      vr_tab_clausulas := vr_tab_clau_adi(pr_cdaditiv).clausula;
      IF vr_tab_clausulas.count > 0 THEN
        pc_escreve_xml('<clausulas>');
        FOR vr_idx IN vr_tab_clausulas.first..vr_tab_clausulas.last LOOP
          pc_escreve_xml('<clausula>
                            <texto><![CDATA['||vr_tab_clausulas(vr_idx) ||']]></texto>
                         </clausula>');    
        END LOOP;    
        pc_escreve_xml('</clausulas>');
      END IF;
    END IF;  
    
    --> ASSINATURAS
    vr_rel_nmcidade := rw_crapcop.nmcidade||', '||gene0005.fn_data_extenso(pr_dtmvtolt)||'.';
    pc_escreve_xml('<nmcidade>'||vr_rel_nmcidade||'</nmcidade>');
    
    IF pr_cdaditiv < 7 THEN
      
      pc_escreve_xml('<assinaturas>');
      --> Dados do avalista 1 e conjuge
      IF nvl(rw_crawepr.nrctaav1,0) <> 0    OR
         TRIM(rw_crawepr.nmdaval1) IS NOT NULL THEN
        pc_Trata_Assinatura ( pr_cdcooper     => pr_cdcooper,
                              pr_nrdconta     => pr_nrdconta,
                              pr_nrctremp     => pr_nrctremp,
                              pr_nrctaava     => rw_crawepr.nrctaav1,
                              pr_nmdavali     => rw_crawepr.nmdaval1,
                              pr_iddoaval     => 1,
                              pr_cdaditiv     => pr_cdaditiv,
                              pr_linhatra     => vr_linhatra,
                              pr_nmdevsol     => vr_nmdevsol,
                              pr_dscpfcgc     => vr_dscpfcgc,
                              pr_dsendere     => vr_dsendere,
                              pr_dstelefo     => vr_dstelefo,
                              pr_linhatra_cje => vr_linhatra_cje,
                              pr_nmdevsol_cje => vr_nmdevsol_cje,
                              pr_dscpfcgc_cje => vr_dscpfcgc_cje,
                              pr_dsendere_cje => vr_dsendere_cje,
                              pr_dstelefo_cje => vr_dstelefo_cje,
                              pr_cdcritic     => vr_cdcritic, 
                              pr_dscritic     => vr_dscritic);
                              
        IF TRIM(vr_linhatra) IS NOT NULL THEN
          pc_escreve_xml('<avalista>
                             <linhatra>'       ||  vr_linhatra    ||'</linhatra>'||
                            '<nmdevsol>'       ||  vr_nmdevsol    ||'</nmdevsol>'||
                            '<dscpfcgc>'       ||  vr_dscpfcgc    ||'</dscpfcgc>'||
                            '<dsendere>'       ||  vr_dsendere    ||'</dsendere>'||
                            '<dstelefo>'       ||  vr_dstelefo    ||'</dstelefo>'||
                            '<vr_linhatra_cje>'|| vr_linhatra_cje ||'</vr_linhatra_cje>'||
                            '<vr_nmdevsol_cje>'|| vr_nmdevsol_cje ||'</vr_nmdevsol_cje>'||
                            '<vr_dscpfcgc_cje>'|| vr_dscpfcgc_cje ||'</vr_dscpfcgc_cje>'||
                            '<vr_dsendere_cje>'|| vr_dsendere_cje ||'</vr_dsendere_cje>'||
                            '<vr_dstelefo_cje>'|| vr_dstelefo_cje ||'</vr_dstelefo_cje>
                          </avalista>');
        END IF; 
        
        --> Dados do avalista 2 e conjuge 
        IF nvl(rw_crawepr.nrctaav2,0) <> 0    OR
           TRIM(rw_crawepr.nmdaval2) IS NOT NULL THEN
          pc_Trata_Assinatura ( pr_cdcooper     => pr_cdcooper,
                                pr_nrdconta     => pr_nrdconta,
                                pr_nrctremp     => pr_nrctremp,
                                pr_nrctaava     => rw_crawepr.nrctaav2,
                                pr_nmdavali     => rw_crawepr.nmdaval2,
                                pr_iddoaval     => 2,
                                pr_cdaditiv     => pr_cdaditiv,
                                pr_linhatra     => vr_linhatra,
                                pr_nmdevsol     => vr_nmdevsol,
                                pr_dscpfcgc     => vr_dscpfcgc,
                                pr_dsendere     => vr_dsendere,
                                pr_dstelefo     => vr_dstelefo,
                                pr_linhatra_cje => vr_linhatra_cje,
                                pr_nmdevsol_cje => vr_nmdevsol_cje,
                                pr_dscpfcgc_cje => vr_dscpfcgc_cje,
                                pr_dsendere_cje => vr_dsendere_cje,
                                pr_dstelefo_cje => vr_dstelefo_cje,
                                pr_cdcritic     => vr_cdcritic, 
                                pr_dscritic     => vr_dscritic);
                                
          IF TRIM(vr_linhatra) IS NOT NULL THEN
            pc_escreve_xml('<avalista>
                             <linhatra>'       ||  vr_linhatra    ||'</linhatra>'||
                            '<nmdevsol>'       ||  vr_nmdevsol    ||'</nmdevsol>'||
                            '<dscpfcgc>'       ||  vr_dscpfcgc    ||'</dscpfcgc>'||
                            '<dsendere>'       ||  vr_dsendere    ||'</dsendere>'||
                            '<dstelefo>'       ||  vr_dstelefo    ||'</dstelefo>'||
                            '<vr_linhatra_cje>'|| vr_linhatra_cje ||'</vr_linhatra_cje>'||
                            '<vr_nmdevsol_cje>'|| vr_nmdevsol_cje ||'</vr_nmdevsol_cje>'||
                            '<vr_dscpfcgc_cje>'|| vr_dscpfcgc_cje ||'</vr_dscpfcgc_cje>'||
                            '<vr_dsendere_cje>'|| vr_dsendere_cje ||'</vr_dsendere_cje>'||
                            '<vr_dstelefo_cje>'|| vr_dstelefo_cje ||'</vr_dstelefo_cje>
                          </avalista>');
          END IF; 
        END IF;                          
        
      END IF; 

      pc_escreve_xml('</assinaturas>');
    END IF;  
    
    --> Descarregar buffer
    pc_escreve_xml('</termo></raiz>',TRUE);
    
    IF pr_cdaditiv < 7 THEN
      vr_dsjasper := 'crrl724_aditiv.jasper';
    ELSE
      vr_dsjasper := 'crrl724_aditiv_declaracao.jasper';
    END IF;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz/termo'
                               , pr_dsjasper  => vr_dsjasper
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'S'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;
    
    -- copia contrato pdf do diretorio da cooperativa para servidor web
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                               , pr_cdagenci => NULL
                               , pr_nrdcaixa => NULL
                               , pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_des_reto => vr_des_reto
                               , pr_tab_erro => vr_tab_erro
                               );

    -- caso apresente erro na opera��o
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);

    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT null THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;
    
    -- Liberando a mem�ria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
          
  EXCEPTION
    WHEN vr_exc_sucesso THEN
      NULL; --> Apenas retornar para programa chamador
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao aditivo: ' || SQLERRM, chr(13)),chr(10));   
  END pc_gera_impressao_aditiv;
  
END TELA_ADITIV;
/
