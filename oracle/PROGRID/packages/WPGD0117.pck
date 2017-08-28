CREATE OR REPLACE PACKAGE PROGRID.WPGD0117 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD017
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao:  23/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de Informações para Ministrante
  --
  -- Alteracoes: 23/08/2017 - SD 706932 (Jean Michel) 
  --
  ---------------------------------------------------------------------------------------------------------------*/

  -- Rotina geração do relatorio da tela WPGD0117 - Relatório de Informações para Ministrante  
  PROCEDURE pc_relat_wpgd0117( pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                              ,pr_dtanoage       IN VARCHAR2              --> Ano da agenda informado
                              ,pr_nrcpfcgc       IN crapcdp.nrcpfcgc%TYPE --> Numero do cpf/cnpj do fornecedor
                              ,pr_idevento       IN crapedp.idevento%TYPE --> Id do evento(tipo)
                              ,pr_dtiniper       IN VARCHAR2              --> Data inicial do periodo para o relatorio
                              ,pr_dtfimper       IN VARCHAR2              --> Data final do periodo para o relatorio
                              ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro      OUT VARCHAR2);            --> Erros do processo
                              
END WPGD0117;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0117 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD017
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao:  09/08/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de Informações para Ministrante
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------*/  
  
  -- Rotina geração do relatorio da tela WPGD0117 - Relatório de Informações para Ministrante  
  PROCEDURE pc_relat_wpgd0117( pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                              ,pr_dtanoage       IN VARCHAR2              --> Ano da agenda informado
                              ,pr_nrcpfcgc       IN crapcdp.nrcpfcgc%TYPE --> Numero do cpf/cnpj do fornecedor
                              ,pr_idevento       IN crapedp.idevento%TYPE --> Id do evento(tipo)
                              ,pr_dtiniper       IN VARCHAR2              --> Data inicial do periodo para o relatorio
                              ,pr_dtfimper       IN VARCHAR2              --> Data final do periodo para o relatorio
                              ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro      OUT VARCHAR2) IS          --> Erros do processo
  
    /* ..........................................................................
    --
    --  Programa : pc_relat_wpgd0117
    --  Sistema  : Progrid
    --  Sigla    : WPGD
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 23/08/2017
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina geração do relatorio da tela WPGD0117 - Relatório de Informações para Ministrante  
    --
    --  Alteracoes: 23/08/2017 - SD 706932 (Jean Michel)
    -- .............................................................................*/

      -- Buscar informacoes para ministrantes
      CURSOR cr_infminis( pr_dtanoage  crapadp.dtanoage%TYPE,
                          pr_cdcooper  crapadp.cdcooper%TYPE,
                          pr_nrcpfcgc  gnapfdp.nrcpfcgc%TYPE,
                          pr_dtiniper  DATE,
                          pr_dtfimper  DATE) IS
        SELECT 1 idquery
              ,c.cdcooper
              ,c.cdcooper ||' - '||co.nmrescop  nmrescop
              ,c.nrmeseve
              ,gf.nmfacili
              ,g.nrcpfcgc
              ,g.nmfornec
              ,c.dtinieve
              ,decode(to_char(c.dtinieve, 'DD/MM/YYYY'),
                      to_char(c.dtfineve, 'DD/MM/YYYY'),
                      to_char(c.dtinieve, 'DD/MM/YYYY'),
                      to_char(c.dtinieve, 'DD/MM/YYYY') || ' à ' || to_char(c.dtfineve, 'DD/MM/YYYY')) AS dsevento              
              ,ce.tpevento
              ,ce.nmevento 
              ,ca.nmresage 
              ,c.dsdiaeve
              ,decode(TRIM(cl.dslocali||cl.dsrefloc),NULL,NULL,cl.dslocali) || 
               decode(TRIM(cl.dsrefloc),NULL,NULL,' - ' || cl.dsrefloc) AS dsdlocal
              ,decode(TRIM(cl.dsendloc||cl.nmbailoc),NULL,NULL, cl.dsendloc || ' - ' || cl.nmbailoc || ' - ' || cl.nmcidloc ) AS dsendere
              ,c.dshroeve
              ,'Código ' || ca.cdcooper AS dsnotfis
              ,ca.cdagenci || ' - ' || ca.nmresage || ' / ' ||
               decode(TRIM(ca.nrtelvoz),NULL,'Telefone não Cadastrado',
                                        ca.nrtelvoz) || ' falar com ' || cr.nmrespgd ||
               ' (Responsável pelo Progrid no PA).' AS dsrespon
              ,DECODE(TRIM(NVL(cr.nrdddct1,'0')),'0',TRIM(cr.nmctopla),TRIM(cr.nmctopla) || ' - Telefone: (' || cr.nrdddct1 || ') ' || cr.nrtelct1 || 
                 DECODE(TRIM(NVL(cr.nrdddct2,'0')),'0',NULL, ' (' || cr.nrdddct2 || ') ' || cr.nrtelct2)
               ) AS dscontat 
          FROM crapadp c
              ,crapedp ce
              ,crapage ca
              ,crapldp cl
              ,crapcdp cc
              ,gnapfdp g
              ,gnappdp gp
              ,gnfacep gc
              ,gnapfep gf 
              ,craprcp cr
              ,crapcop co
         WHERE c.idevento = 1
           AND c.dtanoage = pr_dtanoage
           AND c.cdcooper = nvl(nullif(pr_cdcooper,0),c.cdcooper)
           AND c.dtinieve >= pr_dtiniper
           AND c.dtinieve <= pr_dtfimper
           and g.nrcpfcgc = nvl(nullif(pr_nrcpfcgc,0),g.nrcpfcgc)
           AND c.idstaeve IN (1, 3, 6, 4) --1 - AGENDADO, 3 - TRANSFERIDO, 6 - ACRESCIDO , 4 – Encerrado
           AND c.cdcooper = co.cdcooper
           AND ce.idevento = c.idevento
           AND ce.cdcooper = c.cdcooper
           AND ce.dtanoage = c.dtanoage
           AND ce.cdevento = c.cdevento
           AND ce.tpevento NOT IN (10, 11) -- Eventos EAD
           AND ca.cdcooper = c.cdcooper
           AND ca.cdagenci = c.cdagenci
           AND cl.idevento(+) = c.idevento
           AND cl.cdcooper(+) = c.cdcooper
           AND cl.nrseqdig(+) = c.cdlocali
              -- Custo
           AND cc.idevento(+) = c.idevento
           AND cc.cdcooper(+) = c.cdcooper
           AND cc.cdagenci(+) = c.cdagenci
           AND cc.dtanoage(+) = c.dtanoage
           AND cc.cdevento(+) = c.cdevento
           AND cc.cdcuseve(+) = 1
           AND cc.tpcuseve(+) = 1
           AND gp.idevento(+) = cc.idevento
           AND gp.cdcooper(+) = 0
           AND gp.nrcpfcgc(+) = cc.nrcpfcgc
           AND gp.nrpropos(+) = cc.nrpropos
           AND gc.idevento(+) = cc.idevento
           AND gc.cdcooper(+) = 0
           AND gc.nrcpfcgc(+) = cc.nrcpfcgc
           AND gc.nrpropos(+) = cc.nrpropos
           AND gf.idevento(+) = gc.idevento
           AND gf.cdcooper(+) = gc.cdcooper
           AND gf.nrcpfcgc(+) = gc.nrcpfcgc
           AND gf.cdfacili(+) = gc.cdfacili
           AND g.idevento(+) = gp.idevento
           AND g.cdcooper(+) = gp.cdcooper
           AND g.nrcpfcgc(+) = gp.nrcpfcgc
           -- Contatos de Plantão
           and cr.cdcoprcp(+)= c.cdcooper 
           and cr.cdagenci(+)= c.cdagenci 

        UNION ALL -- Trazer os eventos sem data informada
        SELECT 2
              ,c.cdcooper
              ,c.cdcooper ||' - '||co.nmrescop  nmrescop
              ,c.nrmeseve
              ,gf.nmfacili
              ,g.nrcpfcgc
              ,g.nmfornec
              ,c.dtinieve
              ,''
              ,ce.tpevento
              ,ce.nmevento 
              ,ca.nmresage
              ,c.dsdiaeve
              ,decode(TRIM(cl.dslocali||cl.dsrefloc),NULL,NULL, cl.dslocali) ||
               decode(TRIM(cl.dsrefloc),NULL,NULL,' - ' || cl.dsrefloc)
              ,decode(TRIM(cl.dsendloc||cl.nmbailoc),NULL,NULL, cl.dsendloc || ' - ' || cl.nmbailoc || ' - ' || cl.nmcidloc )
              ,c.dshroeve
              ,'Código ' || ca.cdcooper
              ,ca.cdagenci || ' - ' || ca.nmresage || ' / ' ||
               decode(TRIM(ca.nrtelvoz),NULL,'Telefone não Cadastrado',
                                        ca.nrtelvoz) || ' falar com ' || cr.nmrespgd ||
               ' (Responsável pelo Progrid no PA).'
              ,DECODE(TRIM(NVL(cr.nrdddct1,'0')),'0',TRIM(cr.nmctopla), ' (' || cr.nrdddct1 || ') ' || cr.nrtelct1 || 
                 DECODE(TRIM(NVL(cr.nrdddct2,'0')),'0',NULL,TRIM(cr.nmctopla) || ' - Telefone: (' || cr.nrdddct2 || ') ' || cr.nrtelct2)
               )
          FROM crapadp c
              ,crapedp ce
              ,crapage ca
              ,crapldp cl
              ,crapcdp cc
              ,GNAPFDP g
              ,gnappdp gp
              ,gnfacep gc
              ,gnapfep gf
              ,craprcp cr
              ,crapcop co
         WHERE c.idevento = 1
           AND c.dtanoage = pr_dtanoage
           AND c.cdcooper = nvl(nullif(pr_cdcooper,0),c.cdcooper)
           AND TRIM(c.dtinieve) is NULL
           
           -- Apenas os meses que pertecerem ao filtro
           AND to_date('01'||to_char(c.nrmeseve,'FM00')||c.dtanoage,'DDMMRRRR') >= pr_dtiniper
           AND to_date('01'||to_char(c.nrmeseve,'FM00')||c.dtanoage,'DDMMRRRR') <= pr_dtfimper
           
           AND g.nrcpfcgc = nvl(nullif(pr_nrcpfcgc,0),g.nrcpfcgc)   
           AND c.idstaeve IN (1, 3, 6, 4) --1 - AGENDADO, 3 - TRANSFERIDO, 6 - ACRESCIDO , 4 – Encerrado
           AND c.cdcooper = co.cdcooper
           AND ce.idevento = c.idevento
           AND ce.cdcooper = c.cdcooper
           AND ce.dtanoage = c.dtanoage
           AND ce.cdevento = c.cdevento
           AND ce.tpevento NOT IN (10, 11) -- Eventos EAD
           AND ca.cdcooper = c.cdcooper
           AND ca.cdagenci = c.cdagenci
           AND cl.idevento(+) = c.idevento
           AND cl.cdcooper(+) = c.cdcooper
           AND cl.nrseqdig(+) = c.cdlocali
              -- Custo
           AND cc.idevento(+) = c.idevento
           AND cc.cdcooper(+) = c.cdcooper
           AND cc.cdagenci(+) = c.cdagenci
           AND cc.dtanoage(+) = c.dtanoage
           AND cc.cdevento(+) = c.cdevento
           AND cc.cdcuseve(+) = 1
           AND cc.tpcuseve(+) = 1
           AND gp.idevento(+) = cc.idevento
           AND gp.cdcooper(+) = 0
           AND gp.nrcpfcgc(+) = cc.nrcpfcgc
           AND gp.nrpropos(+) = cc.nrpropos
           AND gc.idevento(+) = cc.idevento
           AND gc.cdcooper(+) = 0
           AND gc.nrcpfcgc(+) = cc.nrcpfcgc
           AND gc.nrpropos(+) = cc.nrpropos
           AND gf.idevento(+) = gc.idevento
           AND gf.cdcooper(+) = gc.cdcooper
           AND gf.nrcpfcgc(+) = gc.nrcpfcgc
           AND gf.cdfacili(+) = gc.cdfacili
           AND g.IDEVENTO(+) = gp.idevento
           AND g.CDCOOPER(+) = gp.cdcooper
           AND g.NRCPFCGC(+) = gp.nrcpfcgc
           -- Contatos de Plantão
           AND cr.cdcoprcp(+)= c.cdcooper
           AND cr.cdagenci(+)= c.cdagenci 
         ORDER BY cdcooper
                 ,nmfornec --3
                 ,idquery  --1
                 ,dtinieve --2
                 ,dsdiaeve --2
                 ,nrmeseve
                 ,nmevento;--6
                 
                 
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
      vr_dsdstyle  VARCHAR2(300) := NULL;      
      
      vr_dsevento  VARCHAR2(500);
      vr_dsdiaeve  VARCHAR2(1000);
      vr_dsmeseve  VARCHAR2(500);
      
      vr_dtiniper  DATE;
      vr_dtfimper  DATE;
      
      vr_dsindefi  VARCHAR2(500);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600); 
    
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
      
      vr_dtiniper := to_date(pr_dtiniper,'DD/MM/RRRR');
      vr_dtfimper := to_date(pr_dtfimper,'DD/MM/RRRR');       

      --Definir indefinido
      vr_dsindefi := '<span style="COLOR: red" >INDEFINIDO</span>';
    
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      vr_dsdstyle := 'style="font-family: Arial, Helvetica, sans-serif;font-size: 9px;margin: 0 0;padding-right:5px; word-wrap: break-word;"';
      
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');
      
      --> Listar ministrantes
      FOR rw_infminis in cr_infminis ( pr_dtanoage => pr_dtanoage,
                                       pr_cdcooper => pr_cdcooper,
                                       pr_nrcpfcgc => pr_nrcpfcgc,
                                       pr_dtiniper => vr_dtiniper,
                                       pr_dtfimper => vr_dtfimper) LOOP
        
        vr_dsevento := NULL;
        vr_dsdiaeve := NULL;
        vr_dsmeseve := NULL;
        
        -- Definir dia do evento
        vr_dsdiaeve := prgd0002.fn_dia_semana(TRIM(rw_infminis.dsdiaeve));
        
        --> Definir descrição do evento
        IF rw_infminis.idquery = 2 THEN
          vr_dsmeseve := gene0001.vr_vet_nmmesano(rw_infminis.nrmeseve);
        END IF;        
        vr_dsevento := rw_infminis.dsevento||vr_dsmeseve;
        
        pc_escreve_xml('<infminis> '||
                           ' <cdcooper> <![CDATA['|| gene0007.fn_acento_xml(rw_infminis.cdcooper) ||']]></cdcooper>'||
                           ' <nmrescop> <![CDATA['|| gene0007.fn_acento_xml(rw_infminis.nmrescop) ||']]></nmrescop>'||
                           ' <dsminist> <![CDATA['|| gene0007.fn_acento_xml(rw_infminis.nmfornec) ||']]></dsminist>'||
                           ' <nmfacili> <![CDATA['|| gene0007.fn_acento_xml(rw_infminis.nmfacili) ||']]></nmfacili>'||
                           ' <nmevento> <![CDATA['|| prgd0002.fn_desc_tpevento(rw_infminis.tpevento)||' - '||
                                                     gene0007.fn_acento_xml(rw_infminis.nmevento || ' - ' || 
                                                     rw_infminis.nmresage)                        ||']]></nmevento>   '||    
                           ' <dtevento> <![CDATA['|| gene0007.fn_acento_xml(vr_dsevento)          ||']]></dtevento>   '||    
                           ' <Dias>     <![CDATA['|| nvl(gene0007.fn_acento_xml(TRIM(vr_dsdiaeve))         ,vr_dsindefi) ||']]></Dias>     '||      
                           ' <Local>    <![CDATA['|| nvl(gene0007.fn_acento_xml(TRIM(rw_infminis.dsdlocal)),vr_dsindefi) ||']]></Local>    '||      
                           ' <Endereco> <![CDATA['|| nvl(gene0007.fn_acento_xml(TRIM(rw_infminis.dsendere)),vr_dsindefi) ||']]></Endereco> '||      
                           ' <Horario>  <![CDATA['|| nvl(gene0007.fn_acento_xml(TRIM(rw_infminis.dshroeve)),vr_dsindefi) ||']]></Horario>  '||      
                           ' <dsnotfis> <![CDATA['|| gene0007.fn_acento_xml(rw_infminis.dsnotfis) ||']]></dsnotfis>  '||      
                           ' <dsrespon> <![CDATA['|| gene0007.fn_acento_xml(rw_infminis.dsrespon) ||']]></dsrespon>  '||                                 
                           ' <Telefone> <![CDATA['|| gene0007.fn_acento_xml(rw_infminis.dscontat) ||']]></Telefone> '||                                 
                        '</infminis>');          
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
  END pc_relat_wpgd0117;

-----------------------------------------------------                       
END WPGD0117;
/
