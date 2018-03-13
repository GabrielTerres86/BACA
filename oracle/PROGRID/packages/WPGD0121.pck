CREATE OR REPLACE PACKAGE PROGRID.WPGD0121 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0121
  --  Sistema  : Rotinas para geração Relatório de EAD
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Janeiro/2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de EAD
  --
  -- Alteracoes: 
  --
  --
  ---------------------------------------------------------------------------------------------------------------
              
  -- Procedure para listar os eventos do sistema
  PROCEDURE pc_lista_eventos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                            ,pr_cdagenci IN VARCHAR2              --> Codigo da Agencia (PA)    
                            ,pr_dtanoage IN crapedp.dtanoage%TYPE --> Ano da Agenda
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro  

  -- Consulta do relatório da tela WPGD0121
  PROCEDURE pc_relat_wpgd0121(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                             ,pr_dtanoage       IN crapadp.dtanoage%TYPE --> Ano da agenda informado
                             ,pr_cdagenci       IN crapadp.cdagenci%TYPE --> Codigo da Agencia Informada
                             ,pr_cdevento       IN crapadp.cdevento%TYPE --> Codigo do Evento informado
                             ,pr_dtinieve       IN VARCHAR2              --> Data inicial informada
                             ,pr_dtfineve       IN VARCHAR2              --> Data final informada
                             ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                             ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro      OUT VARCHAR2);            --> Erros do processo  
                           
