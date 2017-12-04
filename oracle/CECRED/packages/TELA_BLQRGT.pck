CREATE OR REPLACE PACKAGE CECRED.TELA_BLQRGT IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CONPRO
  --  Sistema  : Rotinas utilizadas pela Tela COMPRO
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CONPRO
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_bloq_apli_cobe(pr_cddopcao IN VARCHAR2
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_desbloq_cobertura(pr_idcobertura IN NUMBER
                                ,pr_vldesblo    IN NUMBER
                                ,pr_cdopelib    IN VARCHAR2 --> Codigo do operador que liberou o desbloqueio
                                ,pr_xmllog      IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2); --> Erros do processo
END TELA_BLQRGT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_BLQRGT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_LDESCO
  --  Sistema  : Rotinas utilizadas pela Tela BLQRGT
  --  Sigla    : EMPR
  --  Autor    : Lombardi
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela LDESCO
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_bloq_apli_cobe(pr_cddopcao IN VARCHAR2
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_busca_bloq_apli_cobe
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Novembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar os bloqueios antigos (CRAPTAB) e os novos criados
                    para a cobertura das operações de crédito.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
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
    
      CURSOR cr_craprpp(pr_cdcooper IN crapcob.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT 'POUP.PROG' dstipapl
              ,rpp.nrctrrpp
              ,rpp.vlsdrdpp
          FROM craprpp rpp
              ,craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND upper(tab.cdacesso) = to_char(pr_nrdconta,'fm0000000000')
           AND upper(tab.nmsistem) = 'CRED'
           AND upper(tab.tptabela) = 'BLQRGT'
           AND tab.cdempres = 0
           AND to_number(SUBSTR(tab.dstextab,1,7)) = rpp.nrctrrpp
           AND rpp.cdcooper = pr_cdcooper
           AND rpp.nrdconta = pr_nrdconta;
           
      CURSOR cr_cobertura(pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ope.idcobertura
              ,ope.nrdconta
              ,ope.tpcontrato
              ,ope.nrcontrato
              ,ope.perminimo
          FROM tbgar_cobertura_operacao ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.insituacao = 1 /* Bloqueadas */
           AND ((ope.inaplicacao_propria + ope.inpoupanca_propria > 0 AND ope.nrdconta = pr_nrdconta)
            OR  (ope.inaplicacao_terceiro + ope.inpoupanca_terceiro > 0 AND ope.nrconta_terceiro = pr_nrdconta));
      
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.vlsdeved
            FROM crapepr epr
           WHERE epr.cdcooper = pr_cdcooper
             AND epr.nrdconta = pr_nrdconta
             AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT lim.vllimite
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrctrlim
           AND lim.tpctrlim = pr_tpctrlim;
      rw_craplim cr_craplim%ROWTYPE;
      
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variaveis auxiliares
      vr_valopera   NUMBER       := 0;
      vr_vlroriginal         NUMBER       := 0;
      vr_valbloque  NUMBER       := 0;
      vr_nrcpfcnpj_cobertura NUMBER       := 0;
      vr_tpcontrato VARCHAR2(10) := '';
    
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'LDESCO' 
                                ,pr_action => null);  
    
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
      
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><bloq_apli></bloq_apli><bloq_cobert></bloq_cobert></Root>');
      
      FOR rw_craprpp IN cr_craprpp(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP
        -- Registros
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/bloq_apli'
                                            ,XMLTYPE('<bloq>'
                                                   ||'  <dstipapl>'||rw_craprpp.dstipapl||'</dstipapl>'
                                                   ||'  <nrctrrpp>'||rw_craprpp.nrctrrpp||'</nrctrrpp>'
                                                   ||'  <vlsdrdpp>'||rw_craprpp.vlsdrdpp||'</vlsdrdpp>'
                                                   ||'  <tpaplica>0</tpaplica>'
                                                   ||'  <idtipapl>A</idtipapl>'
                                                   ||'  <nmprodut> </nmprodut>'
                                                   ||'</bloq>'));
      END LOOP;
      
      
      FOR rw_cobertura IN cr_cobertura(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta) LOOP
        IF rw_cobertura.tpcontrato = 90 THEN
          -- Buscar empréstimo
          OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => rw_cobertura.nrdconta
                         ,pr_nrctremp => rw_cobertura.nrcontrato);
          FETCH cr_crapepr INTO rw_crapepr;
          
          CLOSE cr_crapepr;
          
          vr_valopera := rw_crapepr.vlsdeved;
          
        ELSE
          -- Buscar limite
          OPEN cr_craplim(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => rw_cobertura.nrdconta
                         ,pr_nrctrlim => rw_cobertura.nrcontrato
                         ,pr_tpctrlim => rw_cobertura.tpcontrato);
          FETCH cr_craplim INTO rw_craplim;
          CLOSE cr_craplim;
          vr_valopera := rw_craplim.vllimite;
        END IF;
        
        -- Calcular o valor a bloquear
        BLOQ0001.pc_bloqueio_garantia_atualizad(pr_idcobert =>            rw_cobertura.idcobertura
                                               ,pr_vlroriginal =>         vr_vlroriginal
                                               ,pr_vlratualizado =>       vr_valbloque
                                               ,pr_nrcpfcnpj_cobertura => vr_nrcpfcnpj_cobertura
                                               ,pr_dscritic =>            vr_dscritic);
        
        IF vr_valbloque > 0 THEN
          
          IF rw_cobertura.tpcontrato = 1 THEN
            vr_tpcontrato := 'Lim.Créd.';
          ELSIF rw_cobertura.tpcontrato = 2 THEN
            vr_tpcontrato := 'Dsc.Cheque';
          ELSIF rw_cobertura.tpcontrato = 3 THEN
            vr_tpcontrato := 'Dsc.Título';
          ELSE
            vr_tpcontrato := 'Emp.Fin.';
          END IF;
          
          -- Registros
          pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                              ,'/Root/bloq_cobert'
                                              ,XMLTYPE('<bloq>'
                                                     ||'  <tpcontrato>'  || vr_tpcontrato            || '</tpcontrato>'
                                                     ||'  <nrdconta>'    || rw_cobertura.nrdconta    || '</nrdconta>'
                                                     ||'  <nrcontrato>'  || rw_cobertura.nrcontrato  || '</nrcontrato>'
                                                     ||'  <vlopera>'     || to_char(vr_valopera,'fm999g999g990d00') || '</vlopera>'
                                                     ||'  <valbloque>'   || to_char(vr_valbloque,'fm999g999g990d00') || '</valbloque>'
                                                     ||'  <idcobertura>' || rw_cobertura.idcobertura || '</idcobertura>'
                                                     ||'</bloq>'));
        END IF;
      END LOOP;
      
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
    END;
  END pc_busca_bloq_apli_cobe;

  PROCEDURE pc_desbloq_cobertura(pr_idcobertura IN NUMBER
                                ,pr_vldesblo    IN NUMBER
                                ,pr_cdopelib    IN VARCHAR2 --> Codigo do operador que liberou o desbloqueio
                                ,pr_xmllog      IN VARCHAR2 --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                                ,pr_retxml      IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_desbloq_cobertura
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Novembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para desbloquear Bloqueios por Cobertura de Operação de Crédito
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
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
      
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'LDESCO' 
                                ,pr_action => null);  
    
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
      
      BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_idcobertura => pr_idcobertura
                                           ,pr_inbloq_desbloq => 'L'
                                           ,pr_cdoperador => vr_cdoperad
                                           ,pr_cdcoordenador_desbloq => pr_cdopelib
                                           ,pr_vldesbloq => pr_vldesblo
                                           ,pr_flgerar_log => 'S'
                                           ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
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
    END;
  END pc_desbloq_cobertura;

END TELA_BLQRGT;
/
