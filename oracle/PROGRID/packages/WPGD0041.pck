CREATE OR REPLACE PACKAGE PROGRID.WPGD0041 is
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0029
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Odirlei - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de relatorio de Avaliações.
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------*/
  
  TYPE typ_tprelsel IS VARRAY(3) OF VARCHAR2(30);
  vr_tab_tprelsel typ_tprelsel := typ_tprelsel('Cooperado','Cooperativa','Fornecedor');
  
  TYPE typ_tldatelaTAB IS VARRAY(3) OF VARCHAR2(50);
  vr_tab_tldatelaTAB typ_tldatelaTAB := typ_tldatelaTAB( 'Avaliação do Evento',
                                                         'Avaliação do PA',
                                                         'Avaliação do Fornecedor');  
    
  PROCEDURE pc_gera_relatorio_forn( pr_idevento   IN crapadp.idevento%TYPE,   --> indicador de evento
                                    pr_cdcooper   IN crapadp.cdcooper%TYPE,   --> Codigo da cooperativa
                                    pr_cdAgenci   IN crapadp.cdagenci%TYPE,   --> Codigo da agencia
                                    pr_dtanoage   IN crapadp.dtanoage%TYPE,   --> Ano agenda
                                    pr_nrseqdig   IN crapadp.nrseqdig%TYPE,   --> Sequencial unico do evento
                                    pr_tpdavali   IN INTEGER,                 --> Tipo de avaliações
                                    pr_cdevento   IN crapedp.cdevento%TYPE,   --> Codigo de evento
                                    pr_tprelato   IN crapgap.tprelgru%TYPE,    --> Tipo de agrupamento 0-Todos 
                                    pr_idsessao   IN gnapses.idsessao%TYPE,   --> Id da sessao
                                    pr_nmarqpdf  OUT VARCHAR2,                --> Retorna pdf gerado
                                    pr_cdcritic  OUT INTEGER,
                                    pr_dscritic  OUT VARCHAR2
                                    );
    
