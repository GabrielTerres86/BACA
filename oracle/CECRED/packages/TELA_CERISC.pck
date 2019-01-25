CREATE OR REPLACE PACKAGE CECRED.TELA_CERISC IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CERISC
  --  Sistema  : Rotinas utilizadas pela Tela CERISC
  --  Sigla    : EMPR
  --  Autor    : Douglas Pagel/AMcom
  --  Data     : Novembro/2018                 Ultima atualizacao: --
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CERISC
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------



  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar( pr_perceliq NUMBER        --> % de liquidação para possibilitar redução               
                       ,pr_percecob NUMBER        --> % de cobertura das aplicações bloqueadas
                       ,pr_nivelris INTEGER       --> Menor risco melhora possível                      

                       ,pr_xmllog      IN VARCHAR2  --> XML com informações de LOG
                       ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_CERISC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CERISC IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CERISC
  --  Sistema  : Rotinas utilizadas pela Tela CERISC
  --  Sigla    : EMPR
  --  Autor    : Douglas Pagel/AMcom
  --  Data     : Novembro/2018                 Ultima atualizacao: --
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CERISC
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Douglas Pagel/AMcom
        Data    : Novembro/2018                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar parâmetros do Risco Melhora

        Observacao: -----

        Alteracoes: 

    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      vr_perceliq NUMBER  :=0;  --> % de liquidação para possibilitar redução
      vr_percecob NUMBER  :=0;  --> % de cobertura das aplicações bloqueadas
      vr_nivelris INTEGER :=0;  --> Menor risco melhora possível 

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      ---------->> CURSORES <<--------
   CURSOR cr_tbrisco_central_parametros(vr_cdcooper IN tbrisco_central_parametros.CDCOOPER%TYPE) IS
     SELECT c.perc_liquid_sem_garantia, c.perc_cobert_aplic_bloqueada, c.inrisco_melhora_minimo 
       FROM tbrisco_central_parametros c
      WHERE cdcooper = vr_cdcooper;
      rw_tbrisco_central_parametros cr_tbrisco_central_parametros%ROWTYPE;


    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- Buscar parâmetros
      OPEN cr_tbrisco_central_parametros(vr_cdcooper => vr_cdcooper);
      
      FETCH cr_tbrisco_central_parametros INTO rw_tbrisco_central_parametros;
      
      --Se nao encontrou parametro
      IF cr_tbrisco_central_parametros%NOTFOUND THEN
        vr_cdcritic := 55;
        RAISE vr_exc_saida;
      ELSE --Se encontrou, passa os valores para as variáveis criadas
        vr_perceliq := rw_tbrisco_central_parametros.perc_liquid_sem_garantia;
        vr_percecob := rw_tbrisco_central_parametros.perc_cobert_aplic_bloqueada;
        vr_nivelris := rw_tbrisco_central_parametros.inrisco_melhora_minimo;
      END IF;
      
      CLOSE cr_tbrisco_central_parametros;

      -- PASSA OS DADOS PARA O XML RETORNO
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      -- CAMPOS
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'perceliq',
                             pr_tag_cont => to_char(vr_perceliq,
                                                    '999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'percecob',
                             pr_tag_cont => to_char(vr_percecob,
                                                    '999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nivelris',
                             pr_tag_cont => to_char(vr_nivelris),
                             pr_des_erro => vr_dscritic);
                             
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar;

  PROCEDURE pc_alterar( pr_perceliq NUMBER        --> % de liquidação para possibilitar redução               
                       ,pr_percecob NUMBER        --> % de cobertura das aplicações bloqueadas
                       ,pr_nivelris INTEGER       --> Menor risco melhora possível 

                       ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Douglas Pagel/AMcom
        Data    : Novembro/2018                 Ultima atualizacao: --

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para alterar parâmetros do Risco Melhora

        Observacao: -----

        Alteracoes: 

    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_cdacesso VARCHAR2(100);

    vr_dstextab craptab.dstextab%TYPE;
    vr_dsvlrprm crapprm.dsvlrprm%TYPE;


    ---------->> CURSORES <<--------
   CURSOR cr_tbrisco_central_parametros(vr_cdcooper IN tbrisco_central_parametros.CDCOOPER%TYPE) IS
     SELECT c.perc_liquid_sem_garantia, c.perc_cobert_aplic_bloqueada, c.inrisco_melhora_minimo 
       FROM tbrisco_central_parametros c
      WHERE cdcooper = vr_cdcooper;
      rw_tbrisco_central_parametros cr_tbrisco_central_parametros%ROWTYPE;

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_cerisc(pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_cdoperad IN crapope.cdoperad%TYPE,
                            pr_dscdolog IN VARCHAR2) IS
      vr_dscdolog VARCHAR2(500);
    BEGIN

      vr_dscdolog := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' '|| to_char(SYSDATE,'HH24:MI:SS') ||
                     ' --> '|| vr_cdacesso || ' --> '|| 'Operador '|| pr_cdoperad ||
                     ' '||pr_dscdolog;

      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log  => vr_dscdolog,
                                 pr_nmarqlog => 'cerisc',
                                 pr_flfinmsg => 'N');
    END;



  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    IF (pr_percecob > 100) or (pr_perceliq > 100) THEN        
      vr_dscritic := 'Os percentuais não podem ultrapassar 100%';
      RAISE vr_exc_saida;
    END IF; 
    
    -- Buscar parametros de risco melhora para cooperativa
    OPEN cr_tbrisco_central_parametros(vr_cdcooper => vr_cdcooper);
      
    FETCH cr_tbrisco_central_parametros INTO rw_tbrisco_central_parametros;
    
    --Se encontrou registro da cooperativa
    IF cr_tbrisco_central_parametros%FOUND THEN
      BEGIN 
        --encontrou registro, faz update se for diferente
        IF (rw_tbrisco_central_parametros.perc_liquid_sem_garantia <> pr_perceliq) or
           (rw_tbrisco_central_parametros.perc_cobert_aplic_bloqueada <> pr_percecob) or
           (rw_tbrisco_central_parametros.inrisco_melhora_minimo <> pr_nivelris) THEN
           
          UPDATE tbrisco_central_parametros c
             SET c.perc_liquid_sem_garantia = pr_perceliq
                ,c.perc_cobert_aplic_bloqueada = pr_percecob
                ,c.inrisco_melhora_minimo = pr_nivelris
                ,c.dthr_alteracao = sysdate
                ,c.cdoperador_alteracao = vr_cdoperad
           WHERE c.cdcooper = vr_cdcooper;  
           
           pc_log_cerisc(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad,
                      pr_dscdolog => 'Alterou os parametros do Risco Melhora de: ' ||
                                      'perc_liquid_sem_garantia: ' || to_char(rw_tbrisco_central_parametros.perc_liquid_sem_garantia) ||
                                      ', perc_cobert_aplic_bloqueada: ' || to_char(rw_tbrisco_central_parametros.perc_cobert_aplic_bloqueada) ||
                                      ', inrisco_melhora_minimo: ' || to_char(rw_tbrisco_central_parametros.inrisco_melhora_minimo) ||
                                      ' para: ' || 
                                      'perc_liquid_sem_garantia: ' || to_char(pr_perceliq) ||
                                      ', perc_cobert_aplic_bloqueada: ' || to_char(pr_percecob) ||
                                      ', inrisco_melhora_minimo: ' || to_char(pr_nivelris));
      END IF;
    
    EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar Parametros!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;
      
    END IF;
      
    CLOSE cr_tbrisco_central_parametros;
      
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_alterar;

END TELA_CERISC;
/
