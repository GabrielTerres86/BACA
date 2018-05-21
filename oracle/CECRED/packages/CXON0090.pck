CREATE OR REPLACE PACKAGE CECRED.CXON0090 IS
   /*---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : CXON0090
   --  Sistema  : Rotina 90 e 91 Caixa-Online - Pagamento de Emprestimo (Sem Conta Corrente)
   --  Sigla    : CRED
   --  Autor    : Guilherme/AMcom
   --  Data     : Maio/2018                       Ultima atualizacao: 
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Pagamentos(90) e Estornos(91) de Pagamento de Emprestimo (Sem Conta Corrente)
   --
   -- Alterações: 
   --                     
   --
   --
   ---------------------------------------------------------------------------------------------------------------*/

  /* Retona o lancamento para exibir na tela conforme o nro do documento */
  TYPE typ_rec_lancamento IS
    RECORD(tpdocmto NUMBER(4)
          ,dtmvtolt DATE
          ,vllanmto NUMBER(13,2));

  /* Retona o lancamento para exibir na tela conforme o nro do documento */
  TYPE typ_tab_lancamento IS
    TABLE OF typ_rec_lancamento
    INDEX BY PLS_INTEGER;

  -- Tipo de tabela para vetor literal
  TYPE typ_tab_literal IS table of VARCHAR2(100) index by PLS_INTEGER;
  -- Vetor de memoria do literal
  vr_tab_literal typ_tab_literal;


  PROCEDURE pc_valida_pagto_emprest( pr_cdcooper       IN NUMBER    --> Coop.
                                    ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                    ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                    ,pr_nrdconta       IN NUMBER
                                    ,pr_nrctremp       IN NUMBER
                                    ,pr_vlctrpag       IN NUMBER
                                    ,pr_flgpasso       IN INTEGER --> Identificar o passo de validação
                                    ,pr_cdorigem       IN NUMBER
                                    ,pr_cdoperad       IN VARCHAR2
                                    ,pr_nmdatela       IN VARCHAR2
                                    -- OUT
                                    ,pr_nmprimtl       OUT VARCHAR2
                                    ,pr_dsmensag       OUT VARCHAR2
                                    ,pr_retorno        OUT VARCHAR2
                                    ,pr_cdcritic       OUT INTEGER    --> Cod. Critica
                                    ,pr_dscritic       OUT VARCHAR2   --> Des. da Critica
                                    );


  /* Procedure de Pagamento de Emprestimos sem Conta-Corrente */
  PROCEDURE pc_efetua_pagto_emprest( pr_cdcooper       IN NUMBER    --> Coop.
                                    ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                    ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                    ,pr_cdoperad       IN VARCHAR2   --> Operador
                                    ,pr_nmdatela       IN VARCHAR2
                                    ,pr_cdorigem       IN NUMBER
                                    ,pr_nrdconta       IN NUMBER
                                    ,pr_idseqttl       IN NUMBER
                                    ,pr_dtmvtolt       IN DATE
                                    ,pr_dtmvtopr       IN DATE
                                    ,pr_dtcalcul       IN DATE
                                    ,pr_nrctremp       IN NUMBER
                                    ,pr_vlctrpag       IN NUMBER
                                    ,pr_nmsistem       IN VARCHAR2
                                    ,pr_inproces       IN NUMBER
                                    ,pr_flgerlog       IN NUMBER 
                                    ,pr_flgcondc       IN NUMBER
                                    -- OUT
                                    ,pr_nrdocmto       OUT NUMBER
                                    ,pr_dslitera       OUT VARCHAR2
                                    ,pr_cdultseq       OUT NUMBER                                   
                                    ,pr_retorno        OUT VARCHAR2
                                    ,pr_cdcritic       OUT INTEGER    --> Cod. Critica
                                    ,pr_dscritic       OUT VARCHAR2   --> Des. da Critica
                                   ); 



  PROCEDURE pc_valida_estorno_emprest( pr_cdcooper       IN NUMBER    --> Coop.
                                      ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                      ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                      ,pr_nrdconta       IN NUMBER
                                      ,pr_nrdocmto       IN NUMBER
                                      ,pr_cdorigem       IN NUMBER
                                      ,pr_cdoperad       IN VARCHAR2
                                      ,pr_nmdatela       IN VARCHAR2
                                      -- OUT
                                      ,pr_valorest       OUT NUMBER
                                      ,pr_nmprimtl       OUT VARCHAR2
                                      ,pr_dsmensag       OUT VARCHAR2
                                      ,pr_retorno        OUT VARCHAR2
                                      ,pr_cdcritic       OUT INTEGER    --> Cod. Critica
                                      ,pr_dscritic       OUT VARCHAR2   --> Des. da Critica
                                      );
  /* Procedure que Estorna de Pagamentos de Emprestimos */
  PROCEDURE pc_estorna_pagto_emprest( pr_cdcooper       IN NUMBER    --> Coop.
                                     ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                     ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                     ,pr_nrdconta       IN NUMBER
                                     ,pr_nrdocmto       IN NUMBER
                                     ,pr_cdorigem       IN NUMBER
                                     ,pr_cdoperad       IN VARCHAR2
                                     ,pr_nmdatela       IN VARCHAR2  
                                     -- OUT
                                     ,pr_valorest       OUT NUMBER
                                     ,pr_nrdocaut       OUT NUMBER
                                     ,pr_dslitera       OUT VARCHAR2
--                                     ,pr_cdultseq       OUT NUMBER   
                                     ,pr_dsmensag       OUT VARCHAR2               
                                     ,pr_retorno        OUT VARCHAR2
                                     ,pr_cdcritic       OUT INTEGER  
                                     ,pr_dscritic       OUT VARCHAR2
                                    );
