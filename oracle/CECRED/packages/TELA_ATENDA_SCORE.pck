CREATE OR REPLACE PACKAGE TELA_ATENDA_SCORE IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SCORE
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para interface Web da opção Score na Atenda
  --
  --
  ---------------------------------------------------------------------------------------------------------------                     

  /* Listar os Scores do CPF enviado */
  PROCEDURE pc_lista_scores_cooperado(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                      /* Parametros base da Mensageria */
                                     ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  

  /* Listar as Exclusoes do Scores do CPF enviado */
  PROCEDURE pc_lista_excl_scores_cooperado(pr_cdmodelo IN NUMBER        --> Codigo Modelo
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                          ,pr_dtbase   IN VARCHAR2      --> Data base do Score
                                           /* Parametros base da Mensageria */
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  

END TELA_ATENDA_SCORE;
/
CREATE OR REPLACE PACKAGE BODY TELA_ATENDA_SCORE AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SCORE
  --  Sistema  : Aimaro
  --  Sigla    : CRED
  --  Autor    : Marcos (Envolti)
  --  Data     : Outubro/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para interface Web da opção Score na Atenda
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Listar os Scores do CPF enviado */
  PROCEDURE pc_lista_scores_cooperado(pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                      /* Parametros base da Mensageria */
                                     ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_lista_scores_cooperado
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar Scores Comportamentais do Cooperado enviad
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);    
    
      -- Busca do CPF ou CNPJ base do Cooperado
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE;
      
      -- Busca dos scores do Cooperado
      CURSOR cr_tbcrd_score(pr_cdcooper      crapcop.cdcooper%TYPE
                           ,pr_inpessoa      crapass.inpessoa%TYPE
                           ,pr_nrcpfcnpjbase tbcrd_score.nrcpfcnpjbase%TYPE) IS
        SELECT sco.cdmodelo
              ,csc.dsmodelo
              ,sco.dtbase
              ,sco.nrscore_alinhado
              ,sco.dsclasse_score
              ,sco.dsexclusao_principal
              ,decode(sco.flvigente,1,'Vigente','Não vigente') dsvigente
              ,row_number() over (partition By sco.cdmodelo
                                      order by sco.flvigente DESC, sco.dtbase DESC) nrseqreg          
          FROM tbcrd_score sco
              ,tbcrd_carga_score csc
         WHERE csc.cdmodelo      = sco.cdmodelo
           AND csc.dtbase        = sco.dtbase
           AND sco.cdcooper      = pr_cdcooper
           AND sco.tppessoa      = pr_inpessoa
           AND sco.nrcpfcnpjbase = pr_nrcpfcnpjbase
         ORDER BY sco.flvigente DESC
                 ,sco.dtbase DESC;
      rw_score cr_tbcrd_score%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Validar chamada
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
        RAISE vr_exc_saida;
      END IF;      
      
      -- Buscar cpf ou cnpj base
      OPEN cr_crapass(vr_cdcooper);
      FETCH cr_crapass 
       INTO vr_inpessoa,vr_nrcpfcnpj_base;
      CLOSE cr_crapass;
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      -- Buscar os ultimos 6 scores
      OPEN cr_tbcrd_score(vr_cdcooper,vr_inpessoa,vr_nrcpfcnpj_base);
      LOOP 
        FETCH cr_tbcrd_score INTO rw_score;
        EXIT WHEN cr_tbcrd_score%NOTFOUND;
        
        -- Só enviar os 6 primeiros scores do modelo
        IF rw_score.nrseqreg <= 6 THEN
          
          -- No raiz do Score
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'Score'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);
          -- Campos
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Score'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'cdmodelo'
                                ,pr_tag_cont => rw_score.cdmodelo
                                ,pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Score'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dsmodelo_score'
                                ,pr_tag_cont => rw_score.cdmodelo||'-'||rw_score.dsmodelo
                                ,pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Score'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dtbase'
                                ,pr_tag_cont => to_char(rw_score.dtbase,'dd/mm/rrrr')
                                ,pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Score'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dsclasse_score'
                                ,pr_tag_cont => rw_score.dsclasse_score
                                ,pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Score'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'nrscore_alinhado'
                                ,pr_tag_cont => rw_score.nrscore_alinhado
                                ,pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Score'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dsexclusao_principal'
                                ,pr_tag_cont => rw_score.dsexclusao_principal
                                ,pr_des_erro => vr_dscritic);                                
          gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Score'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dssituacao_score'
                                ,pr_tag_cont => rw_score.dsvigente
                                ,pr_des_erro => vr_dscritic);    
          vr_auxconta := vr_auxconta + 1;
        END IF;  
      END LOOP;
      CLOSE cr_tbcrd_score;
      
      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela SCORE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_scores_cooperado;  
  
  /* Listar as Exclusoes do Scores do CPF enviado */
  PROCEDURE pc_lista_excl_scores_cooperado(pr_cdmodelo IN NUMBER        --> Codigo Modelo
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE -- Conta desejado
                                          ,pr_dtbase   IN VARCHAR2      --> Data base do Score
                                           /* Parametros base da Mensageria */
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de entrada e retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_lista_excl_scores_cooperado
    Sistema : Ayllos Web
    Autor   : Marcos Martini (Envolti)
    Data    : Outubro - 2018.                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para buscar as Exclusões dos Scores Comportamentais do Cooperado enviado
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
    
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);        

      -- Busca do CPF ou CNPJ base do Cooperado
      CURSOR cr_crapass(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT ass.inpessoa
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_nrcpfcnpj_base crapass.nrcpfcnpj_base%TYPE;    
    
      -- Busca dos scores do Cooperado
      CURSOR cr_tbcrd_hist(pr_cdcooper      crapcop.cdcooper%TYPE
                          ,pr_inpessoa      crapass.inpessoa%TYPE
                          ,pr_nrcpfcnpjbase tbcrd_score.nrcpfcnpjbase%TYPE
                          ,pr_dtbase        tbcrd_score.dtbase%TYPE) IS
        SELECT sce.cdexclusao
              ,sce.dsexclusao
          FROM tbcrd_score_exclusao sce
         WHERE sce.cdmodelo      = pr_cdmodelo
           AND sce.cdcooper      = pr_cdcooper
           AND sce.dtbase        = pr_dtbase
           AND sce.tppessoa      = pr_inpessoa
           AND sce.nrcpfcnpjbase = pr_nrcpfcnpjbase
         ORDER BY sce.cdexclusao;
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Conversão de datas
      vr_dat_base DATE;
    
      -- Variaveis auxiliares
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
    BEGIN
      
      -- Validar chamada
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
        RAISE vr_exc_saida;
      END IF;      
      
      -- Validar chamada
      BEGIN
        vr_dat_base := to_date(pr_dtbase,'dd/mm/rrrr');
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Problema no recebimento da data base - Data invalida!';
          RAISE vr_exc_saida;
      END;
      
      -- Buscar cpf ou cnpj base
      OPEN cr_crapass(vr_cdcooper);
      FETCH cr_crapass 
       INTO vr_inpessoa,vr_nrcpfcnpj_base;
      CLOSE cr_crapass;      
      
      -- Criar cabeçalho do XML
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      FOR rw_excl_score IN cr_tbcrd_hist(vr_cdcooper,vr_inpessoa,vr_nrcpfcnpj_base,vr_dat_base) LOOP
        
        -- No raiz do Score
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'ExclScore'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        -- Campos
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ExclScore'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdexclusao'
                              ,pr_tag_cont => rw_excl_score.cdexclusao
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'ExclScore'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsexclusao'
                              ,pr_tag_cont => rw_excl_score.dsexclusao
                              ,pr_des_erro => vr_dscritic);          
        vr_auxconta := vr_auxconta + 1;
      
      END LOOP;
      
      -- Retornar quantidade de registros
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtdregis'
                            ,pr_tag_cont => vr_auxconta
                            ,pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN vr_exc_saida THEN        
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela SCORE: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_lista_excl_scores_cooperado;    

END TELA_ATENDA_SCORE;
/
