CREATE OR REPLACE PACKAGE CECRED.TELA_CONFRP AS
  
/*..............................................................................

   Programa: tela_confrp                        Antigo: Nao ha
   Sistema : Ayllos
   Sigla   : CRED
   Autor   : Marcos Martini - Supero
   Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente a tela CONFRP

   Alteracoes: 
  
..............................................................................*/
  
  /* Buscar configuracao de calculo de reprocidade */
  PROCEDURE pc_busca_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                       ,pr_inpessoa           IN tbrecip_parame_indica_coop.inpessoa%TYPE
                                       ,pr_cdproduto          IN tbrecip_parame_indica_coop.cdproduto%TYPE
                                       ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                       ,pr_xmllog             IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic           OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic           OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml             IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo           OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro           OUT VARCHAR2);             --Saida OK/NOK
  
  /* Salva configuracao de calculo de reprocidade */
  PROCEDURE pc_confirma_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                          ,pr_configrp           IN VARCHAR2
                                          ,pr_perdesmax          IN tbrecip_parame_calculo.perdesconto_maximo%TYPE
                                          ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                          ,pr_xmllog             IN VARCHAR2                --XML com informações de LOG
                                          ,pr_cdcritic           OUT PLS_INTEGER            --Código da crítica
                                          ,pr_dscritic           OUT VARCHAR2               --Descrição da crítica
                                          ,pr_retxml             IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                          ,pr_nmdcampo           OUT VARCHAR2               --Nome do Campo
                                          ,pr_des_erro           OUT VARCHAR2);             --Saida OK/NOK

END TELA_CONFRP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONFRP AS

