CREATE OR REPLACE PACKAGE progrid.wpgd0018 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0018
  --  Sistema  : Rotinas para tela de Custos Orcados
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Outubro/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotinas para tela de Custos Orcados.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de calculo de custos orcados
  PROCEDURE pc_calcula_custo_orcado(pr_cdcooper IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_cdagenci IN VARCHAR2              --> Codigo do PA
                                   ,pr_agerepli IN VARCHAR2              --> Codigo dos PA's para replicacao
                                   ,pr_dtanoage IN crapppc.dtanoage%TYPE --> Ano Agenda
                                   ,pr_idevento IN crapedp.idevento%TYPE --> ID do Evento
                                   ,pr_cdevento IN crapedp.cdevento%TYPE --> Codigo do Evento
                                   ,pr_cdoperad IN crapppc.cdoperad%TYPE --> Codigo do Operador
                                   ,pr_vlrhonor IN crapcdp.vlcuseve%TYPE --> Valor de Honorarios
                                   ,pr_vloutros IN crapcdp.vlcuseve%TYPE --> Valor de Outros Gastos
                                   ,pr_idcokses IN gnapses.idsessao%TYPE --> ID da sessao
                                   ,pr_dscritic OUT CLOB);               --> Descrição da crítica

END wpgd0018;
/
CREATE OR REPLACE PACKAGE BODY progrid.wpgd0018 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0018
  --  Sistema  : Rotinas para tela de Custos Orcados
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Outubro/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : Rotinas para tela de Custos Orcados.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de calculo de custos orcados
  PROCEDURE pc_calcula_custo_orcado(pr_cdcooper IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                                   ,pr_cdagenci IN VARCHAR2              --> Codigo do PA
                                   ,pr_agerepli IN VARCHAR2              --> Codigo dos PA's para replicacao
                                   ,pr_dtanoage IN crapppc.dtanoage%TYPE --> Ano Agenda
                                   ,pr_idevento IN crapedp.idevento%TYPE --> ID do Evento
                                   ,pr_cdevento IN crapedp.cdevento%TYPE --> Codigo do Evento
                                   ,pr_cdoperad IN crapppc.cdoperad%TYPE --> Codigo do Operador
                                   ,pr_vlrhonor IN crapcdp.vlcuseve%TYPE --> Valor de Honorarios
                                   ,pr_vloutros IN crapcdp.vlcuseve%TYPE --> Valor de Outros Gastos
                                   ,pr_idcokses IN gnapses.idsessao%TYPE --> ID da sessao
                                   ,pr_dscritic OUT CLOB) IS             --> Descrição da crítica 
      
    -- Consulta de eventos por cooperativa
    CURSOR cr_crapedp_I(pr_cdcooper crapedp.cdcooper%TYPE
                       ,pr_dtanoage crapedp.dtanoage%TYPE
                       ,pr_cdevento crapedp.cdevento%TYPE) IS
      SELECT 1 AS indice, edp.qtdiaeve
        FROM crapedp edp
       WHERE edp.cdcooper = pr_cdcooper
         AND edp.dtanoage = pr_dtanoage
         AND edp.cdevento = pr_cdevento
      UNION
      SELECT 2 AS indice, edp.qtdiaeve
        FROM crapedp edp
       WHERE edp.cdcooper = 0
         AND edp.dtanoage = 0
         AND edp.cdevento = pr_cdevento
       ORDER BY indice;
  
    rw_crapedp_I cr_crapedp_I%ROWTYPE;

    CURSOR cr_crapedp_II(pr_idevento crapedp.idevento%TYPE
                        ,pr_cdcooper crapedp.cdcooper%TYPE
                        ,pr_dtanoage crapedp.dtanoage%TYPE
                        ,pr_cdevento crapedp.cdevento%TYPE) IS

      SELECT edp.qtmaxtur
            ,edp.tpevento
        FROM crapedp edp
       WHERE edp.idevento = pr_idevento
         AND edp.cdcooper = pr_cdcooper
         AND edp.dtanoage = pr_dtanoage
         AND edp.cdevento = pr_cdevento;
  
    rw_crapedp_II cr_crapedp_II%ROWTYPE;
  
    CURSOR cr_crapage_I(pr_cdcooper crapage.cdcooper%TYPE
                       ,pr_cdagenci VARCHAR2) IS
    
      SELECT age.cdagenci
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci NOT IN (90, 91)
         AND (gene0002.fn_existe_valor(pr_cdagenci,
                                       to_char(age.cdagenci),
                                       ',') = 'S' OR pr_cdagenci = '0')
         AND age.insitage = 1
         AND age.flgdopgd = 1;
  
    rw_crapage_I cr_crapage_I%ROWTYPE;
  
    CURSOR cr_crapage_II(pr_cdcooper crapage.cdcooper%TYPE
                        ,pr_cdagenci VARCHAR2) IS
    
      SELECT age.cdagenci, age.nmresage, age.cdufdcop, age.nmcidade
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.insitage IN (1,3) -- Ativo , Temporariamente Indisponivel
         AND age.flgdopgd = 1
         AND (pr_cdagenci = 0 OR age.cdagenci = pr_cdagenci)
       ORDER BY age.nmresage;
  
    rw_crapage_II cr_crapage_II%ROWTYPE;
  
    CURSOR cr_crapagp_I(pr_idevento crapagp.idevento%TYPE
                       ,pr_cdcooper crapagp.cdcooper%TYPE
                       ,pr_dtanoage crapagp.dtanoage%TYPE
                       ,pr_cdagenci crapagp.cdagenci%TYPE) IS
      SELECT agp.idevento,
             agp.cdcooper,
             agp.dtanoage,
             agp.cdagenci,
             agp.cdageagr
        FROM crapagp agp
       WHERE agp.idevento = pr_idevento
         AND agp.cdcooper = pr_cdcooper
         AND agp.dtanoage = pr_dtanoage
         AND agp.cdagenci = pr_cdagenci;
  
    rw_crapagp_I cr_crapagp_I%ROWTYPE;
  
    CURSOR cr_crapagp_II(pr_idevento crapagp.idevento%TYPE,
                         pr_cdcooper crapagp.cdcooper%TYPE,
                         pr_dtanoage crapagp.dtanoage%TYPE,
                         pr_cdagenci crapagp.cdagenci%TYPE) IS
    
      SELECT age.nmresage
        FROM crapagp agp
        JOIN crapage age
          ON age.cdagenci = agp.cdagenci
       WHERE agp.idevento = pr_idevento
         AND agp.cdcooper = pr_cdcooper
         AND agp.dtanoage = pr_dtanoage
         AND agp.cdageagr = pr_cdagenci
         AND agp.cdagenci <> pr_cdagenci
       ORDER BY age.nmresage;
  
    rw_crapagp_II cr_crapagp_II%ROWTYPE;
  
    CURSOR cr_crapcdp_I(pr_cdcooper crapcdp.cdcooper%TYPE,
                        pr_dtanoage crapcdp.dtanoage%TYPE,
                        pr_cdevento crapcdp.cdevento%TYPE,
                        pr_idevento crapcdp.idevento%TYPE,
                        pr_cdagenci VARCHAR2,
                        pr_tpcuseve crapcdp.tpcuseve%TYPE) IS
    
      SELECT cdp.nrcpfcgc,
             cdp.nrpropos,
             cdp.nrdocfmd,
             cdp.cdevento,
             cdp.idevento,
             cdp.cdcooper,
             cdp.dtanoage,
             cdp.cdcuseve,
             cdp.dsjustif,
             cdp.tpcuseve,
             cdp.qtditens,
             cdp.prdescon
        FROM crapcdp cdp
       WHERE cdp.cdevento = pr_cdevento
         AND cdp.idevento = pr_idevento
         AND (gene0002.fn_existe_valor(pr_cdagenci,
                                       to_char(cdp.cdagenci),
                                       ',') = 'S' OR pr_cdagenci = '0')
         AND cdp.cdcooper = pr_cdcooper
         AND cdp.dtanoage = pr_dtanoage
         AND cdp.tpcuseve = pr_tpcuseve;
  
    rw_crapcdp_I cr_crapcdp_I%ROWTYPE;
  
    CURSOR cr_crapcdp_II(pr_cdcooper crapcdp.cdcooper%TYPE,
                         pr_dtanoage crapcdp.dtanoage%TYPE,
                         pr_cdevento crapcdp.cdevento%TYPE,
                         pr_idevento crapcdp.idevento%TYPE,
                         pr_cdagenci crapcdp.cdagenci%TYPE,
                         pr_tpcuseve crapcdp.tpcuseve%TYPE,
                         pr_cdcuseve crapcdp.cdcuseve%TYPE) IS
    
      SELECT cdp.nrcpfcgc, cdp.nrpropos, cdp.nrdocfmd, cdp.flgfecha, ROWID
        FROM crapcdp cdp
       WHERE cdp.cdevento = pr_cdevento
         AND cdp.idevento = pr_idevento
         AND cdp.cdagenci = pr_cdagenci
         AND cdp.tpcuseve = pr_tpcuseve
         AND cdp.cdcooper = pr_cdcooper
         AND cdp.dtanoage = pr_dtanoage
         AND cdp.cdcuseve = pr_cdcuseve;
  
    rw_crapcdp_II cr_crapcdp_II%ROWTYPE;
  
    CURSOR cr_crapcdp_III(pr_cdcooper crapcdp.cdcooper%TYPE,
                          pr_dtanoage crapcdp.dtanoage%TYPE,
                          pr_cdevento crapcdp.cdevento%TYPE,
                          pr_idevento crapcdp.idevento%TYPE,
                          pr_cdagenci VARCHAR2,
                          pr_tpcuseve crapcdp.tpcuseve%TYPE) IS
    
      SELECT cdp.nrcpfcgc, cdp.nrpropos, cdp.nrdocfmd
        FROM crapcdp cdp
       WHERE cdp.cdevento = pr_cdevento
         AND cdp.idevento = pr_idevento
         AND gene0002.fn_existe_valor(pr_cdagenci,
                                      to_char(cdp.cdagenci),
                                      ',') = 'S'
         AND cdp.tpcuseve = pr_tpcuseve
         AND cdp.cdcooper = pr_cdcooper
         AND cdp.dtanoage = pr_dtanoage
         AND cdp.nrpropos IS NOT NULL;
  
    rw_crapcdp_III cr_crapcdp_III%ROWTYPE;
  
    CURSOR cr_crapcdp_IV(pr_cdevento crapcdp.cdevento%TYPE
                        ,pr_idevento crapcdp.idevento%TYPE
                        ,pr_dtanoage crapcdp.dtanoage%TYPE
                        ,pr_cdcooper crapcdp.cdcooper%TYPE
                        ,pr_tpcuseve crapcdp.tpcuseve%TYPE
                        ,pr_cdagenci crapcdp.cdagenci%TYPE)IS

      SELECT cdp.idevento,
             cdp.cdcooper,
             cdp.cdevento,
             cdp.cdcuseve,
             cdp.cdagenci,
             cdp.dtanoage,
             NVL(cdp.vlcuseve,0) AS vlcuseve,
             cdp.flgfecha,
             cdp.nrpropos,
             cdp.nrcpfcgc,
             cdp.tpcuseve,
             cdp.qtditens,
             cdp.prdescon,
             cdp.dsjustif,
             cdp.nrdocfmd,
             row_number() over(PARTITION BY cdp.cdcooper, cdp.cdevento, cdp.cdcuseve ORDER BY cdp.cdcooper, cdp.cdevento, cdp.cdcuseve) nrseqreg,
             ROWID
        FROM crapcdp cdp
       WHERE cdp.cdcooper = pr_cdcooper
         AND cdp.cdevento = pr_cdevento
         AND cdp.idevento = pr_idevento
         AND cdp.dtanoage = pr_dtanoage
         AND cdp.tpcuseve = pr_tpcuseve
         AND cdp.cdagenci = pr_cdagenci
       ORDER BY cdp.cdcooper, cdp.cdevento, cdp.cdcuseve;
  
    rw_crapcdp_IV cr_crapcdp_IV%ROWTYPE;
  
    CURSOR cr_gnapses(pr_idcokses gnapses.idsessao%TYPE) IS
      SELECT ses.cdagenci, ses.nvoperad
        FROM gnapses ses
       WHERE ses.idsessao = pr_idcokses;
  
    rw_gnapses cr_gnapses%ROWTYPE;
  
    -- Consulta codigo de cidade
    CURSOR cr_crapmun(pr_cdestado crapmun.cdestado%TYPE,
                      pr_dscidade crapmun.dscidade%TYPE) IS
      SELECT mun.cdcidade
        FROM crapmun mun
       WHERE mun.cdestado = pr_cdestado
         AND mun.dscidade = pr_dscidade;
  
    rw_crapmun cr_crapmun%ROWTYPE;
  
    -- Calcula quantidade maxima da turma
    CURSOR cr_crapeap(pr_cdcooper crapeap.cdcooper%TYPE
                     ,pr_idevento crapeap.idevento%TYPE
                     ,pr_cdevento crapeap.cdevento%TYPE
                     ,pr_dtanoage crapeap.dtanoage%TYPE
                     ,pr_cdagenci crapeap.cdagenci%TYPE) IS

      SELECT eap.qtmaxtur 
        FROM crapeap eap
       WHERE eap.cdcooper = pr_cdcooper
         AND eap.idevento = pr_idevento                                     
         AND eap.cdevento = pr_cdevento
         AND eap.dtanoage = pr_dtanoage
         AND eap.cdagenci = pr_cdagenci;

    rw_crapeap cr_crapeap%ROWTYPE;     

    CURSOR cr_crapppa(pr_idevento crapppa.idevento%TYPE
                     ,pr_cdcooper crapppa.cdcooper%TYPE
                     ,pr_dtanoage crapppa.dtanoage%TYPE
                     ,pr_cdagenci crapppa.cdagenci%TYPE
                     ,pr_cdcuseve crapcdp.cdcuseve%TYPE) IS

      SELECT DECODE(pr_cdcuseve,2,NVL(ppa.vlaluloc,0),3,NVL(ppa.vlporali,0)) AS vlrporpa
        FROM crapppa ppa
       WHERE ppa.idevento = pr_idevento
         AND ppa.cdcooper = pr_cdcooper
         AND ppa.dtanoage = pr_dtanoage
         AND ppa.cdagenci = pr_cdagenci
         AND ppa.vlaluloc IS NOT NULL;

    rw_crapppa cr_crapppa%ROWTYPE;

    CURSOR cr_crapppr(pr_idevento crapppr.idevento%TYPE
                     ,pr_cdcooper crapppr.cdcooper%TYPE
                     ,pr_dtanoage crapppr.dtanoage%TYPE
                     ,pr_cdcuseve crapcdp.cdcuseve%TYPE) IS

      SELECT DECODE(pr_cdcuseve,2,NVL(ppr.vlaluloc,0),3,NVL(ppr.vlporali,0)) AS vlrporrg
        FROM crapppr ppr
       WHERE ppr.idevento = pr_idevento
         AND ppr.cdcooper = pr_cdcooper
         AND ppr.dtanoage = pr_dtanoage
         AND ppr.vlaluloc IS NOT NULL;

    rw_crapppr cr_crapppr%ROWTYPE;

    CURSOR cr_crapppc(pr_idevento crapppc.idevento%TYPE
                     ,pr_cdcooper crapppc.cdcooper%TYPE
                     ,pr_dtanoage crapppc.dtanoage%TYPE
                     ,pr_cdcuseve crapcdp.cdcuseve%TYPE) IS

      SELECT DECODE(pr_cdcuseve,2,NVL(ppc.vlaluloc,0),3,NVL(ppc.vlporali,0),0) AS vlrporco
            ,NVL(ppc.vlporqui,0) AS vlporqui
        FROM crapppc ppc
       WHERE ppc.idevento = pr_idevento
         AND ppc.cdcooper = pr_cdcooper
         AND ppc.dtanoage = pr_dtanoage;

    rw_crapppc cr_crapppc%ROWTYPE;

    CURSOR cr_craprep(pr_idevento craprep.idevento%TYPE
                     ,pr_cdcooper craprep.cdcooper%TYPE
                     ,pr_cdevento craprep.cdevento%TYPE) IS

      SELECT rep.nrseqdig
            ,rep.qtreceve
            ,rep.qtgrppar
        FROM craprep rep
       WHERE rep.idevento = pr_idevento
         AND rep.cdcooper = pr_cdcooper
         AND rep.cdevento = pr_cdevento;

    rw_craprep cr_craprep%ROWTYPE;

    CURSOR cr_craprpe(pr_idevento craprpe.idevento%TYPE
                     ,pr_cdcooper craprpe.cdcooper%TYPE
                     ,pr_cdevento craprpe.cdevento%TYPE
                     ,pr_cdagenci craprpe.cdagenci%TYPE
                     ,pr_cdcopage craprpe.cdcopage%TYPE) IS

      SELECT rpe.nrseqdig
            ,rpe.qtrecage
            ,rpe.qtgrppar
        FROM craprpe rpe
       WHERE rpe.idevento = pr_idevento 
         AND rpe.cdcooper = pr_cdcooper
         AND rpe.cdevento = pr_cdevento
         AND rpe.cdagenci = pr_cdagenci
         AND rpe.cdcopage = pr_cdcopage;

    rw_craprpe cr_craprpe%ROWTYPE;

    CURSOR cr_gnaprdp_I(pr_idevento gnaprdp.idevento%TYPE
                       ,pr_cdcooper gnaprdp.cdcooper%TYPE
                       ,pr_idsitrec gnaprdp.idsitrec%TYPE
                       ,pr_nrseqdig gnaprdp.nrseqdig%TYPE) IS
      SELECT rdp.nrseqdig
            ,rdp.dsrecurs
        FROM gnaprdp rdp
       WHERE rdp.idevento = pr_idevento
         AND rdp.cdcooper = pr_cdcooper
         AND rdp.idsitrec = pr_idsitrec
         AND rdp.nrseqdig = pr_nrseqdig
         AND NVL(rdp.cdtiprec,0) = 0;

    rw_gnaprdp_I cr_gnaprdp_I%ROWTYPE;

    CURSOR cr_gnaprdp_II(pr_idevento gnaprdp.idevento%TYPE
                        ,pr_cdcooper gnaprdp.cdcooper%TYPE
                        ,pr_idsitrec gnaprdp.idsitrec%TYPE
                        ,pr_nrseqdig gnaprdp.nrseqdig%TYPE
                        ,pr_cdtiprec VARCHAR2) IS

      SELECT rdp.nrseqdig
            ,rdp.dsrecurs
            ,rdp.idrecpor
        FROM gnaprdp rdp
       WHERE rdp.idevento = pr_idevento
         AND rdp.cdcooper = pr_cdcooper
         AND rdp.idsitrec = pr_idsitrec
         AND rdp.nrseqdig = pr_nrseqdig
         AND (gene0002.fn_existe_valor(pr_cdtiprec,
                                       to_char(rdp.cdtiprec),
                                       ',') = 'S');

    rw_gnaprdp_II cr_gnaprdp_II%ROWTYPE;

    CURSOR cr_crapvra_I(pr_idevento crapvra.idevento%TYPE
                       ,pr_cdcooper crapvra.idevento%TYPE
                       ,pr_nrseqdig crapvra.idevento%TYPE
                       ,pr_dtanoage crapvra.idevento%TYPE
                       ,pr_nrcpfcgc crapvra.idevento%TYPE) IS

      SELECT  NVL(vra.vlrecano,0) AS vlrecano
        FROM crapvra vra
       WHERE vra.idevento = pr_idevento
         AND vra.cdcooper = pr_cdcooper
         AND vra.nrseqdig = pr_nrseqdig
         AND vra.dtanoage = pr_dtanoage
         AND vra.nrcpfcgc = pr_nrcpfcgc;
    
    rw_crapvra_I cr_crapvra_I%ROWTYPE;

    CURSOR cr_crapvra_II(pr_idevento crapvra.idevento%TYPE
                        ,pr_cdcooper crapvra.idevento%TYPE
                        ,pr_nrseqdig crapvra.idevento%TYPE
                        ,pr_dtanoage crapvra.idevento%TYPE
                        ,pr_cdcopvlr crapvra.cdcopvlr%TYPE) IS

      SELECT  vra.vlrecano
        FROM crapvra vra
       WHERE vra.idevento = pr_idevento
         AND vra.cdcooper = pr_cdcooper
         AND vra.nrseqdig = pr_nrseqdig
         AND vra.dtanoage = pr_dtanoage
         AND vra.cdcopvlr = pr_cdcopvlr;

    rw_crapvra_II cr_crapvra_II%ROWTYPE;                    
    
    CURSOR cr_crapqmd(pr_dtanoage crapqmd.dtanoage%TYPE
                     ,pr_cdcopqtd crapqmd.cdcopqtd%TYPE
                     ,pr_cdagenci crapqmd.cdagenci%TYPE
                     ,pr_tpevento crapqmd.tpevento%TYPE
                     ,pr_idevento crapqmd.idevento%TYPE
                     ,pr_cdcooper crapqmd.cdcooper%TYPE
                     ,pr_nrseqdig crapqmd.nrseqdig%TYPE) IS

      SELECT  NVL(qmd.qtrecnes,0) AS qtrecnes
        FROM crapqmd qmd
       WHERE qmd.dtanoage = pr_dtanoage
         AND qmd.cdcopqtd = pr_cdcopqtd
         AND qmd.cdagenci = pr_cdagenci
         AND qmd.tpevento = pr_tpevento
         AND qmd.idevento = pr_idevento
         AND qmd.cdcooper = pr_cdcooper
         AND qmd.nrseqdig = pr_nrseqdig;

    rw_crapqmd cr_crapqmd%ROWTYPE;

    CURSOR cr_craprdf(pr_idevento craprdf.idevento%TYPE
                     ,pr_cdcooper craprdf.cdcooper%TYPE
                     ,pr_nrcpfcgc craprdf.nrcpfcgc%TYPE
                     ,pr_dspropos craprdf.dspropos%TYPE) IS

      SELECT rdf.nrseqdig
            ,rdf.qtrecfor
            ,rdf.qtgrppar
        FROM craprdf rdf
       WHERE rdf.idevento = pr_idevento
         AND rdf.cdcooper = pr_cdcooper
         AND rdf.nrcpfcgc = pr_nrcpfcgc
         AND rdf.dspropos = pr_dspropos;

    rw_craprdf cr_craprdf%ROWTYPE;

    CURSOR cr_gnappdp(pr_cdcooper gnappdp.cdcooper%TYPE
                     ,pr_idevento gnappdp.idevento%TYPE
                     ,pr_cdevento gnappdp.cdevento%TYPE
                     ,pr_nrcpfcgc gnappdp.nrcpfcgc%TYPE
                     ,pr_nrpropos gnappdp.nrpropos%TYPE) IS
      SELECT TRIM(pdp.idtrainc) AS idtrainc
        FROM gnappdp pdp
       WHERE pdp.cdcooper = pr_cdcooper
         AND pdp.idevento = pr_idevento
         AND pdp.cdevento = pr_cdevento
         AND pdp.nrcpfcgc = pr_nrcpfcgc
         AND pdp.nrpropos = pr_nrpropos;

    rw_gnappdp cr_gnappdp%ROWTYPE;
     
    CURSOR cr_gnfacep(pr_cdcooper gnfacep.cdcooper%TYPE
                     ,pr_idevento gnfacep.idevento%TYPE
                     ,pr_nrcpfcgc gnfacep.nrcpfcgc%TYPE
                     ,pr_nrpropos gnfacep.nrpropos%TYPE) IS
      SELECT cep.cdfacili
        FROM gnfacep cep
       WHERE cep.cdcooper = pr_cdcooper
         AND cep.idevento = pr_idevento
         AND cep.nrcpfcgc = pr_nrcpfcgc
         AND cep.nrpropos = pr_nrpropos;

    rw_gnfacep cr_gnfacep%ROWTYPE;
     
    CURSOR cr_gnapfep(pr_idevento gnapfep.idevento%TYPE
                     ,pr_cdcooper gnapfep.cdcooper%TYPE
                     ,pr_nrcpfcgc gnapfep.nrcpfcgc%TYPE
                     ,pr_cdfacili gnapfep.cdfacili%TYPE) IS

      SELECT fep.cdcidade
        FROM gnapfep fep
       WHERE fep.idevento = pr_idevento
         AND fep.cdcooper = pr_cdcooper
         AND fep.nrcpfcgc = pr_nrcpfcgc
         AND fep.cdfacili = pr_cdfacili;
  
    rw_gnapfep cr_gnapfep%ROWTYPE;

    CURSOR cr_crapdod(pr_cdcidafa crapdod.cdcidori%TYPE
                     ,pr_cdcidapa crapdod.cdcidori%TYPE) IS

      SELECT NVL(dod.qtquidod,0) AS qtquidod
        FROM crapdod dod
       WHERE (dod.cdcidori = pr_cdcidafa 
         AND  dod.cdciddes = pr_cdcidapa) 
          OR (dod.cdcidori = pr_cdcidapa
         AND  dod.cdciddes = pr_cdcidafa);

    rw_crapdod cr_crapdod%ROWTYPE;

    -- Variável de críticas
    vr_dscritic VARCHAR2(32000) := '';
    vr_flgerror BOOLEAN := FALSE; -- Erro Geral
    vr_flglocer BOOLEAN := FALSE; -- Erro de Local
    vr_flgalier BOOLEAN := FALSE; -- Erro de Alimentação
    vr_flgparer BOOLEAN := FALSE; -- Erro de Participantes
    vr_flgkmerr BOOLEAN := FALSE; -- Erro de Quilometragem
    vr_flgbrerr BOOLEAN := FALSE; -- Erro de Brindes
    vr_flgfaerr BOOLEAN := FALSE; -- Erro de Facilitador
    vr_flgcferr BOOLEAN := FALSE; -- Erro de Cidade do Facilitador
    vr_flgrderr BOOLEAN := FALSE; -- Erro de Recurso de Divulgação
    vr_flgvrerr BOOLEAN := FALSE; -- Erro de Valor Recurso de Divulgação
    vr_conterro INTEGER := 0;     -- Contador de Erros

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
  
    -- Variaveis Gerais
    vr_qtdiaeve crapedp.qtdiaeve%TYPE := 0;
    vr_nrcpfcgc crapcdp.nrcpfcgc%TYPE := 0;
    vr_nrpropos crapcdp.nrpropos%TYPE := 0;
    vr_nrdocfmd crapcdp.nrdocfmd%TYPE := 0;
    vr_vlrecpor crapcdp.vlcuseve%TYPE := 0;    
    vr_vlrlocal crapcdp.vlcuseve%TYPE := 0;
    vr_vlmateri crapcdp.vlcuseve%TYPE := 0;
    vr_qtgrppar crapcdp.vlcuseve%TYPE := 0;
    vr_vlporqui crapcdp.vlcuseve%TYPE := 0;
    vr_cdageagr crapage.cdagenci%TYPE := 0;
    vr_vldivulg crapcdp.vlcuseve%TYPE := 0;
    vr_cdcidapa crapmun.cdcidade%TYPE := 0;
    vr_qtmaxtur crapeap.qtmaxtur%TYPE := 0;
    vr_vlalimen crapcdp.vlcuseve%TYPE := 0;
    vr_cdcidafa gnapfep.cdcidade%TYPE := 0;
    vr_vltransp crapcdp.vlcuseve%TYPE := 0;
    vr_vlbrinde crapcdp.vlcuseve%TYPE := 0;
    vr_vlrtermo crapcdp.vlcuseve%TYPE := 0;

    vr_cdufdcop crapage.cdufdcop%TYPE := '';
    vr_nmcidade crapage.nmcidade%TYPE := '';

    vr_nmresage VARCHAR2(5000);
  
  BEGIN
  
    -- Verifica quantidade de dias do evento
    OPEN cr_crapedp_I(pr_cdcooper => pr_cdcooper
                     ,pr_dtanoage => pr_dtanoage
                     ,pr_cdevento => pr_cdevento);
  
    FETCH cr_crapedp_I INTO rw_crapedp_I;
  
    IF cr_crapedp_I%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_crapedp_I;
      vr_dscritic := 'Quantidade de dias do evento não informada ou igual a zero. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado';
      vr_flgerror := TRUE;
      vr_conterro := vr_conterro + 1;
      IF vr_conterro = 10 THEN
        RAISE vr_exc_erro;        
      END IF;
    ELSE
      -- Fecha cursor
      CLOSE cr_crapedp_I;
    
      IF nvl(rw_crapedp_I.qtdiaeve, 0) = 0 THEN
        vr_dscritic := 'Quantidade de dias do evento não informada ou igual a zero. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado';
        vr_flgerror := TRUE;
        vr_conterro := vr_conterro + 1;
        IF vr_conterro = 10 THEN
          RAISE vr_exc_erro;        
        END IF;
      ELSE
        vr_qtdiaeve := NVL(rw_crapedp_I.qtdiaeve, 0);
      END IF;
    END IF;
  
    -- Validação de Sessão
    OPEN cr_gnapses(pr_idcokses => pr_idcokses);
  
    FETCH cr_gnapses
      INTO rw_gnapses;
  
    IF cr_gnapses%NOTFOUND THEN
      CLOSE cr_gnapses;
      vr_dscritic := vr_dscritic || '#' || 'Erro de sessão: ID de sessão inválido.';
      vr_flgerror := TRUE;
      vr_conterro := vr_conterro + 1;
      IF vr_conterro = 10 THEN
        RAISE vr_exc_erro;        
      END IF;
    ELSE
      CLOSE cr_gnapses;
    END IF;    

    FOR rw_crapage_I IN cr_crapage_I(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci) LOOP
    
      -- Para Progrid, os PACs sao agrupados
      OPEN cr_crapagp_I(pr_idevento => pr_idevento,
                        pr_cdcooper => pr_cdcooper,
                        pr_dtanoage => pr_dtanoage,
                        pr_cdagenci => rw_crapage_I.cdagenci);
    
      FETCH cr_crapagp_I INTO rw_crapagp_I;
    
      IF pr_idevento = 1 THEN
        IF cr_crapagp_I%NOTFOUND OR
           rw_crapagp_I.cdagenci <> rw_crapagp_I.cdageagr THEN
          CLOSE cr_crapagp_I;
          CONTINUE;
        END IF;
      END IF;
    
      IF cr_crapagp_I%ISOPEN THEN
        CLOSE cr_crapagp_I;
      END IF;
    
      FOR rw_crapcdp_I IN cr_crapcdp_I(pr_cdcooper => pr_cdcooper
                                      ,pr_dtanoage => pr_dtanoage
                                      ,pr_cdevento => pr_cdevento
                                      ,pr_idevento => pr_idevento
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_tpcuseve => 1) LOOP
      
        vr_nrcpfcgc := NULL;
        vr_nrpropos := NULL;
        vr_nrdocfmd := NULL;
      
        OPEN cr_crapcdp_II(pr_cdcooper => rw_crapcdp_I.cdcooper
                          ,pr_dtanoage => rw_crapcdp_I.dtanoage
                          ,pr_cdevento => rw_crapcdp_I.cdevento
                          ,pr_idevento => rw_crapcdp_I.idevento
                          ,pr_cdagenci => rw_crapage_I.cdagenci
                          ,pr_tpcuseve => 1
                          ,pr_cdcuseve => rw_crapcdp_I.cdcuseve);
      
        FETCH cr_crapcdp_II INTO rw_crapcdp_II;
        
        IF cr_crapcdp_II%NOTFOUND THEN

          CLOSE cr_crapcdp_II;

            BEGIN
              INSERT INTO crapcdp
                (idevento,
                 cdcooper,
                 cdevento,
                 cdcuseve,
                 cdagenci,
                 dtanoage,
                 vlcuseve,
                 flgfecha,
                 nrpropos,
                 nrcpfcgc,
                 tpcuseve,
                 qtditens,
                 prdescon,
                 dsjustif,
                 nrdocfmd)
              VALUES
                (rw_crapcdp_I.idevento
                ,rw_crapcdp_I.cdcooper
                ,rw_crapcdp_I.cdevento
                ,rw_crapcdp_I.cdcuseve
                ,rw_crapage_I.cdagenci -- cdagenci
                ,rw_crapcdp_i.dtanoage
                ,0 -- vlcuseve
                ,0 -- flgfecha
                ,CASE WHEN gene0002.fn_existe_valor(pr_agerepli,rw_crapage_I.cdagenci,',') = 'S' THEN TRIM(rw_crapcdp_I.nrpropos) ELSE NULL END
                ,CASE WHEN gene0002.fn_existe_valor(pr_agerepli,rw_crapage_I.cdagenci,',') = 'S' THEN TRIM(rw_crapcdp_I.nrcpfcgc) ELSE NULL END
                ,rw_crapcdp_I.tpcuseve
                ,rw_crapcdp_I.qtditens
                ,rw_crapcdp_I.prdescon
                ,rw_crapcdp_I.dsjustif
                ,CASE WHEN gene0002.fn_existe_valor(pr_agerepli,rw_crapage_I.cdagenci,',') = 'S' THEN TRIM(rw_crapcdp_I.nrdocfmd) ELSE NULL END);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := vr_dscritic || '#' || 'Erro ao incluir registro CRAPCDP: ' || SQLERRM;
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
            END;
              
        ELSE
          CLOSE cr_crapcdp_II;
        
          IF TRIM(rw_crapcdp_II.nrpropos) IS NULL AND
             (GENE0002.fn_existe_valor(pr_agerepli,rw_crapage_I.cdagenci,',') = 'S') THEN
          
            vr_nrcpfcgc := rw_crapcdp_I.nrcpfcgc;
            vr_nrpropos := rw_crapcdp_I.nrpropos;
            vr_nrdocfmd := rw_crapcdp_I.nrdocfmd;
            
            UPDATE crapcdp
             SET flgfecha = 0,
                 nrcpfcgc = vr_nrcpfcgc,
                 nrpropos = vr_nrpropos,
                 nrdocfmd = vr_nrdocfmd
           WHERE crapcdp.rowid = rw_crapcdp_II.rowid;

          END IF;
                
        END IF;
      
      END LOOP;
    
    END LOOP;
 
    OPEN cr_crapcdp_III(pr_cdcooper => pr_cdcooper,
                        pr_dtanoage => pr_dtanoage,
                        pr_cdevento => pr_cdevento,
                        pr_idevento => pr_idevento,
                        pr_cdagenci => pr_cdagenci,
                        pr_tpcuseve => 1);
  
    FETCH cr_crapcdp_III
      INTO rw_crapcdp_III;
  
    IF cr_crapcdp_III%NOTFOUND THEN
      CLOSE cr_crapcdp_III;
    ELSE
      CLOSE cr_crapcdp_III;

      IF rw_crapcdp_III.nrcpfcgc IS NOT NULL THEN
        vr_nrcpfcgc := rw_crapcdp_III.nrcpfcgc;
      END IF;
    
      IF rw_crapcdp_III.nrpropos IS NOT NULL THEN
        vr_nrpropos := rw_crapcdp_III.nrpropos;
      END IF;
    
      IF rw_crapcdp_III.nrdocfmd IS NOT NULL THEN
        vr_nrdocfmd := rw_crapcdp_III.nrdocfmd;
      END IF;

    END IF;
    
    -- Verifica o PAC agrupador do PAC do usuario
    OPEN cr_crapagp_I(pr_idevento => pr_idevento,
                      pr_cdcooper => pr_cdcooper,
                      pr_dtanoage => pr_dtanoage,
                      pr_cdagenci => rw_gnapses.cdagenci);
  
    FETCH cr_crapagp_I
      INTO rw_crapagp_I;
  
    IF cr_crapagp_I%FOUND THEN
      CLOSE cr_crapagp_I;
      vr_cdageagr := rw_crapagp_I.cdageagr;
    ELSE
      CLOSE cr_crapagp_I;
      vr_cdageagr := rw_gnapses.cdagenci;
    END IF;
  
    vr_vlrecpor := 0;
  
    FOR rw_crapage_II IN cr_crapage_II(pr_cdcooper => pr_cdcooper,
                                       pr_cdagenci => pr_cdagenci) LOOP
    
      -- Controle de visualizaçao por PAC
      IF (rw_gnapses.nvoperad IN (1,2)) AND
         rw_gnapses.cdagenci <> rw_crapage_II.cdagenci AND
         rw_crapage_II.cdagenci <> vr_cdageagr THEN
        CONTINUE;
      END IF;
    
      -- Para Progrid, os PACs sao agrupados
      OPEN cr_crapagp_I(pr_idevento => pr_idevento,
                        pr_cdcooper => pr_cdcooper,
                        pr_dtanoage => pr_dtanoage,
                        pr_cdagenci => rw_crapage_II.cdagenci);
    
      FETCH cr_crapagp_I
        INTO rw_crapagp_I;
    
      IF pr_idevento = 1 THEN
        IF cr_crapagp_I%NOTFOUND OR
           rw_crapagp_I.cdagenci <> rw_crapagp_I.cdageagr THEN
          CLOSE cr_crapagp_I;
          CONTINUE;
        END IF;
      END IF;
    
      IF cr_crapagp_I%ISOPEN THEN
        CLOSE cr_crapagp_I;
      END IF;
    
      vr_nmresage := rw_crapage_II.nmresage;
      vr_cdufdcop := rw_crapage_II.cdufdcop;
      vr_nmcidade := rw_crapage_II.nmcidade;
      vr_vldivulg := 0;
    
      -- Consulta codigo do municipio
      OPEN cr_crapmun(pr_cdestado => vr_cdufdcop,
                      pr_dscidade => vr_nmcidade);
    
      FETCH cr_crapmun
        INTO rw_crapmun;
    
      IF cr_crapmun%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapmun;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapmun;
        vr_cdcidapa := rw_crapmun.cdcidade;
      END IF;
    
      -- Pega os PACS agrupados aux_cdcidapa aux_cdcidafa aux_cdufdcop  aux_nmcidade
      IF pr_idevento = 1 THEN
      
        FOR rw_crapagp_II IN cr_crapagp_II(pr_idevento => rw_crapagp_I.idevento,
                                           pr_cdcooper => rw_crapagp_I.cdcooper,
                                           pr_dtanoage => rw_crapagp_I.dtanoage,
                                           pr_cdagenci => rw_crapagp_I.cdagenci) LOOP
        
          vr_nmresage := vr_nmresage || ' / ' || rw_crapagp_II.nmresage;
        
        END LOOP;

      END IF;
        
      FOR rw_crapcdp_IV IN cr_crapcdp_IV(pr_cdevento => pr_cdevento
                                        ,pr_idevento => pr_idevento
                                        ,pr_dtanoage => pr_dtanoage
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_tpcuseve => 1 -- custos Diretos
                                        ,pr_cdagenci => rw_crapagp_I.cdagenci) LOOP
        
        vr_vlrlocal := 0;
        vr_vlalimen := 0;
        vr_vlrecpor := 0;
        vr_vlmateri := 0;
        vr_qtgrppar := 0;
        vr_vlporqui := 0;

        IF GENE0002.fn_existe_valor(pr_agerepli,rw_crapage_II.cdagenci,',') = 'S' THEN
          
          UPDATE crapcdp
             SET crapcdp.nrcpfcgc = vr_nrcpfcgc
                ,crapcdp.nrpropos = vr_nrpropos
                ,crapcdp.nrdocfmd = vr_nrdocfmd
           WHERE ROWID = rw_crapcdp_IV.ROWID;

          OPEN cr_crapeap(pr_cdcooper => pr_cdcooper
                         ,pr_idevento => pr_idevento
                         ,pr_cdevento => pr_cdevento
                         ,pr_dtanoage => pr_dtanoage
                         ,pr_cdagenci => rw_crapage_II.cdagenci);

          FETCH cr_crapeap INTO rw_crapeap;

          IF cr_crapeap%FOUND THEN
            CLOSE cr_crapeap;
            IF NVL(rw_crapeap.qtmaxtur,0) > 0 THEN
              vr_qtmaxtur := NVL(rw_crapeap.qtmaxtur,0);
            ELSE
              OPEN cr_crapedp_II(pr_idevento => pr_idevento
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dtanoage => pr_dtanoage
                                ,pr_cdevento => pr_cdevento);

              FETCH cr_crapedp_II INTO rw_crapedp_II;

              IF cr_crapedp_II%FOUND THEN

                CLOSE cr_crapedp_II;

                IF rw_crapedp_II.qtmaxtur > 0 THEN
                  vr_qtmaxtur := NVL(rw_crapedp_II.qtmaxtur,0);
                ELSE
                           
                  OPEN cr_crapedp_II(pr_idevento => pr_idevento
                                    ,pr_cdcooper => 0
                                    ,pr_dtanoage => 0
                                    ,pr_cdevento => pr_cdevento);

                  FETCH cr_crapedp_II INTO rw_crapedp_II;

                  IF cr_crapedp_II%FOUND THEN
                    CLOSE cr_crapedp_II;
                    vr_qtmaxtur := NVL(rw_crapedp_II.qtmaxtur,0);
                  ELSE
                    CLOSE cr_crapedp_II;
                  END IF;       

                END IF;
              ELSE
                CLOSE cr_crapedp_II;
              END IF;

            END IF; -- rw_crapeap.qtmaxtur > 0         
          ELSE -- 
            CLOSE cr_crapeap;

            OPEN cr_crapedp_II(pr_idevento => pr_idevento
                              ,pr_cdcooper => pr_cdcooper
                              ,pr_dtanoage => pr_dtanoage
                              ,pr_cdevento => pr_cdevento);

            FETCH cr_crapedp_II INTO rw_crapedp_II;

            IF cr_crapedp_II%FOUND THEN

              CLOSE cr_crapedp_II;

              IF NVL(rw_crapedp_II.qtmaxtur,0) > 0 THEN
                vr_qtmaxtur := rw_crapedp_II.qtmaxtur;					
              ELSE
                           
                OPEN cr_crapedp_II(pr_idevento => pr_idevento
                                  ,pr_cdcooper => 0
                                  ,pr_dtanoage => 0
                                  ,pr_cdevento => pr_cdevento);

                FETCH cr_crapedp_II INTO rw_crapedp_II;

                IF cr_crapedp_II%FOUND THEN
                  CLOSE cr_crapedp_II;
                  vr_qtmaxtur := NVL(rw_crapedp_II.qtmaxtur,0);
                ELSE
                  CLOSE cr_crapedp_II;
                END IF;       

              END IF;
            ELSE

              CLOSE cr_crapedp_II; 

              OPEN cr_crapedp_II(pr_idevento => pr_idevento
                                ,pr_cdcooper => 0
                                ,pr_dtanoage => 0
                                ,pr_cdevento => pr_cdevento);

              FETCH cr_crapedp_II INTO rw_crapedp_II;

              IF cr_crapedp_II%FOUND THEN
                CLOSE cr_crapedp_II;
                vr_qtmaxtur := NVL(rw_crapedp_II.qtmaxtur,0);
              ELSE
                CLOSE cr_crapedp_II;
              END IF;       
            END IF;

          END IF;

        END IF;
        
        IF vr_qtmaxtur = 0  THEN
          IF NOT vr_flgparer THEN
            vr_dscritic := vr_dscritic || '#' || 'Quantidade de participantes do evento não cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
            vr_flgerror := TRUE;
            vr_flgparer := TRUE;
            vr_conterro := vr_conterro + 1;
            IF vr_conterro = 10 THEN
              RAISE vr_exc_erro;        
            END IF;
          END IF;
        END IF;          

        IF rw_crapcdp_IV.cdcuseve = 2 THEN -- CALCULO DE LOCAL

          OPEN cr_crapppa(pr_idevento => pr_idevento
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_dtanoage => pr_dtanoage
                         ,pr_cdagenci => rw_crapagp_I.cdagenci
                         ,pr_cdcuseve => 2);

          FETCH cr_crapppa INTO rw_crapppa;

          IF cr_crapppa%FOUND THEN
            CLOSE cr_crapppa;
            vr_vlrlocal := (rw_crapppa.vlrporpa * vr_qtdiaeve);
          ELSE
            CLOSE cr_crapppa;

            OPEN cr_crapppr(pr_idevento => pr_idevento
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_dtanoage => pr_dtanoage
                           ,pr_cdcuseve => 2);

            FETCH cr_crapppr INTO rw_crapppr;
               
            IF cr_crapppr%FOUND THEN
              CLOSE cr_crapppr;
              vr_vlrlocal := (rw_crapppr.vlrporrg * vr_qtdiaeve);
            ELSE
              CLOSE cr_crapppr;

              OPEN cr_crapppc(pr_idevento => pr_idevento
                             ,pr_cdcooper => pr_cdcooper
                             ,pr_dtanoage => pr_dtanoage
                             ,pr_cdcuseve => 2);

              FETCH cr_crapppc INTO rw_crapppc;
               
              IF cr_crapppc%FOUND THEN
                CLOSE cr_crapppc;
                vr_vlrlocal := (rw_crapppc.vlrporco * vr_qtdiaeve);
              ELSE
                CLOSE cr_crapppc;                
              END IF;
            END IF;
            
          END IF;
               
          IF vr_vlrlocal = 0 AND NOT vr_flglocer THEN
            vr_dscritic := vr_dscritic || '#' || 'Valor de local não cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
            vr_flgerror := TRUE;
            vr_flglocer := TRUE;
            vr_conterro := vr_conterro + 1;
            IF vr_conterro = 10 THEN
              RAISE vr_exc_erro;        
            END IF;
          END IF;

        END IF; -- FIM CALCULO DE LOCAL

        IF rw_crapcdp_IV.cdcuseve = 3 THEN -- CALCULO DE ALIMENTACAO
          OPEN cr_crapppa(pr_idevento => pr_idevento
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_dtanoage => pr_dtanoage
                         ,pr_cdagenci => rw_crapagp_I.cdagenci
                         ,pr_cdcuseve => 3);

          FETCH cr_crapppa INTO rw_crapppa;
               
          IF cr_crapppa%FOUND THEN
            CLOSE cr_crapppa;
            vr_vlalimen := (NVL(rw_crapppa.vlrporpa,0) * NVL(vr_qtdiaeve,0));
          ELSE
            CLOSE cr_crapppa;

            OPEN cr_crapppr(pr_idevento => pr_idevento
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_dtanoage => pr_dtanoage
                           ,pr_cdcuseve => 3);

            FETCH cr_crapppr INTO rw_crapppr;
               
            IF cr_crapppr%FOUND THEN
              CLOSE cr_crapppr;
              vr_vlalimen := (NVL(rw_crapppr.vlrporrg,0) * NVL(vr_qtdiaeve,0));
            ELSE
              CLOSE cr_crapppr;

              OPEN cr_crapppc(pr_idevento => pr_idevento
                             ,pr_cdcooper => pr_cdcooper
                             ,pr_dtanoage => pr_dtanoage
                             ,pr_cdcuseve => 3);

              FETCH cr_crapppc INTO rw_crapppc;
               
              IF cr_crapppc%FOUND THEN
                CLOSE cr_crapppc;
                vr_vlalimen := (NVL(rw_crapppc.vlrporco,0) * NVL(vr_qtdiaeve,0));
              ELSE
                CLOSE cr_crapppc; 
                IF NOT vr_flgalier THEN
                  vr_dscritic := vr_dscritic || '#' || 'Valor de alimentação não cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                  vr_flgerror := TRUE;
                  vr_flgalier := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              END IF;
            END IF;            
          END IF;               
        END IF; -- FIM CALCULO DE ALIMENTACAO

        -- CONSULTA POR KM
        OPEN cr_crapppc(pr_idevento => pr_idevento
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_dtanoage => pr_dtanoage
                       ,pr_cdcuseve => 0);

        FETCH cr_crapppc INTO rw_crapppc;
               
        IF cr_crapppc%FOUND THEN
          CLOSE cr_crapppc;
          vr_vlporqui := rw_crapppc.vlporqui;
        ELSE
          CLOSE cr_crapppc;                
        END IF;

        -- Verifica se existe valor por km e se as cidade origem e destinos são diferentes
        IF vr_vlporqui = 0 THEN
          IF NOT vr_flgkmerr THEN
					  vr_dscritic := vr_dscritic || '#' || 'Valor por quilômetro não cadastrado para este Ano/Cooperativa. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
            vr_flgerror := TRUE;
            vr_flgkmerr := TRUE;
            vr_conterro := vr_conterro + 1;
            IF vr_conterro = 10 THEN
              RAISE vr_exc_erro;        
            END IF;
          END IF;
				END IF;

        vr_vlalimen := (NVL(vr_vlalimen,0) * NVL(vr_qtmaxtur,0) * NVL(vr_qtdiaeve,0));

        IF rw_crapcdp_IV.cdcuseve = 7 THEN -- MATERIAL DE DIVULGACAO

          FOR rw_craprep IN cr_craprep(pr_idevento => pr_idevento
                                      ,pr_cdcooper => 0
                                      ,pr_cdevento => pr_cdevento) LOOP

            OPEN cr_gnaprdp_I(pr_idevento => pr_idevento
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprep.nrseqdig);

            FETCH cr_gnaprdp_I INTO rw_gnaprdp_I;

            IF cr_gnaprdp_I%FOUND THEN
              CLOSE cr_gnaprdp_I;

              IF NOT vr_flgrderr THEN 
                vr_dscritic := vr_dscritic || '#' || 'O recurso de divulgação do evento(' || rw_gnaprdp_I.dsrecurs || ') associado ao evento, năo possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgrderr := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;
            ELSE
              CLOSE cr_gnaprdp_I;
            END IF;

            OPEN cr_gnaprdp_II(pr_idevento => pr_idevento
                              ,pr_cdcooper => 0
                              ,pr_idsitrec => 1
                              ,pr_nrseqdig => rw_craprep.nrseqdig
                              ,pr_cdtiprec => 2);

            FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;

            IF cr_gnaprdp_II%FOUND THEN
              CLOSE cr_gnaprdp_II;

              IF NVL(vr_nrdocfmd,0) = 0 AND NOT vr_flgrderr THEN
                vr_dscritic := vr_dscritic || '#' || 'O recurso de divulgação do evento(' || rw_gnaprdp_II.dsrecurs || ') associado ao evento, năo possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;   
                vr_flgrderr := TRUE;  
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;

              -- Busca o valor do Recurso por Ano
              OPEN cr_crapvra_I(pr_idevento => pr_idevento
                               ,pr_cdcooper => 0
                               ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                               ,pr_dtanoage => pr_dtanoage
                               ,pr_nrcpfcgc => vr_nrdocfmd);

              FETCH cr_crapvra_I INTO rw_crapvra_I;

              IF cr_crapvra_I%NOTFOUND THEN
                CLOSE cr_crapvra_I;
                IF NOT vr_flgvrerr THEN
                  vr_dscritic := vr_dscritic || '#' || 'O recurso de divulgação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                  vr_flgerror := TRUE;
                  vr_flgvrerr := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              ELSE
                CLOSE cr_crapvra_I;
              END IF;

              OPEN cr_crapedp_II(pr_idevento => pr_idevento
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dtanoage => pr_dtanoage
                                ,pr_cdevento => pr_cdevento);

              FETCH cr_crapedp_II INTO rw_crapedp_II;

              IF cr_crapedp_II%NOTFOUND THEN
                CLOSE cr_crapedp_II;
              ELSE
                CLOSE cr_crapedp_II;

                OPEN cr_crapqmd(pr_dtanoage => pr_dtanoage
                               ,pr_cdcopqtd => pr_cdcooper
                               ,pr_cdagenci => rw_crapagp_I.cdagenci
                               ,pr_tpevento => rw_crapedp_II.tpevento
                               ,pr_idevento => pr_idevento
                               ,pr_cdcooper => 0
                               ,pr_nrseqdig => rw_craprep.nrseqdig);

                FETCH cr_crapqmd INTO rw_crapqmd;

                IF cr_crapqmd%NOTFOUND THEN
                  CLOSE cr_crapqmd;
                  IF NOT vr_flgrderr THEN
                    vr_dscritic := vr_dscritic || '#' || 'Quantidade de materiais de divulgação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') associado ao evento, não possui quantidade cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                    vr_flgerror := TRUE;
                    vr_flgrderr := TRUE;
                    vr_conterro := vr_conterro + 1;
                    IF vr_conterro = 10 THEN
                      RAISE vr_exc_erro;        
                    END IF;
                  END IF;
                ELSE
                  CLOSE cr_crapqmd;

                  vr_vldivulg := NVL(vr_vldivulg,0) + (NVL(rw_crapqmd.qtrecnes,0) * NVL(rw_crapvra_I.vlrecano,0));
                        
                END IF;
              END IF;
              
            ELSE
              CLOSE cr_gnaprdp_II;
            END IF;

          END LOOP;  

          -- FIM POR EVENTO

          -- POR PA
          FOR rw_craprpe IN cr_craprpe(pr_idevento => pr_idevento
                                      ,pr_cdcooper => 0
                                      ,pr_cdevento => pr_cdevento
                                      ,pr_cdagenci => rw_crapagp_I.cdagenci
                                      ,pr_cdcopage => pr_cdcooper) LOOP
            
            OPEN cr_gnaprdp_I(pr_idevento => pr_idevento
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprpe.nrseqdig);

            FETCH cr_gnaprdp_I INTO rw_gnaprdp_I;

            IF cr_gnaprdp_I%FOUND THEN
              CLOSE cr_gnaprdp_I;
              IF NOT vr_flgrderr THEN
                vr_dscritic := vr_dscritic || '#' || 'O recurso de divulgação(' || UPPER(rw_gnaprdp_I.dsrecurs) || ') do PA(' || UPPER(rw_crapage_II.nmresage) || ') associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;
                vr_flgrderr := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;
            ELSE
              CLOSE cr_gnaprdp_I;
            END IF;                       
              
            OPEN cr_gnaprdp_II(pr_idevento => pr_idevento
                              ,pr_cdcooper => 0
                              ,pr_idsitrec => 1
                              ,pr_nrseqdig => rw_craprpe.nrseqdig
                              ,pr_cdtiprec => 2);

            FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;

            IF cr_gnaprdp_II%FOUND THEN
              CLOSE cr_gnaprdp_II;

              IF NVL(vr_nrdocfmd,0) = 0 THEN
                vr_dscritic := vr_dscritic || '#' || 'Este evento possui recursos de divulgação. Favor informar o FORNECEDOR DE DIVULGAÇÃO antes de informar o FORNECEDOR T&D.';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;

              -- Busca o valor do Recurso por Ano
              OPEN cr_crapvra_I(pr_idevento => pr_idevento
                               ,pr_cdcooper => 0
                               ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                               ,pr_dtanoage => pr_dtanoage
                               ,pr_nrcpfcgc => vr_nrdocfmd);

              FETCH cr_crapvra_I INTO rw_crapvra_I;

              IF cr_crapvra_I%NOTFOUND THEN
                CLOSE cr_crapvra_I;
                IF NOT vr_flgvrerr THEN
                  vr_dscritic := vr_dscritic || '#' || 'O recurso de divulgação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' || UPPER(rw_crapage_II.nmresage) || ') associado ao evento não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                  vr_flgerror := TRUE;
                  vr_flgvrerr := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
              ELSE
                CLOSE cr_crapvra_I;
              END IF;

              -- Para a frequencia minima
              OPEN cr_crapedp_II(pr_idevento => pr_idevento
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dtanoage => pr_dtanoage
                                ,pr_cdevento => pr_cdevento);

              FETCH cr_crapedp_II INTO rw_crapedp_II;

              IF cr_crapedp_II%NOTFOUND THEN
                CLOSE cr_crapedp_II;
              ELSE
                CLOSE cr_crapedp_II;

                OPEN cr_crapqmd(pr_dtanoage => pr_dtanoage
                               ,pr_cdcopqtd => pr_cdcooper
                               ,pr_cdagenci => rw_crapagp_I.cdagenci
                               ,pr_tpevento => rw_crapedp_II.tpevento
                               ,pr_idevento => pr_idevento
                               ,pr_cdcooper => 0
                               ,pr_nrseqdig => rw_craprep.nrseqdig);

                FETCH cr_crapqmd INTO rw_crapqmd;

                IF cr_crapqmd%NOTFOUND THEN
                  CLOSE cr_crapqmd;
                  IF NOT vr_flgrderr THEN
                    vr_dscritic := vr_dscritic || '#' || 'Quantidade de materiais de divulgação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' || UPPER(rw_crapage_II.nmresage) || ') associado ao evento, não possui quantidade cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                    vr_flgerror := TRUE;
                    vr_flgrderr := TRUE;
                    vr_conterro := vr_conterro + 1;
                    IF vr_conterro = 10 THEN
                      RAISE vr_exc_erro;        
                    END IF;
                  END IF;
                ELSE
                  CLOSE cr_crapqmd;

                  vr_vldivulg := NVL(vr_vldivulg,0) + (NVL(rw_crapqmd.qtrecnes,0) * NVL(rw_crapvra_I.vlrecano,0));
                        
                END IF;
              END IF;
              
            ELSE
              CLOSE cr_gnaprdp_II;
            END IF;
   
          END LOOP;

          -- FIM POR PA

          -- DIVULGACAO POR FORNECEDOR
          FOR rw_craprdf IN cr_craprdf(pr_idevento => pr_idevento
                                      ,pr_cdcooper => 0
                                      ,pr_nrcpfcgc => rw_crapcdp_IV.nrcpfcgc 
                                      ,pr_dspropos => vr_nrpropos) LOOP

            OPEN cr_gnaprdp_I(pr_idevento => pr_idevento
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprpe.nrseqdig);

            FETCH cr_gnaprdp_I INTO rw_gnaprdp_I;

            IF cr_gnaprdp_I%FOUND THEN
              CLOSE cr_gnaprdp_I;
              IF NOT vr_flgrderr THEN
                vr_dscritic := vr_dscritic || '#' || 'O recurso de divulgação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do fornecedor associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;
                vr_flgrderr := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;
            ELSE
              CLOSE cr_gnaprdp_I;
            END IF;
            
            OPEN cr_gnaprdp_II(pr_idevento => pr_idevento
                              ,pr_cdcooper => 0
                              ,pr_idsitrec => 1
                              ,pr_nrseqdig => rw_craprdf.nrseqdig
                              ,pr_cdtiprec => 2);

            FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;

            IF cr_gnaprdp_II%FOUND THEN
              CLOSE cr_gnaprdp_II;

              IF NVL(vr_nrdocfmd,0) = 0 THEN
                vr_dscritic := vr_dscritic || '#' || 'Este evento possui recursos de divulgação. Favor informar o FORNECEDOR DE DIVULGAÇÃO antes de informar o FORNECEDOR T&D.';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              END IF;

              -- Busca o valor do Recurso por Ano
              OPEN cr_crapvra_I(pr_idevento => pr_idevento
                               ,pr_cdcooper => 0
                               ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                               ,pr_dtanoage => pr_dtanoage
                               ,pr_nrcpfcgc => vr_nrdocfmd);

              FETCH cr_crapvra_I INTO rw_crapvra_I;

              IF cr_crapvra_I%NOTFOUND THEN
                CLOSE cr_crapvra_I;
                vr_dscritic := vr_dscritic || '#' || 'O recurso de divulgação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' || UPPER(rw_crapage_II.nmresage) || ') associado ao evento não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              ELSE
                CLOSE cr_crapvra_I;
              END IF;

              -- Para a frequencia minima
              OPEN cr_crapedp_II(pr_idevento => pr_idevento
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dtanoage => pr_dtanoage
                                ,pr_cdevento => pr_cdevento);

              FETCH cr_crapedp_II INTO rw_crapedp_II;

              IF cr_crapedp_II%NOTFOUND THEN
                CLOSE cr_crapedp_II;
              ELSE
                CLOSE cr_crapedp_II;

                OPEN cr_crapqmd(pr_dtanoage => pr_dtanoage
                               ,pr_cdcopqtd => pr_cdcooper
                               ,pr_cdagenci => rw_crapagp_I.cdagenci
                               ,pr_tpevento => rw_crapedp_II.tpevento
                               ,pr_idevento => pr_idevento
                               ,pr_cdcooper => 0
                               ,pr_nrseqdig => rw_craprep.nrseqdig);

                FETCH cr_crapqmd INTO rw_crapqmd;

                IF cr_crapqmd%NOTFOUND THEN
                  CLOSE cr_crapqmd;
                  vr_dscritic := vr_dscritic || '#' || 'Quantidade de materiais de divulgação(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' || UPPER(rw_crapage_II.nmresage) || ') associado ao evento, não possui quantidade cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                ELSE
                  CLOSE cr_crapqmd;

                  vr_vldivulg := NVL(vr_vldivulg,0) + (NVL(rw_crapqmd.qtrecnes,0) * NVL(rw_crapvra_I.vlrecano,0));
                        
                END IF;
              END IF;
              
            ELSE
              CLOSE cr_gnaprdp_II;
            END IF;

          END LOOP;

          -- FIM DIVULGACAO POR FORNECEDOR

        END IF; -- FIM MATERIAL DE DIVULGACAO        
        
        IF rw_crapcdp_IV.cdcuseve = 5 THEN -- TRANSPORTE
        
          OPEN cr_gnappdp(pr_cdcooper => 0
                         ,pr_idevento => pr_idevento
                         ,pr_cdevento => pr_cdevento
                         ,pr_nrcpfcgc => vr_nrcpfcgc
                         ,pr_nrpropos => vr_nrpropos);

          FETCH cr_gnappdp INTO rw_gnappdp;
               
          IF cr_gnappdp%NOTFOUND THEN
            CLOSE cr_gnappdp;
          ELSE
            CLOSE cr_gnappdp;

            IF TRIM(rw_gnappdp.idtrainc) = 'N' OR TRIM(rw_gnappdp.idtrainc) IS NULL THEN

              OPEN cr_gnfacep(pr_cdcooper => 0
                             ,pr_idevento => pr_idevento
                             ,pr_nrcpfcgc => vr_nrcpfcgc
                             ,pr_nrpropos => vr_nrpropos);

              FETCH cr_gnfacep INTO rw_gnfacep;
              
              IF cr_gnfacep%NOTFOUND THEN
                CLOSE cr_gnfacep;
                vr_dscritic := vr_dscritic || '#' || 'Facilitador não cadastrado para a proposta do FORNECEDOR T&D. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              ELSE
                CLOSE cr_gnfacep;

                OPEN cr_gnapfep(pr_idevento => pr_idevento
                               ,pr_cdcooper => 0
                               ,pr_nrcpfcgc => vr_nrcpfcgc
                               ,pr_cdfacili => rw_gnfacep.cdfacili);

                FETCH cr_gnapfep INTO rw_gnapfep;

                IF cr_gnapfep%NOTFOUND THEN
                  CLOSE cr_gnapfep;
                  IF NOT vr_flgfaerr THEN      
                    vr_dscritic := vr_dscritic || '#' || 'Cidade do facilitador não cadastrada para a proposta do FORNECEDOR T&D. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                    vr_flgerror := TRUE;
                    vr_conterro := vr_conterro + 1;
                    vr_flgfaerr := TRUE;
                    IF vr_conterro = 10 THEN
                      RAISE vr_exc_erro;        
                    END IF;
                  END IF;
                ELSE
                  CLOSE cr_gnapfep;

                  IF NVL(rw_gnapfep.cdcidade,0) = 0 THEN
                    IF NOT vr_flgfaerr THEN      
                      vr_dscritic := vr_dscritic || '#' || 'Cidade do facilitador não cadastrada para a proposta do FORNECEDOR T&D. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                      vr_flgerror := TRUE;
                      vr_conterro := vr_conterro + 1;
                      vr_flgfaerr := TRUE;
                      IF vr_conterro = 10 THEN
                        RAISE vr_exc_erro;        
                      END IF;
                    END IF;
                  ELSE
                    vr_cdcidafa := rw_gnapfep.cdcidade;
                  END IF;  

                END IF;                

              END IF;
              
              IF NVL(vr_cdcidafa,0) = 0 THEN
                IF NOT vr_flgcferr THEN 
                  vr_dscritic := vr_dscritic || '#' || 'Cadastre a cidade de origem do facilitador. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  vr_flgcferr := TRUE;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                END IF;
							END IF;

              IF vr_cdcidafa <> vr_cdcidapa THEN

                OPEN cr_crapdod(pr_cdcidafa => vr_cdcidafa
                               ,pr_cdcidapa => vr_cdcidapa);

                FETCH cr_crapdod INTO rw_crapdod;

								IF cr_crapdod%NOTFOUND THEN
								  CLOSE cr_crapdod;
                  vr_dscritic := vr_dscritic || '#' || 'Distância entre o Facilitador e o PA(' || UPPER(rw_crapage_II.nmresage) || ') não cadastrada. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
	              ELSE
                  CLOSE cr_crapdod;
                END IF;

							  vr_vltransp := (NVL(vr_qtdiaeve,0) *(NVL(rw_crapdod.qtquidod,0) * NVL(vr_vlporqui,0))) * 2;
									
              ELSE
                vr_vltransp := 0;
              END IF;

            END IF;

          END IF;              

        END IF; -- FIM TRANSPORTE

        IF rw_crapcdp_IV.cdcuseve = 4 THEN -- MATERIAIS

          -- RECURSOS POR EVENTO
          vr_vlmateri := 0;

          FOR rw_craprep IN cr_craprep(pr_idevento => pr_idevento
                                      ,pr_cdcooper => 0
                                      ,pr_cdevento => pr_cdevento) LOOP

            OPEN cr_gnaprdp_I(pr_idevento => pr_idevento            
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprep.nrseqdig);

            FETCH cr_gnaprdp_I INTO rw_gnaprdp_I;
                                                   
            IF cr_gnaprdp_I%FOUND THEN               
              CLOSE cr_gnaprdp_I;
              vr_dscritic := vr_dscritic || '#' || 'O recurso por evento(' || UPPER(rw_gnaprdp_I.dsrecurs) || ') associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
              vr_flgerror := TRUE;
              vr_conterro := vr_conterro + 1;
              IF vr_conterro = 10 THEN
                RAISE vr_exc_erro;        
              END IF;
            ELSE
              CLOSE cr_gnaprdp_I;
            END IF;

            OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprep.nrseqdig
                             ,pr_cdtiprec => '3,4');

            FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                   
            IF cr_gnaprdp_II%NOTFOUND THEN               
              CLOSE cr_gnaprdp_II;
            ELSE
              CLOSE cr_gnaprdp_II;
              
              -- Busca o valor do Recurso por Ano
              OPEN cr_crapvra_II(pr_idevento => pr_idevento
                                ,pr_cdcooper => 0
                                ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                                ,pr_dtanoage => pr_dtanoage
                                ,pr_cdcopvlr => pr_cdcooper);

              FETCH cr_crapvra_II INTO rw_crapvra_II;

              IF cr_crapvra_II%NOTFOUND THEN
                CLOSE cr_crapvra_II;
                vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') por evento associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              ELSE
                CLOSE cr_crapvra_II;
                CASE rw_gnaprdp_II.idrecpor
                  WHEN 1 THEN -- POR EVENTO
                    IF NVL(rw_craprep.qtreceve,0) = 0 THEN
                        vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais por evento não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                        vr_flgerror := TRUE;
                        vr_conterro := vr_conterro + 1;
                        IF vr_conterro = 10 THEN
                          RAISE vr_exc_erro;        
                        END IF;
                      END IF;
                    vr_vlrecpor := rw_craprep.qtreceve;
                  WHEN 2 THEN -- POR PARTICIPANTES
                    vr_vlrecpor := vr_qtmaxtur;
                  WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
                    IF NVL(rw_craprep.qtreceve,0) = 0 OR NVL(rw_craprep.qtgrppar,0) = 0 THEN
                        vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais por grupo de participantes não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                        vr_flgerror := TRUE;
                        vr_conterro := vr_conterro + 1;
                        IF vr_conterro = 10 THEN
                          RAISE vr_exc_erro;        
                        END IF;
                      END IF;
                              
                    vr_vlrecpor := (NVL(vr_qtmaxtur,0) / NVL(rw_craprep.qtgrppar,0)) * NVL(rw_craprep.qtreceve,0);

                END CASE;

                vr_vlmateri := vr_vlmateri + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

              END IF;

            END IF;

          END LOOP;

          -- FIM POR EVENTO  

          -- RECURSOS POR PA
          FOR rw_craprpe IN cr_craprpe(pr_idevento => pr_idevento
                                      ,pr_cdcooper => 0
                                      ,pr_cdevento => pr_cdevento
                                      ,pr_cdagenci => rw_crapagp_I.cdagenci
                                      ,pr_cdcopage => pr_cdcooper) LOOP

            OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprpe.nrseqdig
                             ,pr_cdtiprec => '0');

            FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                   
            IF cr_gnaprdp_II%FOUND THEN               
              CLOSE cr_gnaprdp_II;
              vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' ||  UPPER(rw_crapage_II.nmresage) || ') associado ao evento, năo possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
              vr_flgerror := TRUE;
              vr_conterro := vr_conterro + 1;
              IF vr_conterro = 10 THEN
                RAISE vr_exc_erro;        
              END IF;
            ELSE
              CLOSE cr_gnaprdp_II;
            END IF;

            OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprpe.nrseqdig
                             ,pr_cdtiprec => '3,4');

            FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                   
            IF cr_gnaprdp_II%NOTFOUND THEN               
              CLOSE cr_gnaprdp_II;
            ELSE
              CLOSE cr_gnaprdp_II;

              -- Busca o valor do Recurso por Ano
              OPEN cr_crapvra_II(pr_idevento => pr_idevento
                                ,pr_cdcooper => 0
                                ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                                ,pr_dtanoage => pr_dtanoage
                                ,pr_cdcopvlr => pr_cdcooper);

              FETCH cr_crapvra_II INTO rw_crapvra_II;

              IF cr_crapvra_II%NOTFOUND THEN
                CLOSE cr_crapvra_II;
                vr_dscritic := vr_dscritic || '#' || 'O recurso do PA (' || UPPER(rw_gnaprdp_II.dsrecurs) || ') associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              ELSE
                CLOSE cr_crapvra_II;

                CASE rw_gnaprdp_II.idrecpor
                  WHEN 1 THEN -- POR EVENTO
                    IF NVL(rw_craprpe.qtrecage,0) = 0 THEN
                        vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais não cadastradas por PA para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                        vr_flgerror := TRUE;
                        vr_conterro := vr_conterro + 1;
                        IF vr_conterro = 10 THEN
                          RAISE vr_exc_erro;        
                        END IF;
                      END IF;
                    vr_vlrecpor := rw_craprpe.qtrecage;
                  WHEN 2 THEN -- POR PARTICIPANTES
                    vr_vlrecpor := vr_qtmaxtur;
                  WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
                    IF NVL(rw_craprpe.qtrecage,0) = 0 OR NVL(rw_craprpe.qtgrppar,0) = 0 THEN
                      vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais por PA não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                      vr_flgerror := TRUE;
                      vr_conterro := vr_conterro + 1;
                      IF vr_conterro = 10 THEN
                        RAISE vr_exc_erro;        
                      END IF;
                    END IF;
                              
                  vr_vlrecpor := (NVL(vr_qtmaxtur,0) / NVL(rw_craprpe.qtgrppar,0)) * NVL(rw_craprpe.qtrecage,0);

                END CASE;

                vr_vlmateri := NVL(vr_vlmateri,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

              END IF;

            END IF;            

          END LOOP; -- FIM RECURSOS POR PA

          -- RECURSOS POR FORNECEDOR          
          FOR rw_craprdf IN cr_craprdf(pr_idevento => pr_idevento
                                      ,pr_cdcooper => 0
                                      ,pr_nrcpfcgc => vr_nrcpfcgc 
                                      ,pr_dspropos => vr_nrpropos) LOOP
            
            OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprdf.nrseqdig
                             ,pr_cdtiprec => '0');

            FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                   
            IF cr_gnaprdp_II%NOTFOUND THEN 
              CLOSE cr_gnaprdp_II;
              vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do fornecedor associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
              vr_flgerror := TRUE;
              vr_conterro := vr_conterro + 1;
              IF vr_conterro = 10 THEN
                RAISE vr_exc_erro;        
              END IF;
            ELSE
              CLOSE cr_gnaprdp_II;

              OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                             ,pr_cdcooper => 0
                             ,pr_idsitrec => 1
                             ,pr_nrseqdig => rw_craprdf.nrseqdig
                             ,pr_cdtiprec => '3,4');

              FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
              IF cr_gnaprdp_II%NOTFOUND THEN 
                CLOSE cr_gnaprdp_II;
                vr_dscritic := vr_dscritic || '#' || 'O recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do fornecedor associado ao evento, não possui tipo de recurso cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                vr_flgerror := TRUE;
                vr_conterro := vr_conterro + 1;
                IF vr_conterro = 10 THEN
                  RAISE vr_exc_erro;        
                END IF;
              ELSE
                CLOSE cr_gnaprdp_II;

                -- Busca o valor do Recurso por Ano
                OPEN cr_crapvra_II(pr_idevento => pr_idevento
                                  ,pr_cdcooper => 0
                                  ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                                  ,pr_dtanoage => pr_dtanoage
                                  ,pr_cdcopvlr => pr_cdcooper);

                FETCH cr_crapvra_II INTO rw_crapvra_II;

                IF cr_crapvra_II%NOTFOUND THEN
                  CLOSE cr_crapvra_II;
                  vr_dscritic := vr_dscritic || '#' || 'O recurso (' || UPPER(rw_gnaprdp_II.dsrecurs) || ') associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                  vr_flgerror := TRUE;
                  vr_conterro := vr_conterro + 1;
                  IF vr_conterro = 10 THEN
                    RAISE vr_exc_erro;        
                  END IF;
                ELSE
                  CLOSE cr_crapvra_II;

                  CASE rw_gnaprdp_II.idrecpor
                    WHEN 1 THEN -- POR EVENTO
                      IF NVL(rw_craprdf.qtrecfor,0) = 0 THEN
                          vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais não cadastradas por FORNECEDOR para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                          vr_flgerror := TRUE;
                          vr_conterro := vr_conterro + 1;
                          IF vr_conterro = 10 THEN
                            RAISE vr_exc_erro;        
                          END IF;
                        END IF;
                      vr_vlrecpor := rw_craprdf.qtrecfor;
                    WHEN 2 THEN -- POR PARTICIPANTES
                      vr_vlrecpor := vr_qtmaxtur;
                    WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
                      IF NVL(rw_craprdf.qtrecfor,0) = 0 OR NVL(rw_craprdf.qtgrppar,0) = 0 THEN
                        vr_dscritic := vr_dscritic || '#' || 'Quantidades de materiais por FORNECEDOR não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                        vr_flgerror := TRUE;
                        vr_conterro := vr_conterro + 1;
                        IF vr_conterro = 10 THEN
                          RAISE vr_exc_erro;        
                        END IF;
                      END IF;
                                
                    vr_vlrecpor := (NVL(vr_qtmaxtur,0) / NVL(rw_craprdf.qtgrppar,0)) * NVL(rw_craprdf.qtrecfor,0);

                  END CASE;

                  vr_vlmateri := NVL(vr_vlmateri,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

                END IF;

              END IF; 
 
            END IF;          

          END LOOP;

          -- FIM RECURSOS POR FORNECEDOR

         END IF; -- FIM MATERIAIS
         
         IF rw_crapcdp_IV.cdcuseve = 6 THEN -- BRINDES
           
           vr_vlbrinde := 0;

           -- POR EVENTO	
           FOR rw_craprep IN cr_craprep(pr_idevento => pr_idevento
                                       ,pr_cdcooper => 0
                                       ,pr_cdevento => pr_cdevento) LOOP
             
             OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                              ,pr_cdcooper => 0
                              ,pr_idsitrec => 1
                              ,pr_nrseqdig => rw_craprep.nrseqdig
                              ,pr_cdtiprec => '1');

             FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
             IF cr_gnaprdp_II%NOTFOUND THEN 
               CLOSE cr_gnaprdp_II;
             ELSE
               CLOSE cr_gnaprdp_II;
               
               -- Busca o valor do Recurso por Ano
               OPEN cr_crapvra_II(pr_idevento => pr_idevento
                                 ,pr_cdcooper => 0
                                 ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                                 ,pr_dtanoage => pr_dtanoage
                                 ,pr_cdcopvlr => pr_cdcooper);

               FETCH cr_crapvra_II INTO rw_crapvra_II;

               IF cr_crapvra_II%NOTFOUND THEN
                 CLOSE cr_crapvra_II;
                 IF NOT vr_flgbrerr THEN
                   vr_dscritic := vr_dscritic || '#' || 'O brinde por evento(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                   vr_flgerror := TRUE;
                   vr_conterro := vr_conterro + 1;
                   vr_flgbrerr := TRUE;
                   IF vr_conterro = 10 THEN
                     RAISE vr_exc_erro;        
                   END IF;
                 END IF;
               ELSE
                
                 CLOSE cr_crapvra_II;
                 
                 CASE rw_gnaprdp_II.idrecpor

                 WHEN 1 THEN -- POR EVENTO
                   IF NVL(rw_craprep.qtreceve,0) = 0 THEN
                     vr_dscritic := vr_dscritic || '#' || 'Quantidades de brindes não cadastradas por evento para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                     vr_flgerror := TRUE;
                     vr_conterro := vr_conterro + 1;
                     IF vr_conterro = 10 THEN
                       RAISE vr_exc_erro;        
                     END IF;
                   END IF;
                      
                   vr_vlrecpor := rw_craprep.qtreceve;

                 WHEN 2 THEN -- POR PARTICIPANTES
                   vr_vlrecpor := vr_qtmaxtur;
                 WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
                   IF NVL(rw_craprep.qtreceve,0) = 0 OR
                      NVL(rw_craprep.qtgrppar,0) = 0 THEN
                     vr_dscritic := vr_dscritic || '#' || 'Quantidades de brindes não cadastradas por evento para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                     vr_flgerror := TRUE;
                     vr_conterro := vr_conterro + 1;
                     RAISE vr_exc_erro;        
                   END IF;
                           
                  vr_vlrecpor := (NVL(vr_qtmaxtur,0) / NVL(rw_craprep.qtgrppar,0)) * NVL(rw_craprep.qtreceve,0); 

                  END CASE;

                  vr_vlbrinde := NVL(vr_vlbrinde,0) + (NVL(vr_vlrecpor,0) * nvl(rw_crapvra_II.vlrecano,0));  

               END IF;   

             END IF;

           END LOOP;
           -- FIM POR EVENTO

           -- POR PA

           FOR rw_craprpe IN cr_craprpe(pr_idevento => pr_idevento
                                       ,pr_cdcooper => 0
                                       ,pr_cdevento => pr_cdevento
                                       ,pr_cdagenci => rw_crapagp_I.cdagenci
                                       ,pr_cdcopage => pr_cdcooper) LOOP
  
             OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                               ,pr_cdcooper => 0
                               ,pr_idsitrec => 1
                               ,pr_nrseqdig => rw_craprpe.nrseqdig
                               ,pr_cdtiprec => '1');

             FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
             IF cr_gnaprdp_II%NOTFOUND THEN 
               CLOSE cr_gnaprdp_II;
             ELSE
               CLOSE cr_gnaprdp_II;

               -- Busca o valor do Recurso por Ano
               OPEN cr_crapvra_II(pr_idevento => pr_idevento
                                 ,pr_cdcooper => 0
                                 ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                                 ,pr_dtanoage => pr_dtanoage
                                 ,pr_cdcopvlr => pr_cdcooper);

               FETCH cr_crapvra_II INTO rw_crapvra_II;

               IF cr_crapvra_II%NOTFOUND THEN
                 CLOSE cr_crapvra_II;
                 vr_dscritic := vr_dscritic || '#' || 'O brinde(' || UPPER(rw_gnaprdp_II.dsrecurs) || ') do PA(' || UPPER(rw_crapage_II.nmresage) || ') associado ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                 vr_flgerror := TRUE;
                 vr_conterro := vr_conterro + 1;
                 IF vr_conterro = 10 THEN
                   RAISE vr_exc_erro;        
                 END IF;
               ELSE
                 CLOSE cr_crapvra_II;
               END IF;

               CASE rw_gnaprdp_II.idrecpor

               WHEN 1 THEN -- POR EVENTO
                 IF NVL(rw_craprpe.qtrecage,0) = 0 THEN
                   vr_dscritic := vr_dscritic || '#' || 'Quantidades de brindes por PA não cadastradas por evento para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                   vr_flgerror := TRUE;
                   vr_conterro := vr_conterro + 1;
                   IF vr_conterro = 10 THEN
                     RAISE vr_exc_erro;        
                   END IF;
                 END IF;
                      
                 vr_vlrecpor := rw_craprpe.qtrecage;

               WHEN 2 THEN -- POR PARTICIPANTES
                 vr_vlrecpor := vr_qtmaxtur;
               WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
                 IF NVL(rw_craprpe.qtrecage,0) = 0 OR
                    NVL(rw_craprpe.qtgrppar,0) = 0 THEN
                   vr_dscritic := vr_dscritic || '#' || 'Quantidades de brindes por PA não cadastradas por evento para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                   vr_flgerror := TRUE;
                   vr_conterro := vr_conterro + 1;
                   RAISE vr_exc_erro;        
                 END IF;
                           
                vr_vlrecpor := (NVL(vr_qtmaxtur,0) / NVL(rw_craprpe.qtgrppar,0)) * NVL(rw_craprpe.qtrecage,0); 

                END CASE;

                vr_vlbrinde := NVL(vr_vlbrinde,0) + (NVL(vr_vlrecpor,0) * nvl(rw_crapvra_II.vlrecano,0)); 

             END IF;

           END LOOP; -- FIM POR PA          

           -- POR FORNECEDOR
           FOR rw_craprdf IN cr_craprdf(pr_idevento => pr_idevento
                                       ,pr_cdcooper => 0
                                       ,pr_nrcpfcgc => vr_nrcpfcgc 
                                       ,pr_dspropos => vr_nrpropos) LOOP
             
             OPEN cr_gnaprdp_II(pr_idevento => pr_idevento            
                               ,pr_cdcooper => 0
                               ,pr_idsitrec => 1
                               ,pr_nrseqdig => rw_craprpe.nrseqdig
                               ,pr_cdtiprec => '1');

             FETCH cr_gnaprdp_II INTO rw_gnaprdp_II;
                                                     
             IF cr_gnaprdp_II%NOTFOUND THEN 
               CLOSE cr_gnaprdp_II;
             ELSE
               CLOSE cr_gnaprdp_II;

               -- Busca o valor do Recurso por Ano
               OPEN cr_crapvra_II(pr_idevento => pr_idevento
                                 ,pr_cdcooper => 0
                                 ,pr_nrseqdig => rw_gnaprdp_II.nrseqdig
                                 ,pr_dtanoage => pr_dtanoage
                                 ,pr_cdcopvlr => pr_cdcooper);

               FETCH cr_crapvra_II INTO rw_crapvra_II;

               IF cr_crapvra_II%NOTFOUND THEN
                 CLOSE cr_crapvra_II;
                 vr_dscritic := vr_dscritic || '#' || 'O brinde(' + UPPER(rw_gnaprdp_II.dsrecurs) || ') por fornecedor associados ao evento, não possui valor cadastrado. Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                 vr_flgerror := TRUE;
                 vr_conterro := vr_conterro + 1;
                 IF vr_conterro = 10 THEN
                   RAISE vr_exc_erro;        
                 END IF;
               ELSE
                 CLOSE cr_crapvra_II;

                 CASE rw_gnaprdp_II.idrecpor

                 WHEN 1 THEN -- POR EVENTO
                   IF NVL(rw_craprdf.qtrecfor,0) = 0 THEN
                     vr_dscritic := vr_dscritic || '#' || 'Quantidades de brindes por fornecedor não cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                     vr_flgerror := TRUE;
                     vr_conterro := vr_conterro + 1;
                     IF vr_conterro = 10 THEN
                       RAISE vr_exc_erro;        
                     END IF;
                   END IF;
       
                   vr_vlrecpor := rw_craprdf.qtrecfor;

                 WHEN 2 THEN -- POR PARTICIPANTES
                   vr_vlrecpor := vr_qtmaxtur;
                 WHEN 3 THEN -- POR GRUPO DE PARTICIPANTES
                   IF NVL(rw_craprdf.qtrecfor,0) = 0 OR
                      NVL(rw_craprdf.qtgrppar,0) = 0 THEN
                     vr_dscritic := vr_dscritic || '#' || 'Quantidades de brindes por fornecedor năo cadastradas para o recurso(' || UPPER(rw_gnaprdp_II.dsrecurs) || '). Favor solicitar o cadastro antes de prosseguir com o cálculo do Custo Orçado.';
                     vr_flgerror := TRUE;
                     vr_conterro := vr_conterro + 1;
                     RAISE vr_exc_erro;        
                   END IF;
                             
                   vr_vlrecpor := (NVL(vr_qtmaxtur,0) / NVL(rw_craprdf.qtgrppar,0)) * NVL(rw_craprdf.qtrecfor,0); 

                 END CASE;

                 vr_vlbrinde := NVL(vr_vlbrinde,0) + (NVL(vr_vlrecpor,0) * NVL(rw_crapvra_II.vlrecano,0));

               END IF;

             END IF;             

           END LOOP; -- FIM POR FORNECEDOR

         END IF; -- FIM BRINDES

         CASE rw_crapcdp_IV.cdcuseve
           WHEN 1 THEN -- Honorários
            
             IF pr_cdagenci = '0' AND gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN
           
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;                  
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(pr_vlrhonor,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(pr_vlrhonor,0);
               END IF;    
             END IF;
            
           WHEN 2 THEN -- Local
            
             IF gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(vr_vlrlocal,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(vr_vlrlocal,0);
               END IF;
             END IF;
            
           WHEN 3 THEN -- Alimentacao

             IF gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(vr_vlalimen,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(vr_vlalimen,0);
               END IF;
             END IF;

           WHEN 4 THEN -- Material

             IF gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(vr_vlmateri,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(vr_vlmateri,0);
               END IF;
             END IF;

           WHEN 5 THEN -- Transportes

             IF gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN             
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(vr_vltransp,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(vr_vltransp,0);
               END IF;
             END IF;
            
           WHEN 6 THEN -- Brindes
            
             IF gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(vr_vlbrinde,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(vr_vlbrinde,0);
               END IF;
             END IF;            
           
           WHEN 7 THEN -- Divulgaçao
             IF gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(vr_vldivulg,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(vr_vldivulg,0);
               END IF;
             END IF;
            
           WHEN 8 THEN --Outros
            
             IF gene0002.fn_existe_valor(pr_agerepli,TO_CHAR(rw_crapage_II.cdagenci),',') = 'S' THEN
               IF NVL(vr_nrcpfcgc,0) = 0 AND NVL(vr_nrdocfmd,0) > 0 THEN
                 rw_crapcdp_IV.vlcuseve := 0;
               ELSE
                 rw_crapcdp_IV.vlcuseve := NVL(pr_vloutros,0);
                 vr_vlrtermo := vr_vlrtermo + NVL(pr_vloutros,0);
               END IF;
             END IF;
            
         END CASE; -- CASE rw_crapcdp_IV.cdcuseve

         -- Atualiza registro de Custo do evento
         UPDATE crapcdp
           SET idevento = rw_crapcdp_IV.idevento
              ,cdcooper = rw_crapcdp_IV.cdcooper
              ,cdevento = rw_crapcdp_IV.cdevento
              ,cdcuseve = rw_crapcdp_IV.cdcuseve
              ,cdagenci = rw_crapcdp_IV.cdagenci
              ,dtanoage = rw_crapcdp_IV.dtanoage
              ,vlcuseve = rw_crapcdp_IV.vlcuseve
              ,flgfecha = rw_crapcdp_IV.flgfecha
              ,tpcuseve = rw_crapcdp_IV.tpcuseve
              ,qtditens = rw_crapcdp_IV.qtditens
              ,prdescon = rw_crapcdp_IV.prdescon
              ,dsjustif = rw_crapcdp_IV.dsjustif
           WHERE crapcdp.ROWID = rw_crapcdp_IV.ROWID;

      END LOOP; -- cr_crapcdp_IV
    
      -- INSERE VALOR DE TERMO
      BEGIN

        UPDATE crapcdp
           SET crapcdp.vlcuseve = vr_vlrtermo
         WHERE crapcdp.idevento = pr_idevento
           AND crapcdp.cdcooper = pr_cdcooper
           AND crapcdp.cdagenci = rw_crapagp_I.cdagenci
           AND crapcdp.dtanoage = pr_dtanoage
           AND crapcdp.tpcuseve = 4
           AND crapcdp.cdevento = pr_cdevento
           AND crapcdp.cdcuseve = 1;

        -- Verifica se houve atualizacao de registros
        IF SQL%ROWCOUNT = 0 THEN
          BEGIN
            INSERT INTO crapcdp(
                          idevento
                         ,cdcooper
                         ,cdevento
                         ,cdcuseve
                         ,cdagenci
                         ,dtanoage
                         ,vlcuseve
                         ,flgfecha
                         ,nrpropos
                         ,nrcpfcgc
                         ,tpcuseve
                         ,qtditens
                         ,prdescon
                         ,dsjustif
                         ,nrdocfmd)
                  VALUES(pr_idevento            -- idevento
                        ,pr_cdcooper            -- cdcooper
                        ,pr_cdevento            -- cdevento
                        ,1                      -- cdcuseve
                        ,rw_crapagp_I.cdagenci  -- cdagenci
                        ,pr_dtanoage            -- dtanoage
                        ,vr_vlrtermo            -- vlcuseve
                        ,1                      -- flgfecha
                        ,'0'                    -- nrpropos
                        ,0                      -- nrcpfcgc
                        ,4                      -- tpcuseve
                        ,0                      -- qtditens
                        ,0                      -- prdescon
                        ,''                     -- dsjustif
                        ,0);                    -- nrdocfmd
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de Custo Orçado(CRAPCDP) referente ao valor de Termo. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
          END;              
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro de Custo Orçado(CRAPCDP) referente ao valor de Termo. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

    END LOOP; -- cr_crapage_II
 
    -- Se ocorreu algum erro não efetiva o calculo
    IF vr_flgerror THEN
      RAISE vr_exc_erro;
    END IF;

    COMMIT;         
  
  EXCEPTION
    WHEN vr_exc_erro THEN    
      pr_dscritic := vr_dscritic;    
      ROLLBACK;    
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em PC_WPGD0018.pc_calcula_custo_orcado: ' || SQLERRM;
      ROLLBACK;    
  END pc_calcula_custo_orcado;

END wpgd0018;--
/
