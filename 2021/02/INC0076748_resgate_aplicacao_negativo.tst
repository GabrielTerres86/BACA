PL/SQL Developer Test script 3.0
403
declare
vr_cdbccxlt    craplot.cdbccxlt%TYPE := 100;
vr_tab_care    apli0005.typ_tab_care;
pr_dscritic   VARCHAR2(5000) := ' ';
pr_cdcritic   NUMBER(5);
pr_tpcritic NUMBER(5);
vr_nraplica NUMBER(5);
vr_excsaida   EXCEPTION;
vr_vlsldsli1 NUMBER(20,8);
vr_vlsldsli2 NUMBER(20,8);
vr_vlsldsapl NUMBER(20,8);
pr_nrseqdig NUMBER(5);
vr_nmarqimp1       VARCHAR2(100)  := 'backup.txt';
vr_ind_arquiv1     utl_file.file_type;
vr_nmarqimp2       VARCHAR2(100)  := 'loga.txt';
vr_ind_arquiv2     utl_file.file_type;
vr_nmarqimp3       VARCHAR2(100)  := 'erro.txt';
vr_ind_arquiv3     utl_file.file_type;
vr_craplac_rowid ROWID;

vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0076748'; 

  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE     --> Código da Cooperativa
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE     --> data de movimento
                   ,pr_cdagenci IN craplot.cdagenci%TYPE     --> Codigo da agencia
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE     --> Codigo do caixa
                   ,pr_nrdolote IN craplot.nrdolote%TYPE     --> Numero do lote
                   ,pr_tplotmov IN craplot.tplotmov%TYPE) IS --> Tipo de movimento


      SELECT
         lot.cdcooper
        ,lot.dtmvtolt
        ,lot.cdagenci
        ,lot.cdbccxlt
        ,lot.nrdolote
        ,lot.tplotmov
        ,lot.nrseqdig
        ,lot.qtinfoln
        ,lot.qtcompln
        ,lot.vlinfocr
        ,lot.vlcompcr
        ,lot.vlinfodb
        ,lot.vlcompdb
        ,lot.rowid
      FROM
        craplot lot
      WHERE
            lot.cdcooper = pr_cdcooper
        AND lot.dtmvtolt = pr_dtmvtolt
        AND lot.cdagenci = pr_cdagenci
        AND lot.cdbccxlt = pr_cdbccxlt
        AND lot.nrdolote = pr_nrdolote
        AND lot.tplotmov = pr_tplotmov;

      rw_craplot cr_craplot%ROWTYPE;

      -- Consulta saldo de conta investimento
  CURSOR cr_crapsli(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_nrdconta crapsli.nrdconta%TYPE
                   ,pr_dtrefere crapsli.dtrefere%TYPE) IS

     SELECT sli.vlsddisp
       FROM crapsli sli
      WHERE sli.cdcooper = pr_cdcooper  -- Codigo da cooperativa
        AND sli.nrdconta = pr_nrdconta  -- Numero da conta
        AND sli.dtrefere = pr_dtrefere; -- Deve ser o último dia do mês
    rw_crapsli cr_crapsli%ROWTYPE;

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

  CURSOR cr_craplci (pr_cdcooper IN craplci.cdcooper%TYPE
                    ,pr_nrdconta IN craplci.nrdconta%TYPE
                    ,pr_dtresgat IN craplci.dtmvtolt%TYPE) IS
    SELECT lci.vllanmto,lci.nrseqdig  
      FROM craplci lci 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND dtmvtolt = pr_dtresgat;   
    rw_craplci cr_craplci%ROWTYPE;  
       
   CURSOR cr_craprac (pr_cdcooper IN craprac.cdcooper%TYPE
                     ,pr_nrdconta IN craprac.nrdconta%TYPE
                     ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE) IS      
     SELECT craprac.cdcooper,
            craprac.nrdconta, 
            craprac.nrctrrpp,
            craprac.vlbasapl,
            craprac.vlsldatl,
            craprac.cdprodut,
            craprac.nraplica
       FROM craprac 
      WHERE craprac.cdcooper = pr_cdcooper 
        AND craprac.nrdconta = pr_nrdconta 
        AND craprac.nrctrrpp = pr_nrctrrpp
        AND craprac.idsaqtot = 0; 
     rw_craprac cr_craprac%ROWTYPE;    

  CURSOR cr_craplac (pr_cdcooper IN craplac.cdcooper%TYPE
                    ,pr_nrdconta IN craplac.nrdconta%TYPE
                    ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE
                    ,pr_nraplica IN craprac.nraplica%TYPE) IS   
    SELECT SUM(decode(his.indebcre,'C',1,-1) * lac.vllanmto) vllanmto             
      FROM craplac lac,craprac rac,crapcpc cpc,craphis his
     WHERE rac.cdcooper = pr_cdcooper 
       AND rac.nrdconta = pr_nrdconta
       AND rac.nrctrrpp = pr_nrctrrpp
       AND lac.nraplica = pr_nraplica
       AND rac.cdcooper = lac.cdcooper
       AND rac.nrdconta = lac.nrdconta
       AND rac.nraplica = lac.nraplica
       AND rac.cdprodut = cpc.cdprodut
       AND lac.cdcooper = his.cdcooper
       AND lac.cdhistor = his.cdhistor;  
     rw_craplac cr_craplac%ROWTYPE;  

   CURSOR cr_aplica IS
    SELECT 11 cdcooper, 16179   nrdconta, 39584  nrctrrpp, 40  nraplica FROM dual;
   rw_aplica cr_aplica%ROWTYPE;

  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
  END;  
  
  procedure loga (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END; 
  
  procedure erro (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
  END; 
  
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); --> Handle do arquivo aberto;
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); 
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3);  
  END;    
  
         
