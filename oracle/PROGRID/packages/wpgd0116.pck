CREATE OR REPLACE PACKAGE PROGRID.WPGD0116 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0116
  --  Sistema  : Rotinas para geração Relatório de Material de Divulgação
  --  Sigla    : WPGD
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Junho/2016.                   Ultima atualizacao:  15/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de Material de Divulgação
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geração do relatorio da tela WPGD0116 - Relatório de Material de Divulgação 
  PROCEDURE pc_relat_wpgd0116( pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                              ,pr_dtanoage       IN VARCHAR2              --> Ano da agenda informado
                              ,pr_dtmesrel       IN VARCHAR2              --> Mes para o relatorio informado
                              ,pr_idevento       IN crapedp.idevento%TYPE --> Id do evento(tipo)
                              ,pr_nriniseq       IN PLS_INTEGER           --> Sequencia inicial da busca
                              ,pr_qtregist       IN PLS_INTEGER           --> Qtd de registros da busca
                              ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro      OUT VARCHAR2);            --> Erros do processo

END WPGD0116;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0116 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0116
  --  Sistema  : Rotinas para geração Relatório de Material de Divulgação
  --  Sigla    : WPGD
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Junho/2016.                   Ultima atualizacao:  15/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: 
  -- Objetivo  : Rotinas para geração Relatório de Material de Divulgação
  --
  -- Alteracoes: 
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geração do relatorio da tela WPGD0116 - Relatório de Material de Divulgação 
  PROCEDURE pc_relat_wpgd0116( pr_cdcooper       IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa informada
                              ,pr_dtanoage       IN VARCHAR2              --> Ano da agenda informado
                              ,pr_dtmesrel       IN VARCHAR2              --> Mes para o relatorio informado
                              ,pr_idevento       IN crapedp.idevento%TYPE --> Id do evento(tipo)
                              ,pr_nriniseq       IN PLS_INTEGER           --> Sequencia inicial da busca
                              ,pr_qtregist       IN PLS_INTEGER           --> Qtd de registros da busca
                              ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic      OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic      OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                              ,pr_nmdcampo      OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro      OUT VARCHAR2) IS          --> Erros do processo
  
    /* ..........................................................................
    --
    --  Programa : pc_relat_wpgd0116
    --  Sistema  : Rotinas para tela cadastro de sugestão de produto
    --  Sigla    : WPGD
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Junho/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina geração do relatorio da tela WPGD0116 - Relatório de Material de Divulgação 
    --
    --  Alteracoes: 
    -- .............................................................................*/

      -- Buscar eventos
      CURSOR cr_evento is
        SELECT ct.dseixtem
              ,decode(c.dtinieve,null,'Data à definir - '
                                ,c.dtfineve, to_char(c.dtinieve,'DD/MM/YYYY') ||' - '
                                ,to_char(c.dtinieve,'DD/MM/YYYY') || ' à ' || 
                                 to_char(c.dtfineve,'DD/MM/YYYY')||' - ') ||
               DECODE(ce.tpevento,1,' CURSO',
                                  2,' INTEGRACAO',
                                  3,' GINCANA',
                                  4,' PALESTRA',
                                  5,' TEATRO',
                                  6,' OUTROS',
                                  7,' ASSEMBLEIA',
                                  8,' PRE-ASSEMBLEIA',
                                  9,' PROGRAMA',ce.tpevento) 
                                  || ': ' || ce.nmevento || ' - <b>' || ca.nmresage|| '</b>' Evento
              ,ca.cdagenci
              ,c.dtinieve
              ,replace(
                      replace(
                      replace(
                      replace(
                      replace(
                      replace(
                      replace(c.dsdiaeve,0,'DOMINGO')
                      ,1,'SEGUNDA-FEIRA')
                      ,2,'TERÇA-FEIRA')
                      ,3,'QUARTA-FEIRA')
                      ,4,'QUINTA-FEIRA')
                      ,5,'SEXTA-FEIRA')
                      ,6,'SÁBADO') Dias
              ,c.cdlocali
              ,cl.dslocali LOCAL
              ,decode(cl.dsendloc||cl.nmbailoc,NULL,NULL,cl.dsendloc || ' - ' || cl.nmbailoc || ' - ' || cl.nmcidloc) Endereco
              ,c.dshroeve Horario
              ,gp.dsconteu Conteu_Propos
              ,gf.nmfacili || ' - ' || gf.dscurric Facilitador
              ,ca.nmresage || ' / ' || decode(trim(ca.nrtelvoz),NULL,'Telefone não cadastrado', ca.nrtelvoz) Telefone
              ,
               -- Campos usados para buscar informações de recursos
               c.idevento
              ,c.cdcooper
              ,c.dtanoage              
              ,c.cdevento
              ,cc.nrcpfcgc
              ,cc.nrpropos
              ,ce.tpevento
          FROM crapadp c
              ,crapedp ce
              ,gnapetp ct
              ,crapage ca
              ,crapldp cl
              ,crapcdp cc
              ,gnappdp gp
              ,gnfacep gc
              ,gnapfep gf
         WHERE c.idevento = pr_idevento
           AND c.dtanoage = pr_dtanoage 
           AND c.cdcooper = pr_cdcooper 
           AND c.nrmeseve = pr_dtmesrel 
           AND c.idstaeve IN (1, 3, 6) --1 - AGENDADO, 3 - TRANSFERIDO, 6 - ACRESCIDO 
           AND ce.idevento = c.idevento
           AND ce.cdcooper = c.cdcooper
           AND ce.dtanoage = c.dtanoage
           AND ce.cdevento = c.cdevento
           AND ce.tpevento NOT IN (10, 11) -- Eventos EAD
           AND ct.idevento = ce.idevento
           AND ct.cdcooper = 0
           AND ct.cdeixtem = ce.cdeixtem
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
           and cc.tpcuseve(+) = 1
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
         ORDER BY ct.dseixtem
                 ,ce.nmevento
                 ,ca.nmresage
                 ,c.dtinieve;
                 
      --> Buscar recursos 
      CURSOR cr_recurso( pr_idevento   IN craprpe.idevento%TYPE, 
                         pr_cdcooper   IN craprpe.cdcooper%TYPE,
                         pr_cdagenci   IN craprpe.cdagenci%TYPE, 
                         pr_cdevento   IN craprpe.cdevento%TYPE, 
                         pr_fornecedor IN craprdf.nrcpfcgc%TYPE, 
                         pr_proposta   IN craprdf.dspropos%TYPE) IS
          SELECT g.idevento
                ,g.cdcooper
                ,g.nrseqdig
                ,g.dsrecurs
            FROM craprep cr
                ,gnaprdp g
           WHERE g.idevento = cr.idevento
             AND g.cdcooper = cr.cdcooper
             AND g.nrseqdig = cr.nrseqdig
             AND g.idsitrec = 1
             AND g.cdtiprec = 2 -- Divulgação
             AND cr.idevento = pr_idevento
             AND cr.cdcooper = 0
             AND cr.cdevento = pr_cdevento
          UNION ALL
          SELECT g.idevento
                ,g.cdcooper
                ,g.nrseqdig
                ,g.dsrecurs
            FROM craprpe cp
                ,gnaprdp g
           WHERE g.idevento = cp.idevento
             AND g.cdcooper = cp.cdcooper
             AND g.nrseqdig = cp.nrseqdig
             AND g.idsitrec = 1
             AND g.cdtiprec = 2 -- Divulgação
             AND cp.idevento = pr_idevento
             AND cp.cdcooper = 0
             AND cp.cdcopage = pr_cdcooper
             AND cp.cdagenci = pr_cdagenci
             AND cp.cdevento = pr_cdevento
          UNION ALL
          SELECT g.idevento
                ,g.cdcooper
                ,g.nrseqdig
                ,g.dsrecurs
            FROM craprdf cf
                ,gnaprdp g
           WHERE g.idevento = cf.idevento
             AND g.cdcooper = cf.cdcooper
             AND g.nrseqdig = cf.nrseqdig
             AND g.idsitrec = 1
             AND g.cdtiprec = 2 -- Divulgação
             AND cf.idevento = pr_idevento
             AND cf.cdcooper = 0
             AND cf.nrcpfcgc = pr_fornecedor
             AND cf.dspropos = pr_proposta;
                 
      --> buscar quantidade de recurso
      CURSOR cr_crapqmd (pr_dtanoage   crapqmd.dtanoage%TYPE,
                         pr_cdcopqtd   crapqmd.cdcopqtd%TYPE,
                         pr_cdagenci   crapqmd.cdagenci%TYPE,
                         pr_tpevento   crapqmd.tpevento%TYPE,
                         pr_idevento   crapqmd.idevento%TYPE,   
                         pr_cdcooper   crapqmd.cdcooper%TYPE,                      
                         pr_nrseqdig   crapqmd.nrseqdig%TYPE) IS 
        SELECT qmd.qtrecnes
          FROM crapqmd qmd
         WHERE qmd.dtanoage = pr_dtanoage
           AND qmd.cdcopqtd = pr_cdcopqtd
           AND qmd.cdagenci = pr_cdagenci
           AND qmd.tpevento = pr_tpevento
           AND qmd.idevento = pr_idevento
           AND qmd.cdcooper = pr_cdcooper
           AND qmd.nrseqdig = pr_nrseqdig;
      rw_crapqmd cr_crapqmd%ROWTYPE;
      
                 
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
      vr_dseixaux  VARCHAR2(200) := NULL;
      vr_contador PLS_INTEGER := 0;
      vr_totregis PLS_INTEGER := 0;
      vr_nrseqpdp crappdp.nrseqpdp%TYPE;
      VR_EXISTE_PROPOSTA  NUMBER:=0;
      vr_dsxml_recurso VARCHAR2(20000);
      
      TYPE vr_typ_recursos IS TABLE OF NUMBER
         INDEX BY VARCHAR2(200);         
      vr_tab_recursos vr_typ_recursos;    
      vr_idx VARCHAR2(200);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      vr_texto_completo  VARCHAR2(32600); 
      aux INTEGER;
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
      vr_dsdstyle := 'style="font-family: Arial, Helvetica, sans-serif;font-size: 9px;margin: 0 0;padding-right:5px; word-wrap: break-word;"';
      
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');
      aux := 0;
      FOR rw_evento in cr_evento LOOP
        
        --> Buscar primeiro os recursos para apenas apresentar os eventos
        -- que possuem recurso
        vr_dsxml_recurso := NULL;
        --> buscar recursos
        FOR rw_recurso IN cr_recurso(pr_idevento   => rw_evento.idevento, 
                                     pr_cdcooper   => rw_evento.cdcooper, 
                                     pr_cdagenci   => rw_evento.cdagenci, 
                                     pr_cdevento   => rw_evento.cdevento, 
                                     pr_fornecedor => rw_evento.nrcpfcgc, 
                                     pr_proposta   => rw_evento.nrpropos) LOOP
          
          --> buscar quantidade de recurso
          rw_crapqmd := NULL;
          OPEN cr_crapqmd (pr_dtanoage  => rw_evento.dtanoage,
                           pr_cdcopqtd  => rw_evento.cdcooper,
                           pr_cdagenci  => rw_evento.cdagenci,
                           pr_tpevento  => rw_evento.tpevento,
                           pr_idevento  => rw_recurso.idevento,                           
                           pr_cdcooper  => rw_recurso.cdcooper,
                           pr_nrseqdig  => rw_recurso.nrseqdig );
          FETCH cr_crapqmd INTO rw_crapqmd;
          CLOSE cr_crapqmd;
          
           vr_dsxml_recurso := vr_dsxml_recurso ||
                               '<recurso>'||
                                  '<dsrecurs><![CDATA[Quantidade de '||gene0007.fn_acento_xml(rw_recurso.dsrecurs)
                                            ||': '||nvl(rw_crapqmd.qtrecnes,0)||
                                  ']]></dsrecurs>'||                            
                                '</recurso> ';
                          
           IF vr_tab_recursos.exists(rw_recurso.dsrecurs) THEN
             vr_tab_recursos(rw_recurso.dsrecurs) := vr_tab_recursos(rw_recurso.dsrecurs) + nvl(rw_crapqmd.qtrecnes,0) ;
           ELSE
             vr_tab_recursos(rw_recurso.dsrecurs) := nvl(rw_crapqmd.qtrecnes,0); 
           END IF;
           
        END LOOP;
        
        --> Apenas apresentar os eventos que possuam material de divulgação
        IF vr_dsxml_recurso IS NOT NULL THEN
        
          -- Verificar se mudou o eixo
          IF nvl(vr_dseixaux,' ') <> rw_evento.dseixtem THEN
            -- se nao for o primeiro é necessario fechar o ja aberto
            IF vr_dseixaux IS NOT NULL THEN
              pc_escreve_xml('</eventos></eixo>');
            END IF;
            -- iniciar novo nó
            pc_escreve_xml('<eixo>');            
            aux := aux +1;
            pc_escreve_xml('<dseixtem><![CDATA['||gene0007.fn_acento_xml(rw_evento.dseixtem)||']]></dseixtem>
                            <eventos>');
            vr_dseixaux:= rw_evento.dseixtem;
          END IF;
          
          pc_escreve_xml('<evento> '||
                           ' <NMEVENTO><![CDATA['||gene0007.fn_acento_xml(rw_evento.evento)   ||']]></NMEVENTO>   '||    
                           ' <Dias>    <![CDATA['||gene0007.fn_acento_xml(rw_evento.Dias )    ||']]></Dias>     '||      
                           ' <Local>   <![CDATA['||gene0007.fn_acento_xml(rw_evento.Local)    ||']]></Local>    '||      
                           ' <Endereco><![CDATA['||gene0007.fn_acento_xml(rw_evento.Endereco) ||']]></Endereco> '||      
                           ' <Horario> <![CDATA['||gene0007.fn_acento_xml(rw_evento.Horario)  ||']]></Horario>  '||      
                           ' <Telefone><![CDATA['||gene0007.fn_acento_xml(rw_evento.Telefone) ||']]></Telefone> '||       
                           ' <Conteudo>    <![CDATA[<pre '||vr_dsdstyle||'>'||
                                                      gene0007.fn_acento_xml(rw_evento.Conteu_Propos)  ||
                                                    '</pre>]]></Conteudo> '||         
                           ' <Facilitador> <![CDATA[<pre '||vr_dsdstyle||'>'||
                                                      gene0007.fn_acento_xml(rw_evento.Facilitador )   ||
                                                    '</pre>]]></Facilitador>
                           <recursos>');  

          -- listar os recursos
          pc_escreve_xml(vr_dsxml_recurso);  
                
          pc_escreve_xml('</recursos></evento> ');
        END IF;  
 
      END LOOP; 
      
      -- se abriu o nó, é necessario fecha-lo
      IF vr_dseixaux IS NOT NULL THEN
        pc_escreve_xml('</eventos></eixo>');
      END IF;
      
      IF vr_tab_recursos.count() > 0 THEN
        --> Carregar totais
        pc_escreve_xml('<totais>');
        
        vr_idx :=  vr_tab_recursos.first;
        WHILE vr_idx IS NOT NULL LOOP
          pc_escreve_xml('<recurso>
                            <dstotrec><![CDATA[Total de '||gene0007.fn_acento_xml(vr_idx)
                                        ||': '||nvl(vr_tab_recursos(vr_idx),0)||
                           ']]></dstotrec>'||
                          '</recurso>');

          vr_idx := vr_tab_recursos.next(vr_idx);
        END LOOP; 
        pc_escreve_xml('</totais>');
      END IF;
      
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
  END pc_relat_wpgd0116;

-----------------------------------------------------                       
END WPGD0116;
/
