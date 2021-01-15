
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
    vr_codproduto        PLS_INTEGER := 1007; -- Codigo da aplicacao programada 
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
    vr_nmarqimp3       VARCHAR2(100)  := 'loga.txt';
    vr_ind_arquiv3     utl_file.file_type;
    vr_nmarqimp5       VARCHAR2(100)  := 'erro.txt';
    vr_ind_arquiv5     utl_file.file_type;
    
    
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0059078_migracao'; 
    rw_craplot_rvt lote0001.cr_craplot_sem_lock%rowtype;  
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
    vr_tbcotas_devolucao_rowid ROWID;  
    
    
   CURSOR cr_tbcotas_devolucao (pr_cdcooper IN tbcotas_devolucao.cdcooper%TYPE
                               ,pr_nrdconta IN tbcotas_devolucao.nrdconta%TYPE) IS
    SELECT     tb.nrdconta
              ,tb.vlcapital
              ,tb.cdcooper
              ,tb.tpdevolucao
         FROM tbcotas_devolucao tb
        WHERE tb.cdcooper = pr_cdcooper
          AND tb.nrdconta = pr_nrdconta
          AND tb.tpdevolucao = 4;  
       rw_tbcotas_devolucao cr_tbcotas_devolucao%ROWTYPE; 
              
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
             crapass.dtdemiss,
             crapass.inpessoa
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
       
       
   CURSOR cr_craplot ( pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_dtmvtolt IN DATE
                      ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
         SELECT craplot.rowid
               ,craplot.cdagenci
               ,craplot.cdbccxlt
               ,craplot.nrdolote
               ,craplot.nrseqdig
               ,craplot.qtinfoln
               ,craplot.qtcompln
               ,craplot.cdcooper
               ,craplot.dtmvtolt
               ,craplot.vlinfodb
               ,craplot.vlcompdb
         FROM   craplot
         WHERE  craplot.cdcooper = pr_cdcooper
         AND    craplot.dtmvtolt = pr_dtmvtolt
         AND    craplot.cdagenci = 1
         AND    craplot.cdbccxlt = 100
         AND    craplot.nrdolote = pr_nrdolote;
      rw_craplot7200  cr_craplot%ROWTYPE;       
    
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
    select  1   cdcooper,  6658148  nrdconta,  72779   nrctrrpp  from dual union all
    select  2   cdcooper,  466751   nrdconta,  22087   nrctrrpp  from dual union all 
    select  7   cdcooper,  30031    nrdconta,  1226    nrctrrpp  from dual union all
    select  7   cdcooper,  35947    nrdconta,  2975    nrctrrpp  from dual union all
    select  7   cdcooper,  45535    nrdconta,  280     nrctrrpp  from dual union all 
    select  7   cdcooper,  45624    nrdconta,  2058    nrctrrpp  from dual union all 
    select  7   cdcooper,  80233    nrdconta,  1496    nrctrrpp  from dual union all 
    select  7   cdcooper,  330370   nrdconta,  772     nrctrrpp  from dual union all 
    select  9   cdcooper,  104159   nrdconta,  2066    nrctrrpp  from dual union all 
    select  11  cdcooper,  74810    nrdconta,  816     nrctrrpp  from dual union all 
    select  11  cdcooper,  225304   nrdconta,  3922    nrctrrpp  from dual union all
    select  11  cdcooper,  287687   nrdconta,  10886   nrctrrpp  from dual union all 
    select  11  cdcooper,  370134   nrdconta,  17576   nrctrrpp  from dual union all 
    select  16  cdcooper,  88269    nrdconta,  591     nrctrrpp  from dual union all 
    select  16  cdcooper,  162531   nrdconta,  5927    nrctrrpp  from dual union all 
    select  16  cdcooper,  2272776  nrdconta,  5268    nrctrrpp  from dual union all 
    select  16  cdcooper,  2735490  nrdconta,  11320   nrctrrpp  from dual;
   rw_aplica cr_aplica%ROWTYPE;
  

    -----------------------------------------------------------------------------
   procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
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
      
    
---------------INICIO    
BEGIN

  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;

  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
   
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp5       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv5     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
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
                          
        -- Taxa do indexador devera estar descapitalizada ao dia, pois o rendimento e calculado diariamente
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
   loga('Conta: ' || rw_aplica.nrdconta  || ' - Cooperativa: '||rw_aplica.nrdconta|| 
                ' - Valor resgate: '|| vr_vlresgat || ' - Rendimento: '|| vr_valorend||
                ' - IR: '|| valorir);  
     
 -----------------------------------------------------------------------------------------------------------------------
      --Lancamentos na poupanca programada
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

      --Busca numero sequencial
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
                                    
      -- Lancamento de ajuste do aplicacao. Se o rendimento for maior que zero, vai fazer o calculo da diferenca e creditar
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
      loga('Conta: ' || rw_aplica.nrdconta  || ' - Cooperativa: '||rw_aplica.nrdconta|| 
                ' - AjusteCredito: '|| vr_vlajuste_cr||
                ' - AjusteDebito: '||vr_vlajuste_db );
      -- Para lote 8384 utilizar sequence da tabela de lote.
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                                   ||vr_cdagenci||';'
                                   ||vr_cdbccxlt||';'
                                   ||vr_nrdolote);

      -- Insere historico de ajuste nos lancamentos da poupanca programada
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
      
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_craprpp.cdcooper
                                      , pr_dtmvtolt => rw_crapdat.dtmvtopr
                                      , pr_cdagenci => 1
                                      , pr_cdbccxlt => 100
                                      , pr_nrdolote => 8383
                                      , pr_cdoperad => '1'
                                      , pr_nrdcaixa => 0
                                      , pr_tplotmov => 14
                                      , pr_cdhistor => 0
                                      , pr_craplot => rw_craplot_rvt
                                      , pr_dscritic => vr_dscritic);
                      
            if vr_dscritic is not null then
                  RAISE vr_exc_saida;
            END IF;
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
    --Lancamento conta investimento
    /* Gerar  lancamento na conta investimento*/
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
        erro('lote - 10105 ' || ' - Cooperativa: ' || rw_craprpp.cdcooper );
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
        erro(' lote - 10104 ' || ' - Cooperativa: ' || rw_craprpp.cdcooper );
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
------------------------------------------------------------------------------------------------------------
   --Lancamentos na conta corrente
    lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_craprpp.cdcooper
                                        , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        , pr_cdagenci => 1
                                        , pr_cdbccxlt => 100
                                        , pr_nrdolote => 8473
                                        , pr_cdoperad => '1'
                                        , pr_nrdcaixa => 0
                                        , pr_tplotmov => 1
                                        , pr_cdhistor => 0
                                        , pr_craplot => rw_craplot_rvt
                                        , pr_dscritic => vr_dscritic);
                      
              if vr_dscritic is not null then
                    erro('lote - 8473 ' || ' - Cooperativa: ' || rw_craprpp.cdcooper );
                    RAISE vr_excsaida;
              END IF;   
   
    vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_craprpp.cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'
                                   ||1||';'
                                   ||100||';'
                                   ||8473);

       lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_craplot_rvt.dtmvtolt
                                         ,pr_cdagenci => rw_craplot_rvt.cdagenci
                                         ,pr_cdbccxlt => rw_craplot_rvt.cdbccxlt
                                         ,pr_nrdolote => rw_craplot_rvt.nrdolote
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
      
      OPEN cr_craplot( pr_cdcooper => rw_craprpp.cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_nrdolote => 7200);
      FETCH cr_craplot INTO rw_craplot7200;
      CLOSE cr_craplot;
      
      IF rw_craplot7200.rowid IS NULL THEN
            -- cadastra a capa do lote 7200 na craplot e retornando as informações para usar abaixo
            BEGIN
              INSERT INTO craplot(dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,tplotmov
                                 ,cdcooper)
              VALUES ( rw_crapdat.dtmvtolt
                       ,1
                       ,100
                       ,7200
                       ,1
                       ,rw_craprpp.cdcooper)
              RETURNING cdcooper
                       ,dtmvtolt
                       ,cdagenci
                       ,cdbccxlt
                       ,nrdolote
                       ,nrseqdig
                       ,qtinfoln
                       ,qtcompln
                       ,ROWID
              INTO  rw_craplot7200.cdcooper
                   ,rw_craplot7200.dtmvtolt
                   ,rw_craplot7200.cdagenci
                   ,rw_craplot7200.cdbccxlt
                   ,rw_craplot7200.nrdolote
                   ,rw_craplot7200.nrseqdig
                   ,rw_craplot7200.qtinfoln
                   ,rw_craplot7200.qtcompln
                   ,rw_craplot7200.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir lote 7200 na tabela craplot para a conta ( '||rw_craprpp.nrdconta||' ). '||SQLERRM;
                erro('Erro craplot7200 '  || ' - ' || vr_dscritic);
                --Sair do programa
                RAISE vr_excsaida;
            END;
        END IF;
     OPEN cr_crapass (pr_cdcooper => rw_aplica.cdcooper
                    ,pr_nrdconta => rw_aplica.nrdconta);
     FETCH cr_crapass INTO rw_crapass;
     CLOSE cr_crapass;
            -- inserindo na tabela de depósistos a vista craplcm
                
              -- PRJ450 - 10/10/2018.
              IF rw_crapass.inpessoa = 1 THEN 
                 vr_cdhistor := 2061;
              ELSE 
                 vr_cdhistor := 2062;
              END IF;
              -- Busca o sequencial 
              rw_craplot7200.nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT',
                                                     pr_nmdcampo => 'NRSEQDIG',
                                                     pr_dsdchave => to_char(rw_aplica.cdcooper)||';'||
                                                                    to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||
                                                                    ';1;100;7200');
              lanc0001.pc_gerar_lancamento_conta (pr_dtmvtolt => rw_craplot7200.dtmvtolt
                                                , pr_cdagenci => rw_craplot7200.cdagenci
                                                , pr_cdbccxlt => rw_craplot7200.cdbccxlt
                                                , pr_nrdolote => rw_craplot7200.nrdolote
                                                , pr_nrdconta => rw_craprpp.nrdconta
                                                , pr_nrdocmto => rw_craplot7200.nrseqdig
                                                , pr_cdhistor => vr_cdhistor --decode(rw_crapass.inpessoa,1,2061,2062)
                                                , pr_nrseqdig => rw_craplot7200.nrseqdig
                                                , pr_vllanmto => vr_vlresgat --vr_vldescto
                                                , pr_nrdctabb => rw_craprpp.nrdconta
                                                , pr_cdpesqbb => ' '
                                                , pr_cdcooper => rw_craprpp.cdcooper
                                                , pr_nrdctitg => gene0002.fn_mask(rw_crapass.nrdconta,'99999999')
                                                , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                                , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                                , pr_cdcritic  => vr_cdcritic      -- OUT
                                                , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
              
              IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
                 -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução
                 IF vr_incrineg = 0 THEN  
                   vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
                   erro('1167 craplcm LANC0001- Conta ' || rw_craprpp.nrdconta || ' - Cooperativa: ' || rw_craprpp.cdcooper || ' - ' || vr_dscritic);
                --Sair do programa
                RAISE vr_excsaida;
                 END IF;
              END IF;
               backup('delete from craplcm where rowid = '''||vr_tab_retorno.rowidlct||''';');
      
-------------------------------------------------------------------------------------------------------------
      --lancamentos valores a receber
      OPEN cr_tbcotas_devolucao (pr_cdcooper => rw_aplica.cdcooper
                           ,pr_nrdconta => rw_aplica.nrdconta);
       FETCH cr_tbcotas_devolucao INTO rw_tbcotas_devolucao;

      --Se nao encontrou registro
      IF cr_tbcotas_devolucao%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_tbcotas_devolucao;
        BEGIN 
             INSERT INTO tbcotas_devolucao (cdcooper,
                                            nrdconta,
                                            tpdevolucao,
                                            vlcapital)
                                    VALUES (rw_aplica.cdcooper
                                           ,rw_aplica.nrdconta
                                           ,4 
                                           ,nvl(vr_vlresgat,0))
             RETURNING
             tbcotas_devolucao.rowid
             INTO vr_tbcotas_devolucao_rowid;
             EXCEPTION
               WHEN OTHERS THEN
               vr_dscritic := 'Erro na insercao tbcotas_devolucao: '||rw_aplica.cdcooper||' '||rw_aplica.nrdconta||' '|| sqlerrm;
               erro('tbcotas_devolucao - Conta ' || rw_aplica.nrdconta || ' - ' || vr_dscritic);
               RAISE vr_excsaida;  
           END; 
            backup('delete from tbcotas_devolucao where rowid = '''||vr_tbcotas_devolucao_rowid||''';');                              
       ELSE
         BEGIN
           UPDATE tbcotas_devolucao
              SET vlcapital   = vlcapital + nvl(vr_vlresgat,0)
            WHERE cdcooper    = rw_aplica.cdcooper
              AND nrdconta    = rw_aplica.nrdconta
              AND tpdevolucao = 4;
           EXCEPTION
             WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar tbcotas_devolucao.';
             erro('tbcotas_devolucao - Conta ' || rw_aplica.nrdconta || ' - ' || vr_dscritic);
             RAISE vr_excsaida;
         END;
          backup('update tbcotas_devolucao a set vlcapital = a.vlcapital -'|| nvl(vr_vlresgat,0)||' where rowid = '''||vr_tbcotas_devolucao_rowid||''';'); 
         CLOSE cr_tbcotas_devolucao;
                  
       END IF;               


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
       vr_dscritic := 'ERRO ' || vr_dscritic;  
       loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
       fecha_arquivos;  
       ROLLBACK;
      WHEN OTHERS then
       vr_dscritic := 'ERRO ' || vr_dscritic || sqlerrm;
       loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
       fecha_arquivos; 
       ROLLBACK;       
END;

