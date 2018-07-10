CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_PRESTACOES IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PRESTACOES
  --  Sistema  : Rotinas utilizadas pela Tela ATENDA_PRESTACOES
  --  Sigla    : EMPR
  --  Autor    : Daniel/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: ----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ATENDA_PRESTACOES
  --
  ---------------------------------------------------------------------------
  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  ---------------------------------- ROTINAS --------------------------------

  PROCEDURE pc_consultar_controle(pr_nrdconta IN NUMBER --> Número da conta
                                 ,pr_nrctremp IN NUMBER --> Contrato
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar_controle(pr_nrdconta   IN NUMBER --> Número da conta
                               ,pr_nrctremp   IN NUMBER  --> Contrato
                               ,pr_idquaprc   IN NUMBER  --> Controle Qualificação
                               ,pr_xmllog     IN VARCHAR2  --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2); --> Erros do processo
                               
  PROCEDURE pc_consultar_contratos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada    
                                  ,pr_nrdconta IN crapepr.cdcooper%TYPE --> Número da conta
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                
  PROCEDURE pc_alterar_contratos_liquid(pr_nrdconta   IN NUMBER             --> Número da conta
                                       ,pr_cdcooper   IN NUMBER             --> Cooperativa conectada 
                                       ,pr_nrctremp   IN NUMBER             --> Contrato
                                       ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_dsliquid   IN VARCHAR2           --> Lista de contratos liquidados
                                       ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2);        --> Erros do processo

END TELA_ATENDA_PRESTACOES;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_PRESTACOES IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_PRESTACOES
  --  Sistema  : Rotinas utilizadas pela Tela ATENDA_PRESTACOES
  --  Sigla    : EMPR
  --  Autor    : Daniel/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ATENDA_PRESTACOES
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_consultar_controle(pr_nrdconta IN NUMBER             --> Número da conta
                                 ,pr_nrctremp IN NUMBER             --> Contrato
                                 ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar_controle
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar Qualificacao
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

      vr_dstextab craptab.dstextab%TYPE;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      ---------->> CURSORES <<--------      
      CURSOR cr_consulta_controle (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
				select crapepr.idquaprc
             , crawepr.idquapro
          from crapepr
             , crawepr
         where crawepr.cdcooper = crapepr.cdcooper
           and crawepr.nrdconta = crapepr.nrdconta
           and crawepr.nrctremp = crapepr.nrctremp
           and crapepr.cdcooper = pr_cdcooper
           and crapepr.nrdconta = pr_nrdconta
           and crapepr.nrctremp = pr_nrctremp;
         rw_consulta_controle cr_consulta_controle%ROWTYPE;

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
      -- Busca os dados
      OPEN cr_consulta_controle(vr_cdcooper);
     FETCH cr_consulta_controle
      INTO rw_consulta_controle;
     CLOSE cr_consulta_controle;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'idquaprc',
                             pr_tag_cont => rw_consulta_controle.idquaprc,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'idquapro',
                             pr_tag_cont => rw_consulta_controle.idquapro,
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
  END pc_consultar_controle;

  PROCEDURE pc_alterar_controle(pr_nrdconta   IN NUMBER             --> Número da conta
                               ,pr_nrctremp   IN NUMBER             --> Contrato
                               ,pr_idquaprc   IN NUMBER             --> Controle Qualificação
                               ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar_controle
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para alterar Qualificacao
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

      vr_dstextab craptab.dstextab%TYPE;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      ---------->> CURSORES <<--------      

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

    BEGIN  
      UPDATE crapepr
         SET idquaprc = pr_idquaprc
       WHERE crapepr.cdcooper = vr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp;
         
      BEGIN   
      --Grava log
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Alterada Qualificação da Operação(Controle)'
                          ,pr_dttransa => SYSDATE--pr_dtmvtolt
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                           ,'SSSSS'))
                          ,pr_idseqttl => 1--pr_idseqttl
                          ,pr_nmdatela => 'PRESTACOES'--pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
     END;
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Qualificação do controle!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
    END;

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
  END pc_alterar_controle;
  --
  PROCEDURE pc_consultar_contratos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada    
                                  ,pr_nrdconta IN crapepr.cdcooper%TYPE --> Número da conta
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar_contratos
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Heckmann/AMcom
        Data    : Julho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para consultar os contratos
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posição no XML    

      ---------->> CURSORES <<--------      
      cursor cr_consulta_contratos is
				select  e.cdlcremp
               ,e.cdfinemp
               ,e.nrdconta
               ,e.nrctremp
               ,e.dtmvtolt
               ,e.vlemprst
               ,e.qtpreemp
               ,e.vlpreemp
               ,e.vlsdeved
               ,e.tpemprst
               ,w.nrctrliq##1
               ,w.nrctrliq##2
               ,w.nrctrliq##3
               ,w.nrctrliq##4
               ,w.nrctrliq##5
               ,w.nrctrliq##6
               ,w.nrctrliq##7
               ,w.nrctrliq##8
               ,w.nrctrliq##9
               ,w.nrctrliq##10
          from  crawepr w, crapepr e
         where  e.cdcooper = w.cdcooper
           and  e.nrdconta = w.nrdconta
           and  e.nrctremp = w.nrctremp  
           and  e.cdcooper = pr_cdcooper
           and  e.nrdconta = pr_nrdconta
           and  e.dtliquid >= (e.dtmvtolt - 30);
         rw_consulta_contratos cr_consulta_contratos%ROWTYPE;

    BEGIN

      pr_des_erro := 'OK';      

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
      -- Busca os dados
      OPEN cr_consulta_contratos;
      LOOP
        FETCH cr_consulta_contratos
         INTO rw_consulta_contratos; 
         EXIT WHEN cr_consulta_contratos%notfound;       

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdlcremp',
                               pr_tag_cont => rw_consulta_contratos.cdlcremp,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdfinemp',
                               pr_tag_cont => rw_consulta_contratos.cdfinemp,
                               pr_des_erro => vr_dscritic);
               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nrdconta',
                               pr_tag_cont => rw_consulta_contratos.nrdconta,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nrctremp',
                               pr_tag_cont => rw_consulta_contratos.nrctremp,
                               pr_des_erro => vr_dscritic);
                             
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'dtmvtolt',
                               pr_tag_cont => to_char(rw_consulta_contratos.dtmvtolt, 'dd/mm/yyyy'),
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'vlemprst',
                               pr_tag_cont => to_char(rw_consulta_contratos.vlemprst,'fm9999g999g990d00'),
                               pr_des_erro => vr_dscritic);
                             
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'qtpreemp',
                               pr_tag_cont => rw_consulta_contratos.qtpreemp,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'vlpreemp',
                               pr_tag_cont => to_char(rw_consulta_contratos.vlpreemp,'fm9999g999g990d00'),
                               pr_des_erro => vr_dscritic);
                             
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'vlsdeved',
                               pr_tag_cont => to_char(rw_consulta_contratos.vlsdeved,'fm9999g999g990d00'),
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'tpemprst',
                               pr_tag_cont => rw_consulta_contratos.tpemprst,
                               pr_des_erro => vr_dscritic);
        
        -- Verifica se o contrato já está vinculado ao contrato liquidado                       
        if (rw_consulta_contratos.nrctremp in (rw_consulta_contratos.nrctrliq##1
                                              ,rw_consulta_contratos.nrctrliq##2
                                              ,rw_consulta_contratos.nrctrliq##3
                                              ,rw_consulta_contratos.nrctrliq##4
                                              ,rw_consulta_contratos.nrctrliq##5
                                              ,rw_consulta_contratos.nrctrliq##6
                                              ,rw_consulta_contratos.nrctrliq##7
                                              ,rw_consulta_contratos.nrctrliq##8
                                              ,rw_consulta_contratos.nrctrliq##9
                                              ,rw_consulta_contratos.nrctrliq##10)) then 
                                              
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'tpcontvi',
                               pr_tag_cont => '*',
                               pr_des_erro => vr_dscritic); 
                                
        else
          
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'tpcontvi',
                               pr_tag_cont => '',
                               pr_des_erro => vr_dscritic);
          
        end if;                                     
  END LOOP;
  CLOSE cr_consulta_contratos;

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
      pr_dscritic := 'Erro geral na rotina da tela ' || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar_contratos;
  --
  
  PROCEDURE pc_alterar_contratos_liquid(pr_nrdconta   IN NUMBER             --> Número da conta
                                       ,pr_cdcooper   IN NUMBER             --> Cooperativa conectada 
                                       ,pr_nrctremp   IN NUMBER             --> Contrato
                                       ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_dsliquid   IN VARCHAR2           --> Lista de contratos liquidados
                                       ,pr_cdcritic   OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic   OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_alterar_contratos_liquid
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Heckmann/AMcom
        Data    : Julho/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para alterar os contratos liquidados
        Observacao: -----
        Alteracoes:
      ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variáveis de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
      
      -- Variáveis de controle de atributo preenchido
      vr_qtatrib  number(10);
      vr_catrib   number(10);
      vr_cliq     number(10);
      
      -- Variável para guardar os comandos do SQL dinâmico
      vr_campos   varchar2(4000);
      vr_sql      varchar2(4000);
      
      --Variável de controle de data de risco
      vr_qtdatref number(10);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Var para criar uma lista com os contratos
      -- passados e com os separados nos contratos a liquidar
      vr_split_pr_dsliquid GENE0002.typ_split;
      
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_nrdrowid ROWID;

      ---------->> CURSORES <<-------- 
      rw_crapdat   btch0001.cr_crapdat%ROWTYPE;     

    BEGIN
      
      begin
        -- consulta para retornar em até qual atributo está preenchido com o contrato liquidado
        select nvl(max(to_number(substr(x.data,11,2))),0)
          into vr_qtatrib 
          from (
                select data, nrctremp, nrdconta, cdcooper , a
                  from crawepr
               unpivot (
                        a for data in (nrctrliq##1, nrctrliq##2, nrctrliq##3, nrctrliq##4, nrctrliq##5, 
                                       nrctrliq##6, nrctrliq##7, nrctrliq##8, nrctrliq##9, nrctrliq##10, 
                                       nrliquid)
                       )         
                 where cdcooper = pr_cdcooper 
                   and nrdconta = pr_nrdconta 
                   and nrctremp = pr_nrctremp
               ) x 
         where a > 0;
       exception
         when others then
            -- montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao buscar as informações dos contratos liquidados!';
            -- volta para o programa chamador
            raise vr_exc_saida;
       end;
       
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
          
      -- Efetuar split dos contratos passados para facilitar os testes
      vr_split_pr_dsliquid := gene0002.fn_quebra_string(replace(pr_dsliquid,';',','),',');
       
       if ((vr_qtatrib >= 10) or 
          ((vr_qtatrib + vr_split_pr_dsliquid.count) > 10)) then         
          -- montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Não há espaço para vincular mais contratos!';
          -- volta para o programa chamador
          raise vr_exc_saida;       
       end if; 
      
      if vr_split_pr_dsliquid.count > 0 then
        -- Verificar a quantidade de contratos passados na String
        -- para então fazer o Update 
       
        vr_campos := '';
        vr_catrib := vr_qtatrib + 1; 
        vr_cliq   := 1;     
        loop
          vr_campos := vr_campos || ' nrctrliq##' || vr_catrib || ' = ' 
                    || vr_split_pr_dsliquid(vr_cliq) || ',';
          vr_catrib := vr_catrib + 1;
          vr_cliq   := vr_cliq + 1;
          exit when ((vr_catrib > 10) or (vr_split_pr_dsliquid.count = vr_cliq - 1));
        end loop;
        
        begin
          vr_sql := 'UPDATE crawepr ' ||
                       'SET ' || rtrim(vr_campos, ',') || ' ' ||
                     'WHERE crawepr.cdcooper = :pr_cdcooper ' ||
                       'AND crawepr.nrdconta = :pr_nrdconta ' ||
                       'AND crawepr.nrctremp = :pr_nrctremp ';
         
          execute immediate vr_sql using pr_cdcooper, pr_nrdconta, pr_nrctremp;
        exception
          when others then
            -- montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar os contratos!';
            -- volta para o programa chamador
            raise vr_exc_saida;
        end;        
        
      COMMIT;
      
     end if;
     
     risc0004.pc_dias_atraso_liquidados(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp 
                                       ,pr_qtdatref => vr_qtdatref
                                       ,pr_dscritic => vr_dscritic);
                                       
     /* Busca data de movimento */
     open  btch0001.cr_crapdat(pr_cdcooper);
     fetch btch0001.cr_crapdat into rw_crapdat;
     close btch0001.cr_crapdat;
                                       
     begin
       update crapepr
          set dtinicio_atraso_refin = rw_crapdat.dtmvtoan - vr_qtdatref
        WHERE crapepr.cdcooper = pr_cdcooper
          AND crapepr.nrdconta = pr_nrdconta
          AND crapepr.nrctremp = pr_nrctremp;
          
       commit;
     exception
       when others then
       -- montar mensagem de critica
       vr_cdcritic := 0;
       vr_dscritic := 'Erro ao atualizar a data de atraso do contrato!';
       -- volta para o programa chamador
       raise vr_exc_saida;
     end;

     BEGIN   
      --Grava log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Alterado os contrataos liquidados e data de risco'
                          ,pr_dttransa => SYSDATE--pr_dtmvtolt
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => 1--pr_idseqttl
                          ,pr_nmdatela => 'CONTRATO'--pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
     END;       

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
  END pc_alterar_contratos_liquid;
  --
  
END TELA_ATENDA_PRESTACOES;
/