end CXON0090;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CXON0090 IS
   /*---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : CXON0090
   --  Sistema  : Rotina 90 Caixa-Online - Pagamento de Emprestimo (Sem Conta Corrente)
   --  Sigla    : CRED
   --  Autor    : Guilherme/AMcom
   --  Data     : Maio/2018                       Ultima atualizacao: 
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Pagamentos e Estornos de Emprestimo (Sem Conta Corrente)
   --
   -- Alterações: 
   --                     
   --
   --
   ---------------------------------------------------------------------------------------------------------------*/

  FUNCTION fn_centraliza(pr_frase IN VARCHAR2, pr_tamlinha IN PLS_INTEGER) RETURN VARCHAR2 IS 
            vr_contastr PLS_INTEGER;
  BEGIN
    vr_contastr := TRUNC( (pr_tamlinha - LENGTH(TRIM(pr_frase))) / 2 ,0);
    RETURN LPAD(NVL(' ',' '),vr_contastr,' ')||TRIM(pr_frase);
  END fn_centraliza;

  PROCEDURE pc_valida_pagto_emprest( pr_cdcooper       IN NUMBER    --> Coop.
                                    ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                    ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                    ,pr_nrdconta       IN NUMBER
                                    ,pr_nrctremp       IN NUMBER
                                    ,pr_vlctrpag       IN NUMBER
                                    ,pr_flgpasso       IN INTEGER --> Identificar o passo de validação
                                    ,pr_cdorigem       IN NUMBER
                                    ,pr_cdoperad       IN VARCHAR2
                                    ,pr_nmdatela       IN VARCHAR2
                                    -- OUT
                                    ,pr_nmprimtl       OUT VARCHAR2
                                    ,pr_dsmensag       OUT VARCHAR2
                                    ,pr_retorno        OUT VARCHAR2
                                    ,pr_cdcritic       OUT INTEGER    --> Cod. Critica
                                    ,pr_dscritic       OUT VARCHAR2   --> Des. da Critica
                                    ) IS
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : siscaixa/web/crap090.w
   --  Sistema  : Rotina 90 Caixa-Online - Pagamento de Emprestimo (Sem Conta Corrente)
   --  Sigla    : CRED
   --  Autor    : Guilherme/AMcom
   --  Data     : Maio/2018.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Validações prévias para Pagamento de Emprestimo (Sem Conta Corrente)

   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
            ,crapcop.nrtelura
            ,crapcop.dsdircop
            ,crapcop.cdbcoctl
            ,crapcop.cdagectl
            ,crapcop.flgoppag
            ,crapcop.flgopstr
            ,crapcop.inioppag
            ,crapcop.fimoppag
            ,crapcop.iniopstr
            ,crapcop.fimopstr
            ,crapcop.cdagebcb
            ,crapcop.dssigaut
            ,crapcop.cdagesic
            ,crapcop.nrtelsac
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca dos dados do associado */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.nmprimtl
            ,ass.inpessoa
            ,ass.dtelimin
            ,ass.cdsitdtl
            ,ass.cdagenci
            ,ass.cdtipcta
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_craptrf(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT trf.nrdconta
            ,trf.nrsconta      
        FROM craptrf trf
       WHERE trf.cdcooper = pr_cdcooper
         AND trf.nrdconta = pr_nrdconta
         AND trf.tptransa = 1
         AND trf.insittrs = 2;
    rw_craptrf cr_craptrf%ROWTYPE;                     

    /* Cursor de Emprestimos */
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT epr.tpdescto
            ,epr.inliquid
            ,epr.inprejuz
            ,epr.vlsdeved
            ,epr.vlpreemp
            ,epr.vljurmes
            ,epr.vlemprst
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;

    -- Variaveis Erro
    -- vr_exc_erro  EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_sair          EXCEPTION;
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(4000);
    vr_des_erro      VARCHAR2(4000);
    vr_tab_erro      gene0001.typ_tab_erro;

    -- Variaveis
    vr_nrtrfcta      crapass.nrdconta%TYPE;
    vr_nrdconta      crapass.nrdconta%TYPE;
    vr_dstextab      craptab.dstextab%TYPE;
    vr_inusatab      BOOLEAN;
    vr_parempct      craptab.dstextab%TYPE;
    vr_digitali      craptab.dstextab%TYPE;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_qtregist      INTEGER;    
    vr_dsorigem      VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_cdorigem);
    vr_dstransa      VARCHAR2(100) := 'Validacao Emprestimo Caixa';
    vr_vlsdeved      crapepr.vlsdeved%TYPE;
    vr_vlsdprej      crapepr.vlsdprej%TYPE;
    vr_vlatraso      crapepr.vlsdeved%TYPE;
    vr_nrdrowid      ROWID;
    
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  BEGIN

    --Inicializar parametros erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;

    -- VALIDAR pr_flgpasso (APENAS 1 OU 2)
    IF pr_flgpasso NOT IN(1,2) THEN
      pr_dscritic := 'Parametro de execucao invalido! (' || pr_flgpasso || ')';
      RAISE vr_exc_saida;    
    END IF;
    
    
    -- VALIDAR COOP
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      --Mensagem erro
      pr_dscritic:= 'Cooperativa nao cadastrada.';
      --Criar erro
      CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_cod_erro => 0
                           ,pr_dsc_erro => vr_des_erro
                           ,pr_flg_erro => TRUE
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= vr_des_erro;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    

    -- VALIDAR DAT    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver¿ raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;    
    

    -- VALIDAR CONTA    
    IF pr_nrdconta = 0 THEN
      vr_dscritic := 'Conta deve ser informada!';
      RAISE vr_exc_saida;

    ELSE
      -- VALIDAR ASS            (9)
      --Encontrar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass INTO rw_crapass;
      --Se encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 9);
        RAISE vr_exc_saida;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      
      pr_nmprimtl := rw_crapass.nmprimtl;
     
      -- VALIDAR DATA ELIMIN   (410)
      IF rw_crapass.dtelimin IS NOT NULL THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 410);
        RAISE vr_exc_saida;
      END IF;
      
      -- VALIDAR CDSITDTL
      IF rw_crapass.cdsitdtl IN(2,4,6,8) THEN
        -- Conta TRF
        OPEN cr_craptrf (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        --Posicionar no proximo registro
        FETCH cr_craptrf INTO rw_craptrf;
        --Se encontrar
        IF cr_craptrf%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craptrf;

          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 95);
          RAISE vr_exc_saida;
        END IF;
        --Fechar Cursor
        CLOSE cr_craptrf;
        
        vr_nrdconta := rw_craptrf.nrsconta;
        IF rw_craptrf.nrsconta > 0 THEN
          pr_dsmensag := 'Conta transferida do Numero ' 
                  || gene0002.fn_mask_conta(pr_nrdconta) || ' para o numero '
                  || gene0002.fn_mask_conta(vr_nrdconta);          
        END IF;

      END IF;

      -- VALIDAR CDTIPCTA 6/7  (17)
      IF rw_crapass.cdtipcta IN(6,7) THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 17);
        RAISE vr_exc_saida;
      END IF;
      
    END IF;   -- FIM VALIDACAO ASS

    -- VALIDACAO EPR
    OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp);
    --Posicionar no proximo registro
    FETCH cr_crapepr INTO rw_crapepr;
    --Se encontrar
    IF cr_crapepr%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapepr;

      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 356);
      RAISE vr_exc_saida;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapepr;
    
      IF rw_crapepr.tpdescto = 2 THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 987);
        RAISE vr_exc_saida;        
      END IF;

      IF  rw_crapepr.inliquid > 0
      AND rw_crapepr.inprejuz = 0 THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 358);
        RAISE vr_exc_saida;        
      END IF;
          
    END IF;

    


    IF pr_flgpasso = 2 THEN
      -- PASSO 2 DA VALIDAÇÃO
      -- valida-valores
      -- VALIDAR VALOR SE É ZERO
      IF pr_vlctrpag = 0 THEN
        pr_dscritic := 'Valor deve ser informado!';
        RAISE vr_exc_saida;         
      END IF;

      -- VALIDAR VALOR SE É MAIOR QUE SALDO DEVEDOR 
        -- (OU AO SOMATORIO DAS PARCELAS)
      -- Leitura do indicador de uso da tabela de taxa de juros                                                    
      vr_parempct := tabe0001.fn_busca_dstextab(pr_cdcooper => 3 /*Fixo Cecred*/
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPCTL'
                                               ,pr_tpregist => 1);       
                                                 
      -- busca o tipo de documento GED    
      vr_digitali := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'DIGITALIZA'
                                               ,pr_tpregist => 5);        
        
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Se a primeira posição do campo
        -- dstextab for diferente de zero
        IF SUBSTR(vr_dstextab,1,1) != '0' THEN
          -- É porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- Não existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- Não existe
        vr_inusatab := FALSE;
      END IF;        
        
        
      vr_tab_dados_epr.delete;
      
      -- Busca saldo total de emprestimos
      EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdagenci => 1                   --> Código da agência
                                      ,pr_nrdcaixa => 1                   --> Número do caixa
                                      ,pr_cdoperad => '1'                 --> Código do operador
                                      ,pr_nmdatela => 'CRAP090'        --> Nome datela conectada
                                      ,pr_idorigem => 2                   --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                      ,pr_idseqttl => 1 -- pr_idseqttl    --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => rw_crapdat     --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                      ,pr_nrctremp => pr_nrctremp         --> Número contrato empréstimo
                                      ,pr_cdprogra => 'CRAP090'        --> Programa conectado
                                      ,pr_inusatab => vr_inusatab         --> Indicador de utilização da tabela
                                      ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                      ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                      ,pr_nmprimtl => ' '                 --> Nome Primeiro Titular
                                      ,pr_tab_parempctl  => vr_parempct   --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_digitali   --> Dados tabela parametro
                                      ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                      ,pr_nrregist => 0                   --> Qtd registro por pagina
                                      ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                      ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                      ,pr_des_reto => pr_retorno          --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros

      -- Se ocorreu erro
      IF pr_retorno <> 'OK' THEN
        -- Se tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          pr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          pr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          pr_cdcritic := 983; -- Não foi possivel calcular o saldo devedor
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 983);
        END IF;
        --Sair com erro
        RAISE vr_exc_saida;
      END IF;
    
      -- Condicao para verificar se encontrou contrato de emprestimo
      IF vr_tab_dados_epr.COUNT > 0 THEN
        -- Saldo Devedor
        vr_vlsdeved := nvl(vr_tab_dados_epr(1).vlsdeved,0) + nvl(vr_tab_dados_epr(1).vlmtapar,0) 
                     + nvl(vr_tab_dados_epr(1).vlmrapar,0) + nvl(vr_tab_dados_epr(1).vliofcpl,0);
        -- Saldo Prejuizo
        vr_vlsdprej := nvl(vr_tab_dados_epr(1).vlsdprej,0);
        -- Valor em Atraso
        vr_vlatraso := nvl(vr_tab_dados_epr(1).vltotpag,0);
      END IF;
      
      IF pr_vlctrpag > vr_vlsdeved THEN
        pr_dscritic := 'Valor informado é superior ao Saldo Devedor do empréstimo!' ||
                       ' (R$ '||vr_vlsdeved || ')';
        --Sair com erro
        RAISE vr_exc_saida;  
      END IF;

       
      -- VERIFICAR SE HÁ OUTRAS VALIDAÇÕES NECESSARIAS REFERENTE 
      -- A VALOR INFORMADO E VALOR DO EMPRESTIMO

    END IF;



    -- SE TUDO DEU CERTO...   
    pr_retorno  := 'OK';
    COMMIT;
    

  EXCEPTION
    WHEN vr_sair THEN
      -- SAIR COM A TRANSACAO PENDENTE
      COMMIT;    

    WHEN vr_exc_saida THEN
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := pr_dscritic;
      pr_retorno  := 'NOK';

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- 0-ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1 --pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Validacao Pagamento nao efetuada! (Erro: '|| to_char(SQLCODE) || ')';
      pr_cdcritic := 0;
      pr_retorno  := 'NOK';

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => 'Erro PC_VALIDA_PAGTO_EMPREST: '||SQLERRM
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1 --pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG

  END pc_valida_pagto_emprest;


  PROCEDURE pc_efetua_pagto_emprest( pr_cdcooper       IN NUMBER   --> Coop. 
                                    ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                    ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                    ,pr_cdoperad       IN VARCHAR2   --> Operador
                                    ,pr_nmdatela       IN VARCHAR2
                                    ,pr_cdorigem       IN NUMBER
                                    ,pr_nrdconta       IN NUMBER
                                    ,pr_idseqttl       IN NUMBER
                                    ,pr_dtmvtolt       IN DATE
                                    ,pr_dtmvtopr       IN DATE
                                    ,pr_dtcalcul       IN DATE
                                    ,pr_nrctremp       IN NUMBER
                                    ,pr_vlctrpag       IN NUMBER
                                    ,pr_nmsistem       IN VARCHAR2
                                    ,pr_inproces       IN NUMBER
                                    ,pr_flgerlog       IN NUMBER 
                                    ,pr_flgcondc       IN NUMBER
                                    -- OUT
                                    ,pr_nrdocmto       OUT NUMBER    -- Alterar para nrdocmto
                                    ,pr_dslitera       OUT VARCHAR2
                                    ,pr_cdultseq       OUT NUMBER                                   
                                    ,pr_retorno        OUT VARCHAR2
                                    ,pr_cdcritic       OUT INTEGER    --> Cod. Critica
                                    ,pr_dscritic       OUT VARCHAR2   --> Des. da Critica
                                    ) IS                                  
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : siscaixa/web/crap090.w
   --  Sistema  : Rotina 90 Caixa-Online - Pagamento de Emprestimo (Sem Conta Corrente)
   --  Sigla    : CRED
   --  Autor    : Guilherme/AMcom
   --  Data     : Maio/2018.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Pagamento de Emprestimo (Sem Conta Corrente)

   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nmextcop
            ,cop.cdagectl
            ,cop.nrtelsac
            ,cop.nrtelouv
            ,cop.hrinisac
            ,cop.hrfimsac
            ,cop.hriniouv
            ,cop.hrfimouv
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca dos dados do associado */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.nmprimtl
            ,ass.inpessoa
            ,ass.dtelimin
            ,ass.cdsitdtl
            ,ass.cdagenci
            ,ass.cdtipcta
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

   -- Variaveis Erro
   vr_cdcritic      crapcri.cdcritic%TYPE;
   vr_dscritic      VARCHAR2(4000);
   vr_des_erro      VARCHAR2(4000);
   vr_exc_erro  EXCEPTION;
   vr_exc_saida EXCEPTION;
   vr_sair      EXCEPTION;
   vr_dsorigem  VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_cdorigem);
   vr_dstransa  VARCHAR2(100) := 'Pagamento Emprestimo Caixa';
   vr_nrdrowid  ROWID;

    
   -- Variaveis
   vr_busca    VARCHAR2(100);

   -- FUNCTIONS / PROCEDURES INTERNAS

   BEGIN
     

    -- 00 VALIDAR COOPER
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      --Mensagem erro
      pr_dscritic:= 'Cooperativa nao cadastrada.';
      --Criar erro
      CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_cod_erro => 0
                           ,pr_dsc_erro => vr_des_erro
                           ,pr_flg_erro => TRUE
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= vr_des_erro;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    

    -- 01 CARREGAR CRAPDAT
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver¿ raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;   
   


    -- APENAS PARA TESTES
        -- buscar o nrdocumento da forma correta do sistema
    pr_nrdocmto := to_char(SYStimestamp,'FF5YYMM');