/*..............................................................................

   Programa: tela_confrp                        Antigo: Nao ha
   Sistema : Ayllos
   Sigla   : CRED
   Autor   : Marcos Martini - Supero
   Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -------------------
   Objetivo  : Centralizar as rotinas referente a tela CONFRP

   Alteracoes: 
  
..............................................................................*/
 
  /* Buscar configuracao de calculo de reprocidade */
  PROCEDURE pc_busca_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                       ,pr_inpessoa           IN tbrecip_parame_indica_coop.inpessoa%TYPE
                                       ,pr_cdproduto          IN tbrecip_parame_indica_coop.cdproduto%TYPE
                                       ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                       ,pr_xmllog             IN VARCHAR2                --XML com informações de LOG
                                       ,pr_cdcritic           OUT PLS_INTEGER            --Código da crítica
                                       ,pr_dscritic           OUT VARCHAR2               --Descrição da crítica
                                       ,pr_retxml             IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                       ,pr_nmdcampo           OUT VARCHAR2               --Nome do Campo
                                       ,pr_des_erro           OUT VARCHAR2) IS           --Saida OK/NOK
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_conf_reciprocidade                  Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Lombardi
  --  Data     : Março/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Buscar configuracao de calculo de reprocidade.
  ---------------------------------------------------------------------------------------------------------------
    
    -- Busca dos valores previstos
    CURSOR cr_desconto_maximo(pr_idparame_reciproci tbrecip_parame_calculo.idparame_reciproci%TYPE) IS
      SELECT prc.perdesconto_maximo
        FROM tbrecip_parame_calculo prc
       WHERE prc.idparame_reciproci = pr_idparame_reciproci;
    rw_desconto_maximo cr_desconto_maximo%ROWTYPE;
    
    -- Busca das faixas parametrizadas
    CURSOR cr_parametrizacao(pr_idparame_reciproci  tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                            ,pr_inpessoa            tbrecip_parame_indica_coop.inpessoa%TYPE
                            ,pr_cdproduto           tbrecip_parame_indica_coop.cdproduto%TYPE
                            ,pr_cdcooper            crapcop.cdcooper%TYPE) IS
       SELECT 1 flgativo -- Se veio da tabela está sempre ativo
              ,irc.idindicador
              ,irc.nmindicador
              ,decode(irc.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
              ,ipr.vlminimo
              ,ipr.vlmaximo
              ,ipr.perscore
              ,ipr.pertolera
          FROM tbrecip_parame_indica_calculo ipr 
              ,tbrecip_indicador             irc
         WHERE ipr.idparame_reciproci = pr_idparame_reciproci
           AND ipr.idindicador = irc.idindicador
         UNION
        SELECT 0 flgativo -- Não selecionado
              ,irc.idindicador
              ,irc.nmindicador
              ,decode(irc.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
              ,ico.vlminimo
              ,ico.vlmaximo
              ,ico.perscore
              ,ico.pertolera
          FROM tbrecip_indicador          irc
              ,tbrecip_parame_indica_coop ico
         WHERE ico.idindicador = irc.idindicador
           AND ico.cdcooper    = pr_cdcooper
           AND irc.flgativo    = 1            --> Ativo globalmente
           AND ico.inpessoa    = pr_inpessoa  --> Tipo da pessoa atual
           AND ico.cdproduto   = pr_cdproduto --> Código do produto atual
           -- E o mesmo não está selecionado no cálculo atual
           AND NOT EXISTS(SELECT 1 
                            FROM tbrecip_parame_indica_calculo prc
                           WHERE prc.idparame_reciproci = pr_idparame_reciproci
                             AND prc.idindicador        = irc.idindicador)

         ORDER BY flgativo DESC, idindicador;
    
     -- Busca das faixas parametrizadas
    CURSOR cr_parametrizacao_2(pr_inpessoa            tbrecip_parame_indica_coop.inpessoa%TYPE
                              ,pr_cdproduto           tbrecip_parame_indica_coop.cdproduto%TYPE
                              ,pr_cdcooper            crapcop.cdcooper%TYPE) IS
      SELECT 0 flgativo -- Não selecionado
            ,irc.idindicador
            ,irc.nmindicador
            ,decode(irc.tpindicador,'A','Adesão','Q','Quantidade','Moeda') tpindicador
            ,ico.vlminimo
            ,ico.vlmaximo
            ,ico.perscore
            ,ico.pertolera
        FROM TBRECIP_INDICADOR   irc
            ,tbrecip_parame_indica_coop ico
       WHERE ico.idindicador = irc.idindicador
         AND ico.cdcooper    = pr_cdcooper
         AND irc.flgativo    = 1             --> Ativo globalmente
         AND ico.inpessoa    = pr_inpessoa  --> Tipo da pessoa atual
         AND ico.cdproduto   = pr_cdproduto --> Código do produto atual

       ORDER BY irc.idindicador;
    
    -- Variáveis genéricas
    vr_perdesmax NUMBER;
    vr_contador  INTEGER;
    vr_vlminimo  VARCHAR2(100);
    vr_vlmaximo  VARCHAR2(100);
    vr_pertolera VARCHAR2(100);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;
    
  BEGIN
     --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'RCIP0001'
                              ,pr_action => NULL);
    
    --Inicializar Variaveis
    vr_dscritic:= null;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    -- Buscar o valor o percentual máximo de desconto ao cálculo.
    OPEN cr_desconto_maximo(pr_idparame_reciproci);
    FETCH cr_desconto_maximo INTO rw_desconto_maximo;
   
    IF cr_desconto_maximo%FOUND THEN
      vr_perdesmax := rw_desconto_maximo.perdesconto_maximo;
    ELSE
      vr_perdesmax := 0;
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'Config',    pr_tag_cont => NULL,         pr_des_erro => vr_dscritic);
    
    vr_contador := 0;
    
    IF vr_perdesmax <> 0 THEN
      -- Buscar a parametrização já cadastrada.
      FOR rw_parametrizacao IN cr_parametrizacao(pr_idparame_reciproci
                                                ,pr_inpessoa          
                                                ,pr_cdproduto         
                                                ,pr_cdcooper) LOOP
        IF rw_parametrizacao.tpindicador = 'Adesão' THEN
          vr_vlminimo := '-';
          vr_vlmaximo := '-';
          vr_pertolera := '-';
        ELSE
          vr_vlminimo := RCIP0001.fn_format_valor_indicador(rw_parametrizacao.idindicador, rw_parametrizacao.vlminimo);
          vr_vlmaximo := RCIP0001.fn_format_valor_indicador(rw_parametrizacao.idindicador, rw_parametrizacao.vlmaximo);
          vr_pertolera := to_char(nvl(rw_parametrizacao.pertolera,0),'fm990d00');
        END IF;
        
        -- Insere as tags dos campos da PLTABLE de aplicações
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Config', pr_posicao => 0     , pr_tag_nova => 'Reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'flgativo', pr_tag_cont => rw_parametrizacao.flgativo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'idindicador', pr_tag_cont => rw_parametrizacao.idindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'nmindicador', pr_tag_cont => rw_parametrizacao.nmindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'tpindicador', pr_tag_cont => rw_parametrizacao.tpindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'vlminimo',    pr_tag_cont => vr_vlminimo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'vlmaximo',    pr_tag_cont => vr_vlmaximo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'perscore',    pr_tag_cont => to_char(nvl(rw_parametrizacao.perscore,0),'fm990d00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'pertolera',   pr_tag_cont => vr_pertolera, pr_des_erro => vr_dscritic); 
        vr_contador := vr_contador + 1;
      END LOOP;
    ELSE
      -- Buscar a parametrização já cadastrada.
      FOR rw_parametrizacao IN cr_parametrizacao_2(pr_inpessoa          
                                                ,pr_cdproduto         
                                                ,pr_cdcooper) LOOP
        IF rw_parametrizacao.tpindicador = 'Adesão' THEN
          vr_vlminimo := '';
          vr_vlmaximo := '';
          vr_pertolera := '';
        ELSE
          vr_vlminimo := RCIP0001.fn_format_valor_indicador(rw_parametrizacao.idindicador, rw_parametrizacao.vlminimo);
          vr_vlmaximo := RCIP0001.fn_format_valor_indicador(rw_parametrizacao.idindicador, rw_parametrizacao.vlmaximo);
          vr_pertolera := to_char(nvl(rw_parametrizacao.pertolera,0),'fm990d00');
        END IF;
        
        -- Insere as tags dos campos da PLTABLE de aplicações
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Config', pr_posicao => 0     , pr_tag_nova => 'Reg', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'flgativo',    pr_tag_cont => rw_parametrizacao.flgativo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'idindicador', pr_tag_cont => rw_parametrizacao.idindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'nmindicador', pr_tag_cont => rw_parametrizacao.nmindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'tpindicador', pr_tag_cont => rw_parametrizacao.tpindicador, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'vlminimo',    pr_tag_cont => vr_vlminimo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'vlmaximo',    pr_tag_cont => vr_vlmaximo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'perscore',    pr_tag_cont => to_char(nvl(rw_parametrizacao.perscore,0),'fm990d00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Reg', pr_posicao => vr_contador,  pr_tag_nova => 'pertolera',   pr_tag_cont => vr_pertolera, pr_des_erro => vr_dscritic); 
        vr_contador := vr_contador + 1;
      END LOOP;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'Perdesmax', pr_tag_cont => to_char(nvl(vr_perdesmax,0),'fm990d00'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'QtdRegist', pr_tag_cont => vr_contador,  pr_des_erro => vr_dscritic);

    --Retorno
    pr_des_erro:= 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro tratado
      pr_dscritic := 'TELA_CONFRP..pc_busca_conf_reciprocidade --> '||vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_dscritic := 'TELA_CONFRP..pc_busca_conf_reciprocidade --> Erro não tratado: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_conf_reciprocidade; 

  /* Salva configuracao de calculo de reprocidade */
  PROCEDURE pc_confirma_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                          ,pr_configrp           IN VARCHAR2
                                          ,pr_perdesmax          IN tbrecip_parame_calculo.perdesconto_maximo%TYPE
                                          ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                          ,pr_xmllog             IN VARCHAR2                --XML com informações de LOG
                                          ,pr_cdcritic           OUT PLS_INTEGER            --Código da crítica
                                          ,pr_dscritic           OUT VARCHAR2               --Descrição da crítica
                                          ,pr_retxml             IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                          ,pr_nmdcampo           OUT VARCHAR2               --Nome do Campo
                                          ,pr_des_erro           OUT VARCHAR2) IS           --Saida OK/NOK
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_confirma_conf_reciprocidade                Antigo: Não há
  --  Sistema  : Ayllos
  --  Sigla    : CRED
  --  Autor    : Lucas Lombardi
  --  Data     : Março/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Gravar configuração para um cálculo de reciprocidade 
  --             futuro ou alterar um cálculo pré-existente.
  ---------------------------------------------------------------------------------------------------------------
  
    CURSOR cr_procura_parame (pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
              ,pr_idindicador        IN tbrecip_parame_indica_calculo.idindicador%TYPE) IS
    SELECT vlminimo
          ,vlmaximo
          ,perscore
          ,pertolera
      FROM tbrecip_parame_indica_calculo
     WHERE idparame_reciproci = pr_idparame_reciproci
       AND idindicador = pr_idindicador;
    rw_procura_parame cr_procura_parame%ROWTYPE;
    
    CURSOR cr_tbrecip_parame_calculo (pr_idparame_reciproci IN tbrecip_parame_calculo.idparame_reciproci%TYPE) IS
      SELECT perdesconto_maximo
        FROM tbrecip_parame_calculo
       WHERE idparame_reciproci = pr_idparame_reciproci;
    rw_tbrecip_parame_calculo cr_tbrecip_parame_calculo%ROWTYPE;
    
    -- Variáveis genéricas
    vr_achoureg           BOOLEAN;
    vr_confrp_geral       GENE0002.typ_split;
    vr_confrp_dados       GENE0002.typ_split;
    vr_idparame_reciproci tbrecip_parame_indica_calculo.idparame_reciproci%TYPE;
    vr_old_perdesmax      tbrecip_parame_calculo.perdesconto_maximo%TYPE;
    vr_old_vlminimo       NUMBER;
    vr_old_vlmaximo       NUMBER;
    vr_old_perscore       NUMBER;
    vr_old_pertolera      NUMBER;
    vr_textolog           VARCHAR2(32767);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_dscritic VARCHAR2(4000);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;
    
  BEGIN
     --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'RCIP0001'
                              ,pr_action => NULL);
    
    --Inicializar Variaveis
    vr_dscritic:= null;
      
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    --Retornar no final o idparame_reciproci
    vr_idparame_reciproci := pr_idparame_reciproci;
    
    -- Se é informado pr_idparame_reciproci
    IF pr_idparame_reciproci <> 0 THEN
      
      OPEN cr_tbrecip_parame_calculo(pr_idparame_reciproci);
      FETCH cr_tbrecip_parame_calculo INTO rw_tbrecip_parame_calculo;
      vr_old_perdesmax := rw_tbrecip_parame_calculo.perdesconto_maximo;
      CLOSE cr_tbrecip_parame_calculo;
      
      -- Atualizar % maxima de desconto permitido ao calculo.
      BEGIN
        UPDATE tbrecip_parame_calculo
           SET perdesconto_maximo = pr_perdesmax
         WHERE idparame_reciproci = pr_idparame_reciproci;
      EXCEPTION
        WHEN OTHERS THEN
             vr_dscritic := 'Nao foi possível atualizar % maxima de ' ||
                            'desconto permitido ao calculo.';
        RAISE vr_exc_erro;
      END;
                          
      
      IF vr_old_perdesmax <> pr_perdesmax THEN
        -- Gera log
        vr_textolog := vr_textolog
                    || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                    || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                    || 'Alterou o % Maximo de Desconto Permitido ao Calculo ' 
                    || 'de ' || vr_old_perdesmax || ' para ' || pr_perdesmax || '.' ||'[br]';
      END IF;
                               
      vr_confrp_geral := gene0002.fn_quebra_string(pr_configrp,';');    

      FOR ind_registro IN vr_confrp_geral.FIRST..vr_confrp_geral.LAST LOOP
        
        vr_confrp_dados := gene0002.fn_quebra_string(vr_confrp_geral(ind_registro),',');
        
        -- Substituir os "-" recebidos da tela para indicadores de Adesão para "0"
        IF upper(vr_confrp_dados(3)) = 'A' THEN
          vr_confrp_dados(7) := 0;
          vr_confrp_dados(4) := 0;
          vr_confrp_dados(5) := 0;
        END IF;

        -- Ativo
        IF upper(vr_confrp_dados(1)) = 'TRUE' THEN 
          
          -- Verifica se já existe registro
          OPEN cr_procura_parame(pr_idparame_reciproci => pr_idparame_reciproci
                                ,pr_idindicador        => TO_NUMBER(vr_confrp_dados(2)));
          FETCH cr_procura_parame INTO rw_procura_parame;
          vr_achoureg := cr_procura_parame%FOUND;
          IF vr_achoureg THEN
            vr_old_vlminimo := rw_procura_parame.vlminimo;
            vr_old_vlmaximo := rw_procura_parame.vlmaximo;
            vr_old_perscore := rw_procura_parame.perscore;
            vr_old_pertolera := rw_procura_parame.pertolera;
          END IF;
          CLOSE cr_procura_parame;
          
          -- Se achou registro
          IF vr_achoureg THEN
            --Se há alteração
            IF  nvl(vr_old_pertolera,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',',')),0)
            OR nvl(vr_old_vlminimo,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',',')),0)
            OR nvl(vr_old_vlmaximo,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',',')),0)
            OR nvl(vr_old_perscore,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',',')),0) THEN
              BEGIN
                UPDATE tbrecip_parame_indica_calculo
                   SET vlminimo = TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',','))  -- Valor Minimo
                      ,vlmaximo = TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',','))  -- Valor Maximo
                      ,perscore = TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',','))  -- %Score
                      ,pertolera = TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',',')) -- % Tolerancia
                 WHERE idparame_reciproci = pr_idparame_reciproci
                   AND idindicador = TO_NUMBER(vr_confrp_dados(2));
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao alterar Indicador de parametrizacao' ||
                                 'de calculo de Reciprocidade. ' ||
                                 SQLERRM;
                  RAISE vr_exc_erro;
              END;
              
              -- Gera log
              vr_textolog := vr_textolog 
                          || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                          || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                          || 'Alterou o Indicador '
                          || TO_NUMBER(REPLACE(vr_confrp_dados(2),'.',',')) || '.' ||'[br]';
              
              -- Gera log
              IF nvl(vr_old_vlminimo,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',',')),0) THEN
                vr_textolog := vr_textolog 
                            || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                            || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                            || 'Alterou o Valor Minimo ' 
                            || 'de ' || vr_old_vlminimo || ' para ' 
                            || TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',',')) || '.' ||'[br]';
              END IF;
                
              -- Gera log
              IF nvl(vr_old_vlmaximo,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',',')),0) THEN
                vr_textolog := vr_textolog 
                            || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                            || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                            || 'Alterou o Valor Maximo ' 
                            || 'de ' || vr_old_vlmaximo || ' para ' 
                            || TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',',')) || '.' ||'[br]';
              END IF;
              
              -- Gera LOG
              IF nvl(vr_old_perscore,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',',')),0) THEN
                vr_textolog := vr_textolog 
                            || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                            || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                            || 'Alterou o % Score ' 
                            || 'de ' || vr_old_perscore || ' para ' 
                            || TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',',')) || '.' ||'[br]';
              END IF;
                
              -- Gera log
              IF nvl(vr_old_pertolera,0) <> nvl(TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',',')),0) THEN
                vr_textolog := vr_textolog 
                            || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                            || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                            || 'Alterou o % Tolerancia ' 
                            || 'de ' || vr_old_pertolera || ' para ' 
                            || TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',',')) || '.' ||'[br]';
              END IF;
              
            END IF;
          ELSE 
            -- Se não encontrar, cria novo registro
            BEGIN
              INSERT INTO tbrecip_parame_indica_calculo (
                         idparame_reciproci,idindicador,vlminimo,vlmaximo,perscore,pertolera)
                   VALUES(pr_idparame_reciproci
                         ,TO_NUMBER(REPLACE(vr_confrp_dados(2),'.',','))   -- Indicador
                         ,TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',','))   -- Valor Minimo
                         ,TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',','))   -- Valor Maximo
                         ,TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',','))   -- %Score
                         ,TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',','))); -- % Tolerancia
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao alterar Indicador de parametrizacao' ||
                               'de calculo de Reciprocidade. ' ||
                             SQLERRM;
                RAISE vr_exc_erro;
            END;
            
            -- Gera log
            vr_textolog := vr_textolog 
                        || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                        || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                        || 'Incluiu o indicador : '||TO_NUMBER(REPLACE(vr_confrp_dados(2),'.',','))||'.' ||'[br]';

            -- Gera log
            IF upper(vr_confrp_dados(3)) != 'A' THEN
              vr_textolog := vr_textolog 
                          || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                          || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                          || 'Incluiu o Valor Minimo: ' 
                          || TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',',')) || '.' ||'[br]';
              -- Gera log
              vr_textolog := vr_textolog 
                          || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                          || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                          || 'Incluiu o Valor Maximo: ' 
                          || TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',',')) || '.' ||'[br]';
            END IF;
            
            -- Gera LOG
            vr_textolog := vr_textolog 
                        || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                        || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                        || 'Incluiu o % Score: ' 
                        || TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',',')) || '.' ||'[br]';
              
            IF upper(vr_confrp_dados(3)) != 'A' THEN
              -- Gera log
              vr_textolog := vr_textolog 
                          || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                          || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                          || 'Incluiu o % Tolerancia: ' 
                          || TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',',')) || '.' ||'[br]';
            END IF;
            
          END IF;
          
        ELSE -- Não ativo
          
          -- Verifica se já existe registro
          OPEN cr_procura_parame(pr_idparame_reciproci => pr_idparame_reciproci
                                ,pr_idindicador        => TO_NUMBER(vr_confrp_dados(2)));
          FETCH cr_procura_parame INTO rw_procura_parame;
          vr_achoureg := cr_procura_parame%FOUND;
          CLOSE cr_procura_parame;
          
          IF vr_achoureg THEN
            -- Se achou registro deleta
            BEGIN
              DELETE FROM tbrecip_parame_indica_calculo
               WHERE idparame_reciproci = pr_idparame_reciproci
                 AND idindicador = TO_NUMBER(vr_confrp_dados(2));
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao excluir Indicador de parametrizacao' ||
                               'de calculo de Reciprocidade. ' ||
                               SQLERRM;
                RAISE vr_exc_erro;
            END;
            
            -- Gera log
            vr_textolog := vr_textolog 
                        || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                        || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                        || 'Excluiu o Indicador de parametrizacao de calculo de Reciprocidade: ' 
                        || TO_NUMBER(vr_confrp_dados(2)) || '.' ||'[br]';
             
          END IF;
          
        END IF;
        
      END LOOP;
    
      -- Se houve alteração
      IF trim(vr_textolog) IS NOT NULL THEN
        -- Incluir o início do log
        vr_textolog := TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                  || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                  || 'Alterou parametrizacao Reciprocidade: ' ||'[br]'
                  || vr_textolog;

      END IF;
    
    ELSE -- Não é informado pr_idparame_reciproci
      
      -- Criar novo % maxima de desconto permitido ao calculo.
      BEGIN
        INSERT INTO tbrecip_parame_calculo (perdesconto_maximo)
                                     VALUES(pr_perdesmax)
                                  RETURNING idparame_reciproci 
                                       INTO vr_idparame_reciproci;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir  % maxima de ' ||
                         'desconto permitido ao calculo. ' ||
                         SQLERRM;
          RAISE vr_exc_erro;
      END;

      -- Iniciar LOG
      vr_textolog := TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                  || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                  || 'Incluiu nova parametrizacao Reciprocidade:' ||'[br]';

      -- Gera log
      vr_textolog := vr_textolog
                  || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                  || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                  || 'Incluiu o % Maximo de Desconto Permitido ao Calculo: ' 
                  || pr_perdesmax || '.' ||'[br]';
      
      vr_confrp_geral := gene0002.fn_quebra_string(pr_configrp,';');    

      FOR ind_registro IN vr_confrp_geral.FIRST..vr_confrp_geral.LAST LOOP
        
        vr_confrp_dados := gene0002.fn_quebra_string(vr_confrp_geral(ind_registro),',');
        
        -- Substituir os "-" recebidos da tela para indicadores de Adesão para "0"
        IF upper(vr_confrp_dados(3)) = 'A' THEN
          vr_confrp_dados(7) := 0;
          vr_confrp_dados(4) := 0;
          vr_confrp_dados(5) := 0;
        END IF;
        
        IF upper(vr_confrp_dados(1)) = 'TRUE' THEN -- Ativo
          BEGIN -- Criar indicadores de parametrizacao de calculo de Reciprocidade.
            INSERT INTO tbrecip_parame_indica_calculo (
                              idparame_reciproci,idindicador,vlminimo,vlmaximo,perscore,pertolera)
                 VALUES(vr_idparame_reciproci
                       ,TO_NUMBER(REPLACE(vr_confrp_dados(2),'.',','))   -- Indicador
                       ,TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',','))   -- Valor Minimo
                       ,TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',','))   -- Valor Maximo
                       ,TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',','))   -- %Score
                       ,TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',','))); -- % Tolerancia
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao incluir Indicador de parametrizacao' ||
                             'de calculo de Reciprocidade. ' ||
                           SQLERRM;
              RAISE vr_exc_erro;
          END;
        
          -- Gera log
          vr_textolog := vr_textolog 
                      || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                      || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                      || 'Incluiu o indicador : '||TO_NUMBER(REPLACE(vr_confrp_dados(2),'.',','))||'.' ||'[br]';

          IF upper(vr_confrp_dados(3)) <> 'A' THEN
            -- Gera log
            vr_textolog := vr_textolog 
                        || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                        || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                        || 'Incluiu o Valor Minimo: ' 
                        || TO_NUMBER(REPLACE(vr_confrp_dados(4),'.',',')) || '.' ||'[br]';
                
            -- Gera log
            vr_textolog := vr_textolog 
                        || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                        || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                        || 'Incluiu o Valor Maximo: ' 
                        || TO_NUMBER(REPLACE(vr_confrp_dados(5),'.',',')) || '.' ||'[br]';
          END IF;
          
          -- Gera log
          vr_textolog := vr_textolog 
                      || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                      || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                      || 'Incluiu o % Score: ' 
                      || TO_NUMBER(REPLACE(vr_confrp_dados(6),'.',',')) || '.' ||'[br]';
              
          IF upper(vr_confrp_dados(3)) <> 'A' THEN
                
            -- Gera log
            vr_textolog := vr_textolog 
                        || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                        || ' [fl]  Operador '|| vr_cdoperad || ' - ' 
                        || 'Incluiu o % Tolerancia: ' 
                        || TO_NUMBER(REPLACE(vr_confrp_dados(7),'.',',')) || '.' ||'[br]';
          END IF;
        
        END IF;
        
      END LOOP;
      
    END IF;
    
    --Retorno
    pr_des_erro:= 'OK';

    -- Salva no banco as alterações
    COMMIT;
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'idparame_reciproci', pr_tag_cont => vr_idparame_reciproci, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dsretorno',          pr_tag_cont => pr_des_erro, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslogconfrp',        pr_tag_cont => vr_textolog, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Erro tratado
      pr_dscritic := 'TELA_CONFRP.pc_confirma_conf_reciprocidade --> '||vr_dscritic;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      -- Erro não tratado
      pr_dscritic := 'TELA_CONFRP.pc_confirma_conf_reciprocidade --> Erro não tratado: '||SQLERRM;
      pr_des_erro := 'NOK';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_confirma_conf_reciprocidade;

END TELA_CONFRP;
/
