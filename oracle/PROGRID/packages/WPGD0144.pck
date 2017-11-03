CREATE OR REPLACE PACKAGE PROGRID.WPGD0144 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0144
  --  Sistema  : Rotinas para relatorio de custos orçados
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Junho/2017.                   Ultima atualizacao:  
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Custos dos Eventos do Progrid
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Relatório de Custos Orçados
  PROCEDURE pc_wpgd0144(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                       ,pr_cddregio IN crapreg.cddregio%TYPE --> Código da Regional                
                       ,pr_cdagenci IN VARCHAR2              --> PA's
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE --> Ano de Agenda
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descrição de Erro
  

END WPGD0144;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0144 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0112
  --  Sistema  : Rotinas para relatorio ANALITICO dos valores de custos dos eventos
  --  Sigla    : WPGD
  --  Autor    : Carlos Rafael Tanholi (CECRED)
  --  Data     : Marco/2016.                   Ultima atualizacao: 08/06/2016 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Custos dos Eventos ANALITICO
  --
  -- Alteracoes:  08/06/2016 - Ajustado rotina para apresentara a carga horaria com :
  --                           PRJ229 - Melhorias OQS (Odirlei-AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Relatório de Custos Orçados
  PROCEDURE pc_wpgd0144(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                       ,pr_cddregio IN crapreg.cddregio%TYPE --> Código da Regional                
                       ,pr_cdagenci IN VARCHAR2              --> PA's
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE --> Ano de Agenda
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descrição de Erro
                                      
  BEGIN
    
    /* .............................................................................

    Programa: pc_wpgd0144
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Jean Michel
    Data    : Junho/17.                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina que gera relatorio de custos orcados.

    Observacao: -----

    Alteracoes:
    ..............................................................................*/    
  
  
  	DECLARE
    
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;        
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600);   
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela craptel.nmdatela%TYPE;
      vr_nmdeacao crapaca.nmdeacao%TYPE;     
      vr_idcokses VARCHAR2(100);
      vr_idsistem craptel.idsistem%TYPE;
      vr_cddopcao VARCHAR2(100);      
      
      --------------------------> CURSORES <-----------------------------
      
      -- Cursor de Custos
      CURSOR cr_custos(pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cddregio IN crapreg.cddregio%TYPE
                      ,pr_cdagenci IN VARCHAR2
                      ,pr_dtanoage IN crapagp.dtanoage%TYPE) IS    
                        
        SELECT cc.nmrescop AS nmrescop
              ,NVL(cr.dsdregio,'TESTE') AS dsdregio
              ,decode(c.cdagenci,0,'Todos',ca.nmresage) AS nmresage
              ,ce.nmevento AS nmevento
              ,DECODE(c.dtinieve,c.dtfineve,TO_CHAR(c.dtinieve,'dd/mm/RRRR'),TO_CHAR(c.dtinieve,'dd/mm/RRRR') || '-' || TO_CHAR(c.dtfineve,'dd/mm/RRRR')) AS dtinieve
              ,NVL(c.vlloceve,'0') AS vlloceve
              ,NVL(c.vlalieve,'0') AS vlalieve
              ,NVL(c.vlmateve,'0') AS vlmateve
              ,NVL(c.vlreceve,'0') AS vlreceve
              ,NVL(c.vlloceve,0) + NVL(c.vlalieve,0) + NVL(c.vldiveve,0) + NVL(c.vlmateve,0) + NVL(c.vlreceve,0) AS vlrtotal
          FROM crapadp  c
              ,crapcop cc
              ,crapage ca
              ,crapreg cr
              ,crapedp ce
          WHERE cc.cdcooper    = c.cdcooper     
            AND ca.cdcooper(+) = c.cdcooper
            AND ca.cdagenci(+) = c.cdagenci
            AND cr.cdcooper(+) = ca.cdcooper
            AND cr.cddregio(+) = ca.cddregio
            AND ce.idevento    = c.idevento
            --Evento Raiz
            AND ce.idevento = c.idevento
            AND ce.cdcooper = 0
            AND ce.dtanoage = 0
            AND ce.cdevento = c.cdevento
            AND  c.dtanoage = pr_dtanoage
            AND  c.idevento = 2
            AND  c.idstaeve  <> 2 -- Cancelado
            AND  c.cdevento  < 50000 -- Não EAD
            AND ce.tpevento NOT IN(10,11) -- Não EAD
            AND c.cdcooper = DECODE(pr_cdcooper,0,c.cdcooper ,99,c.cdcooper,pr_cdcooper)
            AND ca.cddregio= DECODE(NVL(pr_cddregio,0),0,ca.cddregio,99,ca.cddregio,pr_cddregio)
            AND c.cdagenci = DECODE(pr_cdagenci,0,c.cdagenci ,99,c.cdagenci,pr_cdagenci)
            and c.cdagenci <> 0
      UNION ALL
        SELECT cc.nmrescop AS nmrescop
              ,'TODAS' AS dsdregio
              ,'TODOS' AS nmresage
              ,ce.nmevento AS nmevento
              ,DECODE(c.dtinieve,c.dtfineve,TO_CHAR(c.dtinieve,'dd/mm/RRRR'),TO_CHAR(c.dtinieve,'dd/mm/RRRR') || '-' || TO_CHAR(c.dtfineve,'dd/mm/RRRR')) AS dtinieve
              ,NVL(c.vlloceve,'0') AS vlloceve
              ,NVL(c.vlalieve,'0') AS vlalieve
              ,NVL(c.vlmateve,'0') AS vlmateve
              ,NVL(c.vlreceve,'0') AS vlreceve
              ,NVL(c.vlloceve,0) + NVL(c.vlalieve,0) + NVL(c.vldiveve,0) + NVL(c.vlmateve,0) + NVL(c.vlreceve,0) AS vlrtotal
          FROM crapadp  c
              ,crapcop cc
              ,crapedp ce
          WHERE cc.cdcooper    = c.cdcooper     
            AND ce.idevento    = c.idevento
            --Evento Raiz
            AND ce.idevento = c.idevento
            AND ce.cdcooper = 0
            AND ce.dtanoage = 0
            AND ce.cdevento = c.cdevento
            AND  c.dtanoage = pr_dtanoage
            AND  c.idevento = 2
            AND  c.idstaeve  <> 2 -- Cancelado
            AND  c.cdevento  < 50000 -- Não EAD
            AND ce.tpevento NOT IN(10,11) -- Não EAD
            AND c.cdcooper = DECODE(pr_cdcooper,0,c.cdcooper ,99,99,pr_cdcooper)
            and c.cdagenci = 0
        ORDER BY 1,2,3,4,5;

      rw_custos cr_custos%ROWTYPE;       
    
      ---------------------------> SUBROTINAS <--------------------------
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      END;      
          
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
      
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');      

      pc_escreve_xml('<custos>');      
      
      FOR rw_custos IN cr_custos(pr_cdcooper, pr_cddregio, pr_cdagenci, pr_dtanoage) LOOP

        pc_escreve_xml ('<custo nmrescop="' || UPPER(TO_CHAR(rw_custos.nmrescop)) || '"' ||
                              ' dsdregio="' || UPPER(TO_CHAR(rw_custos.dsdregio)) || '"' ||
                              ' nmresage="' || UPPER(TO_CHAR(rw_custos.nmresage)) || '"' ||
                              ' nmevento="' || UPPER(TO_CHAR(rw_custos.nmevento)) || '"' ||
                              ' dtinieve="' || rw_custos.dtinieve || '"' ||
                              ' vlloceve="' || TO_CHAR(NVL(rw_custos.vlloceve,'0')) || '"' ||
                              ' vlalieve="' || TO_CHAR(NVL(rw_custos.vlalieve,'0')) || '"' ||
                              ' vlmateve="' || TO_CHAR(NVL(rw_custos.vlmateve,'0')) || '"' ||
                              ' vlreceve="' || TO_CHAR(NVL(rw_custos.vlreceve,'0')) || '"' ||
                              ' vlrtotal="' || TO_CHAR(NVL(rw_custos.vlrtotal,'0')) || '" ></custo>');
      END LOOP;    
    
      pc_escreve_xml('</custos>');          
    
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
        pr_dscritic := 'Erro geral no Relatório de Custos Orçados: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    
    END;
        
  END pc_wpgd0144;
  
END WPGD0144;
/