BEGIN
   --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => pr_dscritic);      --> erro
  -- em caso de crítica
  IF pr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => pr_dscritic);      --> erro
  -- em caso de crítica
  IF pr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => pr_dscritic);      --> erro
  -- em caso de crítica
  IF pr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF; 
  loga('INICIO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS'));  
   OPEN cr_aplica;
     FETCH cr_aplica
     INTO rw_aplica;
   CLOSE cr_aplica; 
    
   OPEN cr_crapdat (pr_cdcooper => rw_aplica.cdcooper);
     FETCH cr_crapdat 
     INTO rw_crapdat;
   CLOSE cr_crapdat;         
   
   OPEN cr_crapsli(pr_cdcooper => rw_aplica.cdcooper
                  ,pr_nrdconta => rw_aplica.nrdconta
                  ,pr_dtrefere => last_day(rw_crapdat.dtmvtolt));
     FETCH cr_crapsli 
     INTO rw_crapsli;
      -- Verifica se consulta retornou registros
   IF cr_crapsli%NOTFOUND THEN
     vr_vlsldsli1 := 0;
   ELSE
     vr_vlsldsli1 := rw_crapsli.vlsddisp;
   END IF;
   CLOSE cr_crapsli;
   backup('update from crapsli set vlsddisp = '||vr_vlsldsli1||' where cdcooper = '||rw_aplica.cdcooper||'and nrdconta = '||rw_aplica.nrdconta||'and dtrefere = '||last_day(rw_crapdat.dtmvtolt)||';'); 
   OPEN cr_craplac (pr_cdcooper => rw_aplica.cdcooper
                   ,pr_nrdconta => rw_aplica.nrdconta
                   ,pr_nrctrrpp => rw_aplica.nrctrrpp
                   ,pr_nraplica => rw_aplica.nraplica);
   FETCH cr_craplac 
   INTO rw_craplac;
   IF cr_craplac%NOTFOUND THEN
     CLOSE cr_craplac;          
     RAISE vr_excsaida;  
   END IF;
   IF rw_craplac.vllanmto < 0 then
     rw_craplac.vllanmto := rw_craplac.vllanmto * -1;
   END IF;
   CLOSE cr_craplac;
   
   OPEN cr_craplot(pr_cdcooper => rw_aplica.cdcooper --> Código da Cooperativa
                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data de movimento
                  ,pr_cdagenci => 1           --> Codigo da agencia
                  ,pr_cdbccxlt => 100         --> Codigo do caixa
                  ,pr_nrdolote => 8502        --> Numero do lote
                  ,pr_tplotmov => 9);         --> Tipo de movimento

   FETCH cr_craplot 
   INTO rw_craplot;

   IF cr_craplot%NOTFOUND THEN
     -- Fecha cursor
     CLOSE cr_craplot;
     -- Insere registro de lote
     BEGIN
     -- Insere registro de lote
     INSERT INTO craplot(cdcooper
                        ,dtmvtolt
                        ,cdagenci
                        ,cdbccxlt
                        ,nrdolote
                        ,tplotmov
                        ,nrseqdig
                        ,qtinfoln
                        ,qtcompln)
         VALUES(rw_aplica.cdcooper
               ,rw_crapdat.dtmvtolt
               ,1
               ,100
               ,8502
               ,9
               ,0
               ,0
               ,0)
     RETURNING
       nrseqdig
     INTO
       pr_nrseqdig;
     EXCEPTION
     WHEN OTHERS THEN
       pr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
       RAISE vr_excsaida;
     END;
   ELSE                                   
     BEGIN
     -- Atualiza registro de lote
     UPDATE craplot
        SET craplot.cdcooper = rw_craplot.cdcooper,
            craplot.dtmvtolt = rw_craplot.dtmvtolt,
            craplot.cdagenci = rw_craplot.cdagenci,
            craplot.cdbccxlt = rw_craplot.cdbccxlt,
            craplot.nrdolote = rw_craplot.nrdolote,
            craplot.tplotmov = rw_craplot.tplotmov,
            craplot.nrseqdig = (NVL(rw_craplot.nrseqdig,0) + 1),
            craplot.qtinfoln = (NVL(rw_craplot.qtinfoln,0) + 1),
            craplot.qtcompln = (NVL(rw_craplot.qtcompln,0) + 1),
            craplot.vlinfodb = (NVL(craplot.vlinfodb,0) + NVL(rw_craplac.vllanmto,0)),
            craplot.vlcompdb = (NVL(craplot.vlcompdb,0) + NVL(rw_craplac.vllanmto,0))
      WHERE craplot.rowid = rw_craplot.rowid
     RETURNING
       craplot.nrseqdig
     INTO
       pr_nrseqdig;
     EXCEPTION
     WHEN OTHERS THEN
       pr_dscritic := 'Erro ao atualizar lote. Erro' || SQLERRM;
       RAISE vr_excsaida;
     END;
     CLOSE cr_craplot;
   END IF;             
   BEGIN
   INSERT INTO craplac(cdcooper
                      ,dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrdconta
                      ,nraplica
                      ,nrdocmto
                      ,nrseqdig
                      ,vllanmto
                      ,cdhistor
                      ,nrseqrgt
                      ,vlrendim
                      ,vlbasren
                      ,cdcanal)
              VALUES(rw_aplica.cdcooper
                    ,rw_crapdat.dtmvtolt
                    ,1
                    ,100
                    ,8502
                    ,rw_aplica.nrdconta
                    ,rw_aplica.nraplica
                    ,pr_nrseqdig
                    ,pr_nrseqdig
                    ,rw_craplac.vllanmto
                    ,2745
                    ,0
                    ,0
                    ,0
                    ,5)
             RETURNING
              craplac.rowid
             INTO
              vr_craplac_rowid;
   EXCEPTION
   WHEN OTHERS THEN
     pr_dscritic := 'Erro ao inserir craplac  ' || SQLERRM;
     RAISE vr_excsaida;
   END;  
    backup('delete from craplac where '||vr_craplac_rowid||';');                                    
   UPDATE craprac r
      SET r.vlsldatl = 0,
          r.vlbasapl = 0,
          r.idsaqtot = 1
    WHERE cdcooper = rw_aplica.cdcooper
      AND nrdconta = rw_aplica.nrdconta
      AND nrctrrpp = rw_aplica.nrctrrpp
      AND nraplica = rw_aplica.nraplica;
  
   FOR rw_craprac IN cr_craprac(pr_cdcooper => rw_aplica.cdcooper
                               ,pr_nrdconta => rw_aplica.nrdconta
                               ,pr_nrctrrpp => rw_aplica.nrctrrpp) LOOP
  
     -- Call the procedure
     APLI0005.pc_efetua_resgate(pr_cdcooper => rw_craprac.cdcooper,
                                pr_nrdconta => rw_craprac.nrdconta,
                                pr_nraplica => rw_craprac.nraplica,
                                pr_vlresgat => 0,
                                pr_idtiprgt => 2,
                                pr_dtresgat => rw_crapdat.dtmvtolt,
                                pr_nrseqrgt => 1,
                                pr_idrgtcti => 1,
                                pr_idorigem => 0,
                                pr_tpcritic => pr_tpcritic,
                                pr_cdcritic => pr_cdcritic,
                                pr_dscritic => pr_dscritic);                        
                             
     IF pr_dscritic IS NOT NULL THEN
       RAISE vr_excsaida;      
     END IF;                                                                                                                                   
   END LOOP;
   
   BEGIN
    UPDATE crapsli
       SET crapsli.vlsddisp = vr_vlsldsli1
     WHERE crapsli.cdcooper = rw_aplica.cdcooper
       AND crapsli.nrdconta = rw_aplica.nrdconta
       AND crapsli.dtrefere = rw_crapdat.dtultdia;
    EXCEPTION
    WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar crapsli.';
    RAISE vr_excsaida;
   END; 
    
  COMMIT;
  loga('FIM ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
  fecha_arquivos;
  EXCEPTION
    WHEN vr_excsaida then 
         pr_dscritic := 'ERRO ' || pr_dscritic;  
         loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
         erro('pr_dscritic');
         fecha_arquivos;  
         ROLLBACK;
    WHEN OTHERS then
         pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
         loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
         erro('pr_dscritic');
         fecha_arquivos; 
         ROLLBACK;   
END;
1
pr_dscritic
0
-5
2
rw_craplac.vllanmto
rw_craprac.nraplica
