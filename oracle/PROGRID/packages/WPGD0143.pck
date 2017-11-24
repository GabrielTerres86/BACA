CREATE OR REPLACE PACKAGE PROGRID.WPGD0143 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0143
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 09/06/2017                   Ultima atualizacao:  
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Relatório de Fichas de Presença de Assembléias
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Relatório de Fichas de Presença de Assembléias
  PROCEDURE pc_wpgd0143(pr_nrseqdig IN crapadp.nrseqdig%TYPE --> Codigo do Evento
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descrição do Erro

  /* Procedure para listar os eventos para o relatório de ficha de presença */
  PROCEDURE pc_lista_evento_wpgd0143(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
END WPGD0143;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0143 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0143
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 09/06/2017                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada 
  -- Objetivo  :
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Relatório de Fichas de Presença de Assembléias
  PROCEDURE pc_wpgd0143(pr_nrseqdig IN crapadp.nrseqdig%TYPE --> Codigo do Evento
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do Erro
                                      
  BEGIN
    
    /* .............................................................................

    Programa: pc_wpgd0143
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Jean Michel
    Data    : 09/06/2017                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotinas para Relatório de Fichas de Presença de Assembléias

    Observacao: -----

    Alteracoes:
    ..............................................................................*/    
  
  
  	DECLARE
    
      --------------------------> CURSORES <-----------------------------
      
      -- Cursor de Fichas de Presença de Assembléias
      CURSOR cr_fichas(pr_nrseqdig IN crapfpa.nrseqdig%TYPE) IS
        SELECT c.nrficpre                        AS nrficpre
              ,c.dtgerfic                        AS dtgerfic
              ,c.nmresfic                        AS nmresfic
              ,'('||c.nrdddres||') '|| TRIM(gene0002.fn_mask(c.nrtelres,'zzzzz-zzzz')) AS nrtelres
              ,co.nmoperad                       AS nmoperad
              ,cg.nmresage                       AS nmresage
              ,(SELECT COUNT(1) 
                  FROM crapidp ci 
                 WHERE ci.idevento = ca.idevento 
                   AND ci.cdcooper = ca.cdcooper
                   AND ci.dtanoage = ca.dtanoage
                   AND ci.cdagenci = ca.cdagenci
                   AND ci.cdevento = ca.cdevento
                   AND ci.nrseqeve = ca.nrseqdig
                   AND ci.nrficpre = c.nrficpre) qtdelanc
          FROM crapfpa  c,
               crapadp  ca,
               crapope  co,
               crapage  cg
         WHERE c.nrseqdig = pr_nrseqdig -- Parâmetro
           AND co.cdcooper = c.cdcopger
           AND co.cdoperad = c.cdopeger
           AND ca.nrseqdig = c.nrseqdig
           AND cg.cdcooper = c.cdcopfic
           AND cg.cdagenci = c.cdagefic
         ORDER BY c.nrficpre;

       rw_fichas cr_fichas%ROWTYPE;

       CURSOR cr_crapadp(pr_nrseqdig crapadp.nrseqdig%TYPE) IS
          SELECT edp.nmevento
                ,DECODE(edp.tpevento,7,'Assembleia Geral Ordinária',12,'Assembleia Geral Extraordinária','SEM TIPO') AS tpevento
                ,adp.dtinieve
                ,adp.dshroeve
                ,ldp.dslocali || ', ' || ldp.dsendloc AS dslocali
            FROM crapadp adp
                ,crapedp edp
                ,crapldp ldp
           WHERE edp.cdcooper = adp.cdcooper
             AND edp.dtanoage = adp.dtanoage 
             AND edp.cdevento = adp.cdevento
             AND adp.nrseqdig = pr_nrseqdig
             AND ldp.nrseqdig(+) = adp.cdlocali;
 
      rw_crapadp cr_crapadp%ROWTYPE;
  
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
      pc_escreve_xml ('<registros>');
      -- percorre os eventos presenciais
      FOR rw_fichas IN cr_fichas(pr_nrseqdig => pr_nrseqdig) LOOP
        pc_escreve_xml ('<registro>');
        pc_escreve_xml ('<nrficpre>' || rw_fichas.nrficpre || '</nrficpre>');
        pc_escreve_xml ('<dtgerfic>' || rw_fichas.dtgerfic || '</dtgerfic>');
        pc_escreve_xml ('<nmresage>' || rw_fichas.nmresage || '</nmresage>');
        pc_escreve_xml ('<nmresfic>' || rw_fichas.nmresfic || '</nmresfic>');
        pc_escreve_xml ('<nrtelres>' || rw_fichas.nrtelres || '</nrtelres>');
        pc_escreve_xml ('<nmoperad>' || rw_fichas.nmoperad || '</nmoperad>');
        pc_escreve_xml ('<qtdelanc>' || rw_fichas.qtdelanc || '</qtdelanc>');
        pc_escreve_xml ('</registro>');
      END LOOP;
      pc_escreve_xml ('</registros>');

      OPEN cr_crapadp(pr_nrseqdig => pr_nrseqdig);

      FETCH cr_crapadp INTO rw_crapadp;

      IF cr_crapadp%NOTFOUND THEN
        CLOSE cr_crapadp;
        vr_dscritic := 'Registro de evento inexistente';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapadp;
      END IF;
          
      pc_escreve_xml ('<evento>');
      pc_escreve_xml ('<nmevento>' || rw_crapadp.nmevento || '</nmevento>');
      pc_escreve_xml ('<tpevento>' || rw_crapadp.tpevento || '</tpevento>');
      pc_escreve_xml ('<dslocali>' || rw_crapadp.dslocali || '</dslocali>');      
      pc_escreve_xml ('<dtinieve>' || rw_crapadp.dtinieve || '</dtinieve>');
      pc_escreve_xml ('<dshroeve>' || rw_crapadp.dshroeve || '</dshroeve>');

      pc_escreve_xml ('</evento>');

      --> Descarregar buffer
      pc_escreve_xml ('</Root>',TRUE);

      --DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, '/micros/cecred/jean', 'wpgd0145.xml', NLS_CHARSET_ID('UTF8')); 

      pr_retxml := XMLType.createXML(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);        
        
      COMMIT;
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
        pr_dscritic := 'Erro geral no Relatório de Ficha de Presença de Assembléias: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    
    END;
        
  END pc_wpgd0143;

  /* Procedure para listar os eventos para o relatório de ficha de presença */
  PROCEDURE pc_lista_evento_wpgd0143(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- .........................................................................
    --
    --  Programa : pc_lista_evento_wpgd0143
    --  Sistema  : Rotinas para listar os eventos para o relatório de ficha de presença
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : 09/06/2017                   Ultima Atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de eventos do sistema.
    --
    --
    -- .............................................................................
  BEGIN
    DECLARE

      -- Cursor sobre os eventos de inscricoes
      CURSOR cr_crapedp(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtanoage IN crapadp.dtanoage%TYPE) IS
       SELECT DISTINCT 
               adp.nrseqdig AS cdevento
              ,edp.nmevento || ' - ' || adp.dtinieve || ' - ' || adp.dshroeve AS nmevento

          FROM crapedp edp,
               crapadp adp
         WHERE edp.cdcooper = adp.cdcooper
           AND edp.dtanoage = adp.dtanoage
           AND edp.cdevento = adp.cdevento
           AND edp.cdcooper = pr_cdcooper
           AND adp.dtanoage = pr_dtanoage
           AND adp.idevento = 2
           AND adp.idstaeve NOT IN (2)
           AND edp.cdevento <> 0
           AND TRIM(edp.nmevento) IS NOT NULL
           AND edp.tpevento IN (7,12)
      ORDER BY nmevento;
        
      rw_crapedp cr_crapedp%ROWTYPE;
      
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
          
    BEGIN          
     
      FOR rw_crapedp IN cr_crapedp(pr_cdcooper,pr_dtanoage) LOOP                                   
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp.cdevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp.nmevento, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;                              
      END LOOP;      
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0; 
        pr_des_erro := 'Erro geral em WPGD0143.pc_lista_evento_wpgd0143: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0143.pc_lista_evento_wpgd0143: ' || SQLERRM;
    END;

  END pc_lista_evento_wpgd0143;

END WPGD0143;
/
