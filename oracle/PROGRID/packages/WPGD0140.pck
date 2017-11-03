CREATE OR REPLACE PACKAGE PROGRID.WPGD0140 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0140
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 05/06/2017                   Ultima atualizacao:  
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Relatório de Fechamento de Inscrições
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Relatório de Fechamento de Inscrições
  PROCEDURE pc_wpgd0140(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código do PA
                       ,pr_cdevento IN INTEGER               --> Código de Evento
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE --> Ano da Agencia
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descrição do Erro

  /* Procedure para listar os eventos para o relatório de fechamento de inscricoes */
  PROCEDURE pc_lista_evento_wpgd0140(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo da Agencia (PA)    
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
END WPGD0140;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0140 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0140
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 25/05/2017                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada 
  -- Objetivo  :
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_wpgd0140(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código do PA
                       ,pr_cdevento IN INTEGER               --> Código de Evento
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE --> Ano da Agencia
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do Erro
                                      
  BEGIN
    
    /* .............................................................................

    Programa: pc_wpgd0140
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Jean Michel
    Data    : 05/06/2017                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotinas para Relatório de Fechamento de Inscrições

    Observacao: -----

    Alteracoes:
    ..............................................................................*/    
  
  
  	DECLARE
    
      --------------------------> CURSORES <-----------------------------
      
      -- Cursor de inscrições antes da data do evento
      CURSOR cr_eventos_ant(pr_idevento IN crapadp.idevento%TYPE
                           ,pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtanoage IN crapagp.dtanoage%TYPE
                           ,pr_cdagenci IN crapidp.cdagenci%TYPE
                           ,pr_nrseqdig IN crapadp.nrseqdig%TYPE) IS
                        
        SELECT c.nminseve                   AS nminseve
              ,c.cdageins||'-'||cg.nmresage AS nmresage
              ,c.nrdconta                   AS nrdconta
              ,c.dtconins                   AS dtconins
          FROM crapidp c , crapedp ce, crapadp ca, crapage cg
         WHERE c.dtanoage = pr_dtanoage -- PR
           AND c.idevento = pr_idevento -- PR 
           AND c.cdcooper = pr_cdcooper -- PR
           AND (
                (c.cdagenci = pr_cdagenci /*PR*/ AND c.cdagenci = cg.cdagenci AND ce.tpevento NOT IN(7,12))
                OR (ce.tpevento IN(7,12) AND ca.cdagenci = 0 AND c.cdageins = pr_cdagenci AND cg.cdagenci = pr_cdagenci/*PR*/ )
               )
           AND ce.idevento = c.idevento 
           AND ce.cdevento = c.cdevento 
           AND ce.dtanoage = c.dtanoage 
           AND ce.cdcooper = c.cdcooper 
           AND ce.flgativo = 1 
           AND ca.nrseqdig = c.nrseqeve
           AND c.cdcooper = cg.cdcooper
           AND c.dtconins <= ca.dtinieve
           AND ca.nrseqdig = pr_nrseqdig -- PR
           AND ca.idstaeve = 4
         ORDER BY c.dtconins,c.nminseve; 

       rw_eventos_ant cr_eventos_ant%ROWTYPE;

      -- Cursor de inscrições antes da data do evento
      CURSOR cr_eventos_dep(pr_idevento IN crapadp.idevento%TYPE
                           ,pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtanoage IN crapagp.dtanoage%TYPE
                           ,pr_cdagenci IN crapidp.cdagenci%TYPE
                           ,pr_nrseqdig IN crapadp.nrseqdig%TYPE) IS
                        
        SELECT c.nminseve                   AS nminseve
              ,c.cdageins||'-'||cg.nmresage AS nmresage
              ,c.nrdconta                   AS nrdconta
              ,c.dtconins                   AS dtconins
          FROM crapidp c , crapedp ce, crapadp ca, crapage cg
         WHERE c.dtanoage = pr_dtanoage -- PR
           AND c.idevento = pr_idevento -- PR 
           AND c.cdcooper = pr_cdcooper -- PR
           --AND c.cdagenci = pr_cdagenci -- PR
           AND (
                (c.cdagenci = pr_cdagenci /*PR*/ AND c.cdagenci = cg.cdagenci AND ce.tpevento NOT IN(7,12))
                OR (ce.tpevento IN(7,12) AND ca.cdagenci = 0 AND c.cdageins = pr_cdagenci AND cg.cdagenci = pr_cdagenci /*PR*/)
               )
           AND ce.idevento = c.idevento 
           AND ce.cdevento = c.cdevento 
           AND ce.dtanoage = c.dtanoage 
           AND ce.cdcooper = c.cdcooper 
           AND ce.flgativo = 1 
           AND ca.nrseqdig = c.nrseqeve
           AND c.cdcooper = cg.cdcooper
           AND c.dtconins > ca.dtinieve
           AND ca.nrseqdig = pr_nrseqdig -- PR
           AND ca.idstaeve = 4
         ORDER BY c.dtconins,c.nminseve; 

       rw_eventos_dep cr_eventos_dep%ROWTYPE; 

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

      -- EVENTOS ANTES
      pc_escreve_xml('<antes>');

      -- Percorre as incricoes antes da data
      FOR rw_eventos_ant IN cr_eventos_ant(pr_idevento => vr_idsistem
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_dtanoage => pr_dtanoage
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_nrseqdig => pr_cdevento) LOOP

        pc_escreve_xml ('<inscricao>');
        pc_escreve_xml ('<nminseve>' || rw_eventos_ant.nminseve || '</nminseve>');
        pc_escreve_xml ('<nmresage>' || rw_eventos_ant.nmresage || '</nmresage>');
        pc_escreve_xml ('<nrdconta>' || GENE0002.fn_mask_conta(rw_eventos_ant.nrdconta) || '</nrdconta>');
        pc_escreve_xml ('<dtconins>' || TO_CHAR(rw_eventos_ant.dtconins,'DD/MM/RRRR') || '</dtconins>');
        pc_escreve_xml ('</inscricao>');
      END LOOP;    
     
      -- FIM EVENTOS ANTES
      pc_escreve_xml('</antes>');

      -- EVENTOS DEPOIS
      pc_escreve_xml('<depois>');

      -- Percorre as incricoes antes da data
      FOR rw_eventos_dep IN cr_eventos_dep(pr_idevento => vr_idsistem
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_dtanoage => pr_dtanoage
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_nrseqdig => pr_cdevento) LOOP
        pc_escreve_xml ('<inscricao>');
        pc_escreve_xml ('<nminseve>' || rw_eventos_dep.nminseve || '</nminseve>');
        pc_escreve_xml ('<nmresage>' || rw_eventos_dep.nmresage || '</nmresage>');
        pc_escreve_xml ('<nrdconta>' || GENE0002.fn_mask_conta(rw_eventos_dep.nrdconta) || '</nrdconta>');
        pc_escreve_xml ('<dtconins>' || TO_CHAR(rw_eventos_dep.dtconins,'DD/MM/RRRR') || '</dtconins>');
        pc_escreve_xml ('</inscricao>');
      END LOOP;    
     
      -- FIM EVENTOS DEPOIS
      pc_escreve_xml('</depois>');

      --> Descarregar buffer
      pc_escreve_xml ('</Root>',TRUE);

      --DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, '/micros/cecred/jean', 'wpgd0145.xml', NLS_CHARSET_ID('UTF8')); 

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
        pr_dscritic := 'Erro geral no Relatório de Fechamento de Inscrições: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    
    END;
        
  END pc_wpgd0140;

  /* Procedure para listar os eventos para o relatório de fechamento de inscricoes */
  PROCEDURE pc_lista_evento_wpgd0140(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo da Agencia (PA)    
                                    ,pr_dtanoage IN crapeap.dtanoage%TYPE --> Ano do filtro
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- .........................................................................
    --
    --  Programa : pc_lista_evento_wpgd0140
    --  Sistema  : Rotinas para listar os eventos para o relatório de fechamento de inscricoes
    --  Sigla    : GENE
    --  Autor    : Jean Michel
    --  Data     : 06/06/2017                   Ultima Atualizacao: --/--/----
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
                       ,pr_cdagenci IN crapage.cdagenci%TYPE
                       ,pr_dtanoage IN crapadp.dtanoage%TYPE) IS
        SELECT DISTINCT 
               adp.nrseqdig AS cdevento
              ,edp.nmevento || ' - ' || adp.dtinieve || ' - ' || adp.dshroeve  AS nmevento
          FROM crapedp edp,
               crapadp adp
         WHERE edp.cdcooper = adp.cdcooper
           AND edp.dtanoage = adp.dtanoage
           AND edp.cdevento = adp.cdevento
           AND edp.cdcooper = pr_cdcooper
           AND adp.cdagenci = pr_cdagenci
           AND adp.dtanoage = pr_dtanoage
           AND adp.idevento = 2
           AND adp.idstaeve = 4
           AND edp.cdevento <> 0
           AND TRIM(edp.nmevento) IS NOT NULL
           AND edp.tpevento NOT IN (10,11)
        union all   
        SELECT DISTINCT 
               adp.nrseqdig AS cdevento
              ,edp.nmevento || ' - ' || adp.dtinieve || ' - ' || adp.dshroeve AS nmevento
          FROM crapedp edp,
               crapadp adp
         WHERE edp.cdcooper = adp.cdcooper
           AND edp.dtanoage = adp.dtanoage 
           AND edp.cdevento = adp.cdevento
           AND edp.cdcooper = pr_cdcooper
           AND adp.cdagenci = 0
           AND adp.dtanoage = pr_dtanoage
           AND adp.idevento = 2
           AND adp.idstaeve = 4
           AND edp.cdevento <> 0
           AND TRIM(edp.nmevento) IS NOT NULL
           AND edp.tpevento NOT IN (10,11)
         ORDER BY nmevento;
        
      rw_crapedp cr_crapedp%ROWTYPE;
      
      -- Variaveis locais
      vr_contador INTEGER := 0;
        
      -- Variaveis de critica
      vr_dscritic crapcri.dscritic%TYPE;
          
    BEGIN          
     
      FOR rw_crapedp IN cr_crapedp(pr_cdcooper,pr_cdagenci,pr_dtanoage) LOOP                                   
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdevento', pr_tag_cont => rw_crapedp.cdevento, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapedp.nmevento, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;                              
      END LOOP;      
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0; 
        pr_des_erro := 'Erro geral em WPGD0140.pc_lista_evento_wpgd0140: ' || SQLERRM;
        pr_dscritic := 'Erro geral em WPGD0140.pc_lista_evento_wpgd0140: ' || SQLERRM;
    END;

  END pc_lista_evento_wpgd0140;

END WPGD0140;
/
