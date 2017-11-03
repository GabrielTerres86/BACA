CREATE OR REPLACE PACKAGE PROGRID.wpgd0141 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : wpgd0141
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
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geração do relatorio da tela wpgd0141 - Relatório de Material de Divulgação 
  PROCEDURE wpgd0141(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                    ,pr_dtanoage       IN crapadp.dtanoage%TYPE --> Ano da agenda informado
                    ,pr_nrseqfea       IN crapfea.nrseqfea%TYPE --> Codigo do Evento informado
                    ,pr_dtinieve       VARCHAR2                 --> Data inicial informada
                    ,pr_dtfimeve       VARCHAR2                 --> Data final informada
                    ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                    ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                    ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                    ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                    ,pr_des_erro      OUT VARCHAR2) ;          --> Erros do processo
            
  -- Procedure para listar as pessoas de abertura de eventos
  PROCEDURE pc_lista_pessoa_abertura(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa                           
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro    
                           
END wpgd0141;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.wpgd0141 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : wpgd0141
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
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geração do relatorio da tela wpgd0141 - Relatório de Material de Divulgação 
  PROCEDURE wpgd0141(pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                    ,pr_dtanoage       IN crapadp.dtanoage%TYPE --> Ano da agenda informado
                    ,pr_nrseqfea       IN crapfea.nrseqfea%TYPE --> Codigo do Evento informado
                    ,pr_dtinieve       VARCHAR2                 --> Data inicial informada
                    ,pr_dtfimeve       VARCHAR2                 --> Data final informada
                    ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                    ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                    ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                    ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                    ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                    ,pr_des_erro      OUT VARCHAR2) IS          --> Erros do processo
  
    /* ..........................................................................
    --
    --  Programa : wpgd0141
    --  Sistema  : Rotinas para consultar informacoes de calendario de eventos de assembleias
    --  Sigla    : WPGD
    --  Autor    : Jean Michel
    --  Data     : Marco/2017.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina geração do relatorio da tela wpgd0141 - Relatório de Pendências de Eventos 
    --
    --  Alteracoes: 
    -- .............................................................................*/
   
      CURSOR cr_calendario(pr_cdcooper crapcop.cdcooper%TYPE
                          ,pr_dtanoage crapadp.dtanoage%TYPE
                          ,pr_nrseqfea crapfea.nrseqfea%TYPE
                          ,pr_dtinieve crapadp.dtinieve%TYPE             
                          ,pr_dtfimeve crapadp.dtfineve%TYPE) IS

        SELECT DECODE(to_char(c.dtinieve,'DD/MM/YYYY'),
                      NULL,
                      DECODE(c.nrmeseve,1,'JANEIRO - ',
                                        2,'FEVEREIRO - ',
                                        3,'MARÇO - ',
                                        4,'ABRIL - ',
                                        5,'MAIO - ',
                                        6,'JUNHO - ',
                                        7,'JULHO - ',
                                        8,'AGOSTO - ',
                                        9,'SETEMBRO - ',
                                        10,'OUTUBRO - ',
                                        11,'NOVEMBRO - ',
                                        12,'DEZEMBRO - '),
                      to_char(c.dtfineve,'DD/MM/YYYY'),
                      to_char(c.dtinieve,'DD/MM/YYYY'),                      
                      to_char(c.dtinieve,'DD/MM/YYYY') ||' à '||to_char(c.dtfineve,'DD/MM/YYYY'))||' '||
               ce.nmevento||' - '||
               decode(c.cdagenci,0,'TODAS',ca.nmresage) AS nmevento
              ,cf.nmfacili AS nmfacili
              ,DECODE(to_char(c.dtinieve,'D'),1,'DOMINGO',
                                             2,'SEGUNDA-FEIRA', 
                                             3,'TERÇA-FEIRA', 
                                             4,'QUARTA-FEIRA', 
                                             5,'QUINTA-FEIRA', 
                                             6,'SEXTA-FEIRA', 
                                             7,'SÁBADO') AS dtinieve
               ,cl.dslocali ||' - '||cl.dsrefloc AS dslocali
               ,cl.dsendloc||' - '||cl.nmbailoc||' - '||cl.nmcidloc AS dsendloc
               ,c.dshroeve AS dshroeve
          FROM crapadp c
              ,crapedp ce
              ,crapage ca
              ,crapldp cl
              ,crapfea cf 
         WHERE c.idevento = 2
           AND c.dtanoage = pr_dtanoage -- Parâmetro
           AND (c.cdcooper = pr_cdcooper OR pr_cdcooper = 99)-- Parâmetro
           AND (c.dtinieve >= pr_dtinieve -- Parâmetro
           AND c.dtfineve <= pr_dtfimeve  -- Parâmetro
            OR (c.dtinieve IS NULL 
            OR  c.dtfineve IS NULL))
           AND c.idstaeve <> 2 -- Cancelado
           AND ce.idevento    = c.idevento
           AND ce.cdcooper    = c.cdcooper
           AND ce.dtanoage    = c.dtanoage
           AND ce.cdevento    = c.cdevento
           AND ce.tpevento    NOT IN(10,11) -- Eventos EAD
           AND ca.cdcooper(+) = c.cdcooper
           AND ca.cdagenci(+) = c.cdagenci
           AND cl.idevento(+) = 1 -- No cadastro de localidade é sempre igual a 1
           AND cl.cdcooper(+) = c.cdcooper
           AND cl.nrseqdig(+) = c.cdlocali
           AND cf.nrseqfea    = c.nrseqfea
           AND c.nrseqfea     = DECODE(pr_nrseqfea,0,c.nrseqfea,pr_nrseqfea)
      ORDER BY cf.nmfacili
              ,c.nrmeseve
              ,c.dtinieve
              ,nmevento;
      
     rw_calendario cr_calendario%ROWTYPE;

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

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
          
      vr_contador INTEGER := 0;
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
    
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');  
      GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'eventos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        
      FOR rw_calendario IN cr_calendario(pr_cdcooper => pr_cdcooper
                                        ,pr_dtanoage => pr_dtanoage
                                        ,pr_nrseqfea => pr_nrseqfea
                                        ,pr_dtinieve => pr_dtinieve
                                        ,pr_dtfimeve => pr_dtfimeve) LOOP
                        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'eventos', pr_posicao => 0, pr_tag_nova => 'evento', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'evento', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_calendario.nmevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'evento', pr_posicao => vr_contador, pr_tag_nova => 'nmfacili', pr_tag_cont => rw_calendario.nmfacili, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'evento', pr_posicao => vr_contador, pr_tag_nova => 'dtinieve', pr_tag_cont => rw_calendario.dtinieve, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'evento', pr_posicao => vr_contador, pr_tag_nova => 'dslocali', pr_tag_cont => rw_calendario.dslocali, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'evento', pr_posicao => vr_contador, pr_tag_nova => 'dsendloc', pr_tag_cont => rw_calendario.dsendloc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'evento', pr_posicao => vr_contador, pr_tag_nova => 'dshroeve', pr_tag_cont => rw_calendario.dshroeve, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
                      
      END LOOP;
      
      
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
  END wpgd0141;

 
  -- Procedure para listar as pessoas de abertura de eventos
  PROCEDURE pc_lista_pessoa_abertura(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa                           
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro  
    -- ..........................................................................
    --
    --  Programa : pc_lista_pessoa_abertura
    --  Sistema  : Rotinas para listar as pessoas de aberturas de eventos
    --  Sigla    : wpgd0141
    --  Autor    : Jean Michel
    --  Data     : Março/2017.                   Ultima atualizacao: 07/03/2017
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de pessoas de aberturas de eventos
    --
    --  Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      
      -- Cursor sobre o cadastro de eventos
      CURSOR cr_crapfea(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT fea.nrseqfea
            ,fea.nmfacili
        FROM crapfea fea
       WHERE (fea.cdcooper = pr_cdcooper OR pr_cdcooper = 99)
         AND fea.idsitfea = 1
       ORDER BY fea.nmfacili;
        
      rw_crapfea cr_crapfea%ROWTYPE;
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
      
    BEGIN
        
      FOR rw_crapfea IN cr_crapfea(pr_cdcooper => pr_cdcooper) LOOP
                        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqfea', pr_tag_cont => rw_crapfea.nrseqfea, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmfacili', pr_tag_cont => rw_crapfea.nmfacili, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
                      
      END LOOP;
               
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro geral em wpgd0141.PC_LISTA_PESSOA_ABERTURA: ' || SQLERRM;
        pr_dscritic := 'Erro geral em wpgd0141.PC_LISTA_PESSOA_ABERTURA: ' || SQLERRM;
    END;

  END pc_lista_pessoa_abertura;
                   
END wpgd0141;
/
