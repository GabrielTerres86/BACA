CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DESCTO IS

  PROCEDURE pc_ren_lim_desc_cheque_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
  
  PROCEDURE pc_desboq_lim_desc_chq_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
                                      
  PROCEDURE pc_confirma_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                       ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                       ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
  
END TELA_ATENDA_DESCTO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DESCTO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_DESCTO
  --  Sistema  : Ayllos Web
  --  Autor    : Lombardi
  --  Data     : Setembro - 2016                 Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Descontos dentro da ATENDA
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------
  
  PROCEDURE pc_ren_lim_desc_cheque_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: Pc_ren_lim_desc_cheque_web
    Sistema : Ayllos Web
    Autor   : Lombardi
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para renovar limite de desconto de cheques.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Chama rotina de renovação
      LIMI0001.pc_renovar_lim_desc_cheque(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_vllimite => pr_vllimite
                                         ,pr_nrctrlim => pr_nrctrlim
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nmdatela => vr_nmdatela
                                         ,pr_idorigem => vr_idorigem
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>ok</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_DESCTO: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_ren_lim_desc_cheque_web;
  
  PROCEDURE pc_desboq_lim_desc_chq_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: Pc_ren_lim_desc_cheque_web
    Sistema : Ayllos Web
    Autor   : Lombardi
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para desbloquear inclusao de desconto de cheques.

    Alteracoes: 
    ..............................................................................*/
    DECLARE
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Chama rotina de renovação
      LIMI0001.pc_desbloq_lim_desc_cheque(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctrlim => pr_nrctrlim
                                         ,pr_nrdcaixa => vr_nrdcaixa
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nmdatela => vr_nmdatela
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>ok</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_desboq_lim_desc_chq_web;
  
  PROCEDURE pc_confirma_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                       ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                       ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: Pc_ren_lim_desc_cheque_web
    Sistema : Ayllos Web
    Autor   : Lombardi
    Data    : Setembro/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para renovar limite de desconto de cheques.

    Alteracoes: 
    ..............................................................................*/
    DECLARE
    
      -- Verifica Conta
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT dtelimin
              ,cdsitdtl
              ,cdagenci
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper 
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Verifica Conta
      CURSOR cr_crapcdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrctrlim IN crapcdc.nrctrlim%TYPE) IS
        SELECT 1
          FROM crapcdc
         WHERE cdcooper = pr_cdcooper 
           AND nrdconta = pr_nrdconta 
           AND nrctrlim = pr_nrctrlim 
           AND tpctrlim = 2;
      rw_crapcdc cr_crapcdc%ROWTYPE;
      
      --Verifica limite
      CURSOR cr_craplim (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT nrctrlim
          FROM craplim
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta 
           AND tpctrlim = 2           
           AND insitlim = 2;
      rw_craplim cr_craplim%ROWTYPE;
      
      --Verifica limite
      CURSOR cr_craplim_ctr (pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_nrctrlim IN crapcdc.nrctrlim%TYPE) IS
        SELECT nrctrlim
              ,insitlim
              ,vllimite
              ,nrdconta
              ,tpctrlim
              ,cddlinha
              ,qtrenova
              ,nrctaav1
              ,nrctaav2
          FROM craplim
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta 
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = 2;
      rw_craplim_ctr cr_craplim_ctr%ROWTYPE;
      
      -- Busca cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT vlmaxleg
             ,vlmaxutl
             ,vlcnsscr
         FROM crapcop 
        WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Busca capa do lote
      CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT nrseqdig
              ,qtcompln
          FROM craplot
         WHERE cdcooper = pr_cdcooper 
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;
      
      -- Busca contratos que foram microfilmados.
      CURSOR cr_crapmcr (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN craplim.nrdconta%TYPE
                        ,pr_nrcontra IN craplim.nrctrlim%TYPE
                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT 1
          FROM crapmcr
         WHERE cdcooper = pr_cdcooper   
           AND nrdconta = pr_nrdconta
           AND nrcontra = pr_nrcontra
           AND tpctrmif = 2               
           AND tpctrlim = pr_tpctrlim;
      rw_crapmcr cr_crapmcr%ROWTYPE;
      
      -- Informações de data do sistema
      rw_crapdat  btch0001.rw_crapdat%TYPE; 
      
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida   EXCEPTION;
      vr_retorna_msg EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis auxiliares
      vr_flgfound     BOOLEAN;
      vr_vlmaxleg     crapcop.vlmaxleg%TYPE;
      vr_vlmaxutl     crapcop.vlmaxutl%TYPE;
      vr_vlminscr     crapcop.vlcnsscr%TYPE;
      vr_par_nrdconta INTEGER;
      vr_par_dsctrliq VARCHAR2(1000);
      vr_par_vlutiliz NUMBER;
      vr_qtctarel     INTEGER;
      vr_flggrupo     INTEGER;
      vr_nrdgrupo     INTEGER;
      vr_dsdrisco     VARCHAR2(2);
      vr_gergrupo     VARCHAR2(1000);
      vr_dsdrisgp     VARCHAR2(1000);
      vr_mensagem_01  VARCHAR2(1000);
      vr_mensagem_02  VARCHAR2(1000);
      vr_mensagem_03  VARCHAR2(1000);
      vr_mensagem_04  VARCHAR2(1000);
      vr_resposta     VARCHAR2(20);
      vr_tab_grupo    geco0001.typ_tab_crapgrp;
      vr_valor        craplim.vllimite%TYPE;
      vr_index        INTEGER;
      vr_str_grupo    VARCHAR2(32767) := '';
      vr_nrseqdig     rw_craplot.nrseqdig%TYPE;
      vr_qtcompln     rw_craplot.qtcompln%TYPE; 
      vr_vlutilizado  VARCHAR2(100) := '';
      vr_vlexcedido   VARCHAR2(100) := '';
      
      --PL tables  
      vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
      vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
      vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
      vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
      vr_tab_ratings          RATI0001.typ_tab_ratings;
      vr_tab_crapras          RATI0001.typ_tab_crapras;
      vr_tab_erro             GENE0001.typ_tab_erro;
      
    BEGIN
      
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                                ,pr_action => NULL);
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se ocorrer algum erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Verifica se existe a conta
      OPEN cr_crapass (vr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      vr_flgfound := cr_crapass%FOUND;
      CLOSE cr_crapass;
      -- Se nao existir
      IF NOT vr_flgfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se a conta foi eliminada
      IF rw_crapass.dtelimin IS NOT NULL THEN
        vr_cdcritic := 410;
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se a conta está em prejuizo
      IF rw_crapass.cdsitdtl IN (5,6,7,8) THEN
        vr_cdcritic := 695;
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se conta esta bloqueada
      IF rw_crapass.cdsitdtl IN (2,4) THEN
        vr_cdcritic := 95;
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se existe contrato
      IF pr_nrctrlim = 0 THEN
        vr_cdcritic := 22;
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se ja existe lancamento
      OPEN cr_crapcdc (vr_cdcooper, pr_nrdconta, pr_nrctrlim);
      FETCH cr_crapcdc INTO rw_crapcdc;
      vr_flgfound := cr_crapcdc%FOUND;
      CLOSE cr_crapcdc;
      IF vr_flgfound THEN
        vr_cdcritic := 92;
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se ja existe limite ativo
      OPEN cr_craplim(vr_cdcooper, pr_nrdconta);
      FETCH cr_craplim INTO rw_craplim;
      vr_flgfound := cr_craplim%FOUND;
      CLOSE cr_craplim;
      IF vr_flgfound THEN
        vr_dscritic:= 'O contrato' ||rw_craplim.nrctrlim || 'deve ser cancelado primeiro.';
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se ja existe limite ativo
      OPEN cr_craplim_ctr(vr_cdcooper, pr_nrdconta,pr_nrctrlim);
      FETCH cr_craplim_ctr INTO rw_craplim_ctr;
      vr_flgfound := cr_craplim_ctr%FOUND;
      CLOSE cr_craplim_ctr;
      IF NOT vr_flgfound THEN
        vr_cdcritic := 484;
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se esta em estudo
      IF rw_craplim_ctr.insitlim <> 1   THEN
        vr_dscritic := 'Deve estar em estudo.';
        RAISE vr_exc_saida;
      END IF;
        
      -- Verifica se o limite está diferente do registro
      IF rw_craplim_ctr.vllimite <> pr_vllimite   THEN
        vr_cdcritic := 91;
        RAISE vr_exc_saida;
      END IF;
        
      -- Inicializa variaveis
      vr_vlmaxleg := 0;
      vr_vlmaxutl := 0;
      vr_vlminscr := 0;
        
      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      vr_flgfound := cr_crapcop%FOUND;
      CLOSE cr_crapcop;
      -- Carrega informacoes da cooperativa
      IF vr_flgfound THEN
        vr_vlmaxleg := rw_crapcop.vlmaxleg;
        vr_vlmaxutl := rw_crapcop.vlmaxutl;
        vr_vlminscr := rw_crapcop.vlcnsscr;
      END IF;
        
      -- Inicializa variaveis
      vr_par_nrdconta := pr_nrdconta;
      vr_par_dsctrliq := ' ';
      vr_par_vlutiliz := 0;
      vr_qtctarel     := 0;
        
      -- Verifica se tem grupo economico em formacao
      GECO0001.pc_busca_grupo_associado (pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_flggrupo => vr_flggrupo
                                        ,pr_nrdgrupo => vr_nrdgrupo 
                                        ,pr_gergrupo => vr_gergrupo
                                        ,pr_dsdrisgp => vr_dsdrisgp);
      -- Se tiver grupo economico em formacao
      IF vr_gergrupo <> '' AND
         pr_cddopera < 1   THEN
        vr_mensagem_01 := vr_gergrupo || ' Confirma?';
      END IF;
      
      -- Se conta pertence a um grupo
      IF vr_flggrupo = 1 THEN
        geco0001.pc_calc_endivid_grupo(pr_cdcooper  => vr_cdcooper
                                      ,pr_cdagenci  => vr_cdagenci
                                      ,pr_nrdcaixa  => 0
                                      ,pr_cdoperad  => vr_cdoperad
                                      ,pr_nmdatela  => vr_nmdatela
                                      ,pr_idorigem  => 1
                                      ,pr_nrdgrupo  => vr_nrdgrupo
                                      ,pr_tpdecons  => TRUE
                                      ,pr_dsdrisco  => vr_dsdrisco
                                      ,pr_vlendivi  => vr_par_vlutiliz
                                      ,pr_tab_grupo => vr_tab_grupo
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);
        
        IF vr_cdcritic > 0 OR vr_dscritic <> '' THEN
          RAISE vr_exc_saida;
        END IF;
        
        IF vr_vlmaxutl > 0 THEN
          -- Verifica se o valor limite é maior que o valor da divida
          -- e pega o maior valor
          IF pr_vllimite > vr_par_vlutiliz THEN
            vr_valor := pr_vllimite;
          ELSE
            vr_valor := vr_par_vlutiliz;
          END IF;
          -- Verifica se o valor é maior que o valor maximo
          -- utilizado pelo associado nos emprestimos
          IF vr_valor > vr_vlmaxutl AND
             pr_cddopera < 1        THEN    
            vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
              to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' || 
              to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') ||
              '.';
          END IF;
          -- Verifica se o valor é maior que o valor legal
          -- a ser emprestado pela cooperativa
          IF vr_valor > vr_vlmaxleg AND
             pr_cddopera < 1        THEN
            
            vr_mensagem_03 := 'Valor Legal Excedido';            
            vr_vlutilizado := to_char(vr_par_vlutiliz,'999G999G990D00');
            vr_vlexcedido  := to_char((vr_valor - vr_vlmaxutl),'999G999G990D00');
            
            -- Abre tabela do grupo
            vr_str_grupo := '<grupo>';
            
            vr_qtctarel := 0;
            vr_index := vr_tab_grupo.first;
            WHILE vr_index IS NOT NULL LOOP
              -- Popula tabela do grupo
              vr_str_grupo := vr_str_grupo 
              || '<conta>' ||
              to_char(gene0002.fn_mask_conta((vr_tab_grupo(vr_index).nrctasoc)))
              || '</conta>';
              vr_index := vr_tab_grupo.next(vr_index);
              vr_qtctarel := vr_qtctarel + 1;
            END LOOP;
            -- Encerra tabela grupo
            vr_str_grupo := vr_str_grupo || '</grupo>' ||
             '<qtctarel>' || vr_qtctarel || '</qtctarel>';
            
          END IF;
          -- Verifica se o valor é maior que o valor da consulta SCR
          IF vr_valor > vr_vlminscr AND
             pr_cddopera < 1        THEN
            vr_mensagem_04 := 'Efetue consulta no SCR.';
          END IF;
        END IF;
      ELSE --  Se conta nao pertence a um grupo
        
        gene0005.pc_saldo_utiliza(pr_cdcooper    => vr_cdcooper
                                 ,pr_tpdecons    => 1
                                 ,pr_dsctrliq    => vr_par_dsctrliq
                                 ,pr_cdprogra    => vr_nmdatela
                                 ,pr_nrdconta    => vr_par_nrdconta
                                 ,pr_tab_crapdat => rw_crapdat
                                 ,pr_inusatab    => TRUE
                                 ,pr_vlutiliz    => vr_par_vlutiliz
                                 ,pr_cdcritic    => vr_cdcritic
                                 ,pr_dscritic    => vr_dscritic);
        
        IF vr_vlmaxutl > 0 THEN
          -- Verifica se o valor limite é maior que o valor da divida
          -- e pega o maior valor
          IF pr_vllimite > vr_par_vlutiliz THEN
            vr_valor := pr_vllimite;
          ELSE
            vr_valor := vr_par_vlutiliz;
          END IF;
          -- Verifica se o valor é maior que o valor maximo
          -- utilizado pelo associado nos emprestimos
          IF vr_valor > vr_vlmaxutl AND
             pr_cddopera < 1        THEN    
            vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
              to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' || 
              to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') || '.';
          END IF;
          -- Verifica se o valor é maior que o valor legal
          -- a ser emprestado pela cooperativa      
          IF vr_valor > vr_vlmaxleg AND
             pr_cddopera < 1        THEN
            vr_mensagem_03 := 'Valor legal excedido. Utilizado R$: ' ||
              to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
              to_char((vr_valor - vr_vlmaxleg),'999G999G990D00') || '.';
          END IF;
          -- Verifica se o valor é maior que o valor da consulta SCR
          IF vr_valor > vr_vlminscr AND
             pr_cddopera < 1        THEN
            vr_mensagem_04 := 'Efetue consulta no SCR.';
          END IF;
          
        END IF;
      END IF;
      
      -- Se houver alguma mensagem para o usuario
      IF vr_mensagem_01 IS NOT NULL OR
         vr_mensagem_02 IS NOT NULL OR
         vr_mensagem_03 IS NOT NULL OR
         vr_mensagem_04 IS NOT NULL THEN
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>' ||
                                       '<Msg>' ||
                                           '<msg_01>' || vr_mensagem_01 || '</msg_01>' ||
                                           '<msg_02>' || vr_mensagem_02 || '</msg_02>' ||
                                           '<msg_03>' || vr_mensagem_03 || '</msg_03>' ||
                                           '<msg_04>' || vr_mensagem_04 || '</msg_04>' ||
                                                          vr_str_grupo  ||
                                           '<vlutil>' || vr_vlutilizado || '</vlutil>' ||
                                           '<vlexce>' || vr_vlexcedido  || '</vlexce>' ||
                                       '</Msg></Root>');
      ELSE
        -- Verifica se ja existe lote criado
        OPEN cr_craplot(pr_cdcooper => vr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => vr_cdagenci
                       ,pr_cdbccxlt => 700
                       ,pr_nrdolote => 1);
        FETCH cr_craplot INTO rw_craplot;
        vr_flgfound := cr_craplot%FOUND;
        IF NOT vr_flgfound THEN
          -- Se não, cria novo lote
          BEGIN
            INSERT INTO craplot (cdcooper
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote)
                         VALUES (vr_cdcooper
                                ,rw_crapdat.dtmvtolt
                                ,vr_cdagenci
                                ,700
                                ,1)RETURNING nrseqdig,qtcompln
                                        INTO vr_nrseqdig, vr_qtcompln;
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir capa do lote. ' || SQLERRM;
            RAISE vr_exc_saida;
          END;
        ELSE
            vr_nrseqdig := rw_craplot.nrseqdig;
            vr_qtcompln := rw_craplot.qtcompln;
        END IF;
        
        -- Atualiza Limite de credito
        BEGIN
          UPDATE craplim
             SET insitlim = 2
                ,qtrenova = 0
                ,dtinivig = rw_crapdat.dtmvtolt
                ,dtfimvig = (rw_crapdat.dtmvtolt + craplim.qtdiavig)
           WHERE cdcooper = vr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctrlim = pr_nrctrlim
             AND tpctrlim = 2;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar limite de credito. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Verifica se ja existe contrato microfilmado
        OPEN cr_crapmcr (pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => rw_craplim_ctr.nrdconta
                        ,pr_nrcontra => rw_craplim_ctr.nrctrlim
                        ,pr_tpctrlim => rw_craplim_ctr.tpctrlim);
        FETCH cr_crapmcr INTO rw_crapmcr;
        vr_flgfound := cr_crapmcr%FOUND;
        CLOSE cr_crapmcr;
        IF vr_flgfound THEN    
          vr_cdcritic := 92;
          RAISE vr_exc_saida;
        END IF;
        
         -- Cria novo contrato para ser microfilmado
        BEGIN 
          INSERT INTO crapmcr (dtmvtolt 
                              ,cdagenci 
                              ,nrdolote 
                              ,cdbccxlt 
                              ,nrdconta 
                              ,nrcontra 
                              ,tpctrmif 
                              ,vlcontra 
                              ,nrctaav1 
                              ,nrctaav2 
                              ,tpctrlim 
                              ,qtrenova 
                              ,cddlinha 
                              ,cdcooper)
                      VALUES (rw_crapdat.dtmvtolt
                             ,rw_crapass.cdagenci
                             ,1
                             ,700
                             ,rw_craplim_ctr.nrdconta
                             ,rw_craplim_ctr.nrctrlim
                             ,2
                             ,rw_craplim_ctr.vllimite
                             ,rw_craplim_ctr.nrctaav1
                             ,rw_craplim_ctr.nrctaav2
                             ,rw_craplim_ctr.tpctrlim
                             ,rw_craplim_ctr.qtrenova
                             ,rw_craplim_ctr.cddlinha
                             ,vr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar contrato para ser microfilmado. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Cria lancamento de contratos de descontos.
        BEGIN
          INSERT INTO crapcdc (dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,nrdconta
                              ,nrctrlim
                              ,vllimite
                              ,nrseqdig
                              ,cdcooper
                              ,tpctrlim)
                       VALUES (rw_crapdat.dtmvtolt
                              ,vr_cdagenci
                              ,700
                              ,1
                              ,pr_nrdconta
                              ,pr_nrctrlim
                              ,pr_vllimite
                              ,vr_nrseqdig + 1
                              ,vr_cdcooper
                              ,2);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar lancamento de contratos de descontos. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Atualiza sequencial e Quantidade computada de lancamentos da e craplot
        BEGIN
          UPDATE craplot 
             SET nrseqdig = vr_nrseqdig + 1
                ,qtcompln = vr_qtcompln + 1
           WHERE cdcooper = vr_cdcooper
             AND dtmvtolt = rw_crapdat.dtmvtolt
             AND cdagenci = vr_cdagenci
             AND cdbccxlt = 700
             AND nrdolote = 1;             
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar capa do lote. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- gera rating
        rati0001.pc_gera_rating(pr_cdcooper => vr_cdcooper                         --> Codigo Cooperativa
                               ,pr_cdagenci => vr_cdagenci                         --> Codigo Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa                         --> Numero Caixa
                               ,pr_cdoperad => vr_cdoperad                         --> Codigo Operador
                               ,pr_nmdatela => 'ATENDA'                            --> Nome da tela
                               ,pr_idorigem => vr_idorigem                         --> Identificador Origem
                               ,pr_nrdconta => pr_nrdconta                         --> Numero da Conta
                               ,pr_idseqttl => 1                                   --> Sequencial do Titular
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt                 --> Data de movimento
                               ,pr_dtmvtopr => rw_crapdat.dtmvtopr                 --> Data do próximo dia útil
                               ,pr_inproces => rw_crapdat.inproces                 --> Situação do processo
                               ,pr_tpctrrat => 2                                   --> Tipo Contrato Rating
                               ,pr_nrctrrat => pr_nrctrlim                         --> Numero Contrato Rating
                               ,pr_flgcriar => 1                                   --> Criar rating
                               ,pr_flgerlog => 1                                   -->  Identificador de geração de log
                               ,pr_tab_rating_sing => vr_tab_crapras               --> Registros gravados para rating singular
                               ,pr_tab_impress_coop => vr_tab_impress_coop         --> Registro impressão da Cooperado
                               ,pr_tab_impress_rating => vr_tab_impress_rating     --> Registro itens do Rating
                               ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                               ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                               ,pr_tab_impress_assina => vr_tab_impress_assina     --> Assinatura na impressao do Rating
                               ,pr_tab_efetivacao => vr_tab_efetivacao             --> Registro dos itens da efetivação
                               ,pr_tab_ratings  => vr_tab_ratings                  --> Informacoes com os Ratings do Cooperado
                               ,pr_tab_crapras  => vr_tab_crapras                  --> Tabela com os registros processados
                               ,pr_tab_erro => vr_tab_erro                         --> Tabela de retorno de erro
                               ,pr_des_reto => pr_des_erro);                       --> Ind. de retorno OK/NOK
        -- Em caso de erro
        IF pr_des_erro <> 'OK' THEN
              
          vr_cdcritic:= vr_tab_erro(0).cdcritic;
          vr_dscritic:= vr_tab_erro(0).dscritic;                                                          
          
          pr_des_erro := 'NOK';
          RAISE vr_exc_saida;
          RETURN;
          
        END IF;
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
        
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_confirma_novo_limite_web;
  
END TELA_ATENDA_DESCTO;
/
