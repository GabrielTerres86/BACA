CREATE OR REPLACE PACKAGE CECRED.PCPS0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : PCPS0001
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário
  ---------------------------------------------------------------------------------------------------------------*/

    PROCEDURE pc_busca_dominio(pr_nmdominio IN tbcc_dominio_campo.nmdominio%TYPE --> Nr. da Conta
														  ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
														  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
														  ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
														  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
														  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
														  ,pr_des_erro OUT VARCHAR2); --> Erros do processo
  

END PCPS0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PCPS0001 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : PCPS0001
      Sistema  : Rotinas referentes a PLATAFORMA CENTRALIZADA DE PORTABILIDADE DE SALÁRIO
      Sigla    : PCPS
      Autor    : Renato Darosci - Supero
      Data     : Setembro/2018.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas genericas utilizadas na plataforma de portabilidade de salário

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
   PROCEDURE pc_busca_dominio(pr_nmdominio IN tbcc_dominio_campo.nmdominio%TYPE --> Nr. da Conta
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
        
            Programa: pc_busca_dominio
            Sistema : CECRED
            Sigla   : CRD
            Autor   : Augusto (Supero)
            Data    : Outubro/2018                 Ultima atualizacao: 03/10/2018
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Retorna os valores do dominio
        
            Observacao: -----
        
            Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;

        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis internas
        vr_cont_tag PLS_INTEGER := 0;


        CURSOR cr_dominio(pr_nmdominio IN tbcc_dominio_campo.nmdominio%TYPE) IS
              SELECT tdc.cddominio
                    ,tdc.dscodigo
                FROM tbcc_dominio_campo tdc
               WHERE tdc.nmdominio = pr_nmdominio;
        rw_dominio cr_dominio%ROWTYPE;
    
    BEGIN
    
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        FOR rw_dominio IN cr_dominio(pr_nmdominio) LOOP
          GENE0007.pc_insere_tag(pr_xml  => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dominio'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
                            
                            
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dominio'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'cddominio'
                                ,pr_tag_cont => rw_dominio.cddominio
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dominio'
                                ,pr_posicao  => vr_cont_tag
                                ,pr_tag_nova => 'dscodigo'
                                ,pr_tag_cont => rw_dominio.dscodigo
                                ,pr_des_erro => vr_dscritic);                                                        
        
          -- Incrementa o contador de tags
          vr_cont_tag := vr_cont_tag + 1;
        END LOOP;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure PCPS0001.pc_busca_dominio. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');        
    END pc_busca_dominio;

END PCPS0001;
/
