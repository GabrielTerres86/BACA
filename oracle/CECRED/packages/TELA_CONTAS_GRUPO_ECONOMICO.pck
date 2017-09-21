CREATE OR REPLACE PACKAGE CECRED.TELA_CONTAS_GRUPO_ECONOMICO IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CONTAS_GRUPO_ECONOMICO
  --  Sistema  : Procedimentos para tela Contas / Grupo Economico
  --  Sigla    : CRED
  --  Autor    : Mauro (MOUTS)
  --  Data     : Julho/2017.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Contas Grupo Economico
  --
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_tela_buscar_dados(pr_nrdconta IN tbcc_grupo_economico.nrdconta%TYPE --> Numero da Conta
                                ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_tela_buscar_dados_integrant(pr_idgrupo      IN tbcc_grupo_economico.idgrupo%TYPE  --> Id do Grupo
                                          ,pr_listar_todos IN PLS_INTEGER                        --> Filtro de Consulta -> Listar todos os integrantes
                                          ,pr_nrdconta     IN tbcc_grupo_economico.nrdconta%TYPE --> Filtro de Consulta -> Numero da Conta
                                          ,pr_xmllog       IN VARCHAR2                           --> XML com informações de LOG
                                          ,pr_cdcritic     OUT PLS_INTEGER                       --> Código da crítica
                                          ,pr_dscritic     OUT VARCHAR2                          --> Descrição da crítica
                                          ,pr_retxml       IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                          ,pr_nmdcampo     OUT VARCHAR2                          --> Nome do campo com erro
                                          ,pr_des_erro     OUT VARCHAR2);

  PROCEDURE pc_tela_atualiza_grp_economico(pr_nrdconta     IN tbcc_grupo_economico.nrdconta%TYPE     --> Numero da Conta
                                          ,pr_nmgrupo      IN tbcc_grupo_economico.nmgrupo%TYPE      --> Nome do Grupo
                                          ,pr_dsobservacao IN tbcc_grupo_economico.dsobservacao%TYPE --> Observacao do Grupo Economico
                                          ,pr_xmllog       IN VARCHAR2                               --> XML com informações de LOG
                                          ,pr_cdcritic     OUT PLS_INTEGER                           --> Código da crítica
                                          ,pr_dscritic     OUT VARCHAR2                              --> Descrição da crítica
                                          ,pr_retxml       IN OUT NOCOPY XMLType                     --> Arquivo de retorno do XML
                                          ,pr_nmdcampo     OUT VARCHAR2                              --> Nome do campo com erro
                                          ,pr_des_erro     OUT VARCHAR2);
                                          
  PROCEDURE pc_tela_verifica_inc_integrant(pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE
                                          ,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);                                         
                                          
  PROCEDURE pc_tela_incluir_integrante(pr_idgrupo        IN tbcc_grupo_economico.idgrupo%TYPE              --> Numero da Conta
                                      ,pr_tppessoa       IN tbcc_grupo_economico_integ.tppessoa%TYPE       --> Tipo de Pessoa
                                      ,pr_nrcpfcgc       IN tbcc_grupo_economico_integ.nrcpfcgc%TYPE       --> CPF/CNPJ
                                      ,pr_nrdconta       IN tbcc_grupo_economico_integ.nrdconta%TYPE       --> Numero da conta corrente
                                      ,pr_nmintegrante   IN tbcc_grupo_economico_integ.nmintegrante%TYPE   --> Nome do Integrante
                                      ,pr_tpvinculo      IN tbcc_grupo_economico_integ.tpvinculo%TYPE      --> Tipo do Vinculo
                                      ,pr_peparticipacao IN tbcc_grupo_economico_integ.peparticipacao%TYPE --> Percentual de Participacao
                                      ,pr_xmllog         IN VARCHAR2                               --> XML com informações de LOG
                                      ,pr_cdcritic       OUT PLS_INTEGER                           --> Código da crítica
                                      ,pr_dscritic       OUT VARCHAR2                              --> Descrição da crítica
                                      ,pr_retxml         IN OUT NOCOPY XMLType                     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo       OUT VARCHAR2                              --> Nome do campo com erro
                                      ,pr_des_erro       OUT VARCHAR2);
                                      
  PROCEDURE pc_tela_excluir_integrante(pr_idgrupo      IN tbcc_grupo_economico_integ.idgrupo%TYPE       --> ID do Grupo
                                      ,pr_idintegrante IN tbcc_grupo_economico_integ.idintegrante%TYPE  --> ID do Integrante
                                      ,pr_xmllog       IN VARCHAR2                               --> XML com informações de LOG
                                      ,pr_cdcritic     OUT PLS_INTEGER                           --> Código da crítica
                                      ,pr_dscritic     OUT VARCHAR2                              --> Descrição da crítica
                                      ,pr_retxml       IN OUT NOCOPY XMLType                     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo     OUT VARCHAR2                              --> Nome do campo com erro
                                      ,pr_des_erro     OUT VARCHAR2);

  PROCEDURE pc_tela_busca_associado(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta Corrente
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> Numero do CPF/CNPJ
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);
                                                                                                               
  PROCEDURE pc_verifica_conta_grp_econ(pr_cdcooper     IN  tbcc_grupo_economico_integ.cdcooper%TYPE --> Codigo da Cooperativa
                                      ,pr_nrdconta     IN  tbcc_grupo_economico_integ.nrdconta%TYPE --> Numero da conta corrente
                                      ,pr_flgativo     OUT PLS_INTEGER                              --> Flag se pertence algum grupo economico
                                      ,pr_nrdconta_grp OUT tbcc_grupo_economico.nrdconta%TYPE       --> Numero da Conta do Grupo que pertence
                                      ,pr_dsvinculo    OUT VARCHAR2                                 --> Tipo do Vinculo na Conta Corrente
                                      ,pr_cdcritic     OUT PLS_INTEGER                              --> Código da crítica
                                      ,pr_dscritic     OUT VARCHAR2);
                                      
  PROCEDURE pc_imprime_grupo_economico (pr_idgrupo      IN tbcc_grupo_economico.idgrupo%TYPE  --> Id do Grupo Economico
                                       ,pr_listar_todos IN PLS_INTEGER                        --> Filtro de Consulta -> Listar todos os integrantes
                                       ,pr_nrdconta     IN tbcc_grupo_economico.nrdconta%TYPE --> Filtro de Consulta -> Numero da Conta
                                       ,pr_dsiduser     IN VARCHAR2                           --> id do usuario                                       
                                       ,pr_xmllog       IN VARCHAR2                           --> XML com informacoes de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER                         --> Codigo da critica
                                       ,pr_dscritic   OUT VARCHAR2                            --> Descricao da critica
                                       ,pr_retxml IN  OUT NOCOPY xmltype                      --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2                            --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2);                                                                     

  PROCEDURE pc_job_grupo_economico_novo;                                       
END TELA_CONTAS_GRUPO_ECONOMICO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONTAS_GRUPO_ECONOMICO IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CONTAS_GRUPO_ECONOMICO
  --  Sistema  : Procedimentos para tela Contas / Grupo Economico
  --  Sigla    : CRED
  --  Autor    : Mauro (MOUTS)
  --  Data     : Julho/2017.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações da Contas Grupo Economico
  --
  ---------------------------------------------------------------------------------------------------------------
  FUNCTION fn_busca_tipo_vinculo(pr_tpvinculo IN tbcc_grupo_economico_integ.tpvinculo%TYPE) RETURN varchar2 IS
  BEGIN
    IF pr_tpvinculo = 1 THEN
      RETURN 'Conta PJ';
    ELSIF pr_tpvinculo = 2 THEN
      RETURN 'Sócio(a)';
    ELSIF pr_tpvinculo = 3 THEN
      RETURN 'Cônjuge';
    ELSIF pr_tpvinculo = 4 THEN
      RETURN 'Companheiro';
    ELSIF pr_tpvinculo = 5 THEN
      RETURN 'Parente primeiro grau';
    ELSIF pr_tpvinculo = 6 THEN
      RETURN 'Parente segundo grau';
    ELSIF pr_tpvinculo = 7 THEN
      RETURN 'Outro';
    END IF;
  END;  
  
  PROCEDURE pc_tela_buscar_dados(pr_nrdconta IN tbcc_grupo_economico.nrdconta%TYPE --> Numero da Conta
                                ,pr_xmllog   IN VARCHAR2                           --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                       --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN                                   
    /* .............................................................................
     Programa: pc_tela_buscar_dados
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os dados do grupo economico

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Grupo Economico
      CURSOR cr_tbcc_grupo_economico(pr_cdcooper IN tbepr_estorno.cdcooper%TYPE,
                                     pr_nrdconta IN tbepr_estorno.nrdconta%TYPE) IS
        SELECT idgrupo,
               nmgrupo,
               dsobservacao,
               dtinclusao
          FROM tbcc_grupo_economico
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_tbcc_grupo_economico cr_tbcc_grupo_economico%ROWTYPE;
           
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
          
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      -- Busca os dados do Grupo Economico
      OPEN cr_tbcc_grupo_economico (pr_cdcooper  => vr_cdcooper
                                   ,pr_nrdconta  => pr_nrdconta);
      FETCH cr_tbcc_grupo_economico INTO rw_tbcc_grupo_economico;
      -- Verifica se a retornou registro
      IF cr_tbcc_grupo_economico%NOTFOUND THEN
        CLOSE cr_tbcc_grupo_economico;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_tbcc_grupo_economico;
        -- Carrega os dados no XML
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'idgrupo', pr_tag_cont => rw_tbcc_grupo_economico.idgrupo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmgrupo', pr_tag_cont => rw_tbcc_grupo_economico.nmgrupo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dtinclusao', pr_tag_cont => TO_CHAR(rw_tbcc_grupo_economico.dtinclusao,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsobservacao', pr_tag_cont => rw_tbcc_grupo_economico.dsobservacao, pr_des_erro => vr_dscritic);
      END IF;      
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_tela_buscar_dados: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_tela_buscar_dados;
  
  PROCEDURE pc_tela_buscar_dados_integrant(pr_idgrupo      IN  tbcc_grupo_economico.idgrupo%TYPE  --> Id do Grupo
                                          ,pr_listar_todos IN  PLS_INTEGER                        --> Filtro de Consulta -> Listar todos os integrantes
                                          ,pr_nrdconta     IN  tbcc_grupo_economico.nrdconta%TYPE --> Filtro de Consulta -> Numero da Conta
                                          ,pr_xmllog       IN  VARCHAR2                           --> XML com informações de LOG
                                          ,pr_cdcritic     OUT PLS_INTEGER                       --> Código da crítica
                                          ,pr_dscritic     OUT VARCHAR2                          --> Descrição da crítica
                                          ,pr_retxml       IN  OUT NOCOPY XMLType                 --> Arquivo de retorno do XML
                                          ,pr_nmdcampo     OUT VARCHAR2                          --> Nome do campo com erro
                                          ,pr_des_erro     OUT VARCHAR2) IS                      --> Erros do processo
  BEGIN                                   
    /* .............................................................................
     Programa: pc_tela_buscar_dados_integrant
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os dados dos integrantes do grupo economico

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Grupo Economico
      CURSOR cr_tbcc_grupo_economico_integ(pr_idgrupo      tbcc_grupo_economico_integ.idgrupo%TYPE
                                          ,pr_listar_todos PLS_INTEGER
                                          ,pr_nrdconta     tbcc_grupo_economico_integ.nrdconta%TYPE) IS
            SELECT tbcc_grupo_economico_integ.idintegrante,
                   tbcc_grupo_economico_integ.nrcpfcgc,
                   tbcc_grupo_economico_integ.nrdconta,
                   tbcc_grupo_economico_integ.tppessoa,
                   CASE WHEN tbcc_grupo_economico_integ.tppessoa = 1 THEN 'PF' else 'PJ' end as tppessoa_desc,
                   tbcc_grupo_economico_integ.tpvinculo,
                   tbcc_grupo_economico_integ.peparticipacao,
                   decode(tbcc_grupo_economico_integ.tpcarga,1,'Carga Inicial'
                                                            ,2,'Carga Manutenção'
                                                            ,tbcc_grupo_economico_integ.cdoperad_inclusao) cdoperad_inclusao,
                   decode(tbcc_grupo_economico_integ.tpcarga,1,'Carga Inicial'
                                                            ,2,'Carga Manutenção'
                                                            ,ope_inc.nmoperad) as nmoperad_inclusao,
                   tbcc_grupo_economico_integ.dtinclusao,
                   decode(tbcc_grupo_economico_integ.cdoperad_exclusao,'1','Carga Manutenção'
                                                                      ,tbcc_grupo_economico_integ.cdoperad_exclusao) as cdoperad_exclusao,
                   decode(tbcc_grupo_economico_integ.cdoperad_exclusao,'1','Carga Manutenção'
                                                                      ,ope_exc.nmoperad) as nmoperad_exclusao,
                   tbcc_grupo_economico_integ.dtexclusao,
                   tbcc_grupo_economico_integ.nmintegrante
              FROM tbcc_grupo_economico_integ
         LEFT JOIN crapope ope_inc
                ON ope_inc.cdcooper = tbcc_grupo_economico_integ.cdcooper
               AND ope_inc.cdoperad = tbcc_grupo_economico_integ.cdoperad_inclusao
         LEFT JOIN crapope ope_exc
                ON ope_exc.cdcooper = tbcc_grupo_economico_integ.cdcooper
               AND ope_exc.cdoperad = tbcc_grupo_economico_integ.cdoperad_exclusao
             WHERE tbcc_grupo_economico_integ.idgrupo = pr_idgrupo
               AND (tbcc_grupo_economico_integ.dtexclusao IS NULL OR pr_listar_todos = 1)
               AND (tbcc_grupo_economico_integ.nrdconta = pr_nrdconta OR pr_nrdconta = 0);
           
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_contador        PLS_INTEGER := 0;
          
    BEGIN      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');                        
                 
      -- Busca todos os emprestimos de acordo com o numero da conta
      FOR rw_tbcc_grupo_economico_integ IN cr_tbcc_grupo_economico_integ(pr_idgrupo      => pr_idgrupo
                                                                        ,pr_listar_todos => pr_listar_todos
                                                                        ,pr_nrdconta     => NVL(pr_nrdconta,0)) LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idintegrante', pr_tag_cont => rw_tbcc_grupo_economico_integ.idintegrante, pr_des_erro => vr_dscritic);

        -- Informacao do CPF/CNPJ
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'inf'
                              ,pr_posicao => vr_contador
                              ,pr_tag_nova => 'nrcpfcgc'
                              ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbcc_grupo_economico_integ.nrcpfcgc, 
                                                                        pr_inpessoa => rw_tbcc_grupo_economico_integ.tppessoa)
                              ,pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => gene0002.fn_mask_conta(pr_nrdconta => rw_tbcc_grupo_economico_integ.nrdconta), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'tppessoa_desc', pr_tag_cont => rw_tbcc_grupo_economico_integ.tppessoa_desc, pr_des_erro => vr_dscritic);
        
        -- Tipo de Vinculo do Integrante
        gene0007.pc_insere_tag(pr_xml => pr_retxml, 
                               pr_tag_pai => 'inf', 
                               pr_posicao => vr_contador, 
                               pr_tag_nova => 'tpvinculo_desc', 
                               pr_tag_cont => fn_busca_tipo_vinculo(pr_tpvinculo => rw_tbcc_grupo_economico_integ.tpvinculo),
                               pr_des_erro => vr_dscritic);
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'peparticipacao', pr_tag_cont => TO_CHAR(rw_tbcc_grupo_economico_integ.peparticipacao,'fm999g999g990d00'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad_inclusao', pr_tag_cont => rw_tbcc_grupo_economico_integ.cdoperad_inclusao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad_inclusao', pr_tag_cont => rw_tbcc_grupo_economico_integ.nmoperad_inclusao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtinclusao', pr_tag_cont => TO_CHAR(rw_tbcc_grupo_economico_integ.dtinclusao,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad_exclusao', pr_tag_cont => rw_tbcc_grupo_economico_integ.cdoperad_exclusao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad_exclusao', pr_tag_cont => rw_tbcc_grupo_economico_integ.nmoperad_exclusao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtexclusao', pr_tag_cont => TO_CHAR(rw_tbcc_grupo_economico_integ.dtexclusao,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmintegrante', pr_tag_cont => rw_tbcc_grupo_economico_integ.nmintegrante, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP; /* END FOR rw_tbcc_grupo_economico_integ */
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_tela_buscar_dados_integrant: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_tela_buscar_dados_integrant;  

  PROCEDURE pc_tela_atualiza_grp_economico(pr_nrdconta     IN tbcc_grupo_economico.nrdconta%TYPE     --> Numero da Conta
                                          ,pr_nmgrupo      IN tbcc_grupo_economico.nmgrupo%TYPE      --> Nome do Grupo
                                          ,pr_dsobservacao IN tbcc_grupo_economico.dsobservacao%TYPE --> Observacao do Grupo Economico
                                          ,pr_xmllog       IN VARCHAR2                               --> XML com informações de LOG
                                          ,pr_cdcritic     OUT PLS_INTEGER                           --> Código da crítica
                                          ,pr_dscritic     OUT VARCHAR2                              --> Descrição da crítica
                                          ,pr_retxml       IN OUT NOCOPY XMLType                     --> Arquivo de retorno do XML
                                          ,pr_nmdcampo     OUT VARCHAR2                              --> Nome do campo com erro
                                          ,pr_des_erro     OUT VARCHAR2) IS                          --> Erros do processo
  BEGIN                                   
    /* .............................................................................
     Programa: pc_tela_atualiza_grp_economico
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para incluir/alterar o grupo economico

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Grupo Economico
      CURSOR cr_tbcc_grupo_economico(pr_cdcooper IN tbepr_estorno.cdcooper%TYPE,
                                     pr_nrdconta IN tbepr_estorno.nrdconta%TYPE) IS
        SELECT idgrupo,
               nmgrupo,
               dsobservacao
          FROM tbcc_grupo_economico
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_tbcc_grupo_economico cr_tbcc_grupo_economico%ROWTYPE;
          
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_nrdrowid        ROWID;
          
    BEGIN      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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
      
      -- Condicao para verificar se foi informado o nome do grupo
      IF TRIM(pr_nmgrupo) IS NULL THEN
        vr_dscritic := 'O campo Nome do Grupo não foi informado';
        RAISE vr_exc_saida;
      END IF;

      -- Busca os dados do Grupo Economico
      OPEN cr_tbcc_grupo_economico (pr_cdcooper  => vr_cdcooper
                                   ,pr_nrdconta  => pr_nrdconta);
      FETCH cr_tbcc_grupo_economico INTO rw_tbcc_grupo_economico;
      -- Verifica se a retornou registro
      IF cr_tbcc_grupo_economico%NOTFOUND THEN
        CLOSE cr_tbcc_grupo_economico;
        
        BEGIN
          INSERT INTO tbcc_grupo_economico
                      (cdcooper
                      ,nrdconta
                      ,nmgrupo
                      ,dtinclusao
                      ,dsobservacao)
               VALUES (vr_cdcooper
                      ,pr_nrdconta
                      ,pr_nmgrupo
                      ,TRUNC(SYSDATE)
                      ,pr_dsobservacao);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível inserir o grupo econômico. '||SQLERRM;
            RAISE vr_exc_saida;
        END; 
        
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_tbcc_grupo_economico;

        BEGIN
          UPDATE tbcc_grupo_economico
             SET nmgrupo      = pr_nmgrupo
                ,dsobservacao = pr_dsobservacao
           WHERE idgrupo      = rw_tbcc_grupo_economico.idgrupo;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível atualizar o grupo econômico. '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
      
      -- Gravar o LOG da atualizacao
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Inclusao/Alteracao do Grupo Economico'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'GRP ECONOMIC'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Nome do Grupo'
                               ,pr_dsdadant => nvl(rw_tbcc_grupo_economico.nmgrupo,' ')
                               ,pr_dsdadatu => pr_nmgrupo);
                                  
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Observacao'
                               ,pr_dsdadant => nvl(rw_tbcc_grupo_economico.dsobservacao,' ')
                               ,pr_dsdadatu => nvl(pr_dsobservacao,' '));
      
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_tela_atualiza_grp_economico: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_tela_atualiza_grp_economico;  
  
  PROCEDURE pc_tela_verifica_inc_integrant(pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE
                                          ,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS                           --> Erros do processo
  BEGIN                                   
    /* .............................................................................
     Programa: pc_tela_verifica_inc_integrant
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para validar se pode cadastrar os integrantes do grupo economico

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Grupo Economico
      CURSOR cr_tbcc_grupo_economico(pr_idgrupo IN tbcc_grupo_economico.idgrupo%TYPE) IS
        SELECT cdcooper,
               nrdconta               
          FROM tbcc_grupo_economico
         WHERE tbcc_grupo_economico.idgrupo = pr_idgrupo;
      rw_tbcc_grupo_economico cr_tbcc_grupo_economico%ROWTYPE;
      
      -- Cursor do Cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta;
      
      -- Variável de críticas
      vr_cdcritic        crapcri.cdcritic%TYPE;
      vr_dscritic        VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida       EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_inpessoa        crapass.inpessoa%TYPE;
          
    BEGIN      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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
      
      -- Busca os dados do Grupo Economico
      OPEN cr_tbcc_grupo_economico(pr_idgrupo => pr_idgrupo);
      FETCH cr_tbcc_grupo_economico INTO rw_tbcc_grupo_economico;
      -- Verifica se a retornou registro
      IF cr_tbcc_grupo_economico%NOTFOUND THEN
        CLOSE cr_tbcc_grupo_economico;
        vr_dscritic := 'Operação não permitida, favor incluir primeiro o grupo econômico!';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_tbcc_grupo_economico;
      END IF;
      
      -- Busca os dado do associado
      OPEN cr_crapass(pr_cdcooper => rw_tbcc_grupo_economico.cdcooper
                     ,pr_nrdconta => rw_tbcc_grupo_economico.nrdconta);
      FETCH cr_crapass INTO vr_inpessoa;
      CLOSE cr_crapass;     
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => vr_inpessoa, pr_des_erro => vr_dscritic);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_tela_verifica_inc_integrant: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_tela_verifica_inc_integrant;    

  PROCEDURE pc_tela_incluir_integrante(pr_idgrupo        IN tbcc_grupo_economico.idgrupo%TYPE              --> Numero da Conta
                                      ,pr_tppessoa       IN tbcc_grupo_economico_integ.tppessoa%TYPE       --> Tipo de Pessoa
                                      ,pr_nrcpfcgc       IN tbcc_grupo_economico_integ.nrcpfcgc%TYPE       --> CPF/CNPJ
                                      ,pr_nrdconta       IN tbcc_grupo_economico_integ.nrdconta%TYPE       --> Numero da conta corrente
                                      ,pr_nmintegrante   IN tbcc_grupo_economico_integ.nmintegrante%TYPE   --> Nome do Integrante
                                      ,pr_tpvinculo      IN tbcc_grupo_economico_integ.tpvinculo%TYPE      --> Tipo do Vinculo
                                      ,pr_peparticipacao IN tbcc_grupo_economico_integ.peparticipacao%TYPE --> Percentual de Participacao
                                      ,pr_xmllog         IN VARCHAR2                               --> XML com informações de LOG
                                      ,pr_cdcritic       OUT PLS_INTEGER                           --> Código da crítica
                                      ,pr_dscritic       OUT VARCHAR2                              --> Descrição da crítica
                                      ,pr_retxml         IN OUT NOCOPY XMLType                     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo       OUT VARCHAR2                              --> Nome do campo com erro
                                      ,pr_des_erro       OUT VARCHAR2) IS                          --> Erros do processo
  BEGIN                                   
    /* .............................................................................
     Programa: pc_tela_incluir_integrante
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para incluir integrante do grupo economico

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Integrante do Grupo Economico
      CURSOR cr_tbcc_grupo_economico_integ(pr_idgrupo  IN tbcc_grupo_economico_integ.idgrupo%TYPE,
                                           pr_nrdconta IN tbcc_grupo_economico_integ.nrdconta%TYPE,
                                           pr_nrcpfcgc IN tbcc_grupo_economico_integ.nrcpfcgc%TYPE) IS
        SELECT 1
          FROM tbcc_grupo_economico_integ
         WHERE tbcc_grupo_economico_integ.idgrupo  = pr_idgrupo
           AND tbcc_grupo_economico_integ.nrdconta = pr_nrdconta
           AND tbcc_grupo_economico_integ.nrcpfcgc = pr_nrcpfcgc
           AND tbcc_grupo_economico_integ.dtexclusao IS NULL;
          
      -- Cursor do Grupo Economico
      CURSOR cr_tbcc_grupo_economico(pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE) IS
        SELECT nrdconta
          FROM tbcc_grupo_economico
         WHERE tbcc_grupo_economico.idgrupo = pr_idgrupo;
      rw_tbcc_grupo_economico cr_tbcc_grupo_economico%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic        crapcri.cdcritic%TYPE;
      vr_dscritic        VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida       EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_nrdrowid        ROWID;
      vr_stsnrcal        boolean;
      vr_exist_cadastro  PLS_INTEGER := 0;
      vr_inpessoa        PLS_INTEGER;
          
    BEGIN      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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
      
      -- Busca os dados do Grupo Economico
      OPEN cr_tbcc_grupo_economico(pr_idgrupo => pr_idgrupo);
      FETCH cr_tbcc_grupo_economico INTO rw_tbcc_grupo_economico;
      -- Verifica se a retornou registro
      IF cr_tbcc_grupo_economico%NOTFOUND THEN
        CLOSE cr_tbcc_grupo_economico;
        vr_dscritic := 'Grupo Econômico não encontrado. Código: ' || TO_CHAR(pr_idgrupo);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_tbcc_grupo_economico;
      END IF;
      
      IF TRIM(pr_nrcpfcgc) IS NULL THEN
        vr_dscritic := 'O campo CPF/CNPJ não foi informado';
        RAISE vr_exc_saida;
      END IF;
      
      IF TRIM(pr_nmintegrante) IS NULL THEN
        vr_dscritic := 'O campo Nome não foi informado';
        RAISE vr_exc_saida;
      END IF;
      
      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcgc, 
                                  pr_stsnrcal => vr_stsnrcal, 
                                  pr_inpessoa => vr_inpessoa);
      -- Verifica se o CPF/CNPJ esta correto
      IF NOT vr_stsnrcal THEN
        vr_dscritic := 'O campo CPF/CNPJ informado está incorreto.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Cursor do Integrante do Grupo Economico
      OPEN cr_tbcc_grupo_economico_integ(pr_idgrupo  => pr_idgrupo
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrcpfcgc => pr_nrcpfcgc);
      FETCH cr_tbcc_grupo_economico_integ INTO vr_exist_cadastro;
      CLOSE cr_tbcc_grupo_economico_integ;
      -- Condicao para verificar se o integrante jah possui cadastro
      IF NVL(vr_exist_cadastro,0) > 0 THEN
        vr_dscritic := 'Integrante já cadastrado neste grupo econômico.';
        RAISE vr_exc_saida;
      END IF;        
      
      BEGIN
        INSERT INTO tbcc_grupo_economico_integ
                      (idgrupo
                      ,nrcpfcgc
                      ,cdcooper
                      ,nrdconta
                      ,tppessoa
                      ,tpcarga
                      ,tpvinculo
                      ,peparticipacao
                      ,dtinclusao
                      ,cdoperad_inclusao
                      ,nmintegrante)
               VALUES (pr_idgrupo
                      ,pr_nrcpfcgc
                      ,vr_cdcooper
                      ,pr_nrdconta
                      ,pr_tppessoa
                      ,3 -- Cadastro Manual
                      ,pr_tpvinculo
                      ,pr_peparticipacao
                      ,TRUNC(SYSDATE)
                      ,vr_cdoperad
                      ,pr_nmintegrante);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possível inserir integrante do grupo econômico. '||SQLERRM;
          RAISE vr_exc_saida;
      END; 
      
      -- Gravar o LOG da atualizacao
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Inclusao Integrante do Grupo Economico'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'GRP ECONOMIC'
                          ,pr_nrdconta => rw_tbcc_grupo_economico.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Grupo'
                               ,pr_dsdadant => ' '
                               ,pr_dsdadatu => pr_idgrupo);
                                  
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta'
                               ,pr_dsdadant => ' '
                               ,pr_dsdadatu => pr_nrdconta);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'CPF/CNPJ'
                               ,pr_dsdadant => ' '
                               ,pr_dsdadatu => pr_nrcpfcgc);
                               
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_tela_incluir_integrante: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_tela_incluir_integrante;  

  PROCEDURE pc_tela_excluir_integrante(pr_idgrupo      IN tbcc_grupo_economico_integ.idgrupo%TYPE       --> ID do Grupo
                                      ,pr_idintegrante IN tbcc_grupo_economico_integ.idintegrante%TYPE  --> ID do Integrante
                                      ,pr_xmllog       IN VARCHAR2                               --> XML com informações de LOG
                                      ,pr_cdcritic     OUT PLS_INTEGER                           --> Código da crítica
                                      ,pr_dscritic     OUT VARCHAR2                              --> Descrição da crítica
                                      ,pr_retxml       IN OUT NOCOPY XMLType                     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo     OUT VARCHAR2                              --> Nome do campo com erro
                                      ,pr_des_erro     OUT VARCHAR2) IS                          --> Erros do processo
  BEGIN                                   
    /* .............................................................................
     Programa: pc_tela_excluir_integrante
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para excluir integrante do grupo economico

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Grupo Economico
      CURSOR cr_tbcc_grupo_economico(pr_idgrupo  IN tbcc_grupo_economico.idgrupo%TYPE) IS
        SELECT nrdconta
          FROM tbcc_grupo_economico
         WHERE tbcc_grupo_economico.idgrupo = pr_idgrupo;
      rw_tbcc_grupo_economico cr_tbcc_grupo_economico%ROWTYPE;
      
      -- Cursor do Integrante do Grupo Economico
      CURSOR cr_tbcc_grupo_economico_integ(pr_idintegrante IN tbcc_grupo_economico_integ.idintegrante%TYPE) IS
        SELECT dtexclusao
          FROM tbcc_grupo_economico_integ
         WHERE tbcc_grupo_economico_integ.idintegrante = pr_idintegrante;
      rw_tbcc_grupo_economico_integ cr_tbcc_grupo_economico_integ%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic        crapcri.cdcritic%TYPE;
      vr_dscritic        VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida       EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_nrdrowid        ROWID;
          
    BEGIN      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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
      
      -- Busca os dados do Grupo Economico
      OPEN cr_tbcc_grupo_economico(pr_idgrupo => pr_idgrupo);
      FETCH cr_tbcc_grupo_economico INTO rw_tbcc_grupo_economico;
      -- Verifica se a retornou registro
      IF cr_tbcc_grupo_economico%NOTFOUND THEN
        CLOSE cr_tbcc_grupo_economico;
        vr_dscritic := 'Grupo Econômico não encontrado. Código: ' || TO_CHAR(pr_idgrupo);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_tbcc_grupo_economico;
      END IF;
      
      -- Busca os dados do Integrante Grupo Economico
      OPEN cr_tbcc_grupo_economico_integ(pr_idintegrante => pr_idintegrante);
      FETCH cr_tbcc_grupo_economico_integ INTO rw_tbcc_grupo_economico_integ;
      -- Verifica se a retornou registro
      IF cr_tbcc_grupo_economico_integ%NOTFOUND THEN
        CLOSE cr_tbcc_grupo_economico_integ;
        vr_dscritic := 'Integrante não encontrado. Código: ' || TO_CHAR(pr_idintegrante);
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_tbcc_grupo_economico_integ;
      END IF;

      -- Condicao para verificar se o registro estah ativo
      IF rw_tbcc_grupo_economico_integ.dtexclusao IS NOT NULL THEN
        vr_dscritic := 'Integrante já está excluído, operação não permitida.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Exclusao do Integrante do Grupo Economico
      BEGIN
        UPDATE tbcc_grupo_economico_integ
           SET cdoperad_exclusao = vr_cdoperad
              ,dtexclusao        = TRUNC(SYSDATE)
         WHERE idintegrante = pr_idintegrante;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := gene0007.fn_caract_acento('Não foi possível excluir integrante do grupo econômico. '||SQLERRM);
          RAISE vr_exc_saida;
      END;
        
      -- Gravar o LOG da atualizacao
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Exclusao Integrante do Grupo Economico'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'GRP ECONOMIC'
                          ,pr_nrdconta => rw_tbcc_grupo_economico.nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
        
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Grupo'
                               ,pr_dsdadant => ' '
                               ,pr_dsdadatu => pr_idgrupo);
                                  
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Integrante'
                               ,pr_dsdadant => ' '
                               ,pr_dsdadatu => pr_idintegrante);
      
      COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_tela_excluir_integrante: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_tela_excluir_integrante;
  
  PROCEDURE pc_tela_busca_associado(pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta Corrente
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE --> Numero do CPF/CNPJ
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN                                   
    /* .............................................................................
     Programa: pc_tela_busca_associado
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para excluir integrante do grupo economico

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
        SELECT nrdconta
              ,nrcpfcgc
              ,nmprimtl
              ,inpessoa
              ,COUNT(1) OVER (PARTITION BY crapass.nrcpfcgc) total
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           and (nrcpfcgc = pr_nrcpfcgc OR pr_nrcpfcgc = 0)
           and (nrdconta = pr_nrdconta OR pr_nrdconta = 0);
      rw_crapass  cr_crapass%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic        crapcri.cdcritic%TYPE;
      vr_dscritic        VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida       EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
                
    BEGIN      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
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

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      -- Caso nao foi informado nenhum filtro, nao sera buscado as informacoes
      IF pr_nrdconta = 0 AND pr_nrcpfcgc = 0 THEN
        RETURN;
      END IF;
      
      -- Busca os dados do Grupo Economico
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrcpfcgc => pr_nrcpfcgc);
      FETCH cr_crapass INTO rw_crapass;
      -- Verifica se a retornou registro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        RETURN;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapass.nrdconta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, 
                             pr_tag_pai => 'inf', 
                             pr_posicao => 0, 
                             pr_tag_nova => 'nrcpfcgc', 
                             pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc, 
                                                                      pr_inpessoa => rw_crapass.inpessoa), 
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmprimtl', pr_tag_cont => rw_crapass.nmprimtl, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'total', pr_tag_cont => rw_crapass.total, pr_des_erro => vr_dscritic);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_tela_busca_associado: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_tela_busca_associado;
    
  PROCEDURE pc_verifica_conta_grp_econ(pr_cdcooper     IN  tbcc_grupo_economico_integ.cdcooper%TYPE --> Codigo da Cooperativa
                                      ,pr_nrdconta     IN  tbcc_grupo_economico_integ.nrdconta%TYPE --> Numero da conta corrente
                                      ,pr_flgativo     OUT PLS_INTEGER                              --> Flag se pertence algum grupo economico
                                      ,pr_nrdconta_grp OUT tbcc_grupo_economico.nrdconta%TYPE       --> Numero da Conta do Grupo que pertence
                                      ,pr_dsvinculo    OUT VARCHAR2                                 --> Tipo do Vinculo na Conta Corrente
                                      ,pr_cdcritic     OUT PLS_INTEGER                              --> Código da crítica
                                      ,pr_dscritic     OUT VARCHAR2) IS
  BEGIN                                   
    /* .............................................................................
     Programa: pc_verifica_conta_grp_econ
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Verificar se possui um acordo ativo para a conta corrente

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor do Integrante do Grupo Economico
      CURSOR cr_tbcc_grupo_economico_integ(pr_cdcooper IN tbcc_grupo_economico_integ.cdcooper%TYPE,
                                           pr_nrdconta IN tbcc_grupo_economico_integ.nrdconta%TYPE) IS
        SELECT tbcc_grupo_economico_integ.tpvinculo
              ,tbcc_grupo_economico.nrdconta
          FROM tbcc_grupo_economico_integ
          join tbcc_grupo_economico
            on tbcc_grupo_economico.idgrupo = tbcc_grupo_economico_integ.idgrupo
         WHERE tbcc_grupo_economico_integ.cdcooper = pr_cdcooper
           AND tbcc_grupo_economico_integ.nrdconta = pr_nrdconta
           AND tbcc_grupo_economico_integ.dtexclusao IS NULL;
      rw_tbcc_grupo_economico_integ cr_tbcc_grupo_economico_integ%ROWTYPE;
          
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;      
    BEGIN      
      pr_flgativo := 0;
      -- Cursor do Integrante do Grupo Economico
      OPEN cr_tbcc_grupo_economico_integ(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta);
      FETCH cr_tbcc_grupo_economico_integ INTO rw_tbcc_grupo_economico_integ;
      -- Verifica se a retornou registro
      IF cr_tbcc_grupo_economico_integ%FOUND THEN
        CLOSE cr_tbcc_grupo_economico_integ;
        pr_flgativo     := 1;
        pr_nrdconta_grp := rw_tbcc_grupo_economico_integ.nrdconta;
        pr_dsvinculo    := fn_busca_tipo_vinculo(pr_tpvinculo => rw_tbcc_grupo_economico_integ.tpvinculo);
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_tbcc_grupo_economico_integ;
      END IF;     
      
    EXCEPTION      
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_verifica_conta_grp_econ: ' || SQLERRM;
    END;    
  END pc_verifica_conta_grp_econ;
  
  --> Rotina para impressao do Grupo Economico
  PROCEDURE pc_imprime_grupo_economico (pr_idgrupo      IN tbcc_grupo_economico.idgrupo%TYPE  --> Id do Grupo Economico
                                       ,pr_listar_todos IN PLS_INTEGER                        --> Filtro de Consulta -> Listar todos os integrantes
                                       ,pr_nrdconta     IN tbcc_grupo_economico.nrdconta%TYPE --> Filtro de Consulta -> Numero da Conta
                                       ,pr_dsiduser     IN VARCHAR2                           --> id do usuario                                       
                                       ,pr_xmllog       IN VARCHAR2                           --> XML com informacoes de LOG
                                       ,pr_cdcritic   OUT PLS_INTEGER                         --> Codigo da critica
                                       ,pr_dscritic   OUT VARCHAR2                            --> Descricao da critica
                                       ,pr_retxml IN  OUT NOCOPY xmltype                      --> Arquivo de retorno do XML
                                       ,pr_nmdcampo   OUT VARCHAR2                            --> Nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2) IS                        --> Erros do processo

  /* ............................................................................
       Programa: pc_imprime_grupo_economico
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odirlei Busana - AMcom
       Data    : Outubro/2016                     Ultima atualizacao: --/--/----

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para impressao do Grupo Economico

       Alteracoes: ----

    ............................................................................ */
    -- Cursor do Grupo Economico
    CURSOR cr_tbcc_grupo_economico(pr_idgrupo IN tbcc_grupo_economico.idgrupo%TYPE) IS
      SELECT idgrupo,
             nmgrupo,
             dtinclusao
        FROM tbcc_grupo_economico
       WHERE idgrupo = pr_idgrupo;
    rw_tbcc_grupo_economico cr_tbcc_grupo_economico%ROWTYPE;
    
	  -- Cursor Integrante do Grupo Economico
    CURSOR cr_tbcc_grupo_economico_integ(pr_idgrupo      tbcc_grupo_economico_integ.idgrupo%TYPE
                                        ,pr_listar_todos PLS_INTEGER
                                        ,pr_nrdconta     tbcc_grupo_economico_integ.nrdconta%TYPE) IS
        SELECT tbcc_grupo_economico_integ.idintegrante,
               tbcc_grupo_economico_integ.nrcpfcgc,
               tbcc_grupo_economico_integ.nrdconta,
               tbcc_grupo_economico_integ.tppessoa,
               CASE WHEN tbcc_grupo_economico_integ.tppessoa = 1 THEN 'Fisica' else 'Juridica' end as tppessoa_desc,
               tbcc_grupo_economico_integ.tpvinculo,
               tbcc_grupo_economico_integ.peparticipacao,
               tbcc_grupo_economico_integ.cdoperad_inclusao,
               tbcc_grupo_economico_integ.dtinclusao,               
               tbcc_grupo_economico_integ.cdoperad_exclusao,
               tbcc_grupo_economico_integ.dtexclusao
          FROM tbcc_grupo_economico_integ
         WHERE tbcc_grupo_economico_integ.idgrupo = pr_idgrupo
           AND (tbcc_grupo_economico_integ.dtexclusao IS NULL OR pr_listar_todos = 1)
           AND (tbcc_grupo_economico_integ.nrdconta = pr_nrdconta OR pr_nrdconta = 0);      
    
    -------------->> VARIAVEIS <<----------------
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto VARCHAR2(100);
    vr_tab_erro GENE0001.typ_tab_erro; 

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper   INTEGER;
    vr_cdoperad   VARCHAR2(100);
    vr_nmdatela   VARCHAR2(100);
    vr_nmeacao    VARCHAR2(100);
    vr_cdagenci   VARCHAR2(100);
    vr_nrdcaixa   VARCHAR2(100);
    vr_idorigem   VARCHAR2(100);

    vr_dsdireto   VARCHAR2(4000);
    vr_dscomand   VARCHAR2(4000);
    vr_typsaida   VARCHAR2(100); 
    vr_nmarqpdf   VARCHAR2(100);
    vr_des_xml    CLOB;
    vr_txtcompl   VARCHAR2(32600);
    
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
   
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

    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;
    
    -- Busca os dados do Grupo Economico
    OPEN cr_tbcc_grupo_economico (pr_idgrupo => pr_idgrupo);
    FETCH cr_tbcc_grupo_economico INTO rw_tbcc_grupo_economico;
    -- Verifica se a retornou registro
    IF cr_tbcc_grupo_economico%NOTFOUND THEN
      CLOSE cr_tbcc_grupo_economico;
      vr_dscritic := 'Grupo Economico não encontrado. Código: ' || TO_CHAR(pr_idgrupo);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas Fecha o Cursor
      CLOSE cr_tbcc_grupo_economico;
    END IF;		
    
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
    pc_escreve_xml('<GrupoEconomico>'||
                     '<idgrupo>'|| rw_tbcc_grupo_economico.idgrupo ||'</idgrupo>'||
                     '<nmgrupo>'|| rw_tbcc_grupo_economico.nmgrupo ||'</nmgrupo>'||
                     '<dtinclusao>'|| TO_CHAR(rw_tbcc_grupo_economico.dtinclusao,'DD/MM/RRRR') ||'</dtinclusao>'||
                   '</GrupoEconomico>');
    
    -- Busca todos os emprestimos de acordo com o numero da conta
    FOR rw_tbcc_grupo_economico_integ IN cr_tbcc_grupo_economico_integ(pr_idgrupo      => pr_idgrupo
                                                                      ,pr_listar_todos => pr_listar_todos
                                                                      ,pr_nrdconta     => NVL(pr_nrdconta,0)) LOOP
      pc_escreve_xml('<Dados>'||
                       '<idintegrante>'|| rw_tbcc_grupo_economico_integ.idintegrante ||'</idintegrante>'||
                       '<tppessoa_desc>'|| rw_tbcc_grupo_economico_integ.tppessoa_desc  ||'</tppessoa_desc>'||
                       '<nrdconta>'|| TRIM(gene0002.fn_mask_conta(rw_tbcc_grupo_economico_integ.nrdconta)) ||'</nrdconta>'||
                       '<nrcpfcgc>'|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbcc_grupo_economico_integ.nrcpfcgc,
                                                                pr_inpessoa => rw_tbcc_grupo_economico_integ.tppessoa) ||'</nrcpfcgc>'||
                       '<tpvinculo_desc>'|| fn_busca_tipo_vinculo(pr_tpvinculo => rw_tbcc_grupo_economico_integ.tpvinculo) ||'</tpvinculo_desc>'||
                       '<peparticipacao>'|| to_char(nvl(rw_tbcc_grupo_economico_integ.peparticipacao,0),'999G999G990D00','NLS_NUMERIC_CHARACTERS='',.''') ||'</peparticipacao>'||
                       '<dtinclusao>'|| TO_CHAR(rw_tbcc_grupo_economico_integ.dtinclusao,'DD/MM/RRRR') ||'</dtinclusao>'||
                       '<dsoperad_inclusao>'||rw_tbcc_grupo_economico_integ.cdoperad_inclusao  ||'</dsoperad_inclusao>'||
                       '<dtexclusao>'|| TO_CHAR(rw_tbcc_grupo_economico_integ.dtexclusao,'DD/MM/RRRR') ||'</dtexclusao>'||
                       '<dsoperad_exclusao>'|| rw_tbcc_grupo_economico_integ.cdoperad_exclusao ||'</dsoperad_exclusao>'||                       
                     '</Dados>');                                                                      
    END LOOP;
    
    pc_escreve_xml('</raiz>',TRUE);   
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => vr_cdcooper,
                                         pr_nmsubdir => '/rl');
      
    vr_dscomand := 'rm '||vr_dsdireto ||'/crrl734_'||pr_dsiduser||'* 2>/dev/null';
      
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Não foi possível remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
      
    vr_nmarqpdf := 'crrl734_'||pr_dsiduser || gene0002.fn_busca_time || '.pdf';      
      
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => vr_cdcooper
                               ,pr_cdprogra  => 'CONTAS'
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_des_xml
                               ,pr_dsxmlnode => '/raiz/Dados'
                               ,pr_dsjasper  => 'crrl734.jasper'
                               ,pr_dsparams  => null
                               ,pr_dsarqsaid => vr_dsdireto ||'/'||vr_nmarqpdf
                               ,pr_flg_gerar => 'S'
                               ,pr_qtcoluna  => 132
                               ,pr_cdrelato  => 734
                               ,pr_sqcabrel  => 1
                               ,pr_flg_impri => 'N'
                               ,pr_nmformul  => ' '
                               ,pr_nrcopias  => 1
                               ,pr_nrvergrl  => 1
                               ,pr_des_erro  => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF; 
    
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    
    -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
    GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => NULL
                                ,pr_nrdcaixa => NULL
                                ,pr_nmarqpdf => vr_dsdireto ||'/'||vr_nmarqpdf
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro);
    -- Se retornou erro
    IF NVL(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros          
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||vr_nmarqpdf
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;           
    
    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmarqpdf'
                          ,pr_tag_cont => vr_nmarqpdf
                          ,pr_des_erro => vr_dscritic);                          
                                                
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_imprime_grupo_economico: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                   
  END pc_imprime_grupo_economico;      
  
  PROCEDURE pc_job_grupo_economico_novo IS
  BEGIN                                   
    /* .............................................................................
     Programa: pc_job_grupo_economico_novo
     Sistema : Rotinas referentes ao grupo economico
     Sigla   : CONTAS
     Autor   : Mauro (MOUTS)
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Executar o JOB do Grupo Economico Novo

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      ------------------------------- Variaveis  -------------------------------       
      vr_dscritic    VARCHAR(1000);
      vr_cdcritic    PLS_INTEGER;
      vr_cdcooper    PLS_INTEGER := 3;
      vr_cdprogra    VARCHAR2(40) := 'PC_CRPS722';
      vr_nomdojob    VARCHAR2(40) := 'JOB_GRUPO_ECONOMICO_NOVO';
      vr_flgerlog    BOOLEAN := FALSE;
      vr_dthoje      DATE := TRUNC(SYSDATE);
      vr_exc_erro    EXCEPTION;
    
      ------------------------------- PROCEDURES -------------------------------   
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2
                                     ,pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      BEGIN
        --> Controlar geração de log de execução dos jobs
        BTCH0001.pc_log_exec_job( pr_cdcooper  => vr_cdcooper   --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra   --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob   --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog   --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic   --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog); --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

      END pc_controla_log_batch;      
      
    BEGIN
      -- JOB somente rodara em dia util
      IF NOT gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                        ,pr_dtmvtolt => vr_dthoje) = vr_dthoje THEN 
        RETURN;
      END IF;  
      
      -- Log de inicio de execucao
      pc_controla_log_batch(pr_dstiplog => 'I');
      
      gene0004.pc_executa_job(pr_cdcooper => vr_cdcooper --> Codigo da cooperativa
                             ,pr_fldiautl => 1           --> Flag se deve validar dia util
                             ,pr_flproces => 1           --> Flag se deve validar se esta no processo
                             ,pr_flrepjob => 1           --> Flag para reprogramar o job
                             ,pr_flgerlog => 1           --> indicador se deve gerar log
                             ,pr_nmprogra => 'TELA_CONTAS_GRUPO_ECONOMICO.pc_job_grupo_economico_novo' --> Nome do programa que esta sendo executado no job
                             ,pr_dscritic => vr_dscritic);                           
      
      -- se nao retornou critica chama rotina
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- Procedure para criar o Grupo Economico Novo
      pc_crps722(pr_cdcritic => vr_cdcritic
                ,pr_dscritic => vr_dscritic);
                                         
      IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Log de fim de execucao
      pc_controla_log_batch(pr_dstiplog => 'F');
      
      COMMIT;
      
    EXCEPTION      
      WHEN vr_exc_erro THEN  
        ROLLBACK;
        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
      WHEN OTHERS THEN
        ROLLBACK;
        -- Erro Geral
        vr_dscritic := 'Erro geral em TELA_CONTAS_GRUPO_ECONOMICO.pc_job_grupo_economico_novo: ' || SQLERRM;
        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
    END;    
  END pc_job_grupo_economico_novo;

  
END TELA_CONTAS_GRUPO_ECONOMICO;
/