END WPGD0121;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0121 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0121
  --  Sistema  : Rotinas para geração Relatório de Material de Divulgação
  --  Sigla    : WPGD
  --  Autor    : Vanessa Klein
  --  Data     : Junho/2016.                   Ultima atualizacao:  15/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de Pendências de Eventos
  --
  -- Alteracoes: 
  -- Chamado 840781 - Marcio (Mouts) 20/02/2018 - Não considerar o ano na query que busca os cursos finalizados
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Procedure para listar os eventos do sistema */
  PROCEDURE pc_lista_eventos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                            ,pr_cdagenci IN VARCHAR2            	 --> Codigo da Agencia (PA)    
                            ,pr_dtanoage IN crapedp.dtanoage%TYPE --> Ano da Agenda
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_eventos
    --  Sistema  : Rotinas para listar os eventos do sistema por cooperativa, pa, dtanoage
    --  Sigla    : WPGD0121
    --  Autor    : Jean Michel
    --  Data     : Janeiro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de eventos liberados na agenda.
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursor sobre os eventos da agenda 
      CURSOR cr_crapedp_age IS
      SELECT DISTINCT edp.cdevento, edp.nmevento
        FROM crapedp edp,
             crapeap eap
       WHERE (edp.cdcooper = eap.cdcooper)
         AND (eap.cdevento = edp.cdevento)
         AND (eap.dtanoage = edp.dtanoage)
         AND (edp.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
         AND (eap.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
         --AND (eap.dtanoage = pr_dtanoage) -- Comentado no chamado 840781
         AND (eap.dtanoage >= pr_dtanoage-1) -- Mostar os eventos EAD do ano atual e anterior
         AND edp.idevento = 1
         AND edp.tpevento IN(10,11)
         AND eap.flgevsel = 1
       ORDER BY edp.nmevento;
        
      rw_crapedp_age cr_crapedp_age%ROWTYPE;
       
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
      arr_agencias GENE0002.typ_split;      
      vr_cdcopage crapcop.cdcooper%TYPE;
    
    BEGIN
        
      FOR rw_crapedp_age IN cr_crapedp_age LOOP
                        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp_age.cdevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp_age.nmevento, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
                      
      END LOOP;  
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em WPGD0121.PC_LISTA_EVENTO: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0121.PC_LISTA_EVENTO: ' || SQLERRM;
    END;

  END pc_lista_eventos;

  -- Rotina geração do relatorio da tela WPGD0121 - Relatório de EAD
  PROCEDURE pc_relat_wpgd0121(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                             ,pr_dtanoage       IN crapadp.dtanoage%TYPE --> Ano da agenda informado
                             ,pr_cdagenci       IN crapadp.cdagenci%TYPE --> Codigo da Agencia Informada
                             ,pr_cdevento       IN crapadp.cdevento%TYPE --> Codigo do Evento informado
                             ,pr_dtinieve       IN VARCHAR2              --> Data inicial informada
                             ,pr_dtfineve       IN VARCHAR2              --> Data final informada
                             ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                             ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro      OUT VARCHAR2) IS          --> Erros do processo
  
    /* ..........................................................................
    --
    --  Programa : pc_relat_wpgd0121
    --  Sistema  : Rotina de consulta de relatório da tela WPGD0121 para tela cadastro de sugestão de produto
    --  Sigla    : WPGD
    --  Autor    : Vanessa Klein
    --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina geração do relatorio da tela WPGD0115 - Relatório de Pendências de Eventos 
    --
    --  Alteracoes: 
    -- .............................................................................*/

      -- Buscar eventos
      CURSOR cr_crapead (pr_cdcooper crapadp.cdcooper%TYPE
                        ,pr_dtanoage crapadp.dtanoage%TYPE
                        ,pr_cdagenci crapadp.cdagenci%TYPE
                        ,pr_cdevento crapadp.cdevento%TYPE
                        ,pr_dtinieve crapadp.dtinieve%TYPE
                        ,pr_dtfineve crapadp.dtfineve%TYPE) IS
        SELECT ce.nmevento AS nmevento
              ,c.dtinieve  AS dtinieve 
              ,c.dtfineve  AS dtfineve 
              ,cc.nmrescop AS nmrescop
              ,ca.nmresage AS nmresage
              ,ci.nminseve AS nminseve
              ,ci.nrdconta AS nrdconta
              ,ci.dtconins AS dtconins
          FROM crapadp c 
              ,crapedp ce
              ,crapidp ci
              ,crapcop cc
              ,crapage ca
         WHERE /*c.dtanoage  = pr_dtanoage -- Parâmetro
           AND */ -- Comentada a linha acima para não considerar o ano ao buscar
           -- os cursos concluídos, visto que, o usuário pode iniciar o curso em 
           -- um ano e terminar somente no ano seguinte
           c.cdcooper  = pr_cdcooper -- Parâmetro
           AND c.cdagenci  = decode(pr_cdagenci,0,c.cdagenci,pr_cdagenci)    -- Parâmetros
           AND c.cdevento  = decode(pr_cdevento,0,c.cdevento,pr_cdevento)    -- Parâmetros
           AND ce.idevento = 1
           AND ce.idevento = c.idevento
           AND ce.cdcooper = c.cdcooper
           AND ce.dtanoage = c.dtanoage
           AND ce.cdevento = c.cdevento
           AND ce.tpevento IN(10,11) -- Eventos EAD
           AND ce.flgativo = 1
           AND ci.idevento = c.idevento
           AND ci.cdcooper = c.cdcooper
           AND ci.dtanoage = c.dtanoage
           AND ci.cdagenci = c.cdagenci
           AND ci.cdevento = c.cdevento
           AND ci.nrseqeve = c.nrseqdig
           AND ci.dtconins >= pr_dtinieve -- Parâmetro
           AND ci.dtconins <= pr_dtfineve -- Parâmetro
           AND cc.cdcooper = c.cdcooper
           AND ca.cdcooper = c.cdcooper
           AND ca.cdagenci = c.cdagenci
      ORDER BY ce.nmevento
              ,c.dtinieve
              ,c.dtfineve
              ,cc.nmrescop
              ,ca.nmresage
              ,ci.nminseve
              ,ci.nrdconta
              ,ci.dtconins;
        
       rw_crapead cr_crapead%ROWTYPE;

       ---------------------------- ESTRUTURAS DE REGISTRO ----------------------
       TYPE typ_tab_reg_relat IS RECORD
          (nmevento crapedp.nmevento%TYPE
          ,dtinieve crapadp.dtinieve%TYPE  
          ,dtfineve crapadp.dtinieve%TYPE
          ,nmrescop crapcop.nmrescop%TYPE 
          ,nmresage crapage.nmresage%TYPE
          ,nminseve crapidp.nminseve%TYPE 
          ,nrdconta crapass.nrdconta%TYPE
          ,dtconins crapadp.dtinieve%TYPE);

      TYPE typ_tab_relat IS
       TABLE OF typ_tab_reg_relat
         INDEX BY BINARY_INTEGER;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela craptel.nmdatela%TYPE;
      vr_nmdeacao crapaca.nmdeacao%TYPE;     
      vr_idcokses VARCHAR2(100);
      vr_idsistem craptel.idsistem%TYPE;
      vr_cddopcao VARCHAR2(100);

      -- Variaveis gerais
      vr_index    PLS_INTEGER := 0;  
      
     -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600); 
      vr_tab_relat typ_tab_relat;
      ---------------------------> SUBROTINAS <--------------------------
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      END;
    
    --inicio  
    BEGIN
    
      prgd0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmdeacao => vr_nmdeacao
                                   ,pr_idcokses => vr_idcokses
                                   ,pr_idsistem => vr_idsistem
                                   ,pr_cddopcao => vr_cddopcao
                                   ,pr_dscritic => vr_dscritic);

      -- Verifica se houve critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                      
    
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);      
         
      FOR rw_crapead IN cr_crapead(pr_cdcooper => pr_cdcooper 
                                  ,pr_dtanoage => pr_dtanoage
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdevento => pr_cdevento
                                  ,pr_dtinieve => pr_dtinieve
                                  ,pr_dtfineve => pr_dtfineve) LOOP
        
        vr_index := vr_index +1;
        vr_tab_relat(vr_index).nmevento := rw_crapead.nmevento;
        vr_tab_relat(vr_index).dtinieve := rw_crapead.dtinieve;
        vr_tab_relat(vr_index).dtfineve := rw_crapead.dtfineve;
        vr_tab_relat(vr_index).nmrescop := rw_crapead.nmrescop;
        vr_tab_relat(vr_index).nmresage := rw_crapead.nmresage;
        vr_tab_relat(vr_index).nminseve := rw_crapead.nminseve;
        vr_tab_relat(vr_index).nrdconta := rw_crapead.nrdconta;
        vr_tab_relat(vr_index).dtconins := rw_crapead.dtconins;      
      
      END LOOP;
      
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>'); 
      
      vr_index := vr_tab_relat.first;  
         

      WHILE vr_index IS NOT NULL LOOP
        pc_escreve_xml('<eventos>  '||  
                       ' <vr_index>'|| vr_index ||'</vr_index>   '||    
                       ' <nmevento>'|| vr_tab_relat(vr_index).nmevento ||'</nmevento>   '||    
                       ' <dtinieve><![CDATA['|| NVL(to_char(vr_tab_relat(vr_index).dtinieve,'DD/MM/YYYY'),'&nbsp;') ||']]></dtinieve>   '||       
                       ' <dtfineve><![CDATA['|| NVL(to_char(vr_tab_relat(vr_index).dtfineve,'DD/MM/YYYY'),'&nbsp;') ||']]></dtfineve>   '||
                       ' <nmrescop>'|| vr_tab_relat(vr_index).nmrescop ||'</nmrescop>   '|| 
                       ' <nmresage>'|| vr_tab_relat(vr_index).nmresage ||'</nmresage>   '|| 
                       ' <nminseve>'|| vr_tab_relat(vr_index).nminseve ||'</nminseve>   '|| 
                       ' <nrdconta>'|| TO_CHAR(vr_tab_relat(vr_index).nrdconta) ||'</nrdconta>   '||  
                       ' <dtconins><![CDATA['|| NVL(to_char(vr_tab_relat(vr_index).dtconins,'DD/MM/YYYY'),'&nbsp;') ||']]></dtconins> '||         
                       ' </eventos>'); 
              
        -- BUSCAR PROXIMO
        vr_index := vr_tab_relat.next(vr_index);   
      END LOOP;  
      
      --> Descarregar buffer
      pc_escreve_xml ('</Root>',TRUE);

      pr_retxml := XMLType.createXML(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);  
      

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro ao gerar relatório: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_relat_wpgd0121;

END WPGD0121;
/
