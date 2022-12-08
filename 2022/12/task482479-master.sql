    DECLARE
     pr_cdcooper crapcop.cdcooper%TYPE := 1;
     pr_cdgrupo   NUMBER := 1;
     pr_idparale NUMBER := 0;
     pr_dscritic VARCHAR2(3000);
     pr_cdcritic NUMBER;
     pr_infimsol NUMBER;
     pr_stprogra NUMBER;
     vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS480';
     vr_exc_erro exception;
     vr_dslog        VARCHAR2(4000) := '';
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
     
      vr_exc_undo EXCEPTION;
     
      vr_exc_next EXCEPTION;

      vr_tab_split  gene0002.typ_split;
      vr_idx_split  gene0002.typ_split;
      vr_qtdjobs    NUMBER := 0;
      vr_jobname    VARCHAR2(500);
      vr_dsplsql    VARCHAR2(3000);
      vr_qterro     NUMBER := 0;
      vr_idparale   NUMBER;
      vr_idlog_ini_ger  NUMBER;
      vr_idlog_ini_par  NUMBER;
      vr_tpexecucao     tbgen_prglog.tpexecucao%type;

      vr_nrini NUMBER := 0;
      vr_nrfim NUMBER := 0;

      CURSOR cr_carga(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT nrdconta registro
          FROM cecred.crapass a
         WHERE a.cdcooper = pr_cdcooper
      ORDER BY nrdconta;
      rw_carga cr_carga%ROWTYPE;

     
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.nrctactl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

     
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

     
      vr_dstextab     craptab.dstextab%TYPE;

      vr_dtinitax     DATE;                  
      vr_dtfimtax     DATE;                  

      vr_vlsdapat NUMBER;              
      vr_qtregres NUMBER := 0;         


      TYPE typ_reg_craprej IS
        RECORD(cdempres craprej.cdempres%TYPE
              ,tplotmov craprej.tplotmov%TYPE
              ,vllanmto craprej.vllanmto%TYPE
              ,nrseqdig craprej.nrseqdig%TYPE);

      TYPE typ_tab_craprej IS
        TABLE OF typ_reg_craprej
          INDEX BY BINARY_INTEGER;

      vr_tab_craprej typ_tab_craprej;

      vr_num_chave_craprej PLS_INTEGER; 

      TYPE typ_reg_resumo IS
        RECORD(tpaplica INTEGER
              ,tpaplrdc INTEGER
              ,dsaplica VARCHAR2(6)
              ,qtaplati NUMBER(7)    DEFAULT 0 
              ,qtaplmes NUMBER(6)    DEFAULT 0 
              ,vlsdapat NUMBER(14,2) DEFAULT 0 
              ,vlaplmes NUMBER(14,2) DEFAULT 0 
              ,vlresmes NUMBER(14,2) DEFAULT 0 
              ,vlrenmes NUMBER(14,2) DEFAULT 0 
              ,vlprvmes NUMBER(14,2) DEFAULT 0 
              ,vlprvlan NUMBER(14,2) DEFAULT 0 
              ,vlajuprv NUMBER(14,2) DEFAULT 0 
              ,vlsqsren NUMBER(14,2) DEFAULT 0 
              ,vlsqcren NUMBER(14,2) DEFAULT 0 
              ,vlrtirrf NUMBER(14,2) DEFAULT 0);

      TYPE typ_tab_resumo IS
        TABLE OF typ_reg_resumo
          INDEX BY BINARY_INTEGER;

      TYPE typ_tab_fisjur IS 
        TABLE OF typ_tab_resumo 
          INDEX BY BINARY_INTEGER; 
      
      vr_tab_resumo typ_tab_resumo;
      vr_tab_fisjur typ_tab_fisjur;

      vr_num_chave_resumo BINARY_INTEGER;
      vr_idx BINARY_INTEGER;


      vr_des_chave_det VARCHAR2(19);

      vr_indvecto NUMBER(1);


      TYPE typ_reg_cta_bndes IS
        RECORD(nrdconta NUMBER
              ,tpaplica NUMBER
              ,vlaplica NUMBER);

      TYPE typ_tab_cta_bndes IS
        TABLE OF typ_reg_cta_bndes
          INDEX BY VARCHAR2(9); 

      vr_tab_cta_bndes typ_tab_cta_bndes;

      vr_des_chave_bndes VARCHAR2(9);


      TYPE typ_reg_resumo_cecred IS
        RECORD(nrdconta NUMBER   
              ,nmrescop VARCHAR2(20)
              ,qtaplati NUMBER(7)   
              ,vlprvmes NUMBER(17,2)
              ,vlrenmes NUMBER(17,2)
              ,vlajuprv NUMBER(17,2)
              ,vlsldmed NUMBER(17,2));

      TYPE typ_tab_resumo_cecred IS
        TABLE OF typ_reg_resumo_cecred
          INDEX BY BINARY_INTEGER; 

      vr_tab_resumo_cecred typ_tab_resumo_cecred;

      vr_num_chave_resumo_cecred BINARY_INTEGER;


      TYPE typ_reg_periodo IS VARRAY(19) OF NUMBER(4);
      vr_vet_periodo typ_reg_periodo := typ_reg_periodo(90,180,270,360,720,1080,1440
                                                       ,1800,2160,2520,2880,3240,3600
                                                       ,3960,4320,4680,5040,5400,5401);

      vr_tab_blqrgt APLI0001.typ_tab_ctablq;


      type typ_reg_crapass is record (cdagenci crapass.cdagenci%TYPE,
                                      nrdconta crapass.nrdconta%TYPE,
                                      nmprimtl crapass.nmprimtl%TYPE,
                                      inpessoa crapass.inpessoa%TYPE,
                                      inpescob crapass.inpessoa%TYPE,
                                      nmrescop crapass.nmprimtl%TYPE,
                                      nmresage crapage.nmresage%TYPE,
                                      cdmodalidade_tipo tbcc_tipo_conta.cdmodalidade_tipo%TYPE);

      type typ_tab_reg_crapass is table of typ_reg_crapass
                             index by Binary_Integer;
      vr_tab_crapass typ_tab_reg_crapass;

      CURSOR cr_craprda IS
        SELECT 
               dtc.tpaplrdc
              ,dtc.dsaplica
              ,rda.tpaplica
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.cdageass
              ,age.nmresage
              ,rda.inaniver
              ,rda.vlaplica
              ,rda.dtmvtolt
              ,rda.dtvencto
              ,rda.dtiniper
              ,rda.dtfimper
              ,rda.vlsdrdca
              ,rda.dtatslmm
              ,rda.vlsltxmm
              ,rda.dtatslmx
              ,rda.vlsltxmx
              ,rda.vlslfmes
              ,rda.vlsdextr
              ,rda.dtsdfmes
              ,rda.dtcalcul
              ,rda.insaqtot
              ,rda.qtdiauti
              ,rda.dtsdfmea
              ,rda.vlslfmea
              ,rda.rowid
          FROM craprda rda
              ,crapdtc dtc
              ,crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND dtc.cdcooper = pr_cdcooper
           AND rda.cdcooper = age.cdcooper
           AND rda.cdageass = age.cdagenci
           AND rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND rda.cdcooper = pr_cdcooper
           AND rda.insaqtot = 0          
           AND dtc.tpaplrdc IN(1,2)      
         ORDER BY rda.cdcooper, rda.tpaplica, rda.insaqtot, rda.cdageass, rda.nrdconta, rda.nraplica;

      CURSOR cr_craprda_grupo(pr_regisini IN tbgen_batch_paralelo.regisini%TYPE DEFAULT 0,
                              pr_regisfim IN tbgen_batch_paralelo.regisfim%TYPE DEFAULT 0) IS
       SELECT 
               dtc.tpaplrdc
              ,dtc.dsaplica
              ,rda.tpaplica
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.cdageass
              ,age.nmresage
              ,rda.inaniver
              ,rda.vlaplica
              ,rda.dtmvtolt
              ,rda.dtvencto
              ,rda.dtiniper
              ,rda.dtfimper
              ,rda.vlsdrdca
              ,rda.dtatslmm
              ,rda.vlsltxmm
              ,rda.dtatslmx
              ,rda.vlsltxmx
              ,rda.vlslfmes
              ,rda.vlsdextr
              ,rda.dtsdfmes
              ,rda.dtcalcul
              ,rda.insaqtot
              ,rda.qtdiauti
              ,rda.dtsdfmea
              ,rda.vlslfmea
              ,rda.rowid
          FROM craprda rda
              ,crapdtc dtc
              ,crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND dtc.cdcooper = pr_cdcooper
           AND rda.cdcooper = age.cdcooper
           AND rda.nrdconta BETWEEN pr_regisini AND pr_regisfim
           AND rda.cdageass = age.cdagenci
           AND rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND rda.cdcooper = pr_cdcooper
           AND rda.insaqtot = 0          
           AND dtc.tpaplrdc IN(1,2) 
           AND rda.dtmvtolt < to_date('01/12/2022','dd/mm/rrrr')
         ORDER BY rda.cdcooper, rda.tpaplica, rda.insaqtot, rda.cdageass, rda.nrdconta, rda.nraplica; 
         
      TYPE typ_craprda_bulk IS TABLE OF cr_craprda%ROWTYPE;
      vr_tab_craprda_bulk typ_craprda_bulk;
      
      CURSOR cr_craprej(pr_nrdconta IN craprej.nrdconta%TYPE) IS
        SELECT rej.rowid
          FROM craprej rej
         WHERE rej.cdcooper = pr_cdcooper
           AND rej.cdpesqbb = vr_cdprogra
           AND rej.tpintegr = 2          
           AND nrdconta     = pr_nrdconta
         ORDER BY rej.progress_recid;
      vr_craprej_rowid ROWID;

      CURSOR cr_craplap(pr_nrdconta IN craprda.nrdconta%TYPE
                       ,pr_nraplica IN craplap.nraplica%TYPE
                       ,pr_dtmvtolt IN craplap.dtmvtolt%TYPE) IS
        SELECT lap.txaplica
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta 
           AND lap.nraplica = pr_nraplica 
           AND lap.dtmvtolt = pr_dtmvtolt 
         ORDER BY lap.progress_recid;     
      rw_craplap cr_craplap%ROWTYPE;


      CURSOR cr_craplot(pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = rw_crapdat.dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote
         ORDER BY cdcooper, dtmvtolt, cdagenci, cdbccxlt, nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      CURSOR cr_craprej_cecred IS
        SELECT rej.nrdconta
              ,SUBSTR(ass.nmprimtl,1,INSTR(ass.nmprimtl,'-',-1)-1) nmrescop
              ,rej.nrseqdig
          FROM crapass ass
              ,craprej rej
         WHERE rej.cdcooper = ass.cdcooper
           AND ass.cdcooper = pr_cdcooper
           AND rej.nrdconta = ass.nrdconta
           AND rej.cdcooper = pr_cdcooper
           AND rej.cdpesqbb = vr_cdprogra
           AND rej.tpintegr = 2
         ORDER BY rej.nrdconta;

      CURSOR cr_crapass_cecred IS
        SELECT SUBSTR(ass.nmprimtl,1,INSTR(ass.nmprimtl,'-',-1)-1) nmrescop,
               ass.nmprimtl,
               ass.nrdconta,
               DECODE(ass.inpessoa, 3, 2, ass.inpessoa) inpescob, 
               DECODE(ass.inpessoa, 2, DECODE(ttc.cdmodalidade_tipo, 4, 3, ass.inpessoa), 3, 2, ass.inpessoa) inpessoa, 
               ass.cdagenci,
               age.nmresage,
               nvl(ttc.cdmodalidade_tipo,0) cdmodalidade_tipo
          FROM crapass ass,
               crapage age,
               tbcc_tipo_conta ttc
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.inpessoa = ttc.inpessoa
           AND ass.cdtipcta = ttc.cdtipo_conta
           AND ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci;
      
      CURSOR cr_crapass_cecred_grupo(pr_regisini IN tbgen_batch_paralelo.regisini%TYPE DEFAULT 0,
                                     pr_regisfim IN tbgen_batch_paralelo.regisfim%TYPE DEFAULT 0) IS
         SELECT SUBSTR(ass.nmprimtl,1,INSTR(ass.nmprimtl,'-',-1)-1) nmrescop,
               ass.nmprimtl,
               ass.nrdconta,
               DECODE(ass.inpessoa, 3, 2, ass.inpessoa) inpescob,
               DECODE(ass.inpessoa, 2, DECODE(ttc.cdmodalidade_tipo, 4, 3, ass.inpessoa), 3, 2, ass.inpessoa) inpessoa,
               ass.cdagenci,
               age.nmresage,
               nvl(ttc.cdmodalidade_tipo,0) cdmodalidade_tipo
          FROM crapass ass,
               crapage age,
               tbcc_tipo_conta ttc
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta BETWEEN pr_regisini AND pr_regisfim
           AND ass.inpessoa = ttc.inpessoa
           AND ass.cdtipcta = ttc.cdtipo_conta
           AND ass.cdcooper = age.cdcooper
           AND ass.cdagenci = age.cdagenci;

      CURSOR cr_crapdtc_ini IS
        SELECT dtc.tpaplica
          FROM crapdtc dtc
         WHERE dtc.cdcooper  = pr_cdcooper
           AND dtc.tpaplrdc IN (1,2);
      
      TYPE typ_crapass_bulk IS TABLE of cr_crapass_cecred%ROWTYPE;
      vr_tab_crapass_bulk typ_crapass_bulk;

      CURSOR cr_craplap_mes IS
        SELECT
               rda.insaqtot
              ,rda.nrdconta
              ,rda.nraplica
              ,dtc.tpaplrdc
              ,dtc.dsaplica
              ,rda.tpaplica
              ,rda.dtvencto
              ,rda.cdageass
              ,age.nmresage
              ,lap.dtmvtolt
              ,rda.dtmvtolt rda_dtmvtolt
              ,rda.vlaplica
              ,rda.vlslfmes
              ,rda.inaniver
              ,rda.dtfimper
              ,lap.txaplica
              ,lap.cdhistor
              ,lap.vllanmto
              ,lap.nrdolote
              ,rda.qtdiauti
          FROM craplap lap
              ,crapage age
              ,craprda rda
              ,crapdtc dtc
         WHERE rda.cdcooper = pr_cdcooper
           AND age.cdcooper = pr_cdcooper
           AND dtc.cdcooper = pr_cdcooper
           AND rda.cdcooper = age.cdcooper
           AND rda.cdageass = age.cdagenci
           AND lap.cdcooper = rda.cdcooper
           AND lap.nrdconta = rda.nrdconta
           AND lap.nraplica = rda.nraplica
           AND rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND lap.cdcooper = pr_cdcooper
           AND lap.dtmvtolt > to_date('01/11/2022','dd/mm/rrrr')
           AND lap.dtmvtolt < rw_crapdat.dtmvtolt + 1
           AND lap.cdhistor IN(474,529,473,528,477,534,532,475,531,463,476,533,3097,3094,3096,3098,3095,3093,3102,3104,3105,3106,3103,3101)
           AND dtc.tpaplrdc IN(1,2);

      CURSOR cr_craplap_mes_grupo(pr_regisini IN tbgen_batch_paralelo.regisini%TYPE DEFAULT 0,
                                  pr_regisfim IN tbgen_batch_paralelo.regisfim%TYPE DEFAULT 0) IS
        SELECT rda.insaqtot
              ,rda.nrdconta
              ,rda.nraplica
              ,dtc.tpaplrdc
              ,dtc.dsaplica
              ,rda.tpaplica
              ,rda.dtvencto
              ,rda.cdageass
              ,age.nmresage
              ,lap.dtmvtolt
              ,rda.dtmvtolt rda_dtmvtolt
              ,rda.vlaplica
              ,rda.vlslfmes
              ,rda.inaniver
              ,rda.dtfimper
              ,lap.txaplica
              ,lap.cdhistor
              ,lap.vllanmto
              ,lap.nrdolote
              ,rda.qtdiauti
          FROM craplap lap
              ,crapage age
              ,craprda rda
              ,crapdtc dtc
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta BETWEEN pr_regisini AND pr_regisfim
           AND age.cdcooper = pr_cdcooper
           AND dtc.cdcooper = pr_cdcooper
           AND rda.cdcooper = age.cdcooper
           AND rda.cdageass = age.cdagenci
           AND lap.cdcooper = rda.cdcooper
           AND lap.nrdconta = rda.nrdconta
           AND lap.nraplica = rda.nraplica
           AND rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND lap.cdcooper = pr_cdcooper
           AND lap.dtmvtolt > to_date('01/11/2022','dd/mm/rrrr')
           AND lap.dtmvtolt < rw_crapdat.dtmvtolt + 1 
           AND lap.cdhistor IN(474,529,473,528,477,534,532,475,531,463,476,533,3097,3094,3096,3098,3095,3093,3102,3104,3105,3106,3103,3101)
           AND dtc.tpaplrdc IN(1,2);

      TYPE typ_craplap_mes_bulk IS TABLE OF cr_craplap_mes%ROWTYPE;
      vr_tab_craplap_mes_bulk typ_craplap_mes_bulk;

      CURSOR cr_craplap_histor(pr_nrdconta IN craplap.nrdconta%TYPE
                              ,pr_nraplica IN craplap.nraplica%TYPE
                              ,pr_cdhistor IN craplap.cdhistor%TYPE
                              ,pr_dtmvtolt IN craplap.dtmvtolt%TYPE)IS
        SELECT COUNT(1)
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.dtmvtolt = pr_dtmvtolt
           AND lap.cdhistor = pr_cdhistor;
      vr_num_exis NUMBER;
           
      CURSOR cr_crapsda(pr_cdcooper crapsda.cdcooper%TYPE
                       ,pr_nrdconta crapsda.nrdconta%TYPE
                       ,pr_dtmvtoan crapdat.dtmvtoan%TYPE
                       ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT (vlsldmed / (SELECT dat.qtdiaute
                              FROM crapdat dat
                             WHERE cdcooper = pr_cdcooper))
          FROM (SELECT SUM(vlsldmed) vlsldmed
                  FROM (SELECT SUM(vlsrdcpo) vlsldmed
                          FROM crapsda
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND dtmvtolt BETWEEN last_day(add_months(pr_dtmvtoan, -1)) + 1 AND pr_dtmvtoan
                         UNION ALL
                        SELECT SUM(vlslfmea)
                          FROM craprda
                         WHERE cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND dtsdfmea = pr_dtmvtolt));     
                           
      vr_dtiniper           DATE;
      vr_dtfimper           DATE;
      vr_vlsldrdc           craprda.vlsdrdca%TYPE;
      vr_vllanmto           NUMBER(18,4);         
      vr_vllctprv           craplap.vllanmto%TYPE;
      vr_vlrendmm           craplap.vlrendmm%TYPE;

      vr_nrdocmto           craplap.nrdocmto%TYPE;
      vr_cdhistor           INTEGER;     
      vr_rowid_craplap      ROWID;       

      vr_prazodia           NUMBER; 
      vr_tipprazo           NUMBER; 

      vr_cdempres           NUMBER;  
      vr_tot_vlacumul       NUMBER;  
      vr_des_periodo        VARCHAR2(20); 
      vr_des_xml            CLOB;         
      vr_dsjasper           VARCHAR2(30); 
      vr_sqcabrel           NUMBER;       

      vr_nmformul           VARCHAR2(10); 
      vr_qtcoluna           NUMBER;       

      vr_nom_direto         VARCHAR2(100);
      vr_nom_arquivo        VARCHAR2(100);

      vr_cdcritic           NUMBER;
      vr_dscritic           VARCHAR2(2000);

      vr_Bufdes_xml varchar2(32000);
      
      vr_idprglog NUMBER;
      
      
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fimarq    IN BOOLEAN default false) IS
      BEGIN

      
        IF length(vr_Bufdes_xml) + length(pr_des_dados) > 31000 OR pr_fimarq THEN
          dbms_lob.writeappend(vr_des_xml,length(vr_Bufdes_xml||pr_des_dados),vr_Bufdes_xml||pr_des_dados);
          vr_Bufdes_xml := null;
        ELSE
      
          vr_Bufdes_xml := vr_Bufdes_xml||pr_des_dados;
        END IF;
      END;

      
      

  PROCEDURE pc_inicializa IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
   
    BEGIN
      DELETE tbfin_fluxo_contas_sysphera 
       WHERE cdcooper = pr_cdcooper
         AND cdconta  = 25;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        pr_cdcritic := 1037;
        pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic)||' tbfin_fluxo_contas_sysphera '||
                      'com cdcooper:'||pr_cdcooper||
                      ', cdconta: 25'||
                      '. '||sqlerrm;
      RAISE vr_exc_erro;
    END;

   
    OPEN cr_craplot(pr_cdagenci => 1
                   ,pr_cdbccxlt => 100
                   ,pr_nrdolote => 8480);
    FETCH cr_craplot INTO rw_craplot;

    IF cr_craplot%NOTFOUND THEN
      CLOSE cr_craplot;
      BEGIN
        INSERT INTO craplot(cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,tplotmov
                           ,vlinfodb
                           ,vlcompdb
                           ,qtinfoln
                           ,qtcompln
                           ,vlinfocr
                           ,vlcompcr)
                     VALUES(pr_cdcooper
                           ,rw_crapdat.dtmvtolt
                           ,1
                           ,100
                           ,8480
                           ,9
                           ,0
                           ,0
                           ,0
                           ,0
                           ,0
                           ,0)
                   RETURNING cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,tplotmov
                            ,nrseqdig
                            ,rowid
                        INTO rw_craplot.cdagenci
                            ,rw_craplot.cdbccxlt
                            ,rw_craplot.nrdolote
                            ,rw_craplot.tplotmov
                            ,rw_craplot.nrseqdig
                            ,rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          pr_cdcritic := 1034;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' craplot: '||
                        'cdcooper:'  ||pr_cdcooper||
                        ', dtmvtolt:'||rw_crapdat.dtmvtolt||
                        ', cdagenci:1, cdbccxlt:100, nrdolote:8480'||
                        ', tplotmov:9, vlinfodb:0, vlcompdb:0'||
                        ', qtinfoln:0, qtcompln:0, vlinfocr:0, vlcompcr:0'||
                        '. '||sqlerrm;
          RAISE vr_exc_erro;
      END;
    ELSE
      CLOSE cr_craplot;
    END IF;
    COMMIT;
  END pc_inicializa;
  
  BEGIN
  
    vr_cdprogra := 'CRPS480';

    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      pr_cdcritic := 1;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    IF nvl(pr_cdgrupo,0) = 0 THEN

  
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => pr_cdcritic);
      IF pr_cdcritic <> 0 THEN
        RAISE vr_exc_erro;
      END IF;

      pc_inicializa();

      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper => pr_cdcooper
                                                   ,pr_cdprogra => vr_cdprogra);
    ELSE
       pc_inicializa();
    END IF;

    IF rw_crapdat.inproces  > 2 AND
       vr_qtdjobs           > 0 AND 
       pr_cdgrupo           = 0 THEN

      vr_idparale := gene0001.fn_gera_id_paralelo;
      IF vr_idparale = 0 THEN
         vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_id_paralelo.';
         RAISE vr_exc_erro;
      END IF;
      
      vr_dscritic := 'Erro na quantidade de grupos';
      RAISE vr_exc_erro;
    

    ELSE      

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
       
      IF cr_crapcop%NOTFOUND THEN
       
        CLOSE cr_crapcop;
       
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
       
        CLOSE cr_crapcop;
      END IF;
                  
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'MXRENDIPOS'
                     ,pr_tpregist => 1);
                                               

      IF TRIM(vr_dstextab) IS NULL THEN

        vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
        vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
      ELSE

        vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/YYYY');
        vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/YYYY');
      END IF;

      TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                ,pr_tab_cta_bloq => vr_tab_blqrgt);
      
      vr_nrini := 1909886;
      vr_nrfim := 1948792;

      IF vr_nrini > 0 THEN
        OPEN cr_crapass_cecred_grupo(vr_nrini, vr_nrfim);
        FETCH cr_crapass_cecred_grupo BULK COLLECT INTO vr_tab_crapass_bulk;        
        CLOSE cr_crapass_cecred_grupo;
      ELSE
        OPEN cr_crapass_cecred;
        FETCH cr_crapass_cecred BULK COLLECT INTO vr_tab_crapass_bulk;
        CLOSE cr_crapass_cecred;
      END IF;


      IF vr_tab_crapass_bulk.COUNT > 0 THEN
        FOR idx IN vr_tab_crapass_bulk.FIRST..vr_tab_crapass_bulk.LAST LOOP
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nrdconta := vr_tab_crapass_bulk(idx).nrdconta;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).cdagenci := vr_tab_crapass_bulk(idx).cdagenci;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nmrescop := vr_tab_crapass_bulk(idx).nmrescop;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nmprimtl := vr_tab_crapass_bulk(idx).nmprimtl;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).inpessoa := vr_tab_crapass_bulk(idx).inpessoa;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).inpescob := vr_tab_crapass_bulk(idx).inpescob;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).nmresage := vr_tab_crapass_bulk(idx).nmresage;
          vr_tab_crapass(vr_tab_crapass_bulk(idx).nrdconta).cdmodalidade_tipo := vr_tab_crapass_bulk(idx).cdmodalidade_tipo;
        END LOOP;
      END IF;
      

      FOR rw_crapdtc IN cr_crapdtc_ini LOOP

        vr_tab_fisjur(1)(rw_crapdtc.tpaplica).qtaplati := 0;
        vr_tab_fisjur(2)(rw_crapdtc.tpaplica).qtaplati := 0;
        vr_tab_fisjur(3)(rw_crapdtc.tpaplica).qtaplati := 0;
      END LOOP;
      
      IF vr_nrini > 0 THEN
        OPEN cr_craprda_grupo(vr_nrini, vr_nrfim);
        FETCH cr_craprda_grupo BULK COLLECT INTO vr_tab_craprda_bulk;        
        CLOSE cr_craprda_grupo;
      ELSE
        OPEN cr_craprda;
        FETCH cr_craprda BULK COLLECT INTO vr_tab_craprda_bulk;
        CLOSE cr_craprda;
      END IF;
      
      IF vr_tab_craprda_bulk.COUNT > 0 THEN
        FOR i IN vr_tab_craprda_bulk.FIRST..vr_tab_craprda_bulk.LAST LOOP
        BEGIN

         vr_dslog := 'UPDATE cecred.crarda SET dtsdfmea = '|| REPLACE(vr_tab_craprda_bulk(i).dtsdfmea,',','.') ||
                                       ', vlsdextr = '|| REPLACE(vr_tab_craprda_bulk(i).vlsdextr,',','.') || 
                                       ', dtsdfmes = '|| REPLACE(vr_tab_craprda_bulk(i).dtsdfmes,',','.') ||    
                                       ', dtatslmx = '|| REPLACE(vr_tab_craprda_bulk(i).dtatslmx,',','.') ||  
                                       ', vlsltxmx = '|| REPLACE(vr_tab_craprda_bulk(i).vlsltxmx,',','.') ||  
                                       ', dtatslmm = '|| REPLACE(vr_tab_craprda_bulk(i).dtatslmm,',','.') ||  
                                       ', vlsltxmm = '|| REPLACE(vr_tab_craprda_bulk(i).vlsltxmm,',','.') ||  
                                       ', vlslfmes = '|| REPLACE(vr_tab_craprda_bulk(i).vlslfmes,',','.') ||  
                                       ', dtcalcul = '|| REPLACE(vr_tab_craprda_bulk(i).dtcalcul,',','.') ||  
                                       ', vlslfmea = '|| REPLACE(vr_tab_craprda_bulk(i).vlslfmea,',','.') ||                             
                ' WHERE CDCOOPER = '||pr_cdcooper ||
                  ' AND NRDCONTA = '||vr_tab_craprda_bulk(i).nrdconta||
                  ' A ND NRAPLICA = '||vr_tab_craprda_bulk(i).nraplica||';';

     CECRED.pc_log_programa(pr_dstiplog      => 'O'
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 111
                           ,pr_cdprograma    => 'INC0235239'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
 
          OPEN cr_craplap(pr_nrdconta => vr_tab_craprda_bulk(i).nrdconta
                         ,pr_nraplica => vr_tab_craprda_bulk(i).nraplica
                         ,pr_dtmvtolt => vr_tab_craprda_bulk(i).dtmvtolt);
          FETCH cr_craplap
           INTO rw_craplap;

          IF cr_craplap%NOTFOUND THEN

            CLOSE cr_craplap;

            pr_cdcritic := 90;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 90)
                          || gene0002.fn_mask_conta(vr_tab_craprda_bulk(i).nrdconta)
                          || gene0002.fn_mask(vr_tab_craprda_bulk(i).nraplica,'zzz.zz9');

            RAISE vr_exc_undo;
          ELSE 

            CLOSE cr_craplap;
          END IF;
          
          vr_dtiniper := add_months(rw_crapdat.dtinimes, -1);
          
            IF vr_dtiniper < vr_tab_craprda_bulk(i).dtiniper THEN
          
              vr_dtiniper := vr_tab_craprda_bulk(i).dtiniper;
            END IF;
          
          vr_dtfimper := rw_crapdat.dtmvtolt;
          
            IF vr_dtfimper > vr_tab_craprda_bulk(i).dtfimper THEN
          
              vr_dtfimper := vr_tab_craprda_bulk(i).dtfimper;
          END IF;
          
            vr_tab_craprda_bulk(i).vlsdextr := vr_tab_craprda_bulk(i).vlsdrdca;
            vr_tab_craprda_bulk(i).dtsdfmes := rw_crapdat.dtmvtolt;
          
          vr_vlsdapat := 0;
          vr_vlrendmm := 0;
          
            IF vr_tab_craprda_bulk(i).tpaplrdc = 1 THEN
            vr_dtfimper := rw_crapdat.dtinimes;
            APLI0001.pc_provisao_rdc_pre(pr_cdcooper  => pr_cdcooper        
                                          ,pr_nrdconta  => vr_tab_craprda_bulk(i).nrdconta
                                          ,pr_nraplica  => vr_tab_craprda_bulk(i).nraplica
                                        ,pr_dtiniper  => vr_dtiniper      
                                        ,pr_dtfimper  => vr_dtfimper      
                                        ,pr_vlsdrdca  => vr_vlsldrdc      
                                        ,pr_vlrentot  => vr_vllanmto      
                                        ,pr_vllctprv  => vr_vllctprv      
                                        ,pr_des_reto => vr_des_reto       
                                        ,pr_tab_erro => vr_tab_erro);     

            IF vr_des_reto = 'NOK' THEN

              IF vr_tab_erro.COUNT > 0 then

                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE

                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_provisao_rdc_pre.';
              END IF;

                pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(vr_tab_craprda_bulk(i).nrdconta)
                                           || ' - Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda_bulk(i).nraplica,'zzz.zz9');

              RAISE vr_exc_undo;
            ELSE

                vr_tab_craprda_bulk(i).dtatslmx := rw_crapdat.dtmvtolt; 

              vr_vlsdapat := APLI0001.fn_round(vr_vlsldrdc,2);

              IF vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).cdmodalidade_tipo = 4 THEN
                vr_cdhistor := 3096;
              ELSE
                vr_cdhistor := 474;
              END IF;
            END IF;

            ELSIF vr_tab_craprda_bulk(i).tpaplrdc = 2  THEN

            APLI0001.pc_provisao_rdc_pos(pr_cdcooper  => pr_cdcooper      
                                        ,pr_cdagenci  => 1                
                                        ,pr_nrdcaixa  => 999              
                                          ,pr_nrctaapl  => vr_tab_craprda_bulk(i).nrdconta 
                                          ,pr_nraplres  => vr_tab_craprda_bulk(i).nraplica 
                                          ,pr_dtiniper  => vr_tab_craprda_bulk(i).dtatslmm 
                                        ,pr_dtfimper  => vr_dtfimper       
                                        ,pr_dtinitax => vr_dtinitax        
                                        ,pr_dtfimtax => vr_dtfimtax        
                                        ,pr_flantven  => TRUE              
                                        ,pr_vlsdrdca  => vr_vlsldrdc     
                                        ,pr_vlrentot  => vr_vllanmto     
                                        ,pr_des_reto  => vr_des_reto     
                                        ,pr_tab_erro  => vr_tab_erro);   
            IF vr_des_reto = 'NOK' THEN

              IF vr_tab_erro.COUNT > 0 then

                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE

                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_provisao_rdc_pos[1].';
              END IF;

                pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(vr_tab_craprda_bulk(i).nrdconta)
                                           || ' - Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda_bulk(i).nraplica,'zzz.zz9');

              RAISE vr_exc_undo;
            ELSE

                vr_tab_craprda_bulk(i).vlsltxmm := NVL(vr_tab_craprda_bulk(i).vlsltxmm,0) + NVL(vr_vllanmto,0); 
                vr_tab_craprda_bulk(i).dtatslmm := rw_crapdat.dtmvtolt;                       

              vr_vlrendmm := vr_vllanmto;
            END IF;

            APLI0001.pc_provisao_rdc_pos(pr_cdcooper  => pr_cdcooper
                                        ,pr_cdagenci  => 1          
                                        ,pr_nrdcaixa  => 999        
                                          ,pr_nrctaapl  => vr_tab_craprda_bulk(i).nrdconta
                                          ,pr_nraplres  => vr_tab_craprda_bulk(i).nraplica
                                          ,pr_dtiniper  => vr_tab_craprda_bulk(i).dtatslmx
                                        ,pr_dtfimper  => vr_dtfimper      
                                        ,pr_dtinitax => vr_dtinitax       
                                        ,pr_dtfimtax => vr_dtfimtax       
                                        ,pr_flantven  => FALSE            
                                        ,pr_vlsdrdca  => vr_vlsldrdc      
                                        ,pr_vlrentot  => vr_vllanmto      
                                        ,pr_des_reto  => vr_des_reto      
                                        ,pr_tab_erro  => vr_tab_erro);    

            IF vr_des_reto = 'NOK' THEN

              IF vr_tab_erro.COUNT > 0 then

                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_provisao_rdc_pos[2].';
              END IF;

                pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(vr_tab_craprda_bulk(i).nrdconta)
                                           || ' - Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda_bulk(i).nraplica,'zzz.zz9');

              RAISE vr_exc_undo;
            ELSE
                vr_tab_craprda_bulk(i).vlsltxmx := NVL(vr_tab_craprda_bulk(i).vlsltxmx,0) + NVL(vr_vllanmto,0);
                vr_tab_craprda_bulk(i).dtatslmx := rw_crapdat.dtmvtolt;                             

              vr_vlsdapat := APLI0001.FN_ROUND(vr_vlsldrdc,2);
              IF vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).cdmodalidade_tipo = 4 THEN
                vr_cdhistor := 3104;
              ELSE
                vr_cdhistor := 529;
              END IF;
              
            END IF;
          END IF;
          
         
          vr_nrdocmto := CECRED.SEQCAPT_CRAPLAP_NRSEQDIG.nextval;

          IF vr_vllanmto > 0 THEN
         
            apli0001.pc_gera_craplap_rdc(pr_cdcooper => pr_cdcooper
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_nrdcaixa => 999
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                          ,pr_nrdconta => vr_tab_craprda_bulk(i).nrdconta
                                          ,pr_nraplica => vr_tab_craprda_bulk(i).nraplica
                                        ,pr_nrdocmto => vr_nrdocmto
                                        ,pr_txapllap => rw_craplap.txaplica
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_nrseqdig => vr_nrdocmto
                                        ,pr_vllanmto => vr_vllanmto
                                          ,pr_dtrefere => vr_tab_craprda_bulk(i).dtfimper
                                        ,pr_vlrendmm => vr_vlrendmm
                                        ,pr_tipodrdb => 'N' 
                                        ,pr_rowidlot => rw_craplot.ROWID
                                        ,pr_rowidlap => vr_rowid_craplap
                                        ,pr_vlinfodb => rw_craplot.vlinfodb
                                        ,pr_vlcompdb => rw_craplot.vlcompdb
                                        ,pr_qtinfoln => rw_craplot.qtinfoln
                                        ,pr_qtcompln => rw_craplot.qtcompln
                                        ,pr_vlinfocr => rw_craplot.vlinfocr
                                        ,pr_vlcompcr => rw_craplot.vlcompcr
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro );

            IF vr_des_reto = 'NOK' THEN

              IF vr_tab_erro.COUNT > 0 then

                pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE

                pr_cdcritic := 9998;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' APLI0001.pc_gera_craplap_rdc.';
              END IF;

                pr_dscritic := pr_dscritic || ' - Conta: ' || gene0002.fn_mask_conta(vr_tab_craprda_bulk(i).nrdconta)
                                           || ' - Nr.Aplicacao: '||gene0002.fn_mask(vr_tab_craprda_bulk(i).nraplica,'zzz.zz9');

              RAISE vr_exc_undo;
            END IF;
          END IF;

            vr_tab_resumo(vr_tab_craprda_bulk(i).tpaplica).tpaplica := vr_tab_craprda_bulk(i).tpaplica;
            vr_tab_resumo(vr_tab_craprda_bulk(i).tpaplica).tpaplrdc := vr_tab_craprda_bulk(i).tpaplrdc;
            vr_tab_resumo(vr_tab_craprda_bulk(i).tpaplica).qtaplati := nvl(vr_tab_resumo(vr_tab_craprda_bulk(i).tpaplica).qtaplati,0) + 1;
            vr_tab_resumo(vr_tab_craprda_bulk(i).tpaplica).vlsdapat := nvl(vr_tab_resumo(vr_tab_craprda_bulk(i).tpaplica).vlsdapat,0) + vr_vlsdapat;

          BEGIN

              vr_tab_fisjur(vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).inpessoa)(vr_tab_craprda_bulk(i).tpaplica).qtaplati :=
                        nvl(vr_tab_fisjur(vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).inpessoa)(vr_tab_craprda_bulk(i).tpaplica).qtaplati,0) + 1;
              vr_tab_fisjur(vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).inpessoa)(vr_tab_craprda_bulk(i).tpaplica).vlsdapat :=
                        nvl(vr_tab_fisjur(vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).inpessoa)(vr_tab_craprda_bulk(i).tpaplica).vlsdapat,0) + vr_vlsdapat;
          EXCEPTION
            WHEN no_data_found THEN
                vr_tab_fisjur(vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).inpessoa)(vr_tab_craprda_bulk(i).tpaplica).qtaplati := 1;
                vr_tab_fisjur(vr_tab_crapass(vr_tab_craprda_bulk(i).nrdconta).inpessoa)(vr_tab_craprda_bulk(i).tpaplica).vlsdapat := vr_vlsdapat;
          END;
                
          BEGIN
            UPDATE craprda rda
               SET rda.vlslfmea = ROUND(vr_vlsldrdc,2)
                    ,rda.dtsdfmea = vr_tab_craprda_bulk(i).dtsdfmes
                    ,rda.vlsdextr = vr_tab_craprda_bulk(i).vlsdextr
                    ,rda.dtsdfmes = vr_tab_craprda_bulk(i).dtsdfmes
                    ,rda.dtatslmx = vr_tab_craprda_bulk(i).dtatslmx
                    ,rda.vlsltxmx = vr_tab_craprda_bulk(i).vlsltxmx
                    ,rda.dtatslmm = vr_tab_craprda_bulk(i).dtatslmm
                    ,rda.vlsltxmm = vr_tab_craprda_bulk(i).vlsltxmm
                  ,rda.vlslfmes = ROUND(vr_vlsldrdc,2) 
                  ,rda.dtcalcul = rw_crapdat.dtmvtolt  
             WHERE rda.rowid = vr_tab_craprda_bulk(i).rowid
             RETURNING rda.vlslfmes
                      ,rda.dtcalcul
                    INTO vr_tab_craprda_bulk(i).vlslfmes
                        ,vr_tab_craprda_bulk(i).dtcalcul;
          EXCEPTION
            WHEN OTHERS THEN

              pr_cdcritic := 1035;
              pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic)||' craprda: '||
                              'vlslfmea:'||ROUND(vr_vlsldrdc,2)  ||', dtsdfmea:'||vr_tab_craprda_bulk(i).dtsdfmes||
                              ', vlsdextr:'||vr_tab_craprda_bulk(i).vlsdextr ||', dtsdfmes:'||vr_tab_craprda_bulk(i).dtsdfmes||
                              ', dtatslmx:'||vr_tab_craprda_bulk(i).dtatslmx ||', vlsltxmx:'||vr_tab_craprda_bulk(i).vlsltxmx||
                              ', dtatslmm:'||vr_tab_craprda_bulk(i).dtatslmm ||', vlsltxmm:'||vr_tab_craprda_bulk(i).vlsltxmm||
                            ', vlslfmes:'||ROUND(vr_vlsldrdc,2)||', dtcalcul:'||rw_crapdat.dtmvtopr||
                              ' com cdcooper:'||pr_cdcooper      ||', nrdconta:'||vr_tab_craprda_bulk(i).nrdconta||
                              ', nraplica:'||vr_tab_craprda_bulk(i).nraplica ||
                            '. '||sqlerrm;


              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

              RAISE vr_exc_undo;
          END;          

            vr_prazodia := vr_tab_craprda_bulk(i).dtvencto - vr_tab_craprda_bulk(i).dtmvtolt;
          FOR vr_ind IN vr_vet_periodo.FIRST..vr_vet_periodo.LAST LOOP
            IF vr_prazodia <= vr_vet_periodo(vr_ind) THEN

              vr_tipprazo := vr_ind;

              EXIT;
            END IF;
            IF vr_ind = vr_vet_periodo.LAST THEN
              vr_tipprazo := vr_vet_periodo.LAST;
            END IF;
          END LOOP;


            vr_num_chave_craprej := LPad(vr_tab_craprda_bulk(i).tpaplica,10,'0')||LPad(vr_tipprazo,5,'0');
          IF vr_tab_craprej.EXISTS(vr_num_chave_craprej) THEN
            vr_tab_craprej(vr_num_chave_craprej).vllanmto := vr_tab_craprej(vr_num_chave_craprej).vllanmto + vr_vlsdapat; 
            vr_tab_craprej(vr_num_chave_craprej).nrseqdig := vr_tab_craprej(vr_num_chave_craprej).nrseqdig + 1;
          ELSE
            vr_tab_craprej(vr_num_chave_craprej).vllanmto := vr_vlsdapat;
            vr_tab_craprej(vr_num_chave_craprej).nrseqdig := 1;
          END IF;

            vr_des_chave_bndes := LPAD(vr_tab_craprda_bulk(i).nrdconta,8,'0')||vr_tab_craprda_bulk(i).tpaplica;

            vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta := vr_tab_craprda_bulk(i).nrdconta;
            vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica := vr_tab_craprda_bulk(i).tpaplica;
          vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica := NVL(vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica,0) + vr_vlsdapat;
            vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta := vr_tab_craprda_bulk(i).nrdconta;

        EXCEPTION
          WHEN vr_exc_next THEN
            vr_qtregres := vr_qtregres + 1;
          WHEN vr_exc_undo THEN
            ROLLBACK;

            RAISE vr_exc_erro;
        END;
        END LOOP;
      END IF;

   
      vr_des_chave_bndes := vr_tab_cta_bndes.FIRST;
      LOOP

        EXIT WHEN vr_des_chave_bndes IS NULL;

        BEGIN

          UPDATE crapprb
             SET vlretorn = NVL(vlretorn,0) + vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica
           WHERE cdcooper = pr_cdcooper        
             AND dtmvtolt = rw_crapdat.dtmvtolt
             AND cddprazo = 0
             AND nrdconta = vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta
             AND cdorigem = vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica;

          IF SQL%ROWCOUNT = 0 THEN
            BEGIN

            INSERT INTO crapprb
                       (cdcooper
                       ,dtmvtolt
                       ,nrdconta
                       ,cdorigem
                       ,cddprazo
                       ,vlretorn)
                 VALUES(pr_cdcooper        
                       ,rw_crapdat.dtmvtolt
                       ,vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta
                       ,vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica
                       ,0
                       ,vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica);
            EXCEPTION
              WHEN OTHERS THEN
                pr_cdcritic := 1034;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapprb: '||
                              'cdcooper:'||pr_cdcooper||
                              ', dtmvtolt:'||rw_crapdat.dtmvtolt||
                              ', nrdconta:'||vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta||
                              ', cdorigem:'||vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica||
                              ', cddprazo:0'||
                              ', vlretorn:'||vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica||
                              '. '||sqlerrm;
               
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                RAISE vr_exc_erro;
            END;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 1035;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||' crapprb: '||
                          'vlretorn: vlretorn + '||vr_tab_cta_bndes(vr_des_chave_bndes).vlaplica||
                          ' com cdcooper:'       ||pr_cdcooper||
                          ', dtmvtolt:'          ||rw_crapdat.dtmvtolt||
                          ', cddprazo:0'         ||
                          ', nrdconta:'          ||vr_tab_cta_bndes(vr_des_chave_bndes).nrdconta||
                          ', cdorigem:'          ||vr_tab_cta_bndes(vr_des_chave_bndes).tpaplica||
                          '. '||sqlerrm;
         
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            RAISE vr_exc_erro;
        END;
     
        vr_des_chave_bndes := vr_tab_cta_bndes.NEXT(vr_des_chave_bndes);
      END LOOP;
     
        

    END IF;


    DELETE FROM TBGEN_BATCH_RELATORIO_WRK W
     WHERE W.CDCOOPER = pr_cdcooper
       AND W.CDPROGRAMA = vr_cdprogra
       AND W.DTMVTOLT = rw_crapdat.dtmvtolt;


    
    COMMIT;

    EXCEPTION
      WHEN vr_exc_erro THEN        

        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
                    
     CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 222
                           ,pr_cdprograma    => 'INC0235239'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);   
         ROLLBACK;                        

      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

        IF pr_cdgrupo <> 0 THEN                                   
          gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                      ,pr_idprogra => LPAD(pr_cdgrupo,4,'0')
                                      ,pr_des_erro => vr_dscritic);
        END IF;

        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 333
                           ,pr_cdprograma    => 'INC0235239'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);

        ROLLBACK;
    END;
