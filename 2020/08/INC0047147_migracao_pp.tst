PL/SQL Developer Test script 3.0
1827


DECLARE

    vr_vlrsldpp    NUMBER(20,8);
    vr_dtmvtolt    craprpp.dtiniper%TYPE;
    vr_txperiod    NUMBER(20,8);
    vr_taxaddia    NUMBER(20,8);
    vr_idx_craptxi VARCHAR(008);
    vr_vlsldtot    NUMBER(20,8) := 0;
    vr_vlrendim    NUMBER(20,8) := 0;
    vr_vlslfina    NUMBER(20,8) := 0;
    vr_vlinicio    NUMBER(20,8) := 0;
    valorir        NUMBER(20,8) := 0;
    vr_qtdiasir    PLS_INTEGER;
    vr_perciirf    NUMBER(12,8);
    pr_percirrf    NUMBER(12,8);
    vr_valorend    NUMBER(20,8);
    vr_nrdolote    NUMBER(4);
    vr_cdhistor    NUMBER(4);
    pr_vlsdrdpp    NUMBER(25,8);
    vr_txaplica    NUMBER(25,8);
    vr_txaplmes    NUMBER(25,8);
    vr_dtdolote    DATE;
    vr_nrseqdig    craplot.nrseqdig%TYPE;
    vr_cdbccxlt    craplot.cdbccxlt%TYPE := 100;
    vr_cdagenci    craplot.cdagenci%TYPE := 1;
    vr_cdbccxl2    NUMBER(4) := 200;
    vr_codproduto        PLS_INTEGER := 1007; -- Código da aplicação programada 
    vr_nrseqted    crapmat.nrseqted%type;
    vr_vldifpro    NUMBER(25,8);
    vr_vlajuste    NUMBER(20,2);
    vr_vlajuste_cr NUMBER(25,8);
    vr_vlajuste_db NUMBER(25,8);
    vr_vlresgat    NUMBER(25,2);
    
    vr_dscritic   VARCHAR2(5000) := ' ';
    vr_cdcritic   NUMBER(5);
    vr_excsaida   EXCEPTION;
    vr_exc_saida  EXCEPTION;
                
    TYPE typ_tab_craptxi IS
      TABLE OF NUMBER(18,8)
      INDEX BY VARCHAR2(8); 
      
    vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
    vr_ind_arquiv4     utl_file.file_type;
    vr_nmarqimp1       VARCHAR2(100)  := 'demitidos.txt';
    vr_ind_arquiv1     utl_file.file_type;
    vr_nmarqimp2       VARCHAR2(100)  := 'erroapli0005.txt';
    vr_ind_arquiv2     utl_file.file_type;
    vr_nmarqimp3       VARCHAR2(100)  := 'loga.txt';
    vr_ind_arquiv3     utl_file.file_type;
    vr_nmarqimp5       VARCHAR2(100)  := 'erro.txt';
    vr_ind_arquiv5     utl_file.file_type;
    
    
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0047147_migracao'; 
      
    vr_tab_craptxi typ_tab_craptxi;
    rw_craplot     lote0001.cr_craplot_sem_lock%ROWTYPE;
    vr_tab_care    apli0005.typ_tab_care;
    vr_nraplica    craprac.nraplica%TYPE;
    vr_tab_retorno lanc0001.typ_reg_retorno;
    vr_incrineg    NUMBER;
    vr_craplpp_rowid ROWID;
    vr_craplci_rowid ROWID;
    vr_crapsli_rowid ROWID;
    vr_craprpp_rowid ROWID;   
    
   --Buscar valor da taxa
   CURSOR cr_craptrd (pr_cdcooper craptrd.cdcooper%TYPE,
                       pr_dtiniper craptrd.dtiniper%TYPE,
                       pr_vlsdrdpp craptrd.vlfaixas%TYPE,
                       pr_tptaxrda craptrd.tptaxrda%TYPE) IS
      SELECT craptrd.rowid,
             craptrd.txofidia,
             craptrd.txofimes,
             craptrd.txprodia,
             craptrd.dtfimper
        FROM craptrd
       WHERE craptrd.cdcooper  = pr_cdcooper
         AND craptrd.dtiniper  = pr_dtiniper
         AND craptrd.tptaxrda  = pr_tptaxrda
         AND craptrd.incarenc  = 0
         AND craptrd.vlfaixas <= pr_vlsdrdpp
       ORDER BY craptrd.vlfaixas DESC;
       rw_craptrd cr_craptrd%ROWTYPE;  
       
        CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                           pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.cdcooper,
             crapass.dtdemiss
        FROM crapass
       WHERE crapass.cdcooper  = pr_cdcooper
         AND crapass.nrdconta  = pr_nrdconta;
       rw_crapass cr_crapass%ROWTYPE;         
    
   --Busca o saldo inicial, caso foi feito o resgate total, pois na tabela craprpp esta zerado  
   CURSOR cr_crapspp (pr_cdcooper IN craprpp.cdcooper%TYPE
                     ,pr_nrdconta IN craprpp.nrdconta%TYPE
                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE
                     ,pr_dtiniper IN craprpp.dtiniper%TYPE) IS
      SELECT spp.cdcooper,
             spp.nrdconta, 
             spp.nrctrrpp,
             spp.dtsldrpp,
             spp.vlsldrpp
        FROM crapspp spp 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta 
         AND nrctrrpp = pr_nrctrrpp 
         AND dtsldrpp = pr_dtiniper; 
       rw_crapspp cr_crapspp%ROWTYPE;           
     
   --Data do sistema
   CURSOR cr_crapdat (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT dat.dtmvtolt,
             dat.dtmvtopr,
             dat.dtmvtoan,
             dat.inproces,
             dat.qtdiaute,
             dat.cdprgant,
             dat.dtmvtocd,
             trunc(dat.dtmvtolt,'mm')               dtinimes, -- Pri. Dia Mes Corr.
             trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms, -- Pri. Dia mes Seguinte
             last_day(add_months(dat.dtmvtolt,-1))  dtultdma, -- Ult. Dia Mes Ant.
             last_day(dat.dtmvtolt)                 dtultdia, -- Utl. Dia Mes Corr.
             ROWID
        FROM crapdat dat
       WHERE dat.cdcooper = pr_cdcooper;
       rw_crapdat cr_crapdat%ROWTYPE;
       
   --Taxa CDI     
   CURSOR cr_craptxi IS
      SELECT txi.*
        FROM craptxi txi
       WHERE txi.cddindex = 1 /* CDI */
         AND txi.dtiniper >= '01/01/2019';
       rw_craptxi cr_craptxi%ROWTYPE;
        
        
   --Busca as informacoes da poupanca programada
   CURSOR cr_craprpp(pr_cdcooper IN craprpp.cdcooper%TYPE
                    ,pr_nrdconta IN craprpp.nrdconta%TYPE
                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE) IS
      SELECT craprpp.cdagenci,
             craprpp.cdageori,
             craprpp.cdcooper,
             craprpp.cdopeori,
             craprpp.cdprodut,
             craprpp.cdsecext,
             craprpp.dtcalcul,
             craprpp.dtdebito,
             craprpp.dtfimper,
             craprpp.dtiniper,
             craprpp.dtrnirpp,
             craprpp.dtinsori,
             craprpp.dtmvtolt,
             craprpp.dtslfmes,
             craprpp.dtvctopp,
             craprpp.flgctain,
             craprpp.nrctrrpp,
             craprpp.nrdconta,
             craprpp.tpemiext,
             craprpp.vlabcpmf,
             craprpp.vlabdiof,
             craprpp.vlprerpp, 
             craprpp.vlsdrdpp,
             craprpp.vlslfmes,
             craprpp.rowid
        FROM craprpp
       WHERE craprpp.cdcooper = pr_cdcooper
         AND craprpp.nrdconta = pr_nrdconta
         AND craprpp.nrctrrpp = pr_nrctrrpp;   
       rw_craprpp cr_craprpp%ROWTYPE;  
    
   --Consulta provisao e ajustes  
   CURSOR cr_craplppprov(pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_nrctrrpp IN craplpp.nrctrrpp%TYPE
                        ,pr_dtfimper IN craplpp.dtmvtolt%TYPE) IS
                        
       SELECT SUM(decode(his.indebcre,'C',1,-1) * lpp.vllanmto) vllanmto
        FROM craplpp lpp
        JOIN craphis his
          on his.cdcooper = lpp.cdcooper
         and his.cdhistor = lpp.cdhistor
       WHERE lpp.cdcooper  = pr_cdcooper
         AND lpp.nrdconta  = pr_nrdconta
         AND lpp.nrctrrpp  = pr_nrctrrpp
         AND lpp.dtrefere  = pr_dtfimper
         AND lpp.cdhistor IN (152,154,155);
       rw_craplppprov cr_craplppprov%ROWTYPE;
      
   --Consulta se houve resgate.   
   CURSOR cr_craplpp(pr_cdcooper IN craplpp.cdcooper%TYPE
                    ,pr_nrdconta IN craplpp.nrdconta%TYPE
                    ,pr_nrctrrpp IN craplpp.nrctrrpp%TYPE
                    ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
      SELECT NVL(SUM(decode(lpp.cdhistor,158,vllanmto,496,vllanmto,0)),0) vlresgat, 
             lpp.cdcooper,
             lpp.nrdconta,
             lpp.nrctrrpp
        FROM craplpp lpp
       WHERE lpp.cdcooper  = pr_cdcooper
         AND lpp.nrdconta  = pr_nrdconta
         AND lpp.nrctrrpp  = pr_nrctrrpp
         AND lpp.dtmvtolt  = pr_dtmvtolt
         AND lpp.cdhistor IN (158,496,152,154)
    GROUP BY lpp.cdcooper, lpp.nrdconta, lpp.nrctrrpp;
       rw_craplpp cr_craplpp%ROWTYPE;   
    
   --Verificar se possui outra aplicacao para realizar a transferencia 
   CURSOR cr_craprpp_migra (pr_cdcooper IN craprpp.cdcooper%TYPE
                           ,pr_nrdconta IN craprpp.nrdconta%TYPE
                           ,pr_vlprerpp IN craprpp.vlprerpp%TYPE
                           ,pr_dtdebito IN craprpp.dtdebito%TYPE) IS
      SELECT rpp.flgctain,
             rpp.cdcooper, 
             rpp.nrdconta,
             rpp.cdprodut, 
             min(rpp.nrctrrpp) nrctrrpp,
             rpp.rowid
        FROM craprpp rpp
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND cdprodut > 1
         AND vlprerpp = pr_vlprerpp
         AND extract(DAY FROM dtdebito) = extract(DAY FROM pr_dtdebito)
    GROUP BY rpp.flgctain, rpp.cdcooper, rpp.nrdconta,rpp.cdprodut, rpp.rowid
    ORDER BY nrctrrpp;   
       rw_craprpp_migra cr_craprpp_migra%ROWTYPE;  
     
   --Saldo da conta investimento 
   CURSOR cr_crapsli(pr_cdcooper IN crapsli.cdcooper%TYPE
                    ,pr_nrdconta IN crapsli.nrdconta%TYPE
                    ,pr_dtrefere IN crapsli.dtrefere%TYPE) IS
      SELECT sli.cdcooper
             ,sli.nrdconta
             ,sli.dtrefere
             ,sli.vlsddisp
             ,sli.rowid
        FROM crapsli sli
       WHERE sli.cdcooper = pr_cdcooper
         AND sli.nrdconta = pr_nrdconta
         AND sli.dtrefere = pr_dtrefere;
       rw_crapsli cr_crapsli%ROWTYPE;                        

   --Contas a serem creditadas o rendimento da poupanca programada
   CURSOR cr_aplica IS
    select  1   cdcooper,  622761   nrdconta,  45814   nrctrrpp  from dual union all
    select  1   cdcooper,  863530   nrdconta,  9535    nrctrrpp  from dual union all 
    select  1   cdcooper,  888176   nrdconta,  184223  nrctrrpp  from dual union all 
    select  1   cdcooper,  899682   nrdconta,  191370  nrctrrpp  from dual union all 
    select  1   cdcooper,  907472   nrdconta,  63746   nrctrrpp  from dual union all
    select  1   cdcooper,  932302   nrdconta,  25184   nrctrrpp  from dual union all 
    select  1   cdcooper,  1510495  nrdconta,  46017   nrctrrpp  from dual union all
    select  1   cdcooper,  1846612  nrdconta,  12937   nrctrrpp  from dual union all 
   select  1   cdcooper,  1928546  nrdconta,  59428   nrctrrpp  from dual union all
   select  1   cdcooper,  1948539  nrdconta,  114678  nrctrrpp  from dual union all
   select  1   cdcooper,  1995421  nrdconta,  21625   nrctrrpp  from dual union all 
   select  1   cdcooper,  2047209  nrdconta,  237192  nrctrrpp  from dual union all 
    select  1   cdcooper,  2085593  nrdconta,  187898  nrctrrpp  from dual union all 
   select  1   cdcooper,  2146037  nrdconta,  29425   nrctrrpp  from dual union all 
    select  1   cdcooper,  2255910  nrdconta,  234600  nrctrrpp  from dual union all 
    select  1   cdcooper,  2671484  nrdconta,  65028   nrctrrpp  from dual union all 
    select  1   cdcooper,  3056520  nrdconta,  148690  nrctrrpp  from dual union all 
    select  1   cdcooper,  3089967  nrdconta,  95757   nrctrrpp  from dual union all 
    select  1   cdcooper,  3132242  nrdconta,  170819  nrctrrpp  from dual union all 
    select  1   cdcooper,  3571041  nrdconta,  102215  nrctrrpp  from dual union all 
    select  1   cdcooper,  3597954  nrdconta,  108300  nrctrrpp  from dual union all 
    select  1   cdcooper,  3735036  nrdconta,  94330   nrctrrpp  from dual union all 
    select  1   cdcooper,  3735036  nrdconta,  26629   nrctrrpp  from dual union all 
    select  1   cdcooper,  3735036  nrdconta,  109904  nrctrrpp  from dual union all 
    select  1   cdcooper,  6098835  nrdconta,  138818  nrctrrpp  from dual union all 
    select  1   cdcooper,  6170633  nrdconta,  147226  nrctrrpp  from dual union all 
    select  1   cdcooper,  6241417  nrdconta,  144717  nrctrrpp  from dual union all 
    select  1   cdcooper,  6259111  nrdconta,  143536  nrctrrpp  from dual union all 
    select  1   cdcooper,  6272827  nrdconta,  206709  nrctrrpp  from dual union all 
    select  1   cdcooper,  6273343  nrdconta,  206733  nrctrrpp  from dual union all 
    select  1   cdcooper,  6375073  nrdconta,  152338  nrctrrpp  from dual union all
    select  1   cdcooper,  6470513  nrdconta,  158715  nrctrrpp  from dual union all
   -- select  1   cdcooper,  6658148  nrdconta,  72779   nrctrrpp  from dual union all PREJUIZO
    select  1   cdcooper,  7058772  nrdconta,  46835   nrctrrpp  from dual union all 
    select  1   cdcooper,  7316984  nrdconta,  77451   nrctrrpp  from dual union all 
    select  1   cdcooper,  8354863  nrdconta,  143279  nrctrrpp  from dual union all 
    select  1   cdcooper,  8427895  nrdconta,  103258  nrctrrpp  from dual union all 
    select  1   cdcooper,  8531897  nrdconta,  108294  nrctrrpp  from dual union all 
    select  1   cdcooper,  8531935  nrdconta,  108293  nrctrrpp  from dual union all 
    select  2   cdcooper,  192546   nrdconta,  10901   nrctrrpp  from dual union all 
    select  2   cdcooper,  234702   nrdconta,  4038    nrctrrpp  from dual union all 
    select  2   cdcooper,  317985   nrdconta,  2517    nrctrrpp  from dual union all 
    select  2   cdcooper,  384526   nrdconta,  13534   nrctrrpp  from dual union all 
    select  2   cdcooper,  385395   nrdconta,  14432   nrctrrpp  from dual union all 
    select  2   cdcooper,  396680   nrdconta,  5741    nrctrrpp  from dual union all 
    select  2   cdcooper,  396680   nrdconta,  227     nrctrrpp  from dual union all 
    select  2   cdcooper,  401625   nrdconta,  3826    nrctrrpp  from dual union all 
    select  2   cdcooper,  404489   nrdconta,  83      nrctrrpp  from dual union all 
    select  2   cdcooper,  425834   nrdconta,  5030    nrctrrpp  from dual union all 
    select  2   cdcooper,  431613   nrdconta,  8050    nrctrrpp  from dual union all 
    select  2   cdcooper,  440558   nrdconta,  4950    nrctrrpp  from dual union all 
    select  2   cdcooper,  444120   nrdconta,  7872    nrctrrpp  from dual union all 
    select  2   cdcooper,  453021   nrdconta,  14946   nrctrrpp  from dual union all 
    select  2   cdcooper,  457620   nrdconta,  20228   nrctrrpp  from dual union all 
    select  2   cdcooper,  460567   nrdconta,  16476   nrctrrpp  from dual union all 
    select  2   cdcooper,  463337   nrdconta,  19475   nrctrrpp  from dual union all 
    select  2   cdcooper,  463990   nrdconta,  20050   nrctrrpp  from dual union all 
    select  2   cdcooper,  464023   nrdconta,  20049   nrctrrpp  from dual union all 
    select  2   cdcooper,  466751   nrdconta,  22087   nrctrrpp  from dual union all 
    select  2   cdcooper,  473634   nrdconta,  6609    nrctrrpp  from dual union all 
    select  2   cdcooper,  473634   nrdconta,  8252    nrctrrpp  from dual union all 
    select  2   cdcooper,  497916   nrdconta,  6305    nrctrrpp  from dual union all 
    select  2   cdcooper,  508900   nrdconta,  5975    nrctrrpp  from dual union all 
    select  2   cdcooper,  516112   nrdconta,  3587    nrctrrpp  from dual union all 
    select  2   cdcooper,  518468   nrdconta,  4633    nrctrrpp  from dual union all 
    select  2   cdcooper,  519138   nrdconta,  3591    nrctrrpp  from dual union all
    select  2   cdcooper,  521981   nrdconta,  2755    nrctrrpp  from dual union all 
    select  2   cdcooper,  523534   nrdconta,  3988    nrctrrpp  from dual union all 
    select  2   cdcooper,  564362   nrdconta,  1991    nrctrrpp  from dual union all 
    select  2   cdcooper,  565270   nrdconta,  2573    nrctrrpp  from dual union all 
    select  2   cdcooper,  566004   nrdconta,  6450    nrctrrpp  from dual union all 
    select  2   cdcooper,  599719   nrdconta,  7436    nrctrrpp  from dual union all 
    select  2   cdcooper,  615382   nrdconta,  8119    nrctrrpp  from dual union all 
    select  2   cdcooper,  615510   nrdconta,  8121    nrctrrpp  from dual union all 
    select  2   cdcooper,  705993   nrdconta,  8213    nrctrrpp  from dual union all 
    select  2   cdcooper,  780251   nrdconta,  6462    nrctrrpp  from dual union all 
    select  5   cdcooper,  63304    nrdconta,  2065    nrctrrpp  from dual union all 
    select  5   cdcooper,  99449    nrdconta,  552     nrctrrpp  from dual union all 
    select  5   cdcooper,  103012   nrdconta,  426     nrctrrpp  from dual union all 
    select  5   cdcooper,  117897   nrdconta,  765     nrctrrpp  from dual union all 
    select  5   cdcooper,  120936   nrdconta,  863     nrctrrpp  from dual union all 
    select  5   cdcooper,  121312   nrdconta,  878     nrctrrpp  from dual union all 
    select  5   cdcooper,  135917   nrdconta,  2482    nrctrrpp  from dual union all 
    select  6   cdcooper,  38423    nrdconta,  2426    nrctrrpp  from dual union all 
    select  6   cdcooper,  46582    nrdconta,  2486    nrctrrpp  from dual union all 
    select  6   cdcooper,  103632   nrdconta,  602     nrctrrpp  from dual union all 
    select  7   cdcooper,  2119     nrdconta,  961     nrctrrpp  from dual union all 
    select  7   cdcooper,  9253     nrdconta,  2776    nrctrrpp  from dual union all 
    select  7   cdcooper,  11258    nrdconta,  2654    nrctrrpp  from dual union all 
    select  7   cdcooper,  12939    nrdconta,  1110    nrctrrpp  from dual union all 
    select  7   cdcooper,  16209    nrdconta,  1823    nrctrrpp  from dual union all 
    select  7   cdcooper,  30031    nrdconta,  1226    nrctrrpp  from dual union all 
    select  7   cdcooper,  34410    nrdconta,  709     nrctrrpp  from dual union all 
    select  7   cdcooper,  35408    nrdconta,  2438    nrctrrpp  from dual union all 
    select  7   cdcooper,  35947    nrdconta,  2975    nrctrrpp  from dual union all 
    select  7   cdcooper,  37176    nrdconta,  1508    nrctrrpp  from dual union all 
    select  7   cdcooper,  38105    nrdconta,  964     nrctrrpp  from dual union all 
    select  7   cdcooper,  45535    nrdconta,  280     nrctrrpp  from dual union all 
    select  7   cdcooper,  45624    nrdconta,  2058    nrctrrpp  from dual union all 
    select  7   cdcooper,  48852    nrdconta,  1568    nrctrrpp  from dual union all 
    select  7   cdcooper,  49190    nrdconta,  2440    nrctrrpp  from dual union all 
    select  7   cdcooper,  53945    nrdconta,  2149    nrctrrpp  from dual union all 
    select  7   cdcooper,  55239    nrdconta,  3427    nrctrrpp  from dual union all 
    select  7   cdcooper,  61778    nrdconta,  1831    nrctrrpp  from dual union all 
    select  7   cdcooper,  68306    nrdconta,  3376    nrctrrpp  from dual union all 
    select  7   cdcooper,  79944    nrdconta,  2744    nrctrrpp  from dual union all 
    select  7   cdcooper,  80063    nrdconta,  1408    nrctrrpp  from dual union all 
    select  7   cdcooper,  80233    nrdconta,  1496    nrctrrpp  from dual union all 
    select  7   cdcooper,  87548    nrdconta,  2050    nrctrrpp  from dual union all 
    select  7   cdcooper,  88153    nrdconta,  452     nrctrrpp  from dual union all 
    select  7   cdcooper,  88927    nrdconta,  803     nrctrrpp  from dual union all 
    select  7   cdcooper,  95290    nrdconta,  2407    nrctrrpp  from dual union all 
    select  7   cdcooper,  100536   nrdconta,  2486    nrctrrpp  from dual union all 
    select  7   cdcooper,  108936   nrdconta,  3819    nrctrrpp  from dual union all 
    select  7   cdcooper,  112887   nrdconta,  4024    nrctrrpp  from dual union all 
    select  7   cdcooper,  114693   nrdconta,  4141    nrctrrpp  from dual union all 
    select  7   cdcooper,  120553   nrdconta,  5124    nrctrrpp  from dual union all 
    select  7   cdcooper,  125156   nrdconta,  5000    nrctrrpp  from dual union all 
    select  7   cdcooper,  128775   nrdconta,  5478    nrctrrpp  from dual union all 
    select  7   cdcooper,  130010   nrdconta,  5316    nrctrrpp  from dual union all 
    select  7   cdcooper,  130036   nrdconta,  5317    nrctrrpp  from dual union all 
    select  7   cdcooper,  131857   nrdconta,  5490    nrctrrpp  from dual union all 
    select  7   cdcooper,  133710   nrdconta,  5615    nrctrrpp  from dual union all 
    select  7   cdcooper,  135119   nrdconta,  5731    nrctrrpp  from dual union all 
    select  7   cdcooper,  140287   nrdconta,  6002    nrctrrpp  from dual union all 
    select  7   cdcooper,  141550   nrdconta,  6108    nrctrrpp  from dual union all 
    select  7   cdcooper,  146200   nrdconta,  6486    nrctrrpp  from dual union all 
    select  7   cdcooper,  154806   nrdconta,  6984    nrctrrpp  from dual union all 
    select  7   cdcooper,  171190   nrdconta,  7863    nrctrrpp  from dual union all 
    select  7   cdcooper,  178527   nrdconta,  8166    nrctrrpp  from dual union all 
    select  7   cdcooper,  184560   nrdconta,  8514    nrctrrpp  from dual union all 
    select  7   cdcooper,  184888   nrdconta,  8346    nrctrrpp  from dual union all 
    select  7   cdcooper,  212784   nrdconta,  3814    nrctrrpp  from dual union all 
    select  7   cdcooper,  214710   nrdconta,  3082    nrctrrpp  from dual union all 
    select  7   cdcooper,  222771   nrdconta,  2159    nrctrrpp  from dual union all 
    select  7   cdcooper,  226254   nrdconta,  7253    nrctrrpp  from dual union all 
    select  7   cdcooper,  228532   nrdconta,  1311    nrctrrpp  from dual union all 
    select  7   cdcooper,  231185   nrdconta,  2796    nrctrrpp  from dual union all 
    select  7   cdcooper,  231665   nrdconta,  1660    nrctrrpp  from dual union all 
    select  7   cdcooper,  237213   nrdconta,  2755    nrctrrpp  from dual union all 
    select  7   cdcooper,  238929   nrdconta,  143     nrctrrpp  from dual union all 
    select  7   cdcooper,  260754   nrdconta,  2882    nrctrrpp  from dual union all 
    select  7   cdcooper,  281980   nrdconta,  2397    nrctrrpp  from dual union all 
    select  7   cdcooper,  310425   nrdconta,  2047    nrctrrpp  from dual union all 
    select  7   cdcooper,  320889   nrdconta,  2258    nrctrrpp  from dual union all 
    select  7   cdcooper,  321575   nrdconta,  2630    nrctrrpp  from dual union all 
    select  7   cdcooper,  330337   nrdconta,  4315    nrctrrpp  from dual union all 
    select  7   cdcooper,  330370   nrdconta,  772     nrctrrpp  from dual union all 
    select  7   cdcooper,  330973   nrdconta,  3615    nrctrrpp  from dual union all 
    select  7   cdcooper,  332283   nrdconta,  1543    nrctrrpp  from dual union all 
    select  7   cdcooper,  332321   nrdconta,  1544    nrctrrpp  from dual union all 
    select  7   cdcooper,  335673   nrdconta,  2772    nrctrrpp  from dual union all 
    select  8   cdcooper,  10499    nrdconta,  698     nrctrrpp  from dual union all 
    select  8   cdcooper,  12505    nrdconta,  376     nrctrrpp  from dual union all 
    select  8   cdcooper,  14192    nrdconta,  742     nrctrrpp  from dual union all 
    select  8   cdcooper,  18570    nrdconta,  46      nrctrrpp  from dual union all 
    select  8   cdcooper,  28398    nrdconta,  1153    nrctrrpp  from dual union all 
    select  8   cdcooper,  28401    nrdconta,  999     nrctrrpp  from dual union all 
    select  9   cdcooper,  1287     nrdconta,  3269    nrctrrpp  from dual union all 
    select  9   cdcooper,  1295     nrdconta,  2498    nrctrrpp  from dual union all 
    select  9   cdcooper,  1350     nrdconta,  2784    nrctrrpp  from dual union all 
    select  9   cdcooper,  18651    nrdconta,  2069    nrctrrpp  from dual union all 
    select  9   cdcooper,  21032    nrdconta,  3814    nrctrrpp  from dual union all 
    select  9   cdcooper,  21644    nrdconta,  1424    nrctrrpp  from dual union all 
    select  9   cdcooper,  23736    nrdconta,  2037    nrctrrpp  from dual union all 
    select  9   cdcooper,  26344    nrdconta,  2572    nrctrrpp  from dual union all 
    select  9   cdcooper,  26395    nrdconta,  2638    nrctrrpp  from dual union all 
    select  9   cdcooper,  32530    nrdconta,  1353    nrctrrpp  from dual union all 
    select  9   cdcooper,  32905    nrdconta,  1358    nrctrrpp  from dual union all 
    select  9   cdcooper,  40266    nrdconta,  1675    nrctrrpp  from dual union all 
    select  9   cdcooper,  50326    nrdconta,  2751    nrctrrpp  from dual union all 
    select  9   cdcooper,  50326    nrdconta,  2949    nrctrrpp  from dual union all 
    select  9   cdcooper,  57100    nrdconta,  234     nrctrrpp  from dual union all 
    select  9   cdcooper,  62715    nrdconta,  2512    nrctrrpp  from dual union all 
    select  9   cdcooper,  70254    nrdconta,  2552    nrctrrpp  from dual union all 
    select  9   cdcooper,  73768    nrdconta,  1141    nrctrrpp  from dual union all 
    select  9   cdcooper,  84689    nrdconta,  631     nrctrrpp  from dual union all 
    select  9   cdcooper,  93874    nrdconta,  2456    nrctrrpp  from dual union all 
    select  9   cdcooper,  104159   nrdconta,  2066    nrctrrpp  from dual union all 
    select  9   cdcooper,  119466   nrdconta,  3114    nrctrrpp  from dual union all 
    select  9   cdcooper,  122386   nrdconta,  3326    nrctrrpp  from dual union all 
    select  9   cdcooper,  176877   nrdconta,  4526    nrctrrpp  from dual union all 
    select  9   cdcooper,  907600   nrdconta,  4269    nrctrrpp  from dual union all
    select  10  cdcooper,  4057     nrdconta,  1653    nrctrrpp  from dual union all 
    select  10  cdcooper,  5878     nrdconta,  1390    nrctrrpp  from dual union all 
    select  10  cdcooper,  8613     nrdconta,  31      nrctrrpp  from dual union all 
    select  10  cdcooper,  8680     nrdconta,  404     nrctrrpp  from dual union all 
    select  10  cdcooper,  10928    nrdconta,  1867    nrctrrpp  from dual union all 
    select  10  cdcooper,  12467    nrdconta,  700     nrctrrpp  from dual union all 
    select  10  cdcooper,  33090    nrdconta,  1226    nrctrrpp  from dual union all 
    select  10  cdcooper,  52884    nrdconta,  1806    nrctrrpp  from dual union all 
    select  10  cdcooper,  64750    nrdconta,  2354    nrctrrpp  from dual union all 
    select  10  cdcooper,  66419    nrdconta,  1358    nrctrrpp  from dual union all 
    select  10  cdcooper,  102725   nrdconta,  833     nrctrrpp  from dual union all 
    select  11  cdcooper,  1660     nrdconta,  8991    nrctrrpp  from dual union all 
    select  11  cdcooper,  2682     nrdconta,  317     nrctrrpp  from dual union all 
    select  11  cdcooper,  4049     nrdconta,  1910    nrctrrpp  from dual union all 
    select  11  cdcooper,  10480    nrdconta,  1651    nrctrrpp  from dual union all 
    select  11  cdcooper,  10480    nrdconta,  1887    nrctrrpp  from dual union all 
    select  11  cdcooper,  10723    nrdconta,  6431    nrctrrpp  from dual union all 
    select  11  cdcooper,  11703    nrdconta,  2256    nrctrrpp  from dual union all 
    select  11  cdcooper,  16179    nrdconta,  483     nrctrrpp  from dual union all 
    select  11  cdcooper,  18813    nrdconta,  10359   nrctrrpp  from dual union all 
    select  11  cdcooper,  20141    nrdconta,  3160    nrctrrpp  from dual union all 
    select  11  cdcooper,  27642    nrdconta,  4029    nrctrrpp  from dual union all 
    select  11  cdcooper,  27928    nrdconta,  6134    nrctrrpp  from dual union all 
    select  11  cdcooper,  33049    nrdconta,  658     nrctrrpp  from dual union all 
    select  11  cdcooper,  35157    nrdconta,  15770   nrctrrpp  from dual union all 
    select  11  cdcooper,  35335    nrdconta,  2675    nrctrrpp  from dual union all 
    select  11  cdcooper,  46230    nrdconta,  1997    nrctrrpp  from dual union all 
    select  11  cdcooper,  50946    nrdconta,  2602    nrctrrpp  from dual union all 
    select  11  cdcooper,  53686    nrdconta,  3010    nrctrrpp  from dual union all 
    select  11  cdcooper,  74810    nrdconta,  816     nrctrrpp  from dual union all 
    select  11  cdcooper,  75221    nrdconta,  3236    nrctrrpp  from dual union all 
    select  11  cdcooper,  82023    nrdconta,  3479    nrctrrpp  from dual union all 
    select  11  cdcooper,  84522    nrdconta,  5152    nrctrrpp  from dual union all 
    select  11  cdcooper,  95109    nrdconta,  7280    nrctrrpp  from dual union all 
    select  11  cdcooper,  101966   nrdconta,  4721    nrctrrpp  from dual union all 
    select  11  cdcooper,  112399   nrdconta,  7531    nrctrrpp  from dual union all 
    select  11  cdcooper,  112437   nrdconta,  6054    nrctrrpp  from dual union all 
    select  11  cdcooper,  116688   nrdconta,  3261    nrctrrpp  from dual union all 
    select  11  cdcooper,  120871   nrdconta,  9721    nrctrrpp  from dual union all 
    select  11  cdcooper,  123420   nrdconta,  7213    nrctrrpp  from dual union all 
    select  11  cdcooper,  128945   nrdconta,  6840    nrctrrpp  from dual union all 
    select  11  cdcooper,  139815   nrdconta,  16167   nrctrrpp  from dual union all 
    select  11  cdcooper,  148288   nrdconta,  7690    nrctrrpp  from dual union all 
    select  11  cdcooper,  162760   nrdconta,  12439   nrctrrpp  from dual union all 
    select  11  cdcooper,  167150   nrdconta,  702     nrctrrpp  from dual union all 
    select  11  cdcooper,  168823   nrdconta,  8087    nrctrrpp  from dual union all 
    select  11  cdcooper,  175250   nrdconta,  1370    nrctrrpp  from dual union all 
    select  11  cdcooper,  180602   nrdconta,  6235    nrctrrpp  from dual union all 
    select  11  cdcooper,  182958   nrdconta,  906     nrctrrpp  from dual union all 
    select  11  cdcooper,  188662   nrdconta,  1521    nrctrrpp  from dual union all 
    select  11  cdcooper,  194379   nrdconta,  1918    nrctrrpp  from dual union all 
    select  11  cdcooper,  195359   nrdconta,  2197    nrctrrpp  from dual union all 
    select  11  cdcooper,  195618   nrdconta,  2637    nrctrrpp  from dual union all 
    select  11  cdcooper,  202347   nrdconta,  2848    nrctrrpp  from dual union all 
    select  11  cdcooper,  203297   nrdconta,  2999    nrctrrpp  from dual union all 
    select  11  cdcooper,  205133   nrdconta,  6169    nrctrrpp  from dual union all 
    select  11  cdcooper,  209210   nrdconta,  5369    nrctrrpp  from dual union all 
    select  11  cdcooper,  211486   nrdconta,  4540    nrctrrpp  from dual union all 
    select  11  cdcooper,  223638   nrdconta,  7025    nrctrrpp  from dual union all 
    select  11  cdcooper,  225304   nrdconta,  3922    nrctrrpp  from dual union all 
    select  11  cdcooper,  225576   nrdconta,  4070    nrctrrpp  from dual union all 
    select  11  cdcooper,  229067   nrdconta,  6426    nrctrrpp  from dual union all 
    select  11  cdcooper,  233420   nrdconta,  5627    nrctrrpp  from dual union all 
    select  11  cdcooper,  242241   nrdconta,  5097    nrctrrpp  from dual union all 
    select  11  cdcooper,  242241   nrdconta,  7469    nrctrrpp  from dual union all 
    select  11  cdcooper,  242756   nrdconta,  7027    nrctrrpp  from dual union all 
    select  11  cdcooper,  247103   nrdconta,  6852    nrctrrpp  from dual union all 
    select  11  cdcooper,  254444   nrdconta,  5406    nrctrrpp  from dual union all 
    select  11  cdcooper,  258954   nrdconta,  7774    nrctrrpp  from dual union all 
    select  11  cdcooper,  262013   nrdconta,  9063    nrctrrpp  from dual union all 
    select  11  cdcooper,  264199   nrdconta,  9064    nrctrrpp  from dual union all 
    select  11  cdcooper,  267872   nrdconta,  8394    nrctrrpp  from dual union all 
    select  11  cdcooper,  271500   nrdconta,  13298   nrctrrpp  from dual union all 
    select  11  cdcooper,  276677   nrdconta,  9871    nrctrrpp  from dual union all 
    select  11  cdcooper,  282880   nrdconta,  10451   nrctrrpp  from dual union all 
    select  11  cdcooper,  287598   nrdconta,  16139   nrctrrpp  from dual union all 
    select  11  cdcooper,  287598   nrdconta,  16114   nrctrrpp  from dual union all 
    select  11  cdcooper,  287687   nrdconta,  10886   nrctrrpp  from dual union all 
    select  11  cdcooper,  291331   nrdconta,  11134   nrctrrpp  from dual union all 
    select  11  cdcooper,  292745   nrdconta,  11294   nrctrrpp  from dual union all 
    select  11  cdcooper,  298816   nrdconta,  11867   nrctrrpp  from dual union all 
    select  11  cdcooper,  299898   nrdconta,  11992   nrctrrpp  from dual union all 
    select  11  cdcooper,  301280   nrdconta,  12173   nrctrrpp  from dual union all 
    select  11  cdcooper,  302970   nrdconta,  17386   nrctrrpp  from dual union all 
    select  11  cdcooper,  309184   nrdconta,  13136   nrctrrpp  from dual union all 
    select  11  cdcooper,  313750   nrdconta,  13307   nrctrrpp  from dual union all 
    select  11  cdcooper,  313769   nrdconta,  13304   nrctrrpp  from dual union all 
    select  11  cdcooper,  322652   nrdconta,  13983   nrctrrpp  from dual union all 
    select  11  cdcooper,  330752   nrdconta,  14532   nrctrrpp  from dual union all 
    select  11  cdcooper,  331180   nrdconta,  14758   nrctrrpp  from dual union all 
    select  11  cdcooper,  333026   nrdconta,  14711   nrctrrpp  from dual union all 
    select  11  cdcooper,  340782   nrdconta,  15344   nrctrrpp  from dual union all 
    select  11  cdcooper,  346330   nrdconta,  15698   nrctrrpp  from dual union all 
    select  11  cdcooper,  351695   nrdconta,  16086   nrctrrpp  from dual union all 
    select  11  cdcooper,  368253   nrdconta,  17402   nrctrrpp  from dual union all 
    select  11  cdcooper,  370134   nrdconta,  17576   nrctrrpp  from dual union all 
    select  11  cdcooper,  371076   nrdconta,  17661   nrctrrpp  from dual union all 
    select  11  cdcooper,  378739   nrdconta,  18317   nrctrrpp  from dual union all 
    select  11  cdcooper,  386391   nrdconta,  18891   nrctrrpp  from dual union all 
    select  11  cdcooper,  387177   nrdconta,  19289   nrctrrpp  from dual union all 
    select  11  cdcooper,  394009   nrdconta,  19821   nrctrrpp  from dual union all 
    select  11  cdcooper,  394009   nrdconta,  19682   nrctrrpp  from dual union all 
    select  11  cdcooper,  396583   nrdconta,  19989   nrctrrpp  from dual union all 
    select  11  cdcooper,  400629   nrdconta,  20271   nrctrrpp  from dual union all 
    select  11  cdcooper,  400947   nrdconta,  20288   nrctrrpp  from dual union all 
    select  11  cdcooper,  403130   nrdconta,  20484   nrctrrpp  from dual union all 
    select  11  cdcooper,  404101   nrdconta,  20567   nrctrrpp  from dual union all 
    select  11  cdcooper,  409634   nrdconta,  21013   nrctrrpp  from dual union all 
    select  11  cdcooper,  411388   nrdconta,  21159   nrctrrpp  from dual union all 
    select  11  cdcooper,  414921   nrdconta,  21825   nrctrrpp  from dual union all 
    select  11  cdcooper,  419486   nrdconta,  21866   nrctrrpp  from dual union all 
    select  11  cdcooper,  429724   nrdconta,  22722   nrctrrpp  from dual union all 
    select  11  cdcooper,  439649   nrdconta,  23462   nrctrrpp  from dual union all 
    select  11  cdcooper,  445843   nrdconta,  23903   nrctrrpp  from dual union all 
    select  12  cdcooper,  116      nrdconta,  228     nrctrrpp  from dual union all 
    select  13  cdcooper,  2143     nrdconta,  85      nrctrrpp  from dual union all 
    select  13  cdcooper,  3000     nrdconta,  63      nrctrrpp  from dual union all 
    select  13  cdcooper,  3450     nrdconta,  840     nrctrrpp  from dual union all 
    select  13  cdcooper,  17760    nrdconta,  2110    nrctrrpp  from dual union all 
    select  13  cdcooper,  20974    nrdconta,  6970    nrctrrpp  from dual union all 
    select  13  cdcooper,  24139    nrdconta,  610     nrctrrpp  from dual union all 
    select  13  cdcooper,  26174    nrdconta,  8915    nrctrrpp  from dual union all 
    select  13  cdcooper,  60640    nrdconta,  2611    nrctrrpp  from dual union all 
    select  13  cdcooper,  61506    nrdconta,  2715    nrctrrpp  from dual union all 
    select  13  cdcooper,  61786    nrdconta,  2732    nrctrrpp  from dual union all 
    select  13  cdcooper,  62430    nrdconta,  2789    nrctrrpp  from dual union all 
    select  13  cdcooper,  70564    nrdconta,  3259    nrctrrpp  from dual union all 
    select  13  cdcooper,  74896    nrdconta,  3676    nrctrrpp  from dual union all 
    select  13  cdcooper,  74950    nrdconta,  10756   nrctrrpp  from dual union all 
    select  13  cdcooper,  78557    nrdconta,  3528    nrctrrpp  from dual union all 
    select  13  cdcooper,  118788   nrdconta,  6457    nrctrrpp  from dual union all 
    select  13  cdcooper,  142042   nrdconta,  7469    nrctrrpp  from dual union all 
    select  13  cdcooper,  147702   nrdconta,  7696    nrctrrpp  from dual union all 
    select  13  cdcooper,  185329   nrdconta,  9571    nrctrrpp  from dual union all 
    select  13  cdcooper,  201090   nrdconta,  4101    nrctrrpp  from dual union all 
    select  13  cdcooper,  202134   nrdconta,  6271    nrctrrpp  from dual union all 
    select  13  cdcooper,  236268   nrdconta,  1128    nrctrrpp  from dual union all 
    select  13  cdcooper,  300098   nrdconta,  4752    nrctrrpp  from dual union all 
    select  13  cdcooper,  309494   nrdconta,  18      nrctrrpp  from dual union all 
    select  13  cdcooper,  405736   nrdconta,  4938    nrctrrpp  from dual union all 
    select  13  cdcooper,  711888   nrdconta,  5080    nrctrrpp  from dual union all 
    select  14  cdcooper,  493      nrdconta,  2843    nrctrrpp  from dual union all 
    select  14  cdcooper,  5207     nrdconta,  127     nrctrrpp  from dual union all 
    select  14  cdcooper,  6467     nrdconta,  2079    nrctrrpp  from dual union all 
    select  14  cdcooper,  7218     nrdconta,  227     nrctrrpp  from dual union all 
    select  14  cdcooper,  7900     nrdconta,  1938    nrctrrpp  from dual union all 
    select  14  cdcooper,  9407     nrdconta,  911     nrctrrpp  from dual union all 
    select  14  cdcooper,  13307    nrdconta,  1423    nrctrrpp  from dual union all 
    select  14  cdcooper,  14346    nrdconta,  2531    nrctrrpp  from dual union all 
    select  14  cdcooper,  15717    nrdconta,  620     nrctrrpp  from dual union all 
    select  14  cdcooper,  18996    nrdconta,  2387    nrctrrpp  from dual union all 
    select  14  cdcooper,  20214    nrdconta,  804     nrctrrpp  from dual union all 
    select  14  cdcooper,  20613    nrdconta,  2820    nrctrrpp  from dual union all 
    select  14  cdcooper,  25739    nrdconta,  363     nrctrrpp  from dual union all 
    select  14  cdcooper,  28975    nrdconta,  2867    nrctrrpp  from dual union all 
    select  14  cdcooper,  34088    nrdconta,  744     nrctrrpp  from dual union all 
    select  14  cdcooper,  40754    nrdconta,  1359    nrctrrpp  from dual union all 
    select  14  cdcooper,  42188    nrdconta,  1188    nrctrrpp  from dual union all 
    select  14  cdcooper,  43222    nrdconta,  1316    nrctrrpp  from dual union all 
    select  14  cdcooper,  53775    nrdconta,  1660    nrctrrpp  from dual union all 
    select  14  cdcooper,  62448    nrdconta,  2248    nrctrrpp  from dual union all 
    select  14  cdcooper,  66800    nrdconta,  2438    nrctrrpp  from dual union all 
    select  14  cdcooper,  81345    nrdconta,  4040    nrctrrpp  from dual union all 
    select  16  cdcooper,  14648    nrdconta,  490     nrctrrpp  from dual union all 
    select  16  cdcooper,  19089    nrdconta,  2392    nrctrrpp  from dual union all 
    select  16  cdcooper,  19216    nrdconta,  12014   nrctrrpp  from dual union all 
    select  16  cdcooper,  22381    nrdconta,  1380    nrctrrpp  from dual union all 
    select  16  cdcooper,  23531    nrdconta,  5710    nrctrrpp  from dual union all 
    select  16  cdcooper,  26646    nrdconta,  8530    nrctrrpp  from dual union all 
    select  16  cdcooper,  28959    nrdconta,  4711    nrctrrpp  from dual union all 
    select  16  cdcooper,  34924    nrdconta,  2041    nrctrrpp  from dual union all 
    select  16  cdcooper,  35963    nrdconta,  2833    nrctrrpp  from dual union all 
    select  16  cdcooper,  36331    nrdconta,  2614    nrctrrpp  from dual union all 
    select  16  cdcooper,  36587    nrdconta,  1361    nrctrrpp  from dual union all 
    select  16  cdcooper,  39411    nrdconta,  2727    nrctrrpp  from dual union all 
    select  16  cdcooper,  39594    nrdconta,  5099    nrctrrpp  from dual union all 
    select  16  cdcooper,  45055    nrdconta,  8760    nrctrrpp  from dual union all 
    select  16  cdcooper,  53295    nrdconta,  3620    nrctrrpp  from dual union all 
    select  16  cdcooper,  53309    nrdconta,  3637    nrctrrpp  from dual union all 
    select  16  cdcooper,  54275    nrdconta,  4829    nrctrrpp  from dual union all 
    select  16  cdcooper,  55220    nrdconta,  3984    nrctrrpp  from dual union all 
    select  16  cdcooper,  56324    nrdconta,  4425    nrctrrpp  from dual union all 
    select  16  cdcooper,  56324    nrdconta,  7785    nrctrrpp  from dual union all 
    select  16  cdcooper,  60127    nrdconta,  4958    nrctrrpp  from dual union all 
    select  16  cdcooper,  60720    nrdconta,  4273    nrctrrpp  from dual union all 
    select  16  cdcooper,  64629    nrdconta,  4453    nrctrrpp  from dual union all 
    select  16  cdcooper,  64653    nrdconta,  15638   nrctrrpp  from dual union all 
    select  16  cdcooper,  64742    nrdconta,  4860    nrctrrpp  from dual union all 
    select  16  cdcooper,  67687    nrdconta,  5361    nrctrrpp  from dual union all 
    select  16  cdcooper,  68950    nrdconta,  5600    nrctrrpp  from dual union all 
    select  16  cdcooper,  71528    nrdconta,  5783    nrctrrpp  from dual union all 
    select  16  cdcooper,  79464    nrdconta,  1168    nrctrrpp  from dual union all 
    select  16  cdcooper,  81981    nrdconta,  9729    nrctrrpp  from dual union all 
    select  16  cdcooper,  85316    nrdconta,  95      nrctrrpp  from dual union all 
    select  16  cdcooper,  88269    nrdconta,  591     nrctrrpp  from dual union all 
    select  16  cdcooper,  96083    nrdconta,  1821    nrctrrpp  from dual union all 
    select  16  cdcooper,  99694    nrdconta,  1372    nrctrrpp  from dual union all 
    select  16  cdcooper,  119903   nrdconta,  3354    nrctrrpp  from dual union all 
    select  16  cdcooper,  120294   nrdconta,  2962    nrctrrpp  from dual union all 
    select  16  cdcooper,  121177   nrdconta,  3442    nrctrrpp  from dual union all 
    select  16  cdcooper,  122009   nrdconta,  3438    nrctrrpp  from dual union all 
    select  16  cdcooper,  126160   nrdconta,  20793   nrctrrpp  from dual union all 
    select  16  cdcooper,  130796   nrdconta,  4774    nrctrrpp  from dual union all 
    select  16  cdcooper,  134295   nrdconta,  4451    nrctrrpp  from dual union all 
    select  16  cdcooper,  135330   nrdconta,  3684    nrctrrpp  from dual union all 
    select  16  cdcooper,  139637   nrdconta,  12332   nrctrrpp  from dual union all 
    select  16  cdcooper,  141623   nrdconta,  20624   nrctrrpp  from dual union all 
    select  16  cdcooper,  141704   nrdconta,  5460    nrctrrpp  from dual union all 
    select  16  cdcooper,  148270   nrdconta,  7293    nrctrrpp  from dual union all 
    select  16  cdcooper,  151017   nrdconta,  5859    nrctrrpp  from dual union all 
    select  16  cdcooper,  152242   nrdconta,  6223    nrctrrpp  from dual union all 
    select  16  cdcooper,  153273   nrdconta,  7387    nrctrrpp  from dual union all 
    select  16  cdcooper,  156353   nrdconta,  6259    nrctrrpp  from dual union all 
    select  16  cdcooper,  157406   nrdconta,  8689    nrctrrpp  from dual union all 
    select  16  cdcooper,  162531   nrdconta,  5927    nrctrrpp  from dual union all 
    select  16  cdcooper,  164704   nrdconta,  9696    nrctrrpp  from dual union all 
    select  16  cdcooper,  165700   nrdconta,  7534    nrctrrpp  from dual union all 
    select  16  cdcooper,  166723   nrdconta,  9996    nrctrrpp  from dual union all 
    select  16  cdcooper,  169650   nrdconta,  5904    nrctrrpp  from dual union all 
    select  16  cdcooper,  170267   nrdconta,  6496    nrctrrpp  from dual union all 
    select  16  cdcooper,  170291   nrdconta,  6145    nrctrrpp  from dual union all 
    select  16  cdcooper,  173681   nrdconta,  8369    nrctrrpp  from dual union all 
    select  16  cdcooper,  177504   nrdconta,  9218    nrctrrpp  from dual union all 
    select  16  cdcooper,  180408   nrdconta,  6793    nrctrrpp  from dual union all 
    select  16  cdcooper,  183601   nrdconta,  10090   nrctrrpp  from dual union all 
    select  16  cdcooper,  184713   nrdconta,  7476    nrctrrpp  from dual union all 
    select  16  cdcooper,  187461   nrdconta,  10492   nrctrrpp  from dual union all 
    select  16  cdcooper,  188824   nrdconta,  7346    nrctrrpp  from dual union all 
    select  16  cdcooper,  189650   nrdconta,  7633    nrctrrpp  from dual union all 
    select  16  cdcooper,  190900   nrdconta,  8278    nrctrrpp  from dual union all 
    select  16  cdcooper,  191000   nrdconta,  8349    nrctrrpp  from dual union all 
    select  16  cdcooper,  192180   nrdconta,  8153    nrctrrpp  from dual union all 
    select  16  cdcooper,  200581   nrdconta,  8669    nrctrrpp  from dual union all 
    select  16  cdcooper,  202819   nrdconta,  8843    nrctrrpp  from dual union all 
    select  16  cdcooper,  205117   nrdconta,  10592   nrctrrpp  from dual union all 
    select  16  cdcooper,  219630   nrdconta,  11261   nrctrrpp  from dual union all 
    select  16  cdcooper,  220930   nrdconta,  11327   nrctrrpp  from dual union all 
    select  16  cdcooper,  220949   nrdconta,  15510   nrctrrpp  from dual union all 
    select  16  cdcooper,  221503   nrdconta,  11357   nrctrrpp  from dual union all 
    select  16  cdcooper,  221988   nrdconta,  11377   nrctrrpp  from dual union all 
    select  16  cdcooper,  236802   nrdconta,  12274   nrctrrpp  from dual union all 
    select  16  cdcooper,  239445   nrdconta,  12481   nrctrrpp  from dual union all 
    select  16  cdcooper,  245046   nrdconta,  12903   nrctrrpp  from dual union all 
    select  16  cdcooper,  262382   nrdconta,  14098   nrctrrpp  from dual union all 
    select  16  cdcooper,  269255   nrdconta,  14562   nrctrrpp  from dual union all 
    select  16  cdcooper,  269522   nrdconta,  14579   nrctrrpp  from dual union all 
    select  16  cdcooper,  281352   nrdconta,  15402   nrctrrpp  from dual union all 
    select  16  cdcooper,  289698   nrdconta,  16076   nrctrrpp  from dual union all 
    select  16  cdcooper,  290351   nrdconta,  16085   nrctrrpp  from dual union all 
    select  16  cdcooper,  296279   nrdconta,  16584   nrctrrpp  from dual union all 
    select  16  cdcooper,  297470   nrdconta,  16534   nrctrrpp  from dual union all 
    select  16  cdcooper,  302279   nrdconta,  17082   nrctrrpp  from dual union all 
    select  16  cdcooper,  311596   nrdconta,  17512   nrctrrpp  from dual union all 
    select  16  cdcooper,  311634   nrdconta,  4167    nrctrrpp  from dual union all 
    select  16  cdcooper,  311634   nrdconta,  2071    nrctrrpp  from dual union all 
    select  16  cdcooper,  311634   nrdconta,  128520  nrctrrpp  from dual union all 
    select  16  cdcooper,  311634   nrdconta,  4742    nrctrrpp  from dual union all 
    select  16  cdcooper,  320226   nrdconta,  18080   nrctrrpp  from dual union all 
    select  16  cdcooper,  325724   nrdconta,  18465   nrctrrpp  from dual union all 
    select  16  cdcooper,  337447   nrdconta,  19121   nrctrrpp  from dual union all 
    select  16  cdcooper,  343080   nrdconta,  19459   nrctrrpp  from dual union all 
    select  16  cdcooper,  350044   nrdconta,  23027   nrctrrpp  from dual union all 
    select  16  cdcooper,  356840   nrdconta,  20255   nrctrrpp  from dual union all 
    select  16  cdcooper,  360899   nrdconta,  21149   nrctrrpp  from dual union all 
    select  16  cdcooper,  369667   nrdconta,  20992   nrctrrpp  from dual union all 
    select  16  cdcooper,  395528   nrdconta,  22341   nrctrrpp  from dual union all 
    select  16  cdcooper,  402958   nrdconta,  23015   nrctrrpp  from dual union all 
    select  16  cdcooper,  407704   nrdconta,  22957   nrctrrpp  from dual union all 
    select  16  cdcooper,  421871   nrdconta,  23794   nrctrrpp  from dual union all 
    select  16  cdcooper,  529885   nrdconta,  7840    nrctrrpp  from dual union all 
    select  16  cdcooper,  825921   nrdconta,  145089  nrctrrpp  from dual union all 
    select  16  cdcooper,  907006   nrdconta,  13496   nrctrrpp  from dual union all 
    select  16  cdcooper,  924482   nrdconta,  3595    nrctrrpp  from dual union all 
    select  16  cdcooper,  946184   nrdconta,  1400    nrctrrpp  from dual union all 
    select  16  cdcooper,  946184   nrdconta,  112900  nrctrrpp  from dual union all 
    select  16  cdcooper,  1908979  nrdconta,  30269   nrctrrpp  from dual union all 
    select  16  cdcooper,  1943197  nrdconta,  228     nrctrrpp  from dual union all 
    select  16  cdcooper,  1943243  nrdconta,  4812    nrctrrpp  from dual union all 
    select  16  cdcooper,  2063352  nrdconta,  2339    nrctrrpp  from dual union all 
    select  16  cdcooper,  2135230  nrdconta,  3596    nrctrrpp  from dual union all 
    select  16  cdcooper,  2137070  nrdconta,  136658  nrctrrpp  from dual union all 
    select  16  cdcooper,  2179008  nrdconta,  487     nrctrrpp  from dual union all 
    select  16  cdcooper,  2207010  nrdconta,  1605    nrctrrpp  from dual union all 
    select  16  cdcooper,  2207010  nrdconta,  4080    nrctrrpp  from dual union all 
    select  16  cdcooper,  2272580  nrdconta,  64404   nrctrrpp  from dual union all 
    select  16  cdcooper,  2272776  nrdconta,  5268    nrctrrpp  from dual union all 
    select  16  cdcooper,  2292661  nrdconta,  44407   nrctrrpp  from dual union all 
    select  16  cdcooper,  2293269  nrdconta,  3826    nrctrrpp  from dual union all 
    select  16  cdcooper,  2409828  nrdconta,  664     nrctrrpp  from dual union all 
    select  16  cdcooper,  2472880  nrdconta,  158176  nrctrrpp  from dual union all 
    select  16  cdcooper,  2538873  nrdconta,  63124   nrctrrpp  from dual union all 
    select  16  cdcooper,  2558378  nrdconta,  183656  nrctrrpp  from dual union all 
    select  16  cdcooper,  2694174  nrdconta,  7558    nrctrrpp  from dual union all 
    select  16  cdcooper,  2720795  nrdconta,  65415   nrctrrpp  from dual union all 
    select  16  cdcooper,  2735490  nrdconta,  11320   nrctrrpp  from dual union all 
    select  16  cdcooper,  2778610  nrdconta,  860     nrctrrpp  from dual union all 
    select  16  cdcooper,  3058590  nrdconta,  3793    nrctrrpp  from dual union all 
    select  16  cdcooper,  3058743  nrdconta,  140342  nrctrrpp  from dual union all 
    select  16  cdcooper,  3062759  nrdconta,  92493   nrctrrpp  from dual union all 
    select  16  cdcooper,  3063070  nrdconta,  88978   nrctrrpp  from dual union all 
    select  16  cdcooper,  3076520  nrdconta,  108088  nrctrrpp  from dual union all 
    select  16  cdcooper,  3175081  nrdconta,  154747  nrctrrpp  from dual union all 
    select  16  cdcooper,  3511456  nrdconta,  138208  nrctrrpp  from dual union all 
    select  16  cdcooper,  3511715  nrdconta,  1790    nrctrrpp  from dual union all 
    select  16  cdcooper,  3620638  nrdconta,  5535    nrctrrpp  from dual union all 
    select  16  cdcooper,  3677400  nrdconta,  15429   nrctrrpp  from dual union all 
    select  16  cdcooper,  3677478  nrdconta,  122     nrctrrpp  from dual union all 
    select  16  cdcooper,  3677478  nrdconta,  5237    nrctrrpp  from dual union all 
    select  16  cdcooper,  3678172  nrdconta,  2035    nrctrrpp  from dual union all 
    select  16  cdcooper,  3959171  nrdconta,  428     nrctrrpp  from dual union all 
    select  16  cdcooper,  3962750  nrdconta,  1904    nrctrrpp  from dual union all 
    select  16  cdcooper,  3986322  nrdconta,  11508   nrctrrpp  from dual union all 
    select  16  cdcooper,  3986365  nrdconta,  11234   nrctrrpp  from dual union all 
    select  16  cdcooper,  6016103  nrdconta,  161541  nrctrrpp  from dual union all 
    select  16  cdcooper,  6077382  nrdconta,  9228    nrctrrpp  from dual union all 
    select  16  cdcooper,  6160565  nrdconta,  8711    nrctrrpp  from dual union all 
    select  16  cdcooper,  6255310  nrdconta,  3285    nrctrrpp  from dual union all 
    select  16  cdcooper,  6276890  nrdconta,  657     nrctrrpp  from dual union all 
    select  16  cdcooper,  6370012  nrdconta,  1900    nrctrrpp  from dual union all 
    select  16  cdcooper,  6432824  nrdconta,  175351  nrctrrpp  from dual union all 
    select  16  cdcooper,  6555039  nrdconta,  8367    nrctrrpp  from dual union all 
    select  16  cdcooper,  6597602  nrdconta,  7461    nrctrrpp  from dual union all 
    select  16  cdcooper,  6670938  nrdconta,  2914    nrctrrpp  from dual union all 
    select  16  cdcooper,  6764614  nrdconta,  1962    nrctrrpp  from dual;
   rw_aplica cr_aplica%ROWTYPE;
  

    -----------------------------------------------------------------------------
   procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;  
  
  procedure demitidos (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
  END; 
  
  procedure erroapli0005 (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END;
  
  procedure loga (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
  END; 
  
  procedure erro (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv5, pr_msg);
  END; 
  
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2);  
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3);
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5);
  END;

   --Carrega as taxas
   PROCEDURE carrega_craptxi IS    
       BEGIN
         FOR rw_craptxi IN cr_craptxi LOOP
            vr_idx_craptxi := to_char(rw_craptxi.dtiniper,'rrrrmmdd');
            vr_tab_craptxi(vr_idx_craptxi) := rw_craptxi.vlrdtaxa;
         END LOOP;
       END;
        
           
   FUNCTION fn_retorna_aliquota_ir(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_dtinicio IN crapdat.dtmvtolt%TYPE
                                   ,pr_dtperfim IN crapdat.dtmvtolt%TYPE) RETURN NUMBER IS
        vr_qtdiasir  PLS_INTEGER;
        vr_perciirf  NUMBER(12,8);
       BEGIN
        vr_perciirf := 0;
        vr_qtdiasir := pr_dtperfim - pr_dtinicio;
          IF vr_qtdiasir <= 0 THEN
            vr_qtdiasir := 1;
          END IF;

   -- Consulta faixas de IR
   apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);
      FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
        IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
          vr_perciirf := NVL(apli0001.vr_faixa_ir_rdc(i).perirtab,0);
          EXIT;
        END IF;
      END LOOP;
      RETURN vr_perciirf;  
    END;
    
   PROCEDURE pc_lancamento_aplic(pr_cdcooper IN craprac.cdcooper%TYPE      -- Código da Cooperativa
                                ,pr_nrdconta IN craprac.nrdconta%TYPE      -- Número da Conta
                                ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE DEFAULT 0 -- Número aplicação programada (Opcional, 0 = Aplicação Não Programada)
                                ,pr_cdprodut IN craprac.cdprodut%TYPE
                                ,pr_nraplica OUT craprac.nraplica%TYPE     -- Numero da aplicacao cadastrada
                                ,pr_cdcritic OUT PLS_INTEGER     -- Codigo da critica de erro
                                ,pr_dscritic OUT VARCHAR2) IS -- Descricao da critica de erro
  BEGIN

     
      OPEN cr_crapsli(pr_cdcooper => rw_craprpp.cdcooper
                     ,pr_nrdconta => rw_craprpp.nrdconta
                     ,pr_dtrefere => rw_crapdat.dtultdia);

        FETCH cr_crapsli INTO rw_crapsli;
        
      -- Atualizar Saldo Conta Investimento ---
      IF cr_crapsli%NOTFOUND THEN
        CLOSE cr_crapsli;
        -- Inserir registro de saldo da conta investimento
        BEGIN
          INSERT INTO crapsli (cdcooper
                              ,nrdconta
                              ,dtrefere
                              ,vlsddisp) 
               VALUES (rw_craprpp.cdcooper
                      ,rw_craprpp.nrdconta
                      ,rw_crapdat.dtultdia
                      ,vr_vlresgat)
             RETURNING
              crapsli.rowid
             INTO
              vr_crapsli_rowid;
            EXCEPTION  
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPSLI.';
            RAISE vr_excsaida;
        END;
        backup('delete from crapsli where rowid = '''||vr_crapsli_rowid||''';'); 
      ELSE
        -- Fecha cursor
        CLOSE cr_crapsli;
       
        -- Atualiza registro de saldo na conta investimento
        BEGIN
          UPDATE crapsli
             SET vlsddisp = rw_crapsli.vlsddisp + vr_vlresgat
           WHERE crapsli.rowid = rw_crapsli.rowid;
          EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro na CRAPSLI.';
          erro('1308 crapsli - Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);
          RAISE vr_excsaida;
        END;
      END IF;
       
      IF vr_crapsli_rowid IS NULL
        THEN vr_crapsli_rowid := rw_crapsli.rowid;
      END IF;
      
      apli0005.pc_obtem_carencias(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                 ,pr_cdprodut => pr_cdprodut -- Codigo do Produto 
                                 ,pr_cdcritic => vr_cdcritic   -- Codigo da Critica
                                 ,pr_dscritic => vr_dscritic   -- Descricao da Critica
                                 ,pr_tab_care => vr_tab_care); -- Tabela com registros de Carencia do produto    

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_excsaida;  
      END IF;

      apli0005.pc_cadastra_aplic(pr_cdcooper => pr_cdcooper,
                                 pr_cdoperad => '1',
                                 pr_nmdatela => 'CRPS145',
                                 pr_idorigem => 5,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_idseqttl => 1,
                                 pr_nrdcaixa => vr_cdbccxlt,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_cdprodut => pr_cdprodut,
                                 pr_qtdiaapl => vr_tab_care(1).qtdiaprz,
                                 pr_dtvencto => rw_crapdat.dtmvtolt + vr_tab_care(1).qtdiaprz,
                                 pr_qtdiacar => vr_tab_care(1).qtdiacar,
                                 pr_qtdiaprz => vr_tab_care(1).qtdiaprz,
                                 pr_vlaplica => vr_vlresgat,
                                 pr_iddebcti => 1,
                                 pr_idorirec => 0,
                                 pr_idgerlog => 1,
                                 pr_nrctrrpp => pr_nrctrrpp, -- Número da RPP
                                 pr_nraplica => vr_nraplica,
                                 pr_cdcritic => vr_cdcritic,
                                 pr_dscritic => vr_dscritic);
     IF (vr_cdcritic IS NOT NULL) OR (vr_dscritic IS NOT NULL) THEN

        vr_dscritic := 'Conta: '|| rw_craprpp_migra.nrdconta || ' Plano: ' || rw_craprpp_migra.nrctrrpp || ' - ' || vr_dscritic;
        erroapli0005 ('Cooperativa: ' || rw_craprpp_migra.cdcooper || ' - Conta: ' || rw_craprpp_migra.nrdconta || ' - Contrato: ' || pr_nrctrrpp || ' - ERRO: - ' || vr_dscritic);
        
        BEGIN
          UPDATE crapsli
             SET vlsddisp = vlsddisp - vr_vlresgat
           WHERE crapsli.rowid = vr_crapsli_rowid;
          EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPSLI.';
            erro('1308 crapsli - Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);         
          RAISE vr_excsaida;
        END;
      RAISE vr_exc_saida;    

        
     END IF; 
       backup('delete from craprac where cdcooper = '|| rw_craprpp.cdcooper || ' and nrdconta = '|| rw_craprpp.nrdconta || ' and nraplica = '|| vr_nraplica || ' and nrctrrpp = '|| pr_nrctrrpp ||';');                                
     --  backup('update craprac set idsaqtot = 1, vlsldatl = 0, vlbasapl = 0 where cdcooper = '|| rw_craprpp.cdcooper || ' and nrdconta = '|| rw_craprpp.nrdconta || ' and nraplica = '|| vr_nraplica || ' and nrctrrpp = '|| pr_nrctrrpp ||';');    
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_craprpp.cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100
                                 ,pr_nrdolote => 10106
                                 ,pr_cdoperad => '1'
                                 ,pr_nrdcaixa => 0
                                 ,pr_tplotmov => 29
                                 ,pr_cdhistor => 0
                                 ,pr_craplot => rw_craplot
                                 ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        erro('1558 lote - 10106 ' || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);
        RAISE vr_excsaida;
      END IF;

      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||10106);

      BEGIN
        INSERT INTO craplci (craplci.dtmvtolt
                             ,craplci.cdagenci
                             ,craplci.cdbccxlt
                             ,craplci.nrdolote
                             ,craplci.nrdconta
                             ,craplci.nrdocmto
                             ,craplci.cdhistor
                             ,craplci.vllanmto
                             ,craplci.nrseqdig
                             ,craplci.cdcooper )
                      VALUES (rw_craplot.dtmvtolt -- craplci.dtmvtolt
                             ,rw_craplot.cdagenci -- craplci.cdagenci
                             ,rw_craplot.cdbccxlt -- craplci.cdbccxlt
                             ,rw_craplot.nrdolote -- craplci.nrdolote
                             ,rw_craprpp.nrdconta         -- craplci.nrdconta
                             ,vr_nrseqdig -- craplci.nrdocmto
                             ,490   /* Credito Proveniente Aplicacao*/     -- craplci.cdhistor
                             ,vr_vlresgat         -- craplci.vllanmto
                             ,vr_nrseqdig -- craplci.nrseqdig
                             ,rw_craprpp.cdcooper)       -- craplci.cdcooper
        RETURNING
          craplci.rowid
        INTO
          vr_craplci_rowid;  
           backup('delete from craplci where rowid = ''' || vr_craplci_rowid ||''';');                                
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel inserir craplci (nrdconta:'||rw_craprpp.nrdconta ||'): '||SQLERRM;
            erro('1573 craplci- Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic); 
            RAISE vr_excsaida;
      END;
       IF cr_craprpp_migra%ISOPEN THEN 
        CLOSE cr_craprpp_migra;        
      END IF; 
      
      
       EXCEPTION
      WHEN vr_exc_saida then 
       vr_dscritic := 'ERRO ' || vr_dscritic;        
        pr_dscritic := vr_dscritic;
        
      IF cr_craprpp_migra%ISOPEN THEN 
        CLOSE cr_craprpp_migra;        
      END IF; 
   END;      
     

       
    
---------------INICIO    
BEGIN

  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
   
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp5       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv5     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;   
    
   loga('INICIO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
   carrega_craptxi;
       
  FOR rw_aplica IN cr_aplica LOOP
    OPEN cr_crapdat (pr_cdcooper => rw_aplica.cdcooper);
     FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
    loga('Conta: ' || rw_aplica.nrdconta || ' - Cooperativa: ' || rw_aplica.cdcooper);
     
    OPEN cr_crapass (pr_cdcooper => rw_aplica.cdcooper
                    ,pr_nrdconta => rw_aplica.nrdconta);
     FETCH cr_crapass INTO rw_crapass;
      IF rw_crapass.dtdemiss IS NOT NULL THEN
        CLOSE cr_crapass;
        demitidos('Conta: ' || rw_aplica.nrdconta || ' - Cooperativa: ' || rw_aplica.cdcooper);
        CONTINUE;
      END IF; 
    CLOSE cr_crapass;
          
    OPEN cr_craprpp (pr_cdcooper => rw_aplica.cdcooper
                    ,pr_nrdconta => rw_aplica.nrdconta
                    ,pr_nrctrrpp => rw_aplica.nrctrrpp);
     FETCH cr_craprpp INTO rw_craprpp;
       IF cr_craprpp%NOTFOUND THEN
         CLOSE cr_craprpp;
         erro('893 - Erro NOTFOUND cr_craprpp - Conta: ' || rw_aplica.nrdconta || ' - Cooperativa: ' || rw_aplica.cdcooper);
         CONTINUE;
       END IF;
    CLOSE cr_craprpp;    
           
    OPEN cr_crapspp (pr_cdcooper => rw_craprpp.cdcooper
                    ,pr_nrdconta => rw_craprpp.nrdconta
                    ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                    ,pr_dtiniper => rw_craprpp.dtiniper);
      FETCH cr_crapspp INTO rw_crapspp;
    CLOSE cr_crapspp;        
               
    vr_valorend := 0;
    vr_vlinicio := rw_craprpp.vlsdrdpp;
    vr_vlrsldpp := rw_craprpp.vlsdrdpp;
    vr_dtmvtolt := rw_craprpp.dtiniper;    
         
    IF vr_vlinicio = 0  THEN
       vr_vlinicio := rw_crapspp.vlsldrpp;
       vr_vlrsldpp := rw_crapspp.vlsldrpp;
    END IF;
        
    WHILE vr_dtmvtolt < rw_crapdat.dtmvtolt LOOP
            
      IF vr_vlrsldpp = 0 THEN
        EXIT;
      END IF;
            
      -- se for dia util
      IF vr_dtmvtolt = GENE0005.fn_valida_dia_util(pr_cdcooper =>  rw_craprpp.cdcooper
                                                   ,pr_dtmvtolt => vr_dtmvtolt
                                                   ,pr_tipo => 'P'
                                                   ,pr_feriado => true
                                                   ,pr_excultdia => true) THEN
                                                        
        OPEN cr_craplpp    (pr_cdcooper => rw_craprpp.cdcooper
                           ,pr_nrdconta => rw_craprpp.nrdconta
                           ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                           ,pr_dtmvtolt => vr_dtmvtolt);
          FETCH cr_craplpp INTO rw_craplpp;
            IF cr_craplpp%NOTFOUND THEN
              rw_craplpp.vlresgat := 0;          
            END IF;
        CLOSE cr_craplpp; 
                                                           
        IF rw_craplpp.vlresgat > 0 THEN
          vr_vlrsldpp := vr_vlrsldpp - rw_craplpp.vlresgat;
        END IF;
              
        -- Consulta a taxa do CDI
        vr_idx_craptxi := to_char(vr_dtmvtolt,'rrrrmmdd');
        IF vr_tab_craptxi.exists(vr_idx_craptxi) THEN
           vr_txperiod := vr_tab_craptxi(vr_idx_craptxi);
        ELSE
           vr_dscritic := 'Taxa nao encontrada! Data: '||to_char(vr_dtmvtolt,'dd/mm/rrrr');
           RAISE vr_excsaida;
        END IF;
                          
        -- Taxa do indexador deverá estar descapitalizada ao dia, pois o rendimento é calculado diariamente
        vr_txperiod := ROUND((POWER((vr_txperiod / 100) + 1, 1 / 252) - 1), 8);
        vr_txperiod := ROUND(vr_txperiod * 0.94, 8);
                      
        vr_vlrendim := ROUND(vr_vlrsldpp * (vr_txperiod), 6);
        vr_vlrsldpp := ROUND(vr_vlrsldpp + vr_vlrendim, 6);
        vr_valorend := ROUND(vr_valorend + vr_vlrendim, 6);

      END IF;--se for dia util
        
      vr_dtmvtolt := vr_dtmvtolt + 1;

    END LOOP; --vr_dtmvtolt < rw_crapdat.dtmvtolt
         
      
    --calcular IR
    pr_percirrf := fn_retorna_aliquota_ir(rw_aplica.cdcooper, rw_craprpp.dtiniper,  vr_dtmvtolt);
    IF NVL(pr_percirrf,0) = 0 AND rw_aplica.cdcooper <> 3 THEN
      vr_dscritic := 'Faixa de IRRF nao encontrada.';
      RAISE vr_excsaida;
    END IF;
          
    valorir :=   vr_valorend * (pr_percirrf/100);
    vr_vlrsldpp := ROUND(vr_vlrsldpp,2);
    vr_valorend := ROUND(vr_valorend,2);
    valorir     := ROUND(valorir,2);
    vr_vlresgat :=  vr_vlrsldpp - valorir;    
     
      
     
 ----------------------------------------------------------------------------------------------------------------  
    --Inicio da migracao ou resgate.             
     
    --Buscar a nova aplicação
  OPEN cr_craprpp_migra (pr_cdcooper => rw_craprpp.cdcooper
                        ,pr_nrdconta => rw_craprpp.nrdconta
                        ,pr_dtdebito => rw_craprpp.dtdebito
                        ,pr_vlprerpp => rw_craprpp.vlprerpp);
   FETCH cr_craprpp_migra INTO rw_craprpp_migra;
  IF cr_craprpp_migra%NOTFOUND THEN
              
   
      --Verifica se a conta possui bloqueio
      Apli0002.pc_ver_val_bloqueio_poup(pr_cdcooper => rw_aplica.cdcooper,
                                        pr_cdagenci => 1,
                                        pr_nrdcaixa => 1,
                                        pr_cdoperad => '1',
                                        pr_nmdatela => 'CRPS156',
                                        pr_idorigem => 7,
                                        pr_nrdconta => rw_aplica.nrdconta,
                                        pr_idseqttl => 1,
                                        pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                        pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                        pr_inproces => rw_crapdat.inproces,
                                        pr_cdprogra => 'CRPS156',
                                        pr_vlresgat => vr_vlresgat,
                                        pr_flgerlog => 0,
                                        pr_flgrespr => 0,
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);

      -- Verifica se houve retorno de erros
      IF (NVL(vr_dscritic, 'OK') <> 'OK') OR (NVL(vr_cdcritic,0) > 0)  THEN
       
        
        vr_nrseqted := cecred.fn_sequence(pr_nmtabela => 'CRAPMAT',
                                            pr_nmdcampo => 'NRRDCAPP',
                                            pr_dsdchave => rw_craprpp.cdcooper,
                                            pr_flgdecre => 'N');
              
              
               Select max(nrseqdig) + 1
                  into vr_nrseqdig
                  from craprpp
                 where cdcooper = rw_craprpp.cdcooper
                   and dtmvtolt = rw_crapdat.dtmvtolt
                   and cdagenci = rw_craprpp.cdagenci
                   and cdbccxlt = 200 -- fixo
                   and nrdolote = 1537; -- fixo
              
                If vr_nrseqdig is null Then
                  vr_nrseqdig := 1;
                End If;  
                        
                BEGIN
                  INSERT INTO craprpp
                    (nrctrrpp,
                     cdsitrpp,
                     cdcooper,
                     cdageass,
                     cdagenci,
                     tpemiext,
                     dtcalcul,
                     dtvctopp,
                     cdopeori,
                     cdageori,
                     dtinsori,
                     dtrnirpp,
                     dtiniper,
                     dtfimper,
                     dtinirpp,
                     dtdebito,
                     flgctain,
                     nrdolote,
                     cdbccxlt,
                     cdsecext,
                     nrdconta,
                     vlprerpp,
                     dtimpcrt,
                     indebito,
                     nrseqdig,
                     dtmvtolt,
                     dtaltrpp,
                     vlabcpmf,
                     vlabdiof,
                     cdprodut,
                     dsfinali,
                     vlsdrdpp)
                  VALUES
                    (vr_nrseqted,
                     3,
                     rw_craprpp.cdcooper,
                     rw_craprpp.cdagenci,
                     rw_craprpp.cdagenci,
                     rw_craprpp.tpemiext,
                     rw_craprpp.dtcalcul,
                     rw_craprpp.dtvctopp,
                     rw_craprpp.cdopeori,
                     rw_craprpp.cdageori,
                     rw_craprpp.dtinsori, -- Mantendo a data original da RPP nao do novo produto
                     rw_craprpp.dtrnirpp,
                     rw_craprpp.dtiniper,
                     rw_craprpp.dtfimper,
                     rw_crapdat.dtmvtolt,
                     rw_craprpp.dtdebito,
                     1,
                     1537,
                     vr_cdbccxl2,
                     rw_craprpp.cdsecext,
                     rw_craprpp.nrdconta,
                     rw_craprpp.vlprerpp,
                     null, -- Contrato não foi impresso da Apl. Prog.
                     0,
                     vr_nrseqdig,
                     rw_crapdat.dtmvtolt,
                     rw_crapdat.dtmvtolt, -- Alteracao do Plano
                     rw_craprpp.vlabcpmf,
                     rw_craprpp.vlabdiof,
                     vr_codproduto, -- Produto AP Default
                     ' ',
                     vr_vlrsldpp)
            RETURNING
             craprpp.rowid
            INTO
             vr_craprpp_rowid;
     
            EXCEPTION
               WHEN OTHERS THEN
                vr_dscritic := 'Erro na insercao RPP: '||rw_craprpp.cdcooper||' '||rw_craprpp.nrdconta||' '||rw_craprpp.dtvctopp||' '||rw_craprpp.vlprerpp||' '|| vr_nrseqted || ' ' ||sqlerrm;
               RAISE vr_excsaida;
          END;
          backup('delete from craprpp where rowid = ''' || vr_craprpp_rowid ||''';');
          erro('1000 - Apli0002 - Conta: ' || rw_aplica.nrdconta || ' - Cooperativa: ' || rw_aplica.cdcooper || ' - ' || vr_cdcritic || ' - ' || vr_dscritic  );                                        
       
        pc_lancamento_aplic(pr_cdcooper => rw_craprpp.cdcooper,
                           pr_nrdconta => rw_craprpp.nrdconta,
                           pr_nrctrrpp => vr_nrseqted, -- Número da RPP
                           pr_cdprodut => vr_codproduto,
                           pr_nraplica => vr_nraplica,
                           pr_cdcritic => vr_cdcritic,
                           pr_dscritic => vr_dscritic);
           IF vr_dscritic is not null THEN
               vr_dscritic := 'Conta: '|| rw_craprpp.nrdconta || ' Cooperativa: '  ||rw_craprpp.cdcooper || ' Plano: ' || vr_nrseqted || ' - ' || vr_dscritic;
               continue;
           END IF; 
           
                 
      ELSE --Bloqueio judicial
          
        
      /* Gerar  lançamento na conta investimento*/
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_craprpp.cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100
                                 ,pr_nrdolote => 10105
                                 ,pr_cdoperad => '1'
                                 ,pr_nrdcaixa => 0
                                 ,pr_tplotmov => 29
                                 ,pr_cdhistor => 0
                                 ,pr_craplot => rw_craplot
                                 ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
            RAISE vr_excsaida;
      END IF;

      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                 ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                 ||1||';'
                                 ||100||';'
                                 ||10105);

      BEGIN
        INSERT INTO craplci
                    (craplci.dtmvtolt
                    ,craplci.cdagenci
                    ,craplci.cdbccxlt
                    ,craplci.nrdolote
                    ,craplci.nrdconta
                    ,craplci.nrdocmto
                    ,craplci.cdhistor
                    ,craplci.vllanmto
                    ,craplci.nrseqdig
                    ,craplci.cdcooper )
             VALUES (rw_craplot.dtmvtolt -- craplci.dtmvtolt
                    ,rw_craplot.cdagenci -- craplci.cdagenci
                    ,rw_craplot.cdbccxlt -- craplci.cdbccxlt
                    ,rw_craplot.nrdolote -- craplci.nrdolote
                    ,rw_craprpp.nrdconta         -- craplci.nrdconta
                    ,vr_nrseqdig -- craplci.nrdocmto
                    ,496 /* Debito */    -- craplci.cdhistor
                    ,vr_vlresgat         -- craplci.vllanmto
                    ,vr_nrseqdig -- craplci.nrseqdig
                    ,rw_craprpp.cdcooper)       -- craplci.cdcooper
        RETURNING
        craplci.rowid
        INTO
        vr_craplci_rowid;
        EXCEPTION
          WHEN OTHERS THEN
           vr_dscritic := 'Não foi possivel inserir craplci(nrdconta:'||rw_craprpp.nrdconta ||'): '||SQLERRM;
           erro('1399 craplci- Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);
          RAISE vr_excsaida;
      END;
      backup('delete from craplci where rowid = ''' || vr_craplci_rowid ||''';');

      /*** Gera lancamentos Conta Investmento  - Credito Transf. ***/
      /* Projeto Revitalizacao - Remocao de lote */
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_craprpp.cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100
                                 ,pr_nrdolote => 10104
                                 ,pr_cdoperad => '1'
                                 ,pr_nrdcaixa => 0
                                 ,pr_tplotmov => 29
                                 ,pr_cdhistor => 0
                                 ,pr_craplot => rw_craplot
                                 ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        erro('1419 lote - 10104 ' || ' - Cooperativa: ' || rw_craprpp.cdcooper );
        RAISE vr_excsaida;
      END IF;

      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||10104);

      BEGIN
        INSERT INTO craplci
                    (craplci.dtmvtolt
                    ,craplci.cdagenci
                    ,craplci.cdbccxlt
                    ,craplci.nrdolote
                    ,craplci.nrdconta
                    ,craplci.nrdocmto
                    ,craplci.cdhistor
                    ,craplci.vllanmto
                    ,craplci.nrseqdig
                    ,craplci.cdcooper )
             VALUES (rw_craplot.dtmvtolt -- craplci.dtmvtolt
                    ,rw_craplot.cdagenci -- craplci.cdagenci
                    ,rw_craplot.cdbccxlt -- craplci.cdbccxlt
                    ,rw_craplot.nrdolote -- craplci.nrdolote
                    ,rw_craprpp.nrdconta         -- craplci.nrdconta
                    ,vr_nrseqdig -- craplci.nrdocmto
                    ,489 /*credito*/     -- craplci.cdhistor
                    ,vr_vlresgat         -- craplci.vllanmto
                    ,vr_nrseqdig -- craplci.nrseqdig
                    ,rw_craprpp.cdcooper)       -- craplci.cdcooper
        RETURNING
        craplci.rowid
        INTO
        vr_craplci_rowid;
        EXCEPTION
         WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel inserir craplci (nrdconta:'||rw_craprpp.nrdconta ||'): '||SQLERRM;
          erro('1460 craplci- Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);
         RAISE vr_excsaida;
      END;
      backup('delete from craplci where rowid = ''' || vr_craplci_rowid ||''';');
          
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||8473);

      lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_craplot.dtmvtolt
                                        ,pr_cdagenci => rw_craplot.cdagenci
                                        ,pr_cdbccxlt => rw_craplot.cdbccxlt
                                        ,pr_nrdolote => rw_craplot.nrdolote
                                        ,pr_nrdconta => rw_craprpp.nrdconta
                                        ,pr_nrdocmto => vr_nrseqdig
                                        ,pr_cdhistor =>(CASE rw_craprpp.flgctain
                                                          WHEN 1 /* true */ THEN 501 -- TRANSF. RESGATE C/I PARA C/C
                                                          ELSE 159 -- CR.POUP.PROGR
                                                         END)
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_vllanmto => vr_vlresgat
                                        ,pr_nrdctabb => rw_craprpp.nrdconta
                                        ,pr_cdcooper => rw_craprpp.cdcooper
                                        ,pr_nrdctitg => gene0002.fn_mask(rw_craprpp.nrdconta,'99999999')
                                        ,pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                        ,pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                        ,pr_cdcritic  => vr_cdcritic      -- OUT
                                        ,pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
         erro('1167 craplcm LANC0001- Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);
        -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução
        IF vr_incrineg = 0 THEN
          vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
          RAISE vr_excsaida;
        ELSE
          vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
          RAISE vr_excsaida;
        END IF;

      END IF;
        backup('delete from craplcm where rowid = '''||vr_tab_retorno.rowidlct||''';'); 
        CLOSE cr_craprpp_migra;  
     END IF;--Bloqueio Judicial - Criado uma nova aplicacao  
     
   
  ELSE --ja possui outra aplicacao
        pc_lancamento_aplic(pr_cdcooper => rw_craprpp.cdcooper,
                           pr_nrdconta => rw_craprpp.nrdconta,
                           pr_nrctrrpp => rw_craprpp_migra.nrctrrpp, -- Número da RPP
                           pr_cdprodut => rw_craprpp_migra.cdprodut,
                           pr_nraplica => vr_nraplica,
                           pr_cdcritic => vr_cdcritic,
                           pr_dscritic => vr_dscritic);
           IF vr_dscritic is not null THEN
               vr_dscritic := 'Conta: '|| rw_craprpp.nrdconta || ' Cooperativa: '  ||rw_craprpp.cdcooper || ' Plano: ' || vr_nrseqted || ' - ' || vr_dscritic;
               continue;
           END IF;  
     END IF;
    
    --Fim migracao
 -----------------------------------------------------------------------------------------------------------------------
      --Lançamentos na poupança programada
      pr_vlsdrdpp := vr_vlrsldpp;
      vr_dtdolote := rw_crapdat.dtmvtolt;
      vr_nrdolote := 8384;
      vr_cdhistor := 151;
        
      --Busta a taxa
      OPEN cr_craptrd (pr_cdcooper => rw_craprpp.cdcooper,
                       pr_dtiniper => rw_craprpp.dtiniper,
                       pr_vlsdrdpp => pr_vlsdrdpp,
                       pr_tptaxrda => 4);
        FETCH cr_craptrd INTO rw_craptrd;
      IF cr_craptrd%NOTFOUND THEN
        vr_dscritic := gene0001.fn_busca_critica(347)||
                       ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy')||
                       ' NrCtrRpp: '||to_char(rw_craprpp.nrctrrpp, 'fm999g999g990')||
                       ' Faixa: '||to_char(pr_vlsdrdpp, 'fm999g999g990d00');
        erro('1022 - Erro NOTFOUND cr_craptrd - Data: ' || rw_craprpp.dtiniper || ' - Cooperativa: ' || rw_craprpp.cdcooper);                         
        RAISE vr_excsaida;
      END IF;
      CLOSE cr_craptrd;
      
      IF rw_craptrd.txofidia > 0 THEN
        vr_txaplica := (rw_craptrd.txofidia / 100);
        vr_txaplmes := rw_craptrd.txofimes;
      ELSIF rw_craptrd.txprodia > 0 THEN
        vr_txaplica := (rw_craptrd.txprodia / 100);
        vr_txaplmes := 0;
      ELSE
        vr_dscritic := gene0001.fn_busca_critica(427)||
                       ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy');
        RAISE vr_excsaida;
      END IF;
        
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_craprpp.cdcooper
                                 ,pr_dtmvtolt => vr_dtdolote
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_cdbccxlt => vr_cdbccxlt
                                 ,pr_nrdolote => vr_nrdolote
                                 ,pr_cdoperad => '1'
                                 ,pr_nrdcaixa => 0
                                 ,pr_tplotmov => 14
                                 ,pr_cdhistor => 0
                                 ,pr_craplot  => rw_craplot
                                 ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;
         erro('1053 - Erro lote -  ' || vr_nrdolote || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);                         
         raise vr_excsaida;
      END IF;

      --Busca número sequencial
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                                   ||vr_cdagenci||';'
                                   ||vr_cdbccxlt||';'
                                   ||vr_nrdolote);
        
      --Creditar o rendimento na LPP
      BEGIN
        INSERT INTO craplpp (dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             nrdolote,
                             nrdconta,
                             nrctrrpp,
                             nrdocmto,
                             txaplica,
                             txaplmes,
                             cdhistor,
                             nrseqdig,
                             vllanmto,
                             dtrefere,
                             cdcooper)
                     VALUES (vr_dtdolote,
                             vr_cdagenci,
                             vr_cdbccxlt,
                             vr_nrdolote,
                             rw_craprpp.nrdconta,
                             rw_craprpp.nrctrrpp,
                             vr_nrseqdig,
                             (NVL(vr_txaplica, 0) * 100),
                             NVL(vr_txaplmes, 0),
                             vr_cdhistor,
                             vr_nrseqdig,
                             vr_valorend,
                             vr_dtdolote,
                             rw_craprpp.cdcooper)
                             
         RETURNING
          craplpp.rowid
        INTO
          vr_craplpp_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir lançamento de poupança programada: '||SQLERRM;
           erro('1104 - Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - Contrato - ' || rw_craprpp.nrctrrpp || ' - ' || vr_dscritic);                          
            RAISE vr_excsaida;
      END;
      backup('delete from craplpp where rowid = ''' || vr_craplpp_rowid ||''';');
                
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                  ,'NRSEQDIG'
                                  ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                                   ||vr_cdagenci||';'
                                   ||vr_cdbccxlt||';'
                                   ||vr_nrdolote);
      -- Debitar do IR - Historico 863
      BEGIN
        INSERT INTO craplpp (dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             nrdolote,
                             nrdconta,
                             nrctrrpp,
                             nrdocmto,
                             txaplica,
                             txaplmes,
                             cdhistor,
                             nrseqdig,
                             vllanmto,
                             dtrefere,
                             cdcooper)
                      VALUES (vr_dtdolote,
                              vr_cdagenci,
                              vr_cdbccxlt,
                              vr_nrdolote,
                              rw_craprpp.nrdconta,
                              rw_craprpp.nrctrrpp,
                              vr_nrseqdig,
                              pr_percirrf,
                              pr_percirrf,
                              863,
                              vr_nrseqdig,
                              valorir,
                              vr_dtdolote,
                              rw_craprpp.cdcooper)
        RETURNING
          craplpp.rowid
        INTO
          vr_craplpp_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir o histórico 863 na poupança programada: '||SQLERRM;
            erro('1154 - Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - Contrato - ' || rw_craprpp.nrctrrpp || ' - ' || vr_dscritic);                          
            RAISE vr_excsaida;
      END;
      backup('delete from craplpp where rowid = ''' || vr_craplpp_rowid ||''';');
          
          
      OPEN cr_craplppprov (pr_cdcooper => rw_craprpp.cdcooper
                          ,pr_nrdconta => rw_craprpp.nrdconta
                          ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                          ,pr_dtfimper => rw_craprpp.dtfimper);
        FETCH cr_craplppprov INTO rw_craplppprov;
      CLOSE cr_craplppprov;  
        
      
      --Calculo para o ajuste
      vr_vldifpro := rw_craplppprov.vllanmto;
      vr_vlajuste := vr_valorend - vr_vldifpro;
                                    
      -- Lançamento de ajuste do aplicação. Se o rendimento for maior que zero, vai fazer o calculo da diferença e creditar
      IF vr_vlajuste > 0 THEN
         vr_cdhistor := 154;
         vr_vlajuste_cr := abs(vr_vlajuste);
         vr_vlajuste_db := 0;
      ELSIF vr_vlajuste < 0 THEN
         vr_vlajuste := vr_vlajuste * -1;
         vr_cdhistor := 155;
         vr_vlajuste_cr := 0;
         vr_vlajuste_db := abs(vr_vlajuste);
      END IF;

      -- Para lote 8384 utilizar sequence da tabela de lote.
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                                   ||vr_cdagenci||';'
                                   ||vr_cdbccxlt||';'
                                   ||vr_nrdolote);

      -- Insere histórico de ajuste nos lançamentos da poupança programada
      BEGIN
        INSERT INTO craplpp (dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             nrdolote,
                             nrdconta,
                             nrctrrpp,
                             nrdocmto,
                             txaplica,
                             txaplmes,
                             cdhistor,
                             nrseqdig,
                             vllanmto,
                             dtrefere,
                             cdcooper)
                     VALUES (vr_dtdolote,
                            vr_cdagenci,
                            vr_cdbccxlt,
                            8384,
                            rw_craprpp.nrdconta,
                            rw_craprpp.nrctrrpp,
                            NVL(vr_nrseqdig,0),
                            (NVL(vr_txaplica, 0) * 100),
                            NVL(vr_txaplmes, 0),
                            vr_cdhistor,
                            NVL(vr_nrseqdig,0),
                            abs(vr_vlajuste),
                            vr_dtdolote,
                            rw_craprpp.cdcooper)
        RETURNING
          craplpp.rowid
        INTO
          vr_craplpp_rowid;            
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir o histórico '||vr_cdhistor||' nos lançamentos da poupança programada: '||sqlerrm;
            erro('1230 - Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - Contrato - ' || rw_craprpp.nrctrrpp || ' - ' || vr_dscritic);
            RAISE vr_excsaida;
      END;
      backup('delete from craplpp where rowid = ''' || vr_craplpp_rowid ||''';');
      

      --Lancamento Resgate
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||8383);
      BEGIN
        INSERT INTO craplpp (craplpp.dtmvtolt
                            ,craplpp.cdagenci
                            ,craplpp.cdbccxlt
                            ,craplpp.nrdolote
                            ,craplpp.nrdconta
                            ,craplpp.nrctrrpp
                            ,craplpp.nrdocmto
                            ,craplpp.txaplmes
                            ,craplpp.txaplica
                            ,craplpp.cdhistor
                            ,craplpp.nrseqdig
                            ,craplpp.dtrefere
                            ,craplpp.vllanmto
                            ,craplpp.cdcooper)
                     VALUES (rw_craplot.dtmvtolt           -- craplpp.dtmvtolt
                            ,rw_craplot.cdagenci           -- craplpp.cdagenci
                            ,rw_craplot.cdbccxlt           -- craplpp.cdbccxlt
                            ,rw_craplot.nrdolote           -- craplpp.nrdolote
                            ,rw_craprpp.nrdconta           -- craplpp.nrdconta
                            ,rw_craprpp.nrctrrpp           -- craplpp.nrctrrpp
                            ,vr_nrseqdig           -- craplpp.nrdocmto
                            ,vr_txaplmes               -- craplpp.txaplmes
                            ,vr_txaplica               -- craplpp.txaplica
                            ,(CASE rw_craprpp.flgctain
                                WHEN 1 /*YES*/  THEN
                                  496   /* RESGATE POUP. p/ C.I */
                                ELSE 158  /* RESGATE POUP. */       -- craplpp.cdhistor
                              END)
                            ,vr_nrseqdig           -- craplpp.nrseqdig
                            ,rw_craprpp.dtfimper           -- craplpp.dtrefere
                            ,vr_vlresgat                   -- craplpp.vllanmto
                            ,rw_craprpp.cdcooper)                -- craplpp.cdcooper
        RETURNING
          craplpp.rowid
        INTO
          vr_craplpp_rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possivel atualizar craplpp (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
              erro('1284 - Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - Contrato - ' || rw_craprpp.nrctrrpp || ' - ' || vr_dscritic);
              RAISE vr_excsaida;
      END;
      backup('delete from craplpp where rowid = ''' || vr_craplpp_rowid ||''';');
            
      --Fim lançamento poupanca programada
------------------------------------------------------------------------------------------------------------------------
               
         UPDATE craprpp
             SET craprpp.vlsdrdpp = 0,
                 craprpp.cdsitrpp = 5 -- 5-vencido.
            WHERE craprpp.rowid = rw_craprpp.rowid;
            
            
   END LOOP; --cr_aplica
   COMMIT;
    loga('FIM COMMIT ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
    fecha_arquivos;
   
    EXCEPTION
      WHEN vr_excsaida then 
       :vr_dscritic := 'ERRO ' || vr_dscritic;  
       loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
       fecha_arquivos;  
       ROLLBACK;
      WHEN OTHERS then
       :vr_dscritic := 'ERRO ' || vr_dscritic || sqlerrm;
       loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
       fecha_arquivos; 
       ROLLBACK;       
END;
1
vr_dscritic
0
5
0