/*    pr_cdultseq := 1;
*/    -- APENAS PARA TESTES

     

     
    -- 02 CARREGAR CONTA
     
    -- 03 CARREGAR CONTRATO
     
    -- 04 ROTINA PARA O PAGAMENTO DO EMPRESTIMO
        -- Utilizar o lote: 13000 + p-nro-caixa.
     
    -- 05 ARMAZENAR O NR DO DOCMENTO NA VARIAVEL DE RETORNO

    -- 06 ATUALIZAR OS DADOS DO BOLETIM DO CAIXA (INSS0002 TEM SIMILAR)

    -- 07 PREPARAR O CONTEUDO DO COMPROVANTE PARA DEVOLVER PRO CAIXA
    ------- GERAÇÃO DO COMPROVANTE ---------------------
    IF pr_cdorigem = 2 THEN -- Apenas CAIXA ON-LINE

      /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/

      -- Populando vetor
      vr_tab_literal.DELETE;
      vr_tab_literal(1):= TRIM(rw_crapcop.nmrescop) ||' - '||TRIM(rw_crapcop.nmextcop);
      vr_tab_literal(2):=  ' ';
      vr_tab_literal(3):= TO_CHAR(rw_crapdat.dtmvtocd,'DD/MM/RR')  ||' '||
                          TO_CHAR(SYSDATE,'HH24:MI:SS') ||' PA  '||
                          TRIM(TO_CHAR(gene0002.fn_mask(pr_cdagenci,'999')))  ||'  CAIXA: '||
                          TO_CHAR(gene0002.fn_mask(pr_nrdcaixa,'Z99')) || '/' ||
                          SUBSTR(pr_cdoperad,1,10);
      vr_tab_literal(4):=  ' ';
      vr_tab_literal(5):=  '  ** COMPROVANTE PAGAMENTO EMPRESTIMO ** ';
      vr_tab_literal(6):=  '              NR.: ' || pr_nrdocmto || '              ';

      vr_tab_literal(7):=  ' ';
      vr_tab_literal(8):=  ' ';
      vr_tab_literal(9):=  'AGENCIA: '||TRIM(TO_CHAR(rw_crapcop.cdagectl,'9999')) ||
                           ' - ' ||TRIM(rw_crapcop.nmrescop);
      vr_tab_literal(10):= 'CONTA..: '||TRIM(TO_CHAR(pr_nrdconta,'9999G999G9')) ||
                           '   PA: ' || TRIM(TO_CHAR(rw_crapass.cdagenci));
      vr_tab_literal(11):= '       ' || TRIM(rw_crapass.nmprimtl); -- NOME TITULAR 1

      vr_tab_literal(12):= ' ';
      vr_tab_literal(13):= ' ';
      vr_tab_literal(14):= ' ';
      vr_tab_literal(15):= '   DADOS DO PAGAMENTO                           ';
      vr_tab_literal(16):= '   ---------------------------------------      ';
      vr_tab_literal(17):= ' ';
      vr_tab_literal(18):= '   CONTRATO.........: '|| GENE0002.fn_mask_contrato(pr_nrctremp);
      vr_tab_literal(19):= '   DATA DO PAGAMENTO: '||TO_CHAR(rw_crapdat.dtmvtocd,'DD/MM/RRRR');
      vr_tab_literal(20):= '   VALOR PAGO.......: R$ '||to_char(pr_vlctrpag, 'fm99g999g990d00');
      vr_tab_literal(21):= ' ';
      vr_tab_literal(22):= ' ';
      vr_tab_literal(23):= ' ';
      vr_tab_literal(24):= ' ';
      vr_tab_literal(25):= ' ';
      vr_tab_literal(26):= ' ';
      vr_tab_literal(27):= ' ';
      vr_tab_literal(28):= fn_centraliza('SAC - '||rw_crapcop.nrtelsac,48);
      vr_tab_literal(29):= fn_centraliza('Atendimento todos os dias das '
        ||to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'MI'),'00')||' as '
        ||to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'MI'),'00') ,48);
      vr_tab_literal(30):= fn_centraliza('OUVIDORIA - '||rw_crapcop.nrtelouv,48);
      vr_tab_literal(31):= fn_centraliza('Atendimento nos dias uteis das '         
        ||to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'MI'),'00')||' as '
        ||to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'MI'),'00') ,48);
      vr_tab_literal(32):= ' ';
      vr_tab_literal(33):= ' ';
      vr_tab_literal(34):= ' ';
      vr_tab_literal(35):= ' * * * *        FIM DA IMPRESSAO        * * * *';
      vr_tab_literal(36):= ' ';
      vr_tab_literal(37):= ' ';
      vr_tab_literal(38):= ' ';
      vr_tab_literal(39):= ' ';
      vr_tab_literal(40):= ' ';       
      vr_tab_literal(41):= ' ';
      vr_tab_literal(42):= ' ';
      vr_tab_literal(43):= ' ';
      vr_tab_literal(44):= ' ';
      vr_tab_literal(45):= ' ';

      -- Inicializa Variavel
      pr_dslitera := NULL;
      pr_dslitera:= RPAD(NVL(vr_tab_literal(1),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(2),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(3),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(4),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(5),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(6),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(7),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(8),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(9),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(10),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(11),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(12),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(13),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(14),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(15),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(16),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(17),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(18),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(19),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(20),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(21),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(22),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(23),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(24),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(25),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(26),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(27),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(28),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(29),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(30),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(31),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(32),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(33),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(34),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(35),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(36),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(37),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(38),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(39),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(40),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(41),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(42),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(43),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(44),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(45),'  '),48,' ');


      ------- GERAÇÃO DA AUTENTICACAO ---------------------
      vr_busca :=  TRIM(pr_cdcooper)    || ';' ||
                   TRIM(pr_cdagenci)    || ';' ||
                   TRIM(pr_nrdcaixa)    || ';' ||
                   TO_char(rw_crapdat.dtmvtocd,'dd/mm/yyyy');

      pr_cdultseq := fn_sequence('CRAPAUT','NRSEQUEN',vr_busca);

      -- Inserir autenticacao
      BEGIN
         INSERT INTO crapaut(crapaut.cdcooper
                            ,crapaut.cdagenci
                            ,crapaut.nrdcaixa
                            ,crapaut.dtmvtolt
                            ,crapaut.nrsequen
                            ,crapaut.cdopecxa
                            ,crapaut.hrautent
                            ,crapaut.vldocmto
                            ,crapaut.nrdocmto
                            ,crapaut.tpoperac
                            ,crapaut.cdstatus
                            ,crapaut.estorno
                            ,crapaut.cdhistor
                            ,crapaut.dslitera)
                     VALUES (pr_cdcooper
                            ,pr_cdagenci
                            ,pr_nrdcaixa
                            ,rw_crapdat.dtmvtocd
                            ,pr_cdultseq
                            ,pr_cdoperad
                            ,GENE0002.fn_busca_time
                            ,pr_vlctrpag
                            ,0
                            ,0 --Nao estorno
                            ,'1' -- On-line
                            ,0
                            ,1414
                            ,pr_dslitera);
      EXCEPTION
        WHEN OTHERS THEN
          -- Libera Tabela de Memoria
          vr_tab_literal.DELETE;
          pr_dslitera :=  NULL;
          -- Levantar Excecao
          pr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
          RAISE vr_exc_saida;
      END;
      ------- FIM GERAÇÃO DA AUTENTICACAO -----------------

      -- Libera Tabela de Memoria
      vr_tab_literal.DELETE;
    END IF; -- FIM - Apenas CAIXA ON-LINE

    ------- FIM GERAÇÃO COMPROVANTE ---------------------


    ------- GRAVAÇÃO LOG VERLOG -------------------------
    -- Se houve sucesso, seta critica do log:
    vr_dscritic := 'Pagamento emprestimo efetuado no Caixa!';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NVL(vr_dscritic,' ')
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1-TRUE/SUCESSO
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Log Item => Contrato
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Contrato'
                            , pr_dsdadant => TRIM(TO_CHAR(GENE0002.fn_mask_contrato(pr_nrctremp)))
                            , pr_dsdadatu => ' ');
    -- Log Item => Valor
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Valor Pago'
                            , pr_dsdadant => TRIM(to_char(pr_vlctrpag, 'fm99g999g990d00'))
                            , pr_dsdadatu => ' ');
    -- Log Item => Documento
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Documento'
                            , pr_dsdadant => TRIM(TO_CHAR(pr_nrdocmto))
                            , pr_dsdadatu => ' ');
    -- Log Item => Ultima Sequencia
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Ult.Seq.'
                            , pr_dsdadant => TRIM(TO_CHAR(pr_cdultseq,'999G999G999D99'))
                            , pr_dsdadatu => ' ');
    ------- GRAVAÇÃO LOG VERLOG -------------------------





    -- SE TUDO DEU CERTO...   
    pr_retorno  := 'OK';
    COMMIT;

  EXCEPTION
    WHEN vr_sair THEN
      -- SAIR COM A TRANSACAO PENDENTE
      COMMIT;    
    WHEN vr_exc_saida THEN
      pr_dscritic := 'Pagamento não efetuado! =>' || pr_dscritic;
      pr_cdcritic := 0;
      pr_retorno  := 'NOK';
      pr_dslitera := '';
      pr_cdultseq := 0;

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
    WHEN OTHERS THEN
      pr_dscritic := 'Pagamento não efetuado! (Erro: '|| to_char(SQLCODE) || ')';
      pr_cdcritic := 0;
      pr_retorno  := 'NOK';
      pr_dslitera := '';
      pr_cdultseq := 0;
      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => 'Erro PC_EFETUA_PAGTO_EMPREST: '||SQLERRM
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG

  END pc_efetua_pagto_emprest;




  PROCEDURE pc_valida_estorno_emprest( pr_cdcooper       IN NUMBER    --> Coop.
                                      ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                      ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                      ,pr_nrdconta       IN NUMBER
                                      ,pr_nrdocmto       IN NUMBER
                                      ,pr_cdorigem       IN NUMBER
                                      ,pr_cdoperad       IN VARCHAR2
                                      ,pr_nmdatela       IN VARCHAR2
                                      -- OUT
                                      ,pr_valorest       OUT NUMBER
                                      ,pr_nmprimtl       OUT VARCHAR2
                                      ,pr_dsmensag       OUT VARCHAR2
                                      ,pr_retorno        OUT VARCHAR2
                                      ,pr_cdcritic       OUT INTEGER    --> Cod. Critica
                                      ,pr_dscritic       OUT VARCHAR2   --> Des. da Critica
                                      ) IS
   ---------------------------------------------------------------------------------------------------------------
   --
   --  Programa : siscaixa/web/crap090.w
   --  Sistema  : Rotina 91 Caixa-Online - Estorno Pagamento de Emprestimo (Sem Conta Corrente)
   --  Sigla    : CRED
   --  Autor    : Guilherme/AMcom
   --  Data     : Maio/2018.                   Ultima atualizacao:
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Validar Estorno Pagamento de Emprestimo (Sem Conta Corrente)

   -- Alteracoes:
   ---------------------------------------------------------------------------------------------------------------

    -- CURSORES
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
            ,crapcop.nrtelura
            ,crapcop.dsdircop
            ,crapcop.cdbcoctl
            ,crapcop.cdagectl
            ,crapcop.flgoppag
            ,crapcop.flgopstr
            ,crapcop.inioppag
            ,crapcop.fimoppag
            ,crapcop.iniopstr
            ,crapcop.fimopstr
            ,crapcop.cdagebcb
            ,crapcop.dssigaut
            ,crapcop.cdagesic
            ,crapcop.nrtelsac
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca dos dados do associado */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.nmprimtl
            ,ass.inpessoa
            ,ass.dtelimin
            ,ass.cdsitdtl
            ,ass.cdagenci
            ,ass.cdtipcta
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_craptrf(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT trf.nrdconta
            ,trf.nrsconta      
        FROM craptrf trf
       WHERE trf.cdcooper = pr_cdcooper
         AND trf.nrdconta = pr_nrdconta
         AND trf.tptransa = 1
         AND trf.insittrs = 2;
    rw_craptrf cr_craptrf%ROWTYPE;                     

    /* Cursor de Lançamentos Emprestimos */
    CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplem.cdagenci%TYPE
                     ,pr_nrdolote IN craplem.nrdolote%TYPE
                     ,pr_nrdconta IN craplem.nrdconta%TYPE
                     ,pr_nrdocmto IN craplem.nrdocmto%TYPE) IS
      SELECT lem.vllanmto
        FROM craplem lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.dtmvtolt = pr_dtmvtolt
         AND lem.cdagenci = pr_cdagenci
         AND lem.cdbccxlt = 11 -- Fixo
         AND lem.nrdolote = pr_nrdolote
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrdocmto = pr_nrdocmto;        
    rw_craplem cr_craplem%ROWTYPE;

    -- BUSCA DOS DADOS DE LOTES
    CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                      pr_cdagenci IN crapepr.cdagenci%TYPE,
                      pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.progress_recid
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND lot.dtmvtolt = pr_dtmvtolt -- DATA DE MOVIMENTACAO
         AND lot.cdagenci = pr_cdagenci -- NUMERO DO PA
         AND lot.cdbccxlt = 11
         AND lot.nrdolote = pr_nrdolote -- NUMERO DO LOTE
       ORDER BY lot.progress_recid DESC;
    rw_craplot cr_craplot%ROWTYPE;


    -- Variaveis Erro
    -- vr_exc_erro  EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_sair          EXCEPTION;
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(4000);
    vr_des_erro      VARCHAR2(4000);
    vr_tab_erro      gene0001.typ_tab_erro;

    -- Variaveis
    vr_nrdolote      craplem.nrdolote%TYPE;
    vr_nrtrfcta      crapass.nrdconta%TYPE;
    vr_nrdconta      crapass.nrdconta%TYPE;
    vr_dstextab      craptab.dstextab%TYPE;
    vr_inusatab      BOOLEAN;
    vr_parempct      craptab.dstextab%TYPE;
    vr_digitali      craptab.dstextab%TYPE;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_qtregist      INTEGER;    
    vr_dsorigem      VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_cdorigem);
    vr_dstransa      VARCHAR2(100) := 'Validacao Estorno Emprestimo Caixa';
    vr_vlsdeved      crapepr.vlsdeved%TYPE;
    vr_vlsdprej      crapepr.vlsdprej%TYPE;
    vr_vlatraso      crapepr.vlsdeved%TYPE;
    vr_nrdrowid      ROWID;
    
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  BEGIN

    --Inicializar parametros erro
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    pr_valorest := 0;


    -- VALIDAR COOP
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      --Mensagem erro
      pr_dscritic:= 'Cooperativa nao cadastrada.';
      --Criar erro
      CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_cod_erro => 0
                           ,pr_dsc_erro => vr_des_erro
                           ,pr_flg_erro => TRUE
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= vr_des_erro;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    

    -- VALIDAR DAT    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver¿ raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;    

    
    -- VALIDAR CONTA    
    IF pr_nrdconta = 0 THEN
      vr_dscritic := 'Conta deve ser informada!';
      RAISE vr_exc_saida;

    ELSE
      -- VALIDAR ASS            (9)
      --Encontrar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass INTO rw_crapass;
      --Se encontrar
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 9);
        RAISE vr_exc_saida;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      
      pr_nmprimtl := rw_crapass.nmprimtl;
     
      -- VALIDAR DATA ELIMIN   (410)
      IF rw_crapass.dtelimin IS NOT NULL THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 410);
        RAISE vr_exc_saida;
      END IF;

      -- VALIDAR CDTIPCTA 6/7  (17)
      IF rw_crapass.cdtipcta IN(6,7) THEN
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 17);
        RAISE vr_exc_saida;
      END IF;

    END IF;   -- FIM VALIDACAO ASS


    -- VALIDAR O DOCUMENTO SE é 0
    IF pr_nrdocmto = 0 THEN
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 22);
      RAISE vr_exc_saida;
    END IF;


    -- BUSCAR UTILIZANDO O LOTE 13000 + NRDCAIXA
    vr_nrdolote := 13000 + pr_nrdcaixa;

    -- VALIDACAO LEM
    OPEN cr_craplem( pr_cdcooper => pr_cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_cdagenci => pr_cdagenci
                    ,pr_nrdolote => vr_nrdolote
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrdocmto => pr_nrdocmto);
    --Posicionar no proximo registro
    FETCH cr_craplem INTO rw_craplem;
    --Se encontrar
    IF cr_craplem%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_craplem;

      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 90);
      RAISE vr_exc_saida;
    ELSE
      --Fechar Cursor
      CLOSE cr_craplem;
    END IF;

    -- VALIDACAO LOT
    OPEN cr_craplot( pr_cdcooper => pr_cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_nrdolote => vr_nrdolote
                    ,pr_cdagenci => pr_cdagenci);
    --Posicionar no proximo registro
    FETCH cr_craplot INTO rw_craplot;
    --Se encontrar
    IF cr_craplot%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_craplot;

      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 60);
      RAISE vr_exc_saida;
    END IF;
    --Fechar Cursor
    CLOSE cr_craplot;

    pr_valorest := rw_craplem.vllanmto;
   




    -- SE TUDO DEU CERTO...   
    pr_retorno  := 'OK';
    COMMIT;

  EXCEPTION
    WHEN vr_sair THEN
      -- SAIR COM A TRANSACAO PENDENTE
      COMMIT;    

    WHEN vr_exc_saida THEN
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := pr_dscritic;
      pr_retorno  := 'NOK';

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1 --pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Validacao Pagamento nao efetuada! (Erro: '|| to_char(SQLCODE) || ')';
      pr_cdcritic := 0;
      pr_retorno  := 'NOK';

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => 'Erro PC_VALIDA_PAGTO_EMPREST: '||SQLERRM
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1 --pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG

  END pc_valida_estorno_emprest;


   PROCEDURE pc_estorna_pagto_emprest(pr_cdcooper       IN NUMBER    --> Coop.
                                     ,pr_cdagenci       IN NUMBER     --> Cod. Agencia
                                     ,pr_nrdcaixa       IN NUMBER     --> Nro Caixa
                                     ,pr_nrdconta       IN NUMBER
                                     ,pr_nrdocmto       IN NUMBER
                                     ,pr_cdorigem       IN NUMBER
                                     ,pr_cdoperad       IN VARCHAR2
                                     ,pr_nmdatela       IN VARCHAR2  
                                     -- OUT
                                     ,pr_valorest       OUT NUMBER
                                     ,pr_nrdocaut       OUT NUMBER
                                     ,pr_dslitera       OUT VARCHAR2
--                                     ,pr_cdultseq       OUT NUMBER   
                                     ,pr_dsmensag       OUT VARCHAR2               
                                     ,pr_retorno        OUT VARCHAR2
                                     ,pr_cdcritic       OUT INTEGER  
                                     ,pr_dscritic       OUT VARCHAR2
                                    ) IS
   ----------------------------------------------------------------------------------------------------------------
   --
   --  Programa : siscaixa/web/crap091.w
   --  Sistema  : Rotina 91 Caixa-Online - Estorno Pagamento de Emprestimo (Sem Conta Corrente)
   --  Sigla    : CRED
   --  Autor    : Guilherme/AMcom
   --  Data     : Maio/2018                       Ultima atualizacao: 
   --
   -- Dados referentes ao programa:
   --
   -- Frequencia: -----
   -- Objetivo  : Estorno de Pagamentos de Emprestimo (Sem Conta Corrente)
   --
   -- Alterações: 
   --                     
   --
   --
   ---------------------------------------------------------------------------------------------------------------*/

    -- CURSORES
    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nmextcop
            ,cop.cdagectl
            ,cop.nrtelsac
            ,cop.nrtelouv
            ,cop.hrinisac
            ,cop.hrfimsac
            ,cop.hriniouv
            ,cop.hrfimouv
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca dos dados do associado */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.nmprimtl
            ,ass.inpessoa
            ,ass.dtelimin
            ,ass.cdsitdtl
            ,ass.cdagenci
            ,ass.cdtipcta
            ,ass.nrcpfcgc
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_craptrf(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT trf.nrdconta
            ,trf.nrsconta      
        FROM craptrf trf
       WHERE trf.cdcooper = pr_cdcooper
         AND trf.nrdconta = pr_nrdconta
         AND trf.tptransa = 1
         AND trf.insittrs = 2;
    rw_craptrf cr_craptrf%ROWTYPE;                     

    /* Cursor de Lançamentos Emprestimos */
    CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplem.cdagenci%TYPE
                     ,pr_nrdolote IN craplem.nrdolote%TYPE
                     ,pr_nrdconta IN craplem.nrdconta%TYPE
                     ,pr_nrdocmto IN craplem.nrdocmto%TYPE) IS
      SELECT lem.vllanmto
            ,lem.nrctremp
        FROM craplem lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.dtmvtolt = pr_dtmvtolt
         AND lem.cdagenci = pr_cdagenci
         AND lem.cdbccxlt = 11 -- Fixo
         AND lem.nrdolote = pr_nrdolote
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrdocmto = pr_nrdocmto;        
    rw_craplem cr_craplem%ROWTYPE;

    -- BUSCA DOS DADOS DE LOTES
    CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                      pr_cdagenci IN crapepr.cdagenci%TYPE,
                      pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.progress_recid
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
         AND lot.dtmvtolt = pr_dtmvtolt -- DATA DE MOVIMENTACAO
         AND lot.cdagenci = pr_cdagenci -- NUMERO DO PA
         AND lot.cdbccxlt = 11
         AND lot.nrdolote = pr_nrdolote -- NUMERO DO LOTE
       ORDER BY lot.progress_recid DESC;
    rw_craplot cr_craplot%ROWTYPE;


    -- Variaveis Erro
    -- vr_exc_erro  EXCEPTION;
    vr_exc_saida     EXCEPTION;
    vr_sair          EXCEPTION;
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(4000);
    vr_des_erro      VARCHAR2(4000);
    vr_tab_erro      gene0001.typ_tab_erro;

    -- Variaveis
    vr_nrdolote      craplem.nrdolote%TYPE;
    vr_nrtrfcta      crapass.nrdconta%TYPE;
    vr_nrdconta      crapass.nrdconta%TYPE;
    vr_nmprimtl      crapass.nmprimtl%TYPE;
    vr_dstextab      craptab.dstextab%TYPE;
    vr_inusatab      BOOLEAN;
    vr_parempct      craptab.dstextab%TYPE;
    vr_digitali      craptab.dstextab%TYPE;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_qtregist      INTEGER;    
    vr_dsorigem      VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_cdorigem);
    vr_dstransa      VARCHAR2(100) := 'Estorno Emprestimo Caixa';
    vr_vlsdeved      crapepr.vlsdeved%TYPE;
    vr_vlsdprej      crapepr.vlsdprej%TYPE;
    vr_vlatraso      crapepr.vlsdeved%TYPE;
    vr_nrdrowid      ROWID;

    -- Variaveis
    vr_busca         VARCHAR2(100);
    vr_cdultseq      INTEGER;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  BEGIN

    --Inicializar parametros erro
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    pr_valorest := 0;
    pr_nrdocaut := 0;
    pr_dslitera := '';
    pr_dsmensag := '';
    pr_retorno  := ''; 


    -- EFETUA NOVAMENTE A VALIDAÇÃO DOS DADOS
    pc_valida_estorno_emprest( pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdocmto => pr_nrdocmto
                              ,pr_cdorigem => pr_cdorigem
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_nmdatela => pr_nmdatela
                              -- OUT
                              ,pr_valorest => pr_valorest
                              ,pr_nmprimtl => vr_nmprimtl
                              ,pr_dsmensag => pr_dsmensag
                              ,pr_retorno  => pr_retorno
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic
                              );
    IF pr_cdcritic IS NOT NULL
    OR pr_dscritic IS NOT NULL THEN
       -- Critica ja está no parametro de retorno.
       RAISE vr_exc_saida;
    END IF;



    -- CARREGAR COOP
    --Verificar se a cooperativa existe
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- CARREGAR DAT    
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
   
    -- CARREGAR ASS
    -- Encontrar Associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    --Posicionar no proximo registro
    FETCH cr_crapass INTO rw_crapass;
    --Fechar Cursor
    CLOSE cr_crapass;

    -- BUSCAR UTILIZANDO O LOTE 13000 + NRDCAIXA
    vr_nrdolote := 13000 + pr_nrdcaixa;

    -- CARREGAR LEM
    OPEN cr_craplem( pr_cdcooper => pr_cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_cdagenci => pr_cdagenci
                    ,pr_nrdolote => vr_nrdolote
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrdocmto => pr_nrdocmto);
    --Posicionar no proximo registro
    FETCH cr_craplem INTO rw_craplem;
    --Fechar Cursor
    CLOSE cr_craplem;


    pr_valorest := rw_craplem.vllanmto;


    -- CARREGAR LOT
    OPEN cr_craplot( pr_cdcooper => pr_cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_nrdolote => vr_nrdolote
                    ,pr_cdagenci => pr_cdagenci);
    --Posicionar no proximo registro
    FETCH cr_craplot INTO rw_craplot;
    --Fechar Cursor
    CLOSE cr_craplot;

   
    -- CARREGAR EPR
    

    -- INSERIR PROCEDIMENTOS DO ESTORNO
       -- ETC
       -- ATUALIZAR/DELETAR 
          -- LEM / EPR / LOT
          -- SE O CONTRATO FOI LIQUIDADO, "DES-LIQUIDAR"
       -- RATING




      -- APENAS TESTES
      pr_nrdocaut := to_char(SYStimestamp,'FF5YYMM');


    -- EMITIR COMPROVANTE
    ------- GERAÇÃO DO COMPROVANTE ---------------------
    IF pr_cdorigem = 2 THEN -- Apenas CAIXA ON-LINE

      /*---- Gera literal autenticacao - RECEBIMENTO(Rolo) ----*/

      -- Populando vetor
      vr_tab_literal.DELETE;
      vr_tab_literal(1):= TRIM(rw_crapcop.nmrescop) ||' - '||TRIM(rw_crapcop.nmextcop);
      vr_tab_literal(2):=  ' ';
      vr_tab_literal(3):= TO_CHAR(rw_crapdat.dtmvtocd,'DD/MM/RR')  ||' '||
                          TO_CHAR(SYSDATE,'HH24:MI:SS') ||' PA  '||
                          TRIM(TO_CHAR(gene0002.fn_mask(pr_cdagenci,'999')))  ||'  CAIXA: '||
                          TO_CHAR(gene0002.fn_mask(pr_nrdcaixa,'Z99')) || '/' ||
                          SUBSTR(pr_cdoperad,1,10);
      vr_tab_literal(4):=  ' ';
      vr_tab_literal(5):=  '  ** COMPROVANTE ESTORNO PAGAMENTO EMPREST. **  ';
      vr_tab_literal(6):=  '              NR.: ' || pr_nrdocaut || '              ';

      vr_tab_literal(7):=  ' ';
      vr_tab_literal(8):=  ' ';
      vr_tab_literal(9):=  'AGENCIA: '||TRIM(TO_CHAR(rw_crapcop.cdagectl,'9999')) ||
                           ' - ' ||TRIM(rw_crapcop.nmrescop);
      vr_tab_literal(10):= 'CONTA..: '||TRIM(TO_CHAR(pr_nrdconta,'9999G999G9')) ||
                           '   PA: ' || TRIM(TO_CHAR(rw_crapass.cdagenci));
      vr_tab_literal(11):= '       ' || TRIM(rw_crapass.nmprimtl); -- NOME TITULAR 1

      vr_tab_literal(12):= ' ';
      vr_tab_literal(13):= ' ';
      vr_tab_literal(14):= ' ';
      vr_tab_literal(15):= '   DADOS DO ESTORNO DO PAGAMENTO                ';
      vr_tab_literal(16):= '   ---------------------------------------      ';
      vr_tab_literal(17):= ' ';
      vr_tab_literal(18):= '   CONTRATO.......: '|| GENE0002.fn_mask_contrato(rw_craplem.nrctremp);
      vr_tab_literal(19):= '   DATA DO ESTORNO: '||TO_CHAR(rw_crapdat.dtmvtocd,'DD/MM/RRRR');
      vr_tab_literal(20):= '   VALOR ESTORNO..: R$ '||to_char(pr_valorest, 'fm99g999g990d00');
      vr_tab_literal(21):= ' ';
      vr_tab_literal(22):= ' ';
      vr_tab_literal(23):= ' ';
      vr_tab_literal(24):= ' ';
      vr_tab_literal(25):= ' ';
      vr_tab_literal(26):= ' ';
      vr_tab_literal(27):= ' ';
      vr_tab_literal(28):= fn_centraliza('SAC - '||rw_crapcop.nrtelsac,48);
      vr_tab_literal(29):= fn_centraliza('Atendimento todos os dias das '
        ||to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrinisac,'SSSSS'),'MI'),'00')||' as '
        ||to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimsac,'SSSSS'),'MI'),'00') ,48);
      vr_tab_literal(30):= fn_centraliza('OUVIDORIA - '||rw_crapcop.nrtelouv,48);
      vr_tab_literal(31):= fn_centraliza('Atendimento nos dias uteis das '         
        ||to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hriniouv,'SSSSS'),'MI'),'00')||' as '
        ||to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'HH24"H"')||nullif(to_char(to_date(rw_crapcop.hrfimouv,'SSSSS'),'MI'),'00') ,48);
      vr_tab_literal(32):= ' ';
      vr_tab_literal(33):= ' ';
      vr_tab_literal(34):= ' ';
      vr_tab_literal(35):= ' * * * *        FIM DA IMPRESSAO        * * * *';
      vr_tab_literal(36):= ' ';
      vr_tab_literal(37):= ' ';
      vr_tab_literal(38):= ' ';
      vr_tab_literal(39):= ' ';
      vr_tab_literal(40):= ' ';       
      vr_tab_literal(41):= ' ';
      vr_tab_literal(42):= ' ';
      vr_tab_literal(43):= ' ';
      vr_tab_literal(44):= ' ';
      vr_tab_literal(45):= ' ';

      -- Inicializa Variavel
      pr_dslitera := NULL;
      pr_dslitera:= RPAD(NVL(vr_tab_literal(1),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(2),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(3),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(4),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(5),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(6),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(7),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(8),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(9),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(10),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(11),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(12),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(13),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(14),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(15),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(16),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(17),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(18),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(19),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(20),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(21),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(22),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(23),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(24),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(25),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(26),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(27),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(28),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(29),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(30),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(31),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(32),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(33),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(34),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(35),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(36),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(37),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(38),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(39),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(40),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(41),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(42),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(43),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(44),'  '),48,' ');
      pr_dslitera:= pr_dslitera||RPAD(NVL(vr_tab_literal(45),'  '),48,' ');


      ------- GERAÇÃO DA AUTENTICACAO ---------------------
      vr_busca :=  TRIM(pr_cdcooper)    || ';' ||
                   TRIM(pr_cdagenci)    || ';' ||
                   TRIM(pr_nrdcaixa)    || ';' ||
                   TO_char(rw_crapdat.dtmvtocd,'dd/mm/yyyy');

      vr_cdultseq := fn_sequence('CRAPAUT','NRSEQUEN',vr_busca);
      
     
      pr_retorno := vr_cdultseq;

      -- Inserir autenticacao
      BEGIN
         INSERT INTO crapaut(crapaut.cdcooper
                            ,crapaut.cdagenci
                            ,crapaut.nrdcaixa
                            ,crapaut.dtmvtolt
                            ,crapaut.nrsequen
                            ,crapaut.cdopecxa
                            ,crapaut.hrautent
                            ,crapaut.vldocmto
                            ,crapaut.nrdocmto
                            ,crapaut.tpoperac
                            ,crapaut.cdstatus
                            ,crapaut.estorno
                            ,crapaut.cdhistor
                            ,crapaut.dslitera)
                     VALUES (pr_cdcooper
                            ,pr_cdagenci
                            ,pr_nrdcaixa
                            ,rw_crapdat.dtmvtocd
                            ,vr_cdultseq
                            ,pr_cdoperad
                            ,GENE0002.fn_busca_time
                            ,pr_valorest
                            ,0
                            ,1 -- Estorno
                            ,'1' -- On-line
                            ,0
                            ,1414   -- REVER HISTORICO-- REVER HISTORICO-- REVER HISTORICO-- REVER HISTORICO
                            ,pr_dslitera);
      EXCEPTION
        WHEN OTHERS THEN
          -- Libera Tabela de Memoria
          vr_tab_literal.DELETE;
          pr_dslitera :=  NULL;
          -- Levantar Excecao
          pr_dscritic:= 'Erro ao atualizar no BL do caixa online. '||sqlerrm;
          RAISE vr_exc_saida;
      END;
      ------- FIM GERAÇÃO DA AUTENTICACAO -----------------

      -- Libera Tabela de Memoria
      vr_tab_literal.DELETE;
    END IF; -- FIM - Apenas CAIXA ON-LINE
    ------- FIM GERAÇÃO COMPROVANTE ---------------------

    ------- GRAVAÇÃO LOG VERLOG -------------------------
    -- Se houve sucesso, seta critica do log:
    vr_dscritic := 'Estorno de Pagamento efetuado no Caixa!';
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => NVL(vr_dscritic,' ')
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> 1-TRUE/SUCESSO
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Log Item => Contrato
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Contrato'
                            , pr_dsdadant => TRIM(TO_CHAR(GENE0002.fn_mask_contrato(rw_craplem.nrctremp)))
                            , pr_dsdadatu => ' ');
    -- Log Item => Valor
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Valor Estorno'
                            , pr_dsdadant => TRIM(to_char(pr_valorest, 'fm99g999g990d00'))
                            , pr_dsdadatu => ' ');
    -- Log Item => Documento
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Documento'
                            , pr_dsdadant => TRIM(TO_CHAR(pr_nrdocaut))
                            , pr_dsdadatu => ' ');
    -- Log Item => Ultima Sequencia
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                            , pr_nmdcampo => 'Ult.Seq.'
                            , pr_dsdadant => TRIM(TO_CHAR(vr_cdultseq,'999G999G999D99'))
                            , pr_dsdadatu => ' ');
    ------- GRAVAÇÃO LOG VERLOG -------------------------




    


    -- SE TUDO DEU CERTO...   
   -- pr_retorno  := 'OK';
    COMMIT;


  EXCEPTION
    WHEN vr_sair THEN
      -- SAIR COM A TRANSACAO PENDENTE
      COMMIT;    

    WHEN vr_exc_saida THEN
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := pr_dscritic;
      pr_retorno  := 'NOK';

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1 --pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG
      
      
    WHEN OTHERS THEN
      pr_dscritic := 'Validacao Pagamento nao efetuada! (Erro: '|| to_char(SQLCODE) || ')';
      pr_cdcritic := 0;
      pr_retorno  := 'NOK';

      -- Desfazer alterações
      ROLLBACK;
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => 'Erro PC_VALIDA_PAGTO_EMPREST: '||SQLERRM
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1 --pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      COMMIT; -- Commitar o LOG

   END pc_estorna_pagto_emprest;

END CXON0090;
/
