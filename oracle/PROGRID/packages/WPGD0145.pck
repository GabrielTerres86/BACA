CREATE OR REPLACE PACKAGE PROGRID.WPGD0145 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0145
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : 25/05/2017                   Ultima atualizacao:  
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para Relatório de Fechamento Geral de Eventos Assembleares
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Relatório de Fechamento Geral
  PROCEDURE pc_wpgd0145(pr_dtanoage IN crapagp.dtanoage%TYPE --> Ano da Agencia
                       ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Aooperativa
                       ,pr_cdagenci IN VARCHAR2              --> Codigo do PA
                       ,pr_cdtiprel IN INTEGER               --> (1 - Por Evento / 2 - Por PA)
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descrição do Erro

END WPGD0145;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0145 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0145
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
  
    -- Relatório de Fechamento Geral
  PROCEDURE pc_wpgd0145(pr_dtanoage IN crapagp.dtanoage%TYPE --> Ano da agencia
                       ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_cdagenci IN VARCHAR2              --> Codigo do PA
                       ,pr_cdtiprel IN INTEGER               --> (1 - Por Evento / 2 - Por PA)
                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descrição do Erro
                                      
  BEGIN
    
    /* .............................................................................

    Programa: pc_wpgd0145
    Sistema : Progrid
    Sigla   : WPGD
    Autor   : Jean Michel
    Data    : 25/05/2017                    Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotinas para Relatório de Fechamento Geral de Eventos Assembleares

    Observacao: -----

    Alteracoes:
    ..............................................................................*/    
  
  
  	DECLARE
    
      --------------------------> CURSORES <-----------------------------
      
      -- Cursor de Eventos
      CURSOR cr_eventos(pr_idevento IN crapadp.idevento%TYPE
                       ,pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtanoage IN crapagp.dtanoage%TYPE
                       ,pr_cdagenci IN VARCHAR2
                       ,pr_cdtiprel IN crapcop.cdcooper%TYPE
                       ,pr_cdtipead IN crapcop.cdcooper%TYPE) IS
                        
        SELECT edp.cdevento AS cdevento 
              ,edp.nmevento AS nmevento
              ,adp.cdagenci AS cdagenci
              ,age.nmresage AS nmresage
              ,cop.cdcooper AS cdcooper
              ,cop.nmrescop AS nmrescop
              ,adp.dtinieve AS dtinieve
              ,/*DECODE(pr_cdtiprel,
                      1, -- EVENTO
                        CASE edp.tpevento 
                          WHEN 10 THEN -- EAD
                            NVL((SELECT TO_CHAR(ced.qtocoeve * ced.qtpareve) FROM crapced ced WHERE ced.dtanoage = adp.dtanoage
                                                                                                AND ced.cdcooper = adp.cdcooper
                                                                                                AND ced.cdagenci = adp.cdagenci
                                                                                                AND ced.cdevento = adp.cdevento),'0')
                          ELSE         -- PROGRID
                            NVL(TO_CHAR(PROGRID.fn_retorna_qtmaxtur(adp.idevento,adp.cdcooper,adp.cdagenci,adp.dtanoage,adp.cdevento)),'0')
                        END,
                      2,adp.qtparpre,0 -- PA
                      )*/ NVL(adp.qtparpre,0) AS qtparpre -- QTD PREVISTA
              ,DECODE(edp.tpevento, -- EVENTO/PA
                      10,   -- EAD
                        DECODE(adp.idstaeve,2,'CANCELADO',NVL((SELECT TO_CHAR(COUNT(*)) FROM crapidp idp WHERE idp.idevento = adp.idevento
                                                                         AND idp.cdcooper = adp.cdcooper
                                                                         AND idp.dtanoage = adp.dtanoage
                                                                         AND idp.cdagenci = adp.cdagenci
                                                                         AND idp.cdevento = adp.cdevento
                                                                         AND idp.nrseqeve = adp.nrseqdig
                                                                         AND idp.idstains = 2 -- Confirmado
                                                                         AND adp.dtfineve < TRUNC(SYSDATE)
                                                                         AND adp.idstaeve <> 2
                                                                         AND edp.tpevento = 10 
                                                                         AND (((idp.qtfaleve * 100) / adp.qtdiaeve) <= (100 - edp.prfreque))
                                                                         AND idp.tpinseve = 1),'0'))  
                       
                        ,DECODE(adp.idstaeve,2,'CANCELADO',NVL((SELECT TO_CHAR(COUNT(*)) FROM crapidp idp WHERE idp.idevento = adp.idevento -- PROGRID
                                                                         AND idp.cdcooper = adp.cdcooper
                                                                         AND idp.dtanoage = adp.dtanoage
                                                                         AND idp.cdagenci = adp.cdagenci
                                                                         AND idp.cdevento = adp.cdevento
                                                                         AND idp.nrseqeve = adp.nrseqdig
                                                                         AND idp.idstains = 2 -- Confirmado
                                                                         AND adp.dtfineve < TRUNC(SYSDATE)
                                                                         AND adp.idstaeve <> 2
                                                                         AND edp.tpevento <> 10 
                                                                         AND (((idp.qtfaleve * 100) / adp.qtdiaeve) <= (100 - edp.prfreque))
                                                                         AND idp.tpinseve = 1),'0'))
                      ) AS qtparcop -- QTD COOPERATIVA
              ,DECODE(edp.tpevento, -- EVENTO/PA
                      10,   -- EAD
                        DECODE(adp.idstaeve,2,'CANCELADO',NVL((SELECT TO_CHAR(COUNT(*)) FROM crapidp idp WHERE idp.idevento = adp.idevento
                                                                         AND idp.cdcooper = adp.cdcooper
                                                                         AND idp.dtanoage = adp.dtanoage
                                                                         AND idp.cdagenci = adp.cdagenci
                                                                         AND idp.cdevento = adp.cdevento
                                                                         AND idp.nrseqeve = adp.nrseqdig
                                                                         AND idp.idstains = 2 -- Confirmado
                                                                         AND adp.dtfineve < TRUNC(SYSDATE)
                                                                         AND adp.idstaeve <> 2
                                                                         AND edp.tpevento = 10 
                                                                         AND (((idp.qtfaleve * 100) / adp.qtdiaeve) <= (100 - edp.prfreque))
                                                                         AND idp.tpinseve <> 1),'0'))  
                       
                      ,DECODE(adp.idstaeve,2,'CANCELADO',NVL((SELECT TO_CHAR(COUNT(*)) FROM crapidp idp WHERE idp.idevento = adp.idevento -- PROGRID
                                                                         AND idp.cdcooper = adp.cdcooper
                                                                         AND idp.dtanoage = adp.dtanoage
                                                                         AND idp.cdagenci = adp.cdagenci
                                                                         AND idp.cdevento = adp.cdevento
                                                                         AND idp.nrseqeve = adp.nrseqdig
                                                                         AND idp.idstains = 2 -- Confirmado
                                                                         AND adp.dtfineve < TRUNC(SYSDATE)
                                                                         AND adp.idstaeve <> 2
                                                                         AND edp.tpevento <> 10 
                                                                         AND (((idp.qtfaleve * 100) / adp.qtdiaeve) <= (100 - edp.prfreque))
                                                                         AND idp.tpinseve <> 1),'0'))
                      ) AS qtparcom -- QTD COMUNIDADE
          FROM crapadp adp
              ,crapedp edp
              ,crapcop cop
              ,crapage age
         WHERE adp.idevento = pr_idevento       
           AND (adp.cdcooper = pr_cdcooper OR pr_cdcooper = 99)
           AND adp.dtanoage = pr_dtanoage
           AND edp.cdevento = adp.cdevento
           AND edp.cdcooper = 0
           AND edp.dtanoage = 0
           AND cop.cdcooper = adp.cdcooper
           AND age.cdcooper = cop.cdcooper
           AND (INSTR(','||pr_cdagenci||',', ','||TO_CHAR(adp.cdagenci)||',') > 0 OR pr_cdagenci = '0') 
           AND edp.idevento = adp.idevento
           AND ((pr_cdtipead = 1 AND (edp.tpevento <> 10 AND edp.tpevento <> 11)) OR (pr_cdtipead = 2 AND (edp.tpevento = 10 OR edp.tpevento = 11)))
           AND adp.cdcooper = age.cdcooper
           AND adp.cdagenci = age.cdagenci
           AND adp.cdagenci NOT IN (90,91,93,95,96,97,98,999)
           AND age.flgdopgd = 1
           AND age.insitage IN (1,3)
           --AND adp.idstaeve <> 2
        ORDER BY edp.nmevento,age.nmresage,adp.nrmeseve,adp.dtinieve;

      rw_eventos cr_eventos%ROWTYPE;

      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS

        SELECT cop.cdcooper
              ,cop.nmrescop 
          FROM crapcop cop
         WHERE cop.flgativo = 1
           AND (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 99)
         ORDER BY cop.nmrescop;

      rw_crapcop cr_crapcop%ROWTYPE;

      CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS

        SELECT age.cdcooper
              ,age.cdagenci
              ,age.nmresage
          FROM crapage age
         WHERE (age.cdcooper = pr_cdcooper OR pr_cdcooper = 99)
           AND (INSTR(','||pr_cdagenci||',', ','||TO_CHAR(age.cdagenci)||',') > 0 OR pr_cdagenci = '0') 
           AND age.cdagenci NOT IN (90,91,93,95,96,97,98,999)
           AND age.flgdopgd = 1
           AND age.insitage IN (1,3)
         ORDER BY age.nmresage;

      rw_crapcop cr_crapcop%ROWTYPE;
 
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
      
      -- Variavéis locais
      vr_cdevento crapadp.cdevento%TYPE := 0;
      vr_flgprime BOOLEAN := TRUE;
      vr_flgregis BOOLEAN := FALSE;

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

      IF pr_cdtiprel = 1 THEN -- EVENTO

        FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP

          pc_escreve_xml ('<cooperativa cdcooper ="' || rw_crapcop.cdcooper || '"' || 
                          ' nmrescop ="' || UPPER(rw_crapcop.nmrescop) || '">');
            
          -- EVENTOS PRESENCIAIS
          pc_escreve_xml('<presencial>');

          -- REINICIALIZA VARIAVEIS        
          vr_flgprime := TRUE;
          vr_flgregis := FALSE;
          vr_cdevento := 0;

          -- percorre os eventos presenciais
          FOR rw_eventos IN cr_eventos(vr_idsistem,rw_crapcop.cdcooper, pr_dtanoage, pr_cdagenci,pr_cdtiprel,1) LOOP
            
            vr_flgregis := TRUE;

            -- EVENTO
            IF vr_cdevento <> rw_eventos.cdevento THEN
              IF NOT vr_flgprime THEN
                pc_escreve_xml ('</evento>');
              END IF;
              pc_escreve_xml ('<evento cdevento ="' || rw_eventos.cdevento || '"' || 
                                     ' nmevento ="' || UPPER(rw_eventos.nmevento) || '">');
              vr_cdevento := rw_eventos.cdevento;
              vr_flgprime := FALSE;
            END IF;                       
            -- FIM EVENTO

            pc_escreve_xml ('<agencia cdagenci ="' || rw_eventos.cdagenci || '"' || 
                                   ' nmresage ="' || UPPER(rw_eventos.nmresage) || '">');
            pc_escreve_xml ('<dtinieve>' || NVL(TO_CHAR(rw_eventos.dtinieve,'dd/mm/RRRR'),'')  || '</dtinieve>');
            pc_escreve_xml ('<qtparpre>' || rw_eventos.qtparpre || '</qtparpre>');
            pc_escreve_xml ('<qtparcop>' || rw_eventos.qtparcop || '</qtparcop>');
            pc_escreve_xml ('<qtparcom>' || rw_eventos.qtparcom || '</qtparcom>');
            pc_escreve_xml ('</agencia>');
          END LOOP;    
          
          IF vr_flgregis THEN
            pc_escreve_xml ('</evento>');
          END IF;
      
          pc_escreve_xml('</presencial>');          
          -- FIM EVENTOS PRESENCIAIS  

          -- EVENTOS EAD
          pc_escreve_xml('<ead>');

          -- REINICIALIZA VARIAVEIS        
          vr_flgprime := TRUE;
          vr_flgregis := FALSE;
          vr_cdevento := 0;

          -- percorre os eventos presenciais
          FOR rw_eventos IN cr_eventos(vr_idsistem,rw_crapcop.cdcooper, pr_dtanoage, pr_cdagenci,pr_cdtiprel,2) LOOP

            vr_flgregis := TRUE; 

            -- EVENTO
            IF vr_cdevento <> rw_eventos.cdevento THEN
              IF NOT vr_flgprime THEN
                pc_escreve_xml ('</evento>');
              END IF;
              pc_escreve_xml ('<evento cdevento ="' || rw_eventos.cdevento || '"' || 
                                     ' nmevento ="' || UPPER(rw_eventos.nmevento) || '">');
              vr_cdevento := rw_eventos.cdevento;
              vr_flgprime := FALSE;
            END IF;                       
            -- FIM EVENTO

            pc_escreve_xml ('<agencia cdagenci ="' || rw_eventos.cdagenci || '"' || 
                                   ' nmresage ="' || UPPER(rw_eventos.nmresage) || '">');
            pc_escreve_xml ('<dtinieve>' || NVL(TO_CHAR(rw_eventos.dtinieve,'dd/mm/RRRR'),'')  || '</dtinieve>');
            pc_escreve_xml ('<qtparpre>' || rw_eventos.qtparpre || '</qtparpre>');
            pc_escreve_xml ('<qtparcop>' || rw_eventos.qtparcop || '</qtparcop>');
            pc_escreve_xml ('<qtparcom>' || rw_eventos.qtparcom || '</qtparcom>');
            pc_escreve_xml ('</agencia>');
          END LOOP;    
          
          IF vr_flgregis THEN
            pc_escreve_xml ('</evento>');
          END IF;

          pc_escreve_xml('</ead>');          
          -- FIM EVENTOS EAD

          pc_escreve_xml ('</cooperativa>');

        END LOOP;

      ELSIF pr_cdtiprel = 2 THEN -- PA

        FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP

          pc_escreve_xml ('<cooperativa cdcooper ="' || rw_crapcop.cdcooper || '"' || 
                          ' nmrescop ="' || UPPER(rw_crapcop.nmrescop) || '">');

          FOR rw_crapage IN cr_crapage(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_cdagenci => pr_cdagenci) LOOP

            pc_escreve_xml ('<agencia cdagenci ="' || rw_crapage.cdagenci || '"' || 
                          ' nmresage ="' || UPPER(rw_crapage.nmresage) || '">');

            -- EVENTOS PRESENCIAIS
            pc_escreve_xml('<presencial>');
            
            -- percorre os eventos presenciais
            FOR rw_eventos IN cr_eventos(vr_idsistem,rw_crapcop.cdcooper, pr_dtanoage, rw_crapage.cdagenci,pr_cdtiprel,1) LOOP

              pc_escreve_xml ('<evento cdevento ="' || rw_eventos.cdevento || '"' || 
                                     ' nmevento ="' || UPPER(rw_eventos.nmevento) || '">');
              pc_escreve_xml ('<dtinieve>' || NVL(TO_CHAR(rw_eventos.dtinieve,'dd/mm/RRRR'),'')  || '</dtinieve>');
              pc_escreve_xml ('<qtparpre>' || TO_CHAR(rw_eventos.qtparpre) || '</qtparpre>');
              pc_escreve_xml ('<qtparcop>' || TO_CHAR(rw_eventos.qtparcop) || '</qtparcop>');
              pc_escreve_xml ('<qtparcom>' || TO_CHAR(rw_eventos.qtparcom) || '</qtparcom>');
              pc_escreve_xml ('</evento>');
            END LOOP;    
           
            pc_escreve_xml('</presencial>');          
            -- FIM EVENTOS PRESENCIAIS  

            -- EVENTOS EAD
            pc_escreve_xml('<ead>');

            -- Percorre os eventos presenciais
            FOR rw_eventos IN cr_eventos(vr_idsistem,rw_crapcop.cdcooper, pr_dtanoage, rw_crapage.cdagenci,pr_cdtiprel,2) LOOP
                                    
              pc_escreve_xml ('<evento cdevento ="' || rw_eventos.cdevento || '"' || 
                                       ' nmevento ="' || UPPER(rw_eventos.nmevento) || '">');
              pc_escreve_xml ('<dtinieve>' || NVL(TO_CHAR(rw_eventos.dtinieve,'dd/mm/RRRR'),'')  || '</dtinieve>');
              pc_escreve_xml ('<qtparpre>' || TO_CHAR(rw_eventos.qtparpre) || '</qtparpre>');
              pc_escreve_xml ('<qtparcop>' || TO_CHAR(rw_eventos.qtparcop) || '</qtparcop>');
              pc_escreve_xml ('<qtparcom>' || TO_CHAR(rw_eventos.qtparcom) || '</qtparcom>');
              pc_escreve_xml ('</evento>');
                        
            END LOOP;    

            pc_escreve_xml('</ead>');          

            pc_escreve_xml ('</agencia>');

          END LOOP;

          pc_escreve_xml ('</cooperativa>');

        END LOOP;
        
      END IF;  

      --> Descarregar buffer
      pc_escreve_xml ('</Root>',TRUE);

      --GENE0002.pc_clob_para_arquivo(pr_clob => vr_des_xml, pr_caminho => '/usr/coopq2/sistemaq2/equipe/jean', pr_arquivo => 'wpgd0145.xml', pr_des_erro => vr_dscritic);

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
        pr_dscritic := 'Erro geral no Relatório de Fechamento Geral: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    
    END;
        
  END pc_wpgd0145;

END WPGD0145;
/