END WPGD0041;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0041 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0041
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Odirlei - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de relatorio de Avaliações.
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------*/
  --> Gerar relatorio de avaliação para envio para facilitador
  PROCEDURE pc_gera_relatorio_forn (pr_idevento   IN crapadp.idevento%TYPE,   --> indicador de evento
                                    pr_cdcooper   IN crapadp.cdcooper%TYPE,   --> Codigo da cooperativa
                                    pr_cdAgenci   IN crapadp.cdagenci%TYPE,   --> Codigo da agencia
                                    pr_dtanoage   IN crapadp.dtanoage%TYPE,   --> Ano agenda
                                    pr_nrseqdig   IN crapadp.nrseqdig%TYPE,   --> Sequencial unico do evento
                                    pr_tpdavali   IN INTEGER,                 --> Tipo de avaliações
                                    pr_cdevento   IN crapedp.cdevento%TYPE,   --> Codigo de evento
                                    pr_tprelato   IN crapgap.tprelgru%TYPE,   --> Tipo de agrupamento 0-Todos 
                                    pr_idsessao   IN gnapses.idsessao%TYPE,   --> Id da sessao
                                    pr_nmarqpdf  OUT VARCHAR2,                --> Retorna pdf gerado
                                    pr_cdcritic  OUT INTEGER,
                                    pr_dscritic  OUT VARCHAR2
                                    ) IS
          /* ..........................................................................
    --
    --  Programa : pc_gera_relatorio_forn
    --  Sistema  : Progrid
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Gerar relatorio de avaliações
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................*/
    
    ---------->> CURSORES <<------------
    --> Buscar nome agencia e coop
    CURSOR cr_crapage IS
      SELECT cop.nmrescop,
              decode(pr_cdagenci,0,'TODOS',age.nmresage) nmresage
        FROM crapcop cop
            ,crapage age
       WHERE cop.cdcooper = age.cdcooper(+)
         AND cop.cdcooper = pr_cdcooper
         AND age.cdagenci(+) = pr_cdagenci;          
    rw_crapage cr_crapage%ROWTYPE;
    
    --> buscar PAs agrupados
    CURSOR cr_crapagp IS
      SELECT crapage.nmresage
        FROM crapagp
            ,crapage
       WHERE crapagp.cdcooper = pr_cdcooper
         AND crapagp.dtanoage = pr_dtanoage
         AND crapagp.cdagenci <> crapagp.cdageagr
         AND crapagp.cdageagr = pr_cdagenci
         AND crapage.cdcooper = crapagp.cdcooper
         AND crapage.cdagenci = crapagp.cdagenci;
    
    --> Buscar facilitadores
    CURSOR cr_gnapfep(pr_idevento  crapcdp.idevento%TYPE,
                      pr_cdcooper  crapcdp.cdcooper%TYPE,
                      pr_cdagenci  crapcdp.cdagenci%TYPE,
                      pr_dtanoAge  crapcdp.dtanoage%TYPE,
                      pr_cdevento  crapcdp.cdevento%TYPE ) IS
      SELECT gnapfep.nmfacili
        FROM crapcdp
            ,gnappdp
            ,gnfacep
            ,gnapfep
       WHERE crapcdp.idevento = pr_idevento
         AND crapcdp.cdcooper = pr_cdcooper
         AND crapcdp.cdagenci = pr_cdagenci
         AND crapcdp.dtanoage = pr_dtanoAge
         AND crapcdp.tpcuseve = 1 /* direto */
         AND crapcdp.cdevento = pr_cdevento
         AND crapcdp.cdcuseve = 1 /* honorários */
            /* proposta do evento */
         AND gnappdp.idevento = crapcdp.idevento
         AND gnappdp.cdcooper = 0
         AND gnappdp.nrcpfcgc = crapcdp.nrcpfcgc
         AND gnappdp.nrpropos = crapcdp.nrpropos
            --> Localiza e trata facilitador 
         AND gnfacep.idevento = gnappdp.idevento
         AND gnfacep.cdcooper = 0
         AND gnfacep.nrcpfcgc = Gnappdp.nrcpfcgc
         AND gnfacep.nrpropos = Gnappdp.nrpropos
         AND gnapfep.idevento = gnfacep.idevento
         AND gnapfep.cdcooper = 0
         AND gnapfep.nrcpfcgc = gnfacep.nrcpfcgc
         AND gnapfep.cdfacili = gnfacep.cdfacili;

    
    --> Buscar dados do evento
    CURSOR cr_crapadp IS
      SELECT crapadp.dtinieve
            ,crapadp.nrmeseve
            ,crapadp.idevento
            ,crapedp.tpevento
            ,crapedp.nmevento
            ,crapadp.cdagenci
            ,crapadp.cdevento
            ,' LOCAL: '|| crapldp.dslocali dslocali
        FROM crapadp
            ,crapedp
            ,crapldp
       WHERE crapedp.idevento = crapadp.idevento
         AND crapedp.cdcooper = crapadp.cdcooper
         AND crapedp.dtanoage = crapadp.dtanoage
         AND crapedp.cdevento = crapadp.cdevento
         AND crapldp.idevento(+) = crapadp.idevento
         AND crapldp.cdcooper(+) = crapadp.cdcooper
         AND crapldp.cdagenci(+) = crapadp.cdagenci
         AND crapldp.nrseqdig(+) = crapadp.cdlocali
         AND crapadp.idevento = pr_idevento
         AND crapadp.cdcooper = pr_cdcooper
         AND (crapadp.nrseqdig = pr_nrseqdig OR
              nvl(pr_nrseqdig,0) = 0 AND crapadp.cdevento = pr_cdevento);
    rw_crapadp cr_crapadp%ROWTYPE;
    
    --> Buscar Respostas das avaliaçoes 
    CURSOR cr_craprap (pr_tprelato crapgap.tprelgru%TYPE ) IS
      SELECT crapgap.tpiteava,
             craprap.cdgruava,
             crapgap.dsgruava,
             crapiap.dsiteava,
             SUM(craprap.qtavares) qtavares,
             SUM(craprap.qtavaoti) qtavaoti,
             SUM(craprap.qtavabom) qtavabom,
             SUM(craprap.qtavareg) qtavareg,
             SUM(craprap.qtavains) qtavains                        
        FROM craprap
            ,crapgap
            ,crapiap
       WHERE craprap.idevento = pr_idevento
         AND craprap.cdcooper = pr_cdcooper
         AND craprap.cdagenci = nvl(nullif(pr_cdAgenci,0),craprap.cdagenci)
         AND craprap.dtanoage = pr_dtanoage
         AND ( craprap.nrseqeve = pr_nrseqdig OR 
              (pr_nrseqdig = 0 AND craprap.cdevento = pr_cdEvento )
             )
         --> Grupo de avaliaçoes
         AND crapgap.idevento = craprap.idevento
         AND crapgap.cdcooper = 0
         AND crapgap.cdgruava = craprap.cdgruava
         AND crapgap.tprelgru = pr_tprelato
         AND crapgap.tpiteava = 1 --> Item Alternativo
         --> Item de avaliaçoes 
         AND crapiap.idevento = craprap.idevento
         AND crapiap.cdcooper = 0
         AND crapiap.cdgruava = craprap.cdgruava
         AND crapiap.cditeava = craprap.cditeava
         GROUP BY crapgap.dsgruava
                 ,crapiap.dsiteava
                 ,crapgap.tprelgru
                 ,crapgap.tpiteava 
                 ,crapgap.nrordgru 
                 ,craprap.cdgruava
                 ,craprap.cditeava
         ORDER BY crapgap.tprelgru
                 ,crapgap.tpiteava 
                 ,crapgap.nrordgru 
                 ,craprap.cdgruava
                 ,craprap.cditeava;
    
    --> Respostas das avaliaçoes - Descritivas
    CURSOR cr_craprap_desc (pr_tprelato crapgap.tprelgru%TYPE ) IS
      SELECT crapgap.tpiteava,
             craprap.cdgruava,
             crapgap.dsgruava,
             crapiap.dsiteava,  
             craprap.dsobserv                        
        FROM craprap
            ,crapgap
            ,crapiap
       WHERE craprap.idevento = pr_idevento
         AND craprap.cdcooper = pr_cdcooper
         AND craprap.cdagenci = nvl(nullif(pr_cdAgenci,0),craprap.cdagenci)
         AND craprap.dtanoage = pr_dtanoage
         AND ( craprap.nrseqeve = pr_nrseqdig OR 
              (pr_nrseqdig = 0 AND craprap.cdevento = pr_cdEvento )
             )
         --> Grupo de avaliaçoes
         AND crapgap.idevento = craprap.idevento
         AND crapgap.cdcooper = 0
         AND crapgap.cdgruava = craprap.cdgruava
         AND crapgap.tprelgru = pr_tprelato
         AND crapgap.tpiteava = 2 --> Item Descritivo
         --> Item de avaliaçoes 
         AND crapiap.idevento = craprap.idevento
         AND crapiap.cdcooper = 0
         AND crapiap.cdgruava = craprap.cdgruava
         AND crapiap.cditeava = craprap.cditeava         
         ORDER BY crapgap.tprelgru
                 ,crapgap.tpiteava 
                 ,crapgap.nrordgru 
                 ,craprap.cdgruava
                 ,craprap.cditeava; 
    
    --> Buscar quantidade de participantes
    CURSOR cr_crapidp IS
      SELECT count(crapidp.nrdconta) qtinseve
        FROM crapidp
            ,Crapedp
            ,crapadp
       WHERE Crapedp.IdEvento = Crapidp.IdEvento
         AND Crapedp.CdCooper = Crapidp.CdCooper
         AND Crapedp.DtAnoAge = Crapidp.DtAnoAge
         AND Crapedp.CdEvento = Crapidp.CdEvento
         
         AND Crapedp.IdEvento = crapadp.IdEvento
         AND Crapedp.CdCooper = crapadp.CdCooper
         AND Crapedp.DtAnoAge = crapadp.DtAnoAge
         AND Crapedp.CdEvento = crapadp.CdEvento
         AND crapidp.cdagenci = crapadp.cdagenci
         
         AND crapidp.idevento = pr_idevento
         AND crapidp.cdcooper = pr_cdcooper
         AND crapidp.dtanoage = pr_dtanoage
         AND crapidp.cdagenci = nvl(NULLIF(pr_cdAgenci, 0), crapidp.cdagenci)
         AND ( crapidp.nrseqeve = pr_nrseqdig OR 
              (pr_nrseqdig = 0 AND crapidp.cdevento = pr_cdEvento )
             )         
         --> Apenas confirmados
         AND Crapidp.IdStaIns = 2
         --> Evento nao cancelado
         AND Crapadp.idstaeve <> 2         
         --> Desconsiderar os que não atingiram a quantidade minima de frequencia
         AND ((crapidp.qtfaleve * 100) / Crapadp.QtDiaEve) <= (100 - crapedp.prfreque);
    rw_crapidp cr_crapidp%ROWTYPE;
    
    --------->> VARIAVEIS <<------------
    vr_exc_erro    EXCEPTION;
    vr_cdcritic    INTEGER;
    vr_dscritic    VARCHAR2(1000);
    
    vr_cdagruava   INTEGER;
    vr_nrdoitem    INTEGER;
    vr_nrtopico    INTEGER;
    vr_qtavanre    INTEGER;
    vr_tprelat_ini INTEGER;
    vr_tprelat_fim INTEGER;
    vr_dtinieve    VARCHAR2(50);
    vr_nmresage    VARCHAR2(1000);
    vr_nmfacili    VARCHAR2(1000);
    
    vr_dsimglog    VARCHAR2(2000);
    vr_dsdireto    VARCHAR2(4000);
    vr_cdprogra    crapprg.cdprogra%TYPE := 'wpgd0041';
    
    -- Variáveis para armazenar as informações em XML    
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
    --> Calcular percentual
    FUNCTION fn_calc_percent(pr_qtdoitem IN INTEGER,
                             pr_qtavares IN INTEGER) RETURN VARCHAR2 IS
    BEGIN
      IF nvl(pr_qtdoitem,0) > 0 AND pr_qtavares > 0 THEN
         RETURN to_char((pr_qtdoitem * 100) / pr_qtavares,'fm990D00')|| '%';
      ELSE
        RETURN NULL;
      END IF;      
    END fn_calc_percent;
    
    
  BEGIN
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);    
    vr_txtcompl := NULL;
    
    --> Buscar nome agencia e coop
    OPEN cr_crapage;
    FETCH cr_crapage INTO rw_crapage;
    CLOSE cr_crapage;
    
    --> Buscar dados do evento
    OPEN cr_crapadp;
    FETCH cr_crapadp INTO rw_crapadp;
    CLOSE cr_crapadp;
    
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');    
    
    
    --> Buscar quantidade de participantes
    rw_crapidp := NULL;
    OPEN cr_crapidp;
    FETCH cr_crapidp INTO rw_crapidp;
    CLOSE cr_crapidp;    
    
    vr_nmresage := rw_crapage.nmresage;
    
    IF pr_cdagenci = 0 THEN
      vr_nmresage := 'TODOS OS PA''S';
      vr_dtinieve := 'TODAS AS OCORRENCIAS';
    ELSIF pr_nrseqdig = 0   THEN
      vr_dtinieve := 'TODAS AS OCORRENCIAS';
    ELSIF rw_crapadp.dtinieve IS NULL   THEN
      vr_dtinieve := gene0001.vr_vet_nmmesano(rw_crapadp.nrmeseve);
    ELSE 
      vr_dtinieve := to_char(rw_crapadp.dtinieve,'DD/MM/RRRR');
    END IF;
    
    --> Se for PROGRID, verifica se há PA's agrupados 
    IF rw_crapadp.idevento = 1 THEN
      FOR rw_crapagp IN cr_crapagp LOOP
        vr_nmresage := vr_nmresage ||' / ' || rw_crapagp.nmresage;
      END LOOP;
    END IF;
    
    --> Buscar facilitadores
    FOR rw_gnapfep IN cr_gnapfep (pr_idevento => rw_crapadp.idevento,
                                  pr_cdcooper => pr_cdcooper,
                                  pr_cdagenci => rw_crapadp.cdagenci,
                                  pr_dtanoAge => pr_dtanoAge,
                                  pr_cdevento => rw_crapadp.cdevento  )LOOP
      IF vr_nmfacili IS NULL THEN
        vr_nmfacili := ' FACILITADOR(ES): '|| rw_gnapfep.nmfacili;
      ELSE
        vr_nmfacili := vr_nmfacili ||', ' || rw_gnapfep.nmfacili;
      END IF;  
    END LOOP;
    
    pc_escreve_xml(
                   '<dtanoage>'|| pr_dtanoage         || '</dtanoage>' ||
                   '<nmrescop>'|| rw_crapage.nmrescop || '</nmrescop>' ||
                   '<nmresage>'|| vr_nmresage         || '</nmresage>' ||
                   '<dtinieve>'|| vr_dtinieve         || '</dtinieve>' ||
                   '<nmfacili>'|| vr_nmfacili         || '</nmfacili>' ||
                   '<dslocali>'|| rw_crapadp.dslocali || '</dslocali>' ||
                   '<nmevento>'|| prgd0002.fn_desc_tpevento(pr_tpevento => rw_crapadp.tpevento) 
                                  || ': '|| rw_crapadp.nmevento || '</nmevento>'
                   );
    
    --> Gerar relatorio para todos os tipos de relatorio
    IF pr_tprelato = 0 THEN
      vr_tprelat_ini := 1;
      vr_tprelat_fim := 3;
    ELSE
      vr_tprelat_ini := pr_tprelato;
      vr_tprelat_fim := pr_tprelato;
    END IF;
    
    FOR vr_tprelato IN vr_tprelat_ini..vr_tprelat_fim LOOP
       
      -- Inicializar variaveis de controle
      vr_cdagruava := 0;  
      vr_nrdoitem  := 0;
      vr_nrtopico  := 0;
      pc_escreve_xml('<tprelato tprelato="' ||vr_tab_tprelsel(vr_tprelato)||'"
                                dstitulo="' ||vr_tab_tldatelaTAB(vr_tprelato)||'">');
      
      pc_escreve_xml('<alternativo qtinseve="'|| rw_crapidp.qtinseve || '" ');
      
      --> Buscar Respostas das avaliaçoes Alternativo
      FOR rw_craprap IN cr_craprap (pr_tprelato => vr_tprelato) LOOP
        
        --> Reiniciar nó
        IF rw_craprap.cdgruava <> vr_cdagruava THEN
          --> caso não seja o primeiro, deve fechar tag
          IF vr_cdagruava <> 0 THEN
            pc_escreve_xml('</grupo>');
          ELSE
            --> para o primeiro registro, enviar a qtd de avaliacoes respondidos
            pc_escreve_xml('qtavares="'|| rw_craprap.qtavares ||'" >'); 
          END IF;
            
          vr_nrdoitem  := vr_nrdoitem + 1;
          vr_cdagruava := rw_craprap.cdgruava;
          pc_escreve_xml('<grupo dsgruava="'||to_char(vr_nrdoitem,'FMRM')||' - '||rw_craprap.dsgruava||'">');        
          vr_nrtopico := 0;
        END IF;
          
        --> Quantidade nao respondida
        vr_qtavanre := nvl(rw_craprap.qtavares,0) - ( nvl(rw_craprap.qtavaoti,0) + nvl(rw_craprap.qtavabom,0) +
                                                      nvl(rw_craprap.qtavareg,0) + nvl(rw_craprap.qtavains,0));
          
        vr_nrtopico := vr_nrtopico + 1;
        pc_escreve_xml('<item>
                           <dsiteava>'|| vr_nrtopico || ') '|| rw_craprap.dsiteava                ||'</dsiteava>'||
                          '<prcqtoti>'|| fn_calc_percent(rw_craprap.qtavaoti,rw_craprap.qtavares) ||'</prcqtoti>'||
                          '<prcqtbom>'|| fn_calc_percent(rw_craprap.qtavabom,rw_craprap.qtavares) ||'</prcqtbom>'||
                          '<prcqtreg>'|| fn_calc_percent(rw_craprap.qtavareg,rw_craprap.qtavares) ||'</prcqtreg>'||
                          '<prcqtins>'|| fn_calc_percent(rw_craprap.qtavains,rw_craprap.qtavares) ||'</prcqtins>'||
                          '<prcqtnre>'|| fn_calc_percent(vr_qtavanre        ,rw_craprap.qtavares) ||'</prcqtnre>'||
                       '</item>'
                      );                    
          
      END LOOP;
      
      IF vr_nrtopico > 0 THEN
        pc_escreve_xml('</grupo>'); 
      ELSE
        -- Fechar tag inicial alternativa, caso nao tenha incluido no loop
        pc_escreve_xml('qtavares="0" >'); 
      END IF;
      
      pc_escreve_xml('</alternativo>'); 
      
      -- Inicializar variaveis de controle
      vr_cdagruava := 0;  
      vr_nrdoitem  := 0;
      vr_nrtopico  := 0;
      pc_escreve_xml('<descritiva>');
      
      --> Buscar Respostas das avaliaçoes descritivas
      FOR rw_craprap_desc IN cr_craprap_desc(pr_tprelato => vr_tprelato) LOOP      
        
        --> Reiniciar nó
        IF rw_craprap_desc.cdgruava <> vr_cdagruava THEN
          --> caso não seja o primeiro, deve fechar tag
          IF vr_cdagruava <> 0 THEN
            pc_escreve_xml('</grupo>');
          END IF;
            
          vr_nrdoitem  := vr_nrdoitem + 1;
          vr_cdagruava := rw_craprap_desc.cdgruava;
          pc_escreve_xml('<grupo dsgruava="'||rw_craprap_desc.dsgruava||'">');        
          vr_nrtopico := 0;
        END IF;                      
          
        vr_nrtopico := vr_nrtopico + 1;
        pc_escreve_xml('<item>
                           <dsiteava>'|| rw_craprap_desc.dsiteava                ||'</dsiteava>'||
                          '<dsobserv>'|| rw_craprap_desc.dsobserv ||'</dsobserv>'||                        
                       '</item>');
          
      END LOOP;
      
      IF vr_nrtopico > 0 THEN
        pc_escreve_xml('</grupo>'); 
      END IF;
      
      pc_escreve_xml('</descritiva>');            
      
      pc_escreve_xml('</tprelato>');
      
    END LOOP;
    
    pc_escreve_xml('</raiz>',TRUE);    
    
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    pr_nmarqpdf := 'rpgd0041a_'|| pr_idsessao ||'.pdf';
    pr_nmarqpdf := vr_dsdireto ||'/rl/'||pr_nmarqpdf;
    
    --> Buscar parametros de logo para relatorio
    vr_dsimglog := prgd0002.fn_prm_logo_relat(pr_cdcooper => pr_cdcooper,
                                              pr_nmrescop => rw_crapage.nmrescop);
    
    vr_dsimglog := vr_dsimglog ||'PR_CDPROGRA##'||vr_cdprogra||'@@';
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => vr_cdprogra
                               , pr_dtmvtolt  => trunc(SYSDATE)
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz/tprelato'
                               , pr_dsjasper  => 'rpgd0041.jasper'
                               , pr_dsparams  => vr_dsimglog
                               , pr_dsarqsaid => pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_cdrelato  => 1
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;  
    
    
    COMMIT;         
  EXCEPTION
    WHEN vr_exc_erro THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;


    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em PC_WPGD0041.pc_gera_relatorio_forn: ' || SQLERRM;      
  
  END pc_gera_relatorio_forn;
END WPGD0041;
/
