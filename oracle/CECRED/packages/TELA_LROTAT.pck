CREATE OR REPLACE PACKAGE CECRED.TELA_LROTAT IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_LROTAT
  --  Sistema  : Rotinas utilizadas pela Tela LROTAT
  --  Sigla    : CRAPLRT
  --  Autor    : Rafael Scolari Maciel
  --  Data     : Julho - 2016.                   Ultima atualizacao: 12/07/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela LROTAT
  --
  -- Alteracoes: 12/07/2016 - Ajustes para finzalização da conversão da tela LROTAT
  --                          (Andrei - RKAM).
  --             16/11/2016 - Inclusao dos campos Modelo e % Mínimo Garantia na tela.
  --                          (Lombardi - PRJ404)
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_lrotat(pr_cddopcao IN VARCHAR2
                              ,pr_cddlinha IN NUMBER
                              ,pr_cddepart IN NUMBER
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_calcula_taxa_web(pr_txjurvar IN NUMBER
                               ,pr_txjurfix IN NUMBER
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                           
  PROCEDURE pc_excluir_lrotat(pr_cddopcao IN VARCHAR2
                             ,pr_cddlinha IN NUMBER
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_atualizar_lrotat(pr_cddopcao IN VARCHAR2
                               ,pr_cddlinha IN craplrt.cddlinha%TYPE
                               ,pr_tpdlinha IN craplrt.tpdlinha%TYPE
                               ,pr_dsdlinha IN craplrt.dsdlinha%TYPE
                               ,pr_qtvezcap IN craplrt.qtvezcap%TYPE
                               ,pr_qtdiavig IN craplrt.qtdiavig%TYPE
                               ,pr_vllimmax IN craplrt.vllimmax%TYPE
                               ,pr_txjurfix IN craplrt.txjurfix%TYPE
                               ,pr_txjurvar IN craplrt.txjurvar%TYPE
                               ,pr_txmensal IN craplrt.txmensal%TYPE
                               ,pr_qtvcapce IN craplrt.qtvcapce%TYPE
                               ,pr_vllmaxce IN craplrt.vllimmax%TYPE
                               ,pr_dsencfin1 IN craplrt.dsencfin##1%TYPE
                               ,pr_dsencfin2 IN craplrt.dsencfin##2%TYPE
                               ,pr_dsencfin3 IN craplrt.dsencfin##3%TYPE
                               ,pr_origrecu IN craplrt.dsorgrec%TYPE
                               ,pr_cdmodali IN craplrt.cdmodali%TYPE
                               ,pr_cdsubmod IN craplrt.cdsubmod%TYPE
                               ,pr_cddepart IN NUMBER
                               ,pr_permingr IN craplrt.permingr%TYPE
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2); --> Erros do processo

   PROCEDURE pc_incluir_lrotat(pr_cddopcao IN VARCHAR2
                             ,pr_cddlinha IN craplrt.cddlinha%TYPE
                             ,pr_tpdlinha IN craplrt.tpdlinha%TYPE
                             ,pr_dsdlinha IN craplrt.dsdlinha%TYPE
                             ,pr_qtvezcap IN craplrt.qtvezcap%TYPE
                             ,pr_qtdiavig IN craplrt.qtdiavig%TYPE
                             ,pr_vllimmax IN craplrt.vllimmax%TYPE
                             ,pr_txjurfix IN craplrt.txjurfix%TYPE
                             ,pr_txjurvar IN craplrt.txjurvar%TYPE
                             ,pr_txmensal IN craplrt.txmensal%TYPE
                             ,pr_qtvcapce IN craplrt.qtvcapce%TYPE
                             ,pr_vllmaxce IN craplrt.vllimmax%TYPE
                             ,pr_dsencfin1 IN craplrt.dsencfin##1%TYPE
                             ,pr_dsencfin2 IN craplrt.dsencfin##2%TYPE
                             ,pr_dsencfin3 IN craplrt.dsencfin##3%TYPE
                             ,pr_origrecu IN craplrt.dsorgrec%TYPE
                             ,pr_cdmodali IN craplrt.cdmodali%TYPE
                             ,pr_cdsubmod IN craplrt.cdsubmod%TYPE
                             ,pr_cddepart IN NUMBER
                             ,pr_tpctrato IN craplrt.tpctrato%TYPE
                             ,pr_permingr IN craplrt.permingr%TYPE
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) ; --> Erros do processo

  PROCEDURE pc_lib_bloq_lrotat(pr_cddopcao IN VARCHAR2
                              ,pr_cddlinha IN NUMBER
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_busca_modalidade(pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                               
  PROCEDURE pc_busca_submodalidade(pr_cdmodali IN gnmodal.cdmodali%TYPE --Codigo da modalidade
                                  ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE --Codigo da submodalidade
                                  ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                  ,pr_nrregist IN INTEGER               -- Número de registros
                                  ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK                          
                               
END TELA_LROTAT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LROTAT IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_LROTAT
  --  Sistema  : Rotinas utilizadas pela Tela LROTAT
  --  Sigla    : LROTAT
  --  Autor    : Rafael Scolari Maciel
  --  Data     : Julho - 2016.                   Ultima atualizacao: 12/07/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela LROTAT
  --
  -- Alteracoes: 12/07/2016 - Ajustes para finzalização da conversão da tela LROTAT
  --                          (Andrei - RKAM).
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_lrotat(pr_cddopcao IN VARCHAR2
                              ,pr_cddlinha IN NUMBER
                              ,pr_cddepart IN NUMBER
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_lrotat
        Sistema : CECRED
        Sigla   : LROTAT
        Autor   : Rafael Scolari Maciel
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para consultar linha de desconto
    
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
    
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
      --Busca as Linhas de Credito Rotativo
      CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                       ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT DECODE(lrt.flgstlcr, 1, 'LIBERADA', 0, 'BLOQUEADA') dssitlcr
            ,lrt.cddlinha
            ,lrt.tpdlinha
            ,lrt.dsdlinha
            ,lrt.qtvezcap
            ,lrt.qtdiavig
            ,lrt.vllimmax
            ,lrt.txjurfix
            ,lrt.txjurvar
            ,lrt.txmensal
            ,lrt.vltarifa
            ,lrt.tpctrato
            ,lrt.permingr
            ,lrt.qtvcapce
            ,lrt.vllmaxce
            ,lrt.cdmodali
            ,lrt.cdsubmod
            ,lrt.dsorgrec
            ,lrt.dsencfin##1
            ,lrt.dsencfin##2
            ,lrt.dsencfin##3
       FROM craplrt lrt
      WHERE lrt.cdcooper = pr_cdcooper
        AND lrt.cddlinha = pr_cddlinha;
      rw_craplrt cr_craplrt%ROWTYPE;
    
      --Busca os registros de Cadastro de modalidades das operacoes de credito
      CURSOR cr_gnmodal(pr_cdmodali IN gnmodal.cdmodali%TYPE)IS
      SELECT gnmodal.cdmodali
            ,gnmodal.dsmodali
        FROM gnmodal
       WHERE gnmodal.cdmodali = pr_cdmodali;
      rw_gnmodal cr_gnmodal%ROWTYPE;
      
      --Busca os registros de Cadastro de submodalidades das operacoes de credito.
      CURSOR cr_gnsbmod(pr_cdmodali IN gnsbmod.cdmodali%TYPE
                       ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE)IS
      SELECT gnsbmod.cdsubmod
            ,gnsbmod.dssubmod
        FROM gnsbmod
       WHERE gnsbmod.cdmodali = pr_cdmodali
         AND gnsbmod.cdsubmod = pr_cdsubmod;
      rw_gnsbmod cr_gnsbmod%ROWTYPE;
    
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'LROTAT' 
                                ,pr_action => null);  
    
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
      
      IF pr_cddopcao NOT IN ('A','C') THEN
        
        -- Se o código do departamento não for 8-COORD.ADM/FINANCEIRO, 14-PRODUTOS ou 20-TI
        IF pr_cddepart NOT IN (8,14,20) THEN
          
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Sistema liberado apenas para Consulta e Alteracao !';
          pr_nmdcampo := 'cddlinha';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;
          
        END IF;
        
      END IF;
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        pr_nmdcampo := 'cddlinha';
        
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_craplrt(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha);
                      
      FETCH cr_craplrt INTO rw_craplrt;
    
      -- Se nao encontrar
      IF cr_craplrt%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_craplrt;
      
        IF pr_cddopcao = 'I' THEN
          
          pr_des_erro := 'OK'; 
          
          RETURN;
        END IF;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Linha nao encontrada!';
        pr_nmdcampo := 'cddlinha';
        
        -- volta para o programa chamador
        RAISE vr_exc_saida;
        
      ELSE
        IF pr_cddopcao = 'I' THEN
          
          vr_cdcritic := 873;
          vr_dscritic := '';
          pr_nmdcampo := 'cddlinha';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        END IF;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_craplrt;
    
      OPEN cr_gnmodal(pr_cdmodali => rw_craplrt.cdmodali);
      
      FETCH cr_gnmodal INTO rw_gnmodal;
      
      CLOSE cr_gnmodal;
      
      OPEN cr_gnsbmod(pr_cdmodali => rw_craplrt.cdmodali
                     ,pr_cdsubmod => rw_craplrt.cdsubmod);
      
      FETCH cr_gnsbmod INTO rw_gnsbmod;
      
      CLOSE cr_gnsbmod;
      
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
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dssitlcr',
                             pr_tag_cont => rw_craplrt.dssitlcr,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'cddlinha',
                             pr_tag_cont => rw_craplrt.cddlinha,
                             pr_des_erro => vr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'tpdlinha',
                             pr_tag_cont => rw_craplrt.tpdlinha,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dsdlinha',
                             pr_tag_cont => rw_craplrt.dsdlinha,
                             pr_des_erro => vr_dscritic);


      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtvezcap',
                             pr_tag_cont => to_char(rw_craplrt.qtvezcap,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiavig',
                             pr_tag_cont => rw_craplrt.qtdiavig,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimmax',
                             pr_tag_cont => to_char(rw_craplrt.vllimmax,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txjurfix',
                             pr_tag_cont => to_char(rw_craplrt.txjurfix,'fm990d000000','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txjurvar',
                             pr_tag_cont => to_char(rw_craplrt.txjurvar,'fm990d000000','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txmensal',
                             pr_tag_cont => to_char(rw_craplrt.txmensal,'fm990d000000','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'tpctrato',
                             pr_tag_cont => to_char(rw_craplrt.tpctrato),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'permingr',
                             pr_tag_cont => to_char(rw_craplrt.permingr,'fm990d00','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtvcapce',
                             pr_tag_cont => to_char(rw_craplrt.qtvcapce,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllmaxce',
                             pr_tag_cont => to_char(rw_craplrt.vllmaxce,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);                             
 
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dsencfin1',
                             pr_tag_cont => rw_craplrt.dsencfin##1,
                             pr_des_erro => vr_dscritic);
                             
	    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'dsencfin2',
                           pr_tag_cont => rw_craplrt.dsencfin##2,
                           pr_des_erro => vr_dscritic); 
                           
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'dsencfin3',
                           pr_tag_cont => rw_craplrt.dsencfin##3,
                           pr_des_erro => vr_dscritic);    
                           
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'origrecu',
                           pr_tag_cont => rw_craplrt.dsorgrec,
                           pr_des_erro => vr_dscritic);  
                           
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'cdmodali',
                           pr_tag_cont => rw_gnmodal.cdmodali,
                           pr_des_erro => vr_dscritic);  
                           
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'dsmodali',
                           pr_tag_cont => rw_gnmodal.dsmodali,
                           pr_des_erro => vr_dscritic);                               
                           
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'cdsubmod',
                           pr_tag_cont => rw_gnsbmod.cdsubmod,
                           pr_des_erro => vr_dscritic);      
                           
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => vr_auxconta,
                           pr_tag_nova => 'dssubmod',
                           pr_tag_cont => rw_gnsbmod.dssubmod,
                           pr_des_erro => vr_dscritic); 
                           
      pr_des_erro := 'OK';                                                                                       

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
                
      WHEN OTHERS THEN
      
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_consulta_lrotat --> '|| SQLERRM;
        pr_des_erro := 'NOK';
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');         
       
    END;
    
  END pc_consulta_lrotat;

  PROCEDURE pc_calcula_taxa(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_txjurvar IN NUMBER
                           ,pr_txjurfix IN NUMBER
                           ,pr_txmensal OUT NUMBER
                           ,pr_cdcritic OUT INTEGER
                           ,pr_dscritic OUT VARCHAR2
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_calcula_taxa
        Sistema : CECRED
        Sigla   : LROTAT
        Autor   : Rafael Scolari Maciel
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para calcular taxa de juros
    
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
    
      --Variaveis locais
      vr_dstextab craptab.dstextab%type;  
      vr_txrefmes NUMBER(9,6) := 0;
              
    BEGIN
    
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'TAXASDOMES'
                                              ,pr_tpregist => 001);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        
        -- Montar mensagem de critica
        vr_cdcritic := 347;
        vr_dscritic := '';
        
        -- volta para o programa chamador
        RAISE vr_exc_saida;
        
      ELSE
        
        /* Ident. TR ou UFIR */
        IF  SUBSTR(vr_dstextab,1,1) = 'T' THEN
          
          vr_txrefmes := to_number(substr(vr_dstextab,3,10));
         
        ELSE
          
          vr_txrefmes := to_number(substr(vr_dstextab,14,10));
          
        END IF;    
        
      END IF; 
        
      pr_txmensal := ROUND(((vr_txrefmes * (pr_txjurvar / 100) + 100) * 
                          (1 + (pr_txjurfix / 100)) - 100),6);
                                
    
      pr_des_erro := 'OK';
      
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
        
      WHEN OTHERS THEN
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_calcula_taxa --> '|| SQLERRM;
        
    END;
  END pc_calcula_taxa;
  
  
  PROCEDURE pc_calcula_taxa_web(pr_txjurvar IN NUMBER
                               ,pr_txjurfix IN NUMBER
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_calcula_taxa_web
        Sistema : CECRED
        Sigla   : LROTAT
        Autor   : Andrei - RKAM
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado pela web
    
        Objetivo  : Rotina para calcular taxa de juros
    
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
            
      --Variaveis locais
      vr_txmensal NUMBER;
      vr_des_erro VARCHAR2(10);
    
    BEGIN
        
      GENE0001.pc_informa_acesso(pr_module => 'LROTAT' 
                                ,pr_action => null);
                                
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
    
      pc_calcula_taxa(pr_cdcooper => vr_cdcooper
                     ,pr_txjurvar => pr_txjurvar 
                     ,pr_txjurfix => pr_txjurfix
                     ,pr_txmensal => vr_txmensal
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic
                     ,pr_des_erro => vr_des_erro);                           
       
      IF vr_des_erro <> 'OK'           OR 
         nvl(vr_cdcritic,0) <> 0       OR 
         trim(vr_dscritic) IS NOT NULL THEN      
         
        RAISE vr_exc_saida;
      
      END IF;                   
                           
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'             --> Nome da TAG XML
                               ,pr_atrib => 'txmensal'          --> Nome do atributo
                               ,pr_atval => to_char(vr_txmensal,
                                                    '990D000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.''') --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      pr_des_erro := 'OK';
      
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
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_calcula_taxa_web --> '|| SQLERRM;
          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
        ROLLBACK;
    END;
  END pc_calcula_taxa_web;

  PROCEDURE pc_excluir_lrotat(pr_cddopcao IN VARCHAR2
                             ,pr_cddlinha IN NUMBER
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_excluir_lrotat
        Sistema : CECRED
        Sigla   : LROTAT
        Autor   : Rafael Scolari Maciel
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir linha Desconto
    
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
    
      CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                       ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT lrt.cdcooper,
             lrt.cddlinha,
             lrt.tpdlinha,
             lrt.dsdlinha,
             lrt.txmensal
        FROM craplrt lrt
       WHERE lrt.cdcooper = pr_cdcooper
         AND lrt.cddlinha = pr_cddlinha;
      rw_craplrt cr_craplrt%ROWTYPE;
    
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_cddlinha IN craplim.cddlinha%TYPE) IS
      SELECT lim.cdcooper
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.cddlinha = pr_cddlinha
         AND lim.tpctrlim = 1;
      rw_craplim cr_craplim%ROWTYPE;
      
      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    BEGIN
    
      GENE0001.pc_informa_acesso(pr_module => 'LROTAT' 
                                ,pr_action => null);
                                
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
    
      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_craplrt(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha);
                      
      FETCH cr_craplrt INTO rw_craplrt;
    
      -- Se nao encontrar
      IF cr_craplrt%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplrt;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Linha nao encontrada!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_craplrt;
    
      OPEN cr_craplim(pr_cdcooper => rw_craplrt.cdcooper,
                      pr_cddlinha => rw_craplrt.cddlinha);
                      
      FETCH cr_craplim INTO rw_craplim;
    
      -- Se nao encontrar
      IF cr_craplim%FOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplim;
      
        -- Montar mensagem de critica
        vr_cdcritic := 377;
        vr_dscritic := '';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_craplim;
    
      BEGIN
        DELETE FROM craplrt lrt
         WHERE lrt.cdcooper = vr_cdcooper
           AND lrt.cddlinha = pr_cddlinha;
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao excluir Linha de Desconto!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;       
    
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lrotat.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    ' Excluiu a linha ' || pr_cddlinha || ' - ' || rw_craplrt.dsdlinha || '.');
      COMMIT;
      
      pr_des_erro := 'OK';
          
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
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_excluir_lrotat --> '|| SQLERRM;
          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
        ROLLBACK;
    END;
  END pc_excluir_lrotat;

  PROCEDURE pc_atualizar_lrotat(pr_cddopcao IN VARCHAR2
                               ,pr_cddlinha IN craplrt.cddlinha%TYPE
                               ,pr_tpdlinha IN craplrt.tpdlinha%TYPE
                               ,pr_dsdlinha IN craplrt.dsdlinha%TYPE
                               ,pr_qtvezcap IN craplrt.qtvezcap%TYPE
                               ,pr_qtdiavig IN craplrt.qtdiavig%TYPE
                               ,pr_vllimmax IN craplrt.vllimmax%TYPE
                               ,pr_txjurfix IN craplrt.txjurfix%TYPE
                               ,pr_txjurvar IN craplrt.txjurvar%TYPE
                               ,pr_txmensal IN craplrt.txmensal%TYPE
                               ,pr_qtvcapce IN craplrt.qtvcapce%TYPE
                               ,pr_vllmaxce IN craplrt.vllimmax%TYPE
                               ,pr_dsencfin1 IN craplrt.dsencfin##1%TYPE
                               ,pr_dsencfin2 IN craplrt.dsencfin##2%TYPE
                               ,pr_dsencfin3 IN craplrt.dsencfin##3%TYPE
                               ,pr_origrecu IN craplrt.dsorgrec%TYPE
                               ,pr_cdmodali IN craplrt.cdmodali%TYPE
                               ,pr_cdsubmod IN craplrt.cdsubmod%TYPE
                               ,pr_cddepart IN NUMBER
                               ,pr_permingr IN craplrt.permingr%TYPE
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_atualizar_lrotat
        Sistema : CECRED
        Sigla   : LROTAT
        Autor   : Rafael Scolari Maciel
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para atualizar linha Desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
      vr_des_erro VARCHAR2(10);
      
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
      vr_txmensal NUMBER(9,6) := 0;    
      
      -- Variaveis auxiliares
      vr_permingr craplrt.permingr%TYPE;
      
      CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                       ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT lrt.cdcooper,
             lrt.cddlinha,
             lrt.tpdlinha,
             lrt.dsdlinha,
             lrt.vllimmax,
             lrt.vllmaxce,
             lrt.qtvezcap,
             lrt.qtdiavig,
             lrt.qtvcapce,
             lrt.txjurfix,
             lrt.txjurvar,
             lrt.tpctrato,
             lrt.permingr,
             lrt.dsencfin##1,
             lrt.dsencfin##2,
             lrt.dsencfin##3,
             lrt.txmensal	
       FROM craplrt lrt
      WHERE lrt.cdcooper = pr_cdcooper
        AND lrt.cddlinha = pr_cddlinha;
      rw_craplrt cr_craplrt%ROWTYPE;
    
      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'LROTAT' 
                                ,pr_action => null);
      
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
    
      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_craplrt(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha);
                      
      FETCH cr_craplrt INTO rw_craplrt;
    
      -- Se nao encontrar
      IF cr_craplrt%NOTFOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_craplrt;
      
        -- Montar mensagem de critica
        vr_cdcritic := 363;
        vr_dscritic := '';
        
        -- volta para o programa chamador
        RAISE vr_exc_saida;
        
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_craplrt;
      
      -- Se o código do departamento não for 8-COORD.ADM/FINANCEIRO, 14-PRODUTOS ou 20-TI
        IF pr_cddepart NOT IN (8,14,20) THEN
        
        IF trim(pr_dsdlinha) IS NOT NULL THEN 
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Descricao da linha so pode ser alterada pela central.';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;    
        
        END IF;
        
        IF nvl(pr_vllmaxce,0) < nvl(pr_vllimmax,0) THEN
          
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Valor limite maximo CECRED menor que valor vimite maximo operacional.';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida; 
          
        END IF;
        
      
      END IF;
      
      -- Se o código do departamento não for 8-COORD.ADM/FINANCEIRO, 14-PRODUTOS ou 20-TI
      IF pr_cddepart NOT IN (8,14,20) THEN
        
        IF nvl(pr_qtvezcap,0) > 0 THEN   
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao e permitido alterar a quantidade de vezes do capital.';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;     
          
        END IF;
        
        IF nvl(pr_vllimmax,0) > 0 THEN   
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao e permitido alterar o valor limite maximo.';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;     
          
        END IF;
        
        IF nvl(pr_vllimmax,0) > nvl(pr_vllmaxce,0) THEN   
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Valor Limite maximo operacional maior que valor limite maximo CECRED.';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;     
          
        END IF;
        
        IF trim(pr_origrecu) IS NOT NULL OR
           trim(pr_cdmodali) IS NOT NULL OR
           trim(pr_cdsubmod) IS NOT NULL THEN
           
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao e permitido alterar as informacoes de central de risco';
          
          -- volta para o programa chamador
          RAISE vr_exc_saida;     
           
        END IF;            
        
      END IF;
    
      IF pr_dsdlinha IS NULL THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Descricao da Linha deve ser preenchido!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
      
       IF pr_tpdlinha IS NULL OR 
         (pr_tpdlinha <> 1    AND 
          pr_tpdlinha <> 2 )  THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Tipo da Linha invalido!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      pc_calcula_taxa(pr_cdcooper => vr_cdcooper
                     ,pr_txjurvar => pr_txjurvar 
                     ,pr_txjurfix => pr_txjurfix
                     ,pr_txmensal => vr_txmensal
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic
                     ,pr_des_erro => vr_des_erro);                           
       
      IF vr_des_erro <> 'OK'           OR 
         nvl(vr_cdcritic,0) <> 0       OR 
         trim(vr_dscritic) IS NOT NULL THEN      
         
        RAISE vr_exc_saida;
      
      END IF;
                           
      IF rw_craplrt.tpctrato NOT IN (0,4) THEN
        
        vr_cdcritic := 529;
          
        RAISE  vr_exc_saida;
        
      END IF;
      
      IF rw_craplrt.tpctrato <> 4 THEN
        vr_permingr := 0;
      ELSE
        vr_permingr := pr_permingr;
      END IF;
      
      IF rw_craplrt.tpctrato = 4 AND (vr_permingr < 0.01 OR vr_permingr > 300) THEN
        
        vr_dscritic := 'Percentual minimo da cobertura da garantia de aplicacao inválido. Deve ser entre "0.01" e "300".';
        pr_nmdcampo := 'permingr';
          
        RAISE  vr_exc_saida;
        
      END IF;
      
      BEGIN
        UPDATE craplrt lrt
           SET lrt.dsdlinha = UPPER(pr_dsdlinha) ,
               lrt.tpdlinha = pr_tpdlinha,
               lrt.qtdiavig = pr_qtdiavig,
               lrt.qtvezcap = pr_qtvezcap,
               lrt.qtvcapce = pr_qtvcapce,
               lrt.txjurfix = pr_txjurfix,
               lrt.txjurvar = pr_txjurvar,
               lrt.txmensal = vr_txmensal,
               lrt.permingr = vr_permingr,
               lrt.vllimmax = pr_vllimmax,
               lrt.vllmaxce = pr_vllmaxce,
               lrt.dsencfin##1 = pr_dsencfin1,
               lrt.dsencfin##2 = pr_dsencfin2,
               lrt.dsencfin##3 = pr_dsencfin3,
               lrt.dsorgrec    = pr_origrecu,
               lrt.cdmodali    = TRIM(to_char(pr_cdmodali,'99900')),
               lrt.cdsubmod    = TRIM(to_char(pr_cdsubmod,'99900'))        
         WHERE lrt.cdcooper = vr_cdcooper
           AND lrt.cddlinha = pr_cddlinha;
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar Linha de Desconto!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;
      
    
      IF rw_craplrt.dsdlinha <> pr_dsdlinha THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Descricao da linha de credito de ' || 
                                                      rw_craplrt.dsdlinha || ' para ' || pr_dsdlinha || ' da linha ' ||
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;      
      
      IF rw_craplrt.tpdlinha <> pr_tpdlinha THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Tipo de linha de credito de ' || 
                                                      (CASE rw_craplrt.tpdlinha 
                                                         WHEN 1 THEN 
                                                            'Limite de Credito PF'
                                                         ELSE 
                                                            'Limite de Credito PJ'
                                                       END) || 
                                                      ' para ' || 
                                                      (CASE pr_tpdlinha 
                                                         WHEN 1 THEN 
                                                            'Limite de Credito PF'
                                                         ELSE 
                                                            'Limite de Credito PJ'
                                                       END)  || ' da linha ' ||
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
           
      IF rw_craplrt.qtvezcap <> pr_qtvezcap THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Quantidade de vezes do capital - Operacional ' || 
                                                      to_char(rw_craplrt.qtvezcap,'fm999g999g990d00') || ' para ' || to_char(pr_qtvezcap,'fm999g999g990d00') || ' da linha ' ||
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;  
      
      IF rw_craplrt.qtvcapce <> pr_qtvcapce THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Quantidade de vezes do capital - CECRED ' || 
                                                      to_char(rw_craplrt.qtvcapce,'fm999g999g990d00') || ' para ' || to_char(pr_qtvcapce,'fm999g999g990d00') || ' da linha ' ||
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
      
      IF rw_craplrt.vllimmax <> pr_vllimmax THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Valor Limite maximo - Operacional ' || 
                                                      to_char(rw_craplrt.vllimmax,'fm999g999g990d00') || ' para ' || to_char(pr_vllimmax,'fm999g999g990d00') || ' da linha ' ||
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
      
      IF rw_craplrt.vllmaxce <> pr_vllmaxce THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Valor Limite maximo - CECRED ' || 
                                                      to_char(rw_craplrt.vllmaxce,'fm999g999g990d00') || ' para ' || to_char(pr_vllmaxce,'fm999g999g990d00') || ' da linha ' ||                                                      
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
      
      IF rw_craplrt.qtdiavig <> pr_qtdiavig THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Dias de vigencia no contrato ' || 
                                                      rw_craplrt.qtdiavig || ' para ' || pr_qtdiavig || ' da linha ' ||
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
      
      IF rw_craplrt.txjurfix <> pr_txjurfix THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Taxa Fixa ' || 
                                                      to_char(rw_craplrt.txjurfix,'fm990d000000') || ' para ' || to_char(pr_txjurfix,'fm990d000000') || ' da linha ' ||                                                      
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
      
      IF rw_craplrt.txjurvar <> pr_txjurvar THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Taxa Variavel ' || 
                                                      to_char(rw_craplrt.txjurvar,'fm990d000000') || ' para ' || to_char(pr_txjurvar,'fm990d000000') || ' da linha ' ||       
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
      
      IF rw_craplrt.permingr <> vr_permingr THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Percentual minimo da cobertura da garantia de aplicacao ' || 
                                                      to_char(rw_craplrt.permingr,'fm990d00') || ' para ' || to_char(vr_permingr,'fm990d00') || ' da linha ' ||       
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
      
      IF rw_craplrt.dsencfin##1 <> pr_dsencfin1 OR 
         rw_craplrt.dsencfin##2 <> pr_dsencfin2 OR
         rw_craplrt.dsencfin##3 <> pr_dsencfin3 THEN
        
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'lrotat.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                      'Alterou o/a Texto no contrato ' || 
                                                      rw_craplrt.dsencfin##1 || ' ' || rw_craplrt.dsencfin##2 ||
                                                      ' ' || rw_craplrt.dsencfin##3  || ' para ' || pr_dsencfin1 || 
                                                      ' ' || pr_dsencfin2 || ' ' || pr_dsencfin3 || ' da linha ' ||
                                                      rw_craplrt.cddlinha || '.');
      
      END IF;
                                                
      COMMIT;
      
      pr_des_erro := 'OK';
    
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
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_atualizar_lrotat --> '|| SQLERRM;
          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
        ROLLBACK;
    END;
  END pc_atualizar_lrotat;
                               
  PROCEDURE pc_incluir_lrotat(pr_cddopcao IN VARCHAR2
                             ,pr_cddlinha IN craplrt.cddlinha%TYPE
                             ,pr_tpdlinha IN craplrt.tpdlinha%TYPE
                             ,pr_dsdlinha IN craplrt.dsdlinha%TYPE
                             ,pr_qtvezcap IN craplrt.qtvezcap%TYPE
                             ,pr_qtdiavig IN craplrt.qtdiavig%TYPE
                             ,pr_vllimmax IN craplrt.vllimmax%TYPE
                             ,pr_txjurfix IN craplrt.txjurfix%TYPE
                             ,pr_txjurvar IN craplrt.txjurvar%TYPE
                             ,pr_txmensal IN craplrt.txmensal%TYPE
                             ,pr_qtvcapce IN craplrt.qtvcapce%TYPE
                             ,pr_vllmaxce IN craplrt.vllimmax%TYPE
                             ,pr_dsencfin1 IN craplrt.dsencfin##1%TYPE
                             ,pr_dsencfin2 IN craplrt.dsencfin##2%TYPE
                             ,pr_dsencfin3 IN craplrt.dsencfin##3%TYPE
                             ,pr_origrecu IN craplrt.dsorgrec%TYPE
                             ,pr_cdmodali IN craplrt.cdmodali%TYPE
                             ,pr_cdsubmod IN craplrt.cdsubmod%TYPE
                             ,pr_cddepart IN NUMBER
                             ,pr_tpctrato IN craplrt.tpctrato%TYPE
                             ,pr_permingr IN craplrt.permingr%TYPE
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_incluir_lrotat
        Sistema : CECRED
        Sigla   : LROTAT
        Autor   : Rafael Scolari Maciel
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir linha Desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
      vr_des_erro VARCHAR2(10);
    
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
    
      vr_txmensal NUMBER(9,6) := 0; 
      vr_permingr craplrt.permingr%TYPE;
    
      CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                       ,pr_cddlinha IN craplrt.cddlinha%TYPE
                       ,pr_tpdlinha IN craplrt.tpdlinha%TYPE) IS
      SELECT lrt.cdcooper,
             lrt.cddlinha,
             lrt.tpdlinha,
             lrt.txmensal
        FROM craplrt lrt
       WHERE lrt.cdcooper = pr_cdcooper
         AND lrt.cddlinha = pr_cddlinha
         AND lrt.tpdlinha = pr_tpdlinha;
      rw_craplrt cr_craplrt%ROWTYPE;
    
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'LROTAT' 
                                ,pr_action => null);    
      
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
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_craplrt(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha,
                      pr_tpdlinha => pr_tpdlinha);
                      
      FETCH cr_craplrt INTO rw_craplrt;
    
      -- Se nao encontrar
      IF cr_craplrt%FOUND THEN
        
        -- Fechar o cursor
        CLOSE cr_craplrt;
      
        -- Montar mensagem de critica
        vr_cdcritic := 873;
        vr_dscritic := '';
        
        -- volta para o programa chamador
        RAISE vr_exc_saida;
        
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_craplrt;
    
      IF pr_dsdlinha IS NULL THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Descricao da linha deve ser preenchido!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
        
      IF nvl(pr_vllimmax,0) > nvl(pr_vllmaxce,0) THEN   
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Valor limite maximo operacional maior que valor limite maximo CECRED.';
          
        -- volta para o programa chamador
        RAISE vr_exc_saida;     
          
      END IF;
        
      pc_calcula_taxa(pr_cdcooper => vr_cdcooper
                     ,pr_txjurvar => pr_txjurvar 
                     ,pr_txjurfix => pr_txjurfix
                     ,pr_txmensal => vr_txmensal
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic
                     ,pr_des_erro => vr_des_erro);                           
       
      IF vr_des_erro <> 'OK'           OR 
         nvl(vr_cdcritic,0) <> 0       OR 
         trim(vr_dscritic) IS NOT NULL THEN      
         
        RAISE vr_exc_saida;
      
      END IF;
      
      IF pr_tpctrato NOT IN (1,4) THEN
        
        vr_cdcritic := 529;
          
        RAISE  vr_exc_saida;
        
      END IF;
      
      IF pr_tpctrato <> 4 THEN
        vr_permingr := 0;
      ELSE
        vr_permingr := pr_permingr;
      END IF;
      
      IF pr_tpctrato = 4 AND (vr_permingr < 0.01 OR vr_permingr > 300) THEN
        
        vr_dscritic := 'Percentual minimo da cobertura da garantia de aplicacao inválido. Deve ser entre "0.01" e "300".';
        pr_nmdcampo := 'permingr';
          
        RAISE  vr_exc_saida;
        
      END IF;
      
      BEGIN
        INSERT INTO craplrt lrt
              (lrt.cddlinha
              ,lrt.flgstlcr
              ,lrt.cdcooper
              ,lrt.tpdlinha
              ,lrt.dsdlinha
              ,lrt.qtdiavig
              ,lrt.qtvezcap
              ,lrt.qtvcapce
              ,lrt.txjurfix
              ,lrt.txjurvar
              ,lrt.txmensal
              ,lrt.vllimmax
              ,lrt.vllmaxce
              ,lrt.tpctrato
              ,lrt.permingr
              ,lrt.dsencfin##1
              ,lrt.dsencfin##2
              ,lrt.dsencfin##3
              ,lrt.dsorgrec
              ,lrt.cdmodali
              ,lrt.cdsubmod)
        VALUES(pr_cddlinha
              ,1
              ,vr_cdcooper
              ,pr_tpdlinha
              ,pr_dsdlinha
              ,pr_qtdiavig
              ,pr_qtvezcap
              ,pr_qtvcapce
              ,pr_txjurfix
              ,pr_txjurvar
              ,vr_txmensal
              ,pr_vllimmax
              ,pr_vllmaxce
              ,pr_tpctrato
              ,vr_permingr
              ,pr_dsencfin1
              ,pr_dsencfin2
              ,pr_dsencfin3
              ,pr_origrecu
              ,trim(to_char(pr_cdmodali,'99900'))
              ,trim(to_char(pr_cdsubmod,'99900')));
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir Linha de Desconto!' || SQLERRM;
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;
      
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lrotat.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' || 
                                                    'Cadastrou a linha ' || pr_cddlinha || ' - ' ||
                                                    pr_dsdlinha || '.');
      

    
      COMMIT;
      
      pr_des_erro := 'OK';
    
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
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_incluir_lrotat --> '|| SQLERRM;
          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
        ROLLBACK;
    END;
  END pc_incluir_lrotat;

  PROCEDURE pc_lib_bloq_lrotat(pr_cddopcao IN VARCHAR2
                              ,pr_cddlinha IN NUMBER
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_lib_bloq_lrotat
        Sistema : CECRED
        Sigla   : LROTAT
        Autor   : Rafael Scolari Maciel
        Data    : Julho - 2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir linha Desconto
    
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
    
      vr_flgstlcr NUMBER;
      
      CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                       ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
        SELECT lrt.cdcooper,
               lrt.cddlinha,
               lrt.tpdlinha,
               lrt.dsdlinha,
               lrt.flgstlcr,
               lrt.txmensal
          FROM craplrt lrt
         WHERE lrt.cdcooper = pr_cdcooper
           AND lrt.cddlinha = pr_cddlinha;
      rw_craplrt cr_craplrt%ROWTYPE;
    
    BEGIN
    
      GENE0001.pc_informa_acesso(pr_module => 'LROTAT' 
                                ,pr_action => null);
                                
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
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_craplrt(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha);
                      
      FETCH cr_craplrt INTO rw_craplrt;
    
      -- Se nao encontrar
      IF cr_craplrt%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplrt;
      
        -- Montar mensagem de critica
        vr_cdcritic := 363;
        vr_dscritic := '';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_craplrt;
    
      IF pr_cddopcao = 'B' THEN
        vr_flgstlcr := 0; -- Bloqueada
      ELSE
        vr_flgstlcr := 1; -- Liberada
      END IF;
      
      IF vr_flgstlcr = rw_craplrt.flgstlcr THEN
        
        pr_des_erro := 'OK';
        RETURN;
        
      END IF;
    
      BEGIN
        UPDATE craplrt lrt
           SET lrt.flgstlcr = vr_flgstlcr
         WHERE lrt.cdcooper = vr_cdcooper
           AND lrt.cddlinha = pr_cddlinha;
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          IF vr_flgstlcr = 0 THEN
            vr_dscritic := 'Erro ao bloquear Linha de Desconto!';
          ELSE
            vr_dscritic := 'Erro ao liberar Linha de Desconto!';
          END IF;
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;
      
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'lrotat.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  LROTAT '|| vr_cdoperad || ' - ' || (CASE vr_flgstlcr WHEN 0 THEN 'Bloqueou' ELSE 'Liberou' END) ||
                                                    ' a linha ' || pr_cddlinha || ' - ' || rw_craplrt.dsdlinha || '.');
                                                        
      
      COMMIT;
      
      pr_des_erro := 'OK';
    
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
      
        pr_des_erro := 'NOK';
           
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_lib_bloq_lrotat --> '|| SQLERRM;
          
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
        ROLLBACK;
    END;
  END pc_lib_bloq_lrotat;
  
  PROCEDURE pc_busca_modalidade(pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_modalidade                           
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Julho/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca modalidades
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_gnmodal IS
    SELECT gnmodal.cdmodali
          ,gnmodal.dsmodali
      FROM gnmodal
     WHERE gnmodal.cdmodali IN ('02','14');          
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'LROTAT'
                              ,pr_action => null); 
    
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
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><modalidades>');     
                           
    --Busca as propostas
    FOR rw_gnmodal IN cr_gnmodal LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<modalidade>'||  
                                                       '  <cdmodali>' || rw_gnmodal.cdmodali ||'</cdmodali>'||                                                                                                      
                                                       '  <dsmodali>' || rw_gnmodal.dsmodali ||'</dsmodali>'||                                                       
                                                     '</modalidade>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Nenhuma modalidade encontrada!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</modalidades></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_modalidade --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_modalidade;  

  PROCEDURE pc_busca_submodalidade(pr_cdmodali IN gnmodal.cdmodali%TYPE --Codigo da modalidade
                                  ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE --Codigo da submodalidade
                                  ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                  ,pr_nrregist IN INTEGER               -- Número de registros
                                  ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_submodalidade                           
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Julho/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca submodalidades
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_gnsbmod(pr_cdmodali IN gnmodal.cdmodali%TYPE
                     ,pr_cdsubmod IN gnsbmod.cdsubmod%TYPE)IS
    SELECT gnsbmod.cdsubmod
          ,gnsbmod.dssubmod
      FROM gnsbmod
     WHERE gnsbmod.cdmodali = pr_cdmodali
       AND (pr_cdsubmod IS NULL OR gnsbmod.cdsubmod = pr_cdsubmod)
     ORDER BY gnsbmod.cdsubmod;          
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'LROTAT'
                              ,pr_action => null); 
    
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
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><submodalidades>');     
                           
    --Busca as propostas
    FOR rw_gnsbmod IN cr_gnsbmod(pr_cdmodali => TRIM(TO_CHAR(pr_cdmodali,'00'))
                                ,pr_cdsubmod => TRIM(TO_CHAR(pr_cdsubmod,'00'))) LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<submodalidade>'||  
                                                       '  <cdsubmod>' || rw_gnsbmod.cdsubmod ||'</cdsubmod>'||                                                                                                      
                                                       '  <dssubmod>' || rw_gnsbmod.dssubmod ||'</dssubmod>'||                                                       
                                                     '</submodalidade>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Nenhuma submodalidade encontrada!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</submodalidades></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'submodalidades'    --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_submodalidade --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_submodalidade;  


END TELA_LROTAT;
/
