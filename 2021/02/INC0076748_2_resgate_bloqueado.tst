PL/SQL Developer Test script 3.0
586
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
vr_vlaplica  NUMBER(20,8);
pr_nrseqdig NUMBER(5);
vr_nrdocmto NUMBER(5);
vr_nmarqimp1       VARCHAR2(100)  := 'backup3.txt';
vr_ind_arquiv1     utl_file.file_type;
vr_nmarqimp2       VARCHAR2(100)  := 'loga3.txt';
vr_ind_arquiv2     utl_file.file_type;
vr_nmarqimp3       VARCHAR2(100)  := 'erro3.txt';
vr_ind_arquiv3     utl_file.file_type;
vr_craplci_rowid ROWID;

vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0076748'; 

  -- Consulta saldo de conta investimento
  CURSOR cr_crapsli(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_nrdconta crapsli.nrdconta%TYPE
                   ,pr_dtrefere crapsli.dtrefere%TYPE) IS
  SELECT sli.vlsddisp,sli.rowid
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
                    ,pr_nraplica IN craprac.nraplica%TYPE
                    ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE) IS      
  SELECT craprac.cdcooper,
         craprac.nrdconta, 
         craprac.nrctrrpp,
         craprac.vlbasapl,
         craprac.vlsldatl,
         craprac.cdprodut
    FROM craprac 
   WHERE craprac.cdcooper = pr_cdcooper 
     AND craprac.nrdconta = pr_nrdconta 
     AND craprac.nraplica = pr_nraplica
     AND craprac.nrctrrpp = pr_nrctrrpp; 
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
   
  CURSOR cr_crapblq (pr_cdcooper IN crapblj.cdcooper%TYPE
                    ,pr_nrdconta IN crapblj.nrdconta%TYPE) IS 
   SELECT vlbloque 
     FROM crapblj
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta 
      AND dtblqfim IS NULL 
      AND cdmodali = 3;
   rw_crapblq cr_crapblq%ROWTYPE;
   
  CURSOR cr_craplac_blq (pr_cdcooper IN craplac.cdcooper%TYPE
                        ,pr_nrdconta IN craplac.nrdconta%TYPE
                        ,pr_nraplica IN craplac.nraplica%TYPE) IS
   SELECT vllanmto
     FROM craplac 
    WHERE cdcooper = pr_cdcooper 
      AND nrdconta = pr_nrdconta 
      AND nraplica = pr_nraplica 
      AND cdhistor = 2743;
   rw_craplac_blq cr_craplac_blq%ROWTYPE;
   
   
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
             

  CURSOR cr_aplica IS   
   SELECT 13 cdcooper, 3000   nrdconta, 19274  nrctrrpp, 2  nraplica,  59755990 progress_recid  FROM dual;
  rw_aplica cr_aplica%ROWTYPE;

  procedure backup3 (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
  END;  
  
  procedure loga3 (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END; 
  
  procedure erro3 (pr_msg VARCHAR2) IS
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
  loga3('INICIO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS'));  
  FOR rw_aplica IN cr_aplica LOOP
    OPEN cr_crapdat (pr_cdcooper => rw_aplica.cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;

    OPEN cr_craplac (pr_cdcooper => rw_aplica.cdcooper
                    ,pr_nrdconta => rw_aplica.nrdconta
                    ,pr_nrctrrpp => rw_aplica.nrctrrpp
                    ,pr_nraplica => rw_aplica.nraplica);
    FETCH cr_craplac INTO rw_craplac;
    IF cr_craplac%NOTFOUND THEN
      CLOSE cr_craplac;          
      RAISE vr_excsaida;  
    END IF;
    CLOSE cr_craplac;
    
    BEGIN
    UPDATE craprac
       SET vlsldatl = rw_craplac.vllanmto
     WHERE cdcooper = rw_aplica.cdcooper
       AND nrdconta = rw_aplica.nrdconta
       AND nrctrrpp = rw_aplica.nrctrrpp
       AND nraplica = rw_aplica.nraplica;
    EXCEPTION
    WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar craprac.';
    RAISE vr_excsaida;
    END; 
    
    BEGIN
    UPDATE craplac
       SET cdhistor = 2742 --2747  
     WHERE progress_recid =  rw_aplica.progress_recid;
    EXCEPTION
    WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar craplac.'; 
    RAISE vr_excsaida;    
    END;
    backup3('update from craplac set cdhistor = 2747 where progress_recid = '||rw_aplica.progress_recid||';');
    
    OPEN cr_crapsli(pr_cdcooper => rw_aplica.cdcooper
                   ,pr_nrdconta => rw_aplica.nrdconta
                   ,pr_dtrefere => last_day(rw_crapdat.dtmvtolt));
    FETCH cr_crapsli INTO rw_crapsli;
    -- Verifica se consulta retornou registros
    IF cr_crapsli%NOTFOUND THEN
      vr_vlsldsli1 := 0;
    ELSE
      vr_vlsldsli1 := rw_crapsli.vlsddisp;
    END IF;
    CLOSE cr_crapsli;
    backup3('update from crapsli set vlsddisp = '||vr_vlsldsli1||' where cdcooper = '||rw_aplica.cdcooper||'and nrdconta = '||rw_aplica.nrdconta||'and dtrefere = '||last_day(rw_crapdat.dtmvtolt)||';'); 
    -- Call the procedure
    APLI0005.pc_efetua_resgate(pr_cdcooper => rw_aplica.cdcooper,
                               pr_nrdconta => rw_aplica.nrdconta,
                               pr_nraplica => rw_aplica.nraplica,
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

    BEGIN
    UPDATE craplac
       SET cdhistor = 2747  --2742
     WHERE progress_recid = rw_aplica.progress_recid;
    EXCEPTION
    WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar craplac.';
    RAISE vr_excsaida;
    END;

    OPEN cr_craprac (pr_cdcooper => rw_aplica.cdcooper
                    ,pr_nrdconta => rw_aplica.nrdconta
                    ,pr_nraplica => rw_aplica.nraplica
                    ,pr_nrctrrpp => rw_aplica.nrctrrpp);
    FETCH cr_craprac INTO rw_craprac;
    IF cr_craprac%NOTFOUND THEN
      CLOSE cr_craprac;          
      RAISE vr_excsaida;  
    END IF;
    CLOSE cr_craprac;
             
    apli0005.pc_obtem_carencias(pr_cdcooper => rw_aplica.cdcooper   -- Codigo da Cooperativa
                               ,pr_cdprodut => rw_craprac.cdprodut -- Codigo do Produto 
                               ,pr_cdcritic => pr_cdcritic   -- Codigo da Critica
                               ,pr_dscritic => pr_dscritic   -- Descricao da Critica
                               ,pr_tab_care => vr_tab_care); -- Tabela com registros de Carencia do produto
                                 
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excsaida;  
    END IF;
                 
    OPEN cr_crapsli(pr_cdcooper => rw_aplica.cdcooper
                   ,pr_nrdconta => rw_aplica.nrdconta
                   ,pr_dtrefere => last_day(rw_crapdat.dtmvtolt));
    FETCH cr_crapsli INTO rw_crapsli;
      vr_vlsldsli2 := rw_crapsli.vlsddisp;      
    CLOSE cr_crapsli;
        
    vr_vlsldsapl := vr_vlsldsli2 - vr_vlsldsli1;
        
    IF vr_vlsldsapl < 0 THEN
      pr_dscritic := 'Saldo conta investimento menor que zero';
    RAISE vr_excsaida;  
    END IF;
        
    apli0005.pc_cadastra_aplic(pr_cdcooper => rw_aplica.cdcooper,
                               pr_cdoperad => '1',
                               pr_nmdatela => 'CRPS145',
                               pr_idorigem => 5,
                               pr_nrdconta => rw_aplica.nrdconta,
                               pr_idseqttl => 1,
                               pr_nrdcaixa => vr_cdbccxlt,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                               pr_cdprodut => rw_craprac.cdprodut,
                               pr_qtdiaapl => vr_tab_care(1).qtdiaprz,
                               pr_dtvencto => rw_crapdat.dtmvtolt + vr_tab_care(1).qtdiaprz,
                               pr_qtdiacar => vr_tab_care(1).qtdiacar,
                               pr_qtdiaprz => vr_tab_care(1).qtdiaprz,
                               pr_vlaplica => vr_vlsldsapl,
                               pr_iddebcti => 1,
                               pr_idorirec => 0,
                               pr_idgerlog => 1,
                               pr_nrctrrpp => rw_aplica.nrctrrpp, -- Número da RPP
                               pr_nraplica => vr_nraplica,
                               pr_cdcritic => pr_cdcritic,
                               pr_dscritic => pr_dscritic);
                                 
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excsaida;  
    END IF;  
    
    OPEN cr_craplac_blq (pr_cdcooper => rw_aplica.cdcooper
                        ,pr_nrdconta => rw_aplica.nrdconta
                        ,pr_nraplica => vr_nraplica);
    FETCH cr_craplac_blq INTO rw_craplac_blq;
    IF cr_craplac_blq%NOTFOUND THEN
      erro3('Erro ao buscar o novo lançamento de aplicação.');
      CLOSE cr_craplac_blq;          
      RAISE vr_excsaida;  
    END IF;
    CLOSE cr_craplac_blq;
    
    OPEN cr_crapblq (pr_cdcooper => rw_aplica.cdcooper
                    ,pr_nrdconta => rw_aplica.nrdconta);
    FETCH cr_crapblq INTO rw_crapblq;
    IF cr_crapblq%NOTFOUND THEN
      erro3('Erro ao buscar o valor bloqueado.');
      CLOSE cr_crapblq;          
      RAISE vr_excsaida;  
    END IF;
    CLOSE cr_crapblq;
  
  vr_vlaplica :=  rw_crapblq.vlbloque - rw_craplac_blq.vllanmto;
  
  IF  vr_vlaplica < 0 THEN
    erro3('valor da segunda aplicação mero que zero.');          
      RAISE vr_excsaida; 
  END IF;
  -----------------------------------------------------
    -- Consulta de lote
        OPEN cr_craplot(pr_cdcooper => rw_aplica.cdcooper --> Código da Cooperativa
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> data de movimento
                       ,pr_cdagenci => 1           --> Codigo da agencia
                       ,pr_cdbccxlt => 100         --> Codigo do caixa
                       ,pr_nrdolote => 10113       --> Numero do lote
                       ,pr_tplotmov => 29);        --> Tipo de movimento

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se registro de lote existe
        IF cr_craplot%NOTFOUND THEN

          -- Fecha cursor
          CLOSE cr_craplot;

          -- Insere registro de lote
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfocr
               ,vlcompcr
              )VALUES(
                 rw_aplica.cdcooper,
                 rw_crapdat.dtmvtolt
                ,1,100,10113,29,0,0,0,0,0)
                 RETURNING
                   nrseqdig
                 INTO
                  pr_nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN             
              pr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
              erro3(pr_dscritic);
              RAISE vr_excsaida;
          END;

        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;

        -- Atualiza registro de lote
        BEGIN

          UPDATE
            craplot
          SET
            craplot.nrseqdig = rw_craplot.nrseqdig + 1,
            craplot.qtinfoln = rw_craplot.qtinfoln + 1,
            craplot.qtcompln = rw_craplot.qtcompln + 1,
            craplot.vlinfocr = rw_craplot.vlinfocr + vr_vlaplica,
            craplot.vlcompcr = rw_craplot.vlcompcr + vr_vlaplica
          WHERE
            craplot.rowid    = rw_craplot.rowid
          RETURNING
            craplot.nrseqdig
          INTO
            pr_nrseqdig;

        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar registro de lote. Erro: ' || SQLERRM;
            erro3(pr_dscritic);
            RAISE vr_excsaida;
        END;

        -- Atualiza numero do documento
        vr_nrdocmto := vr_nraplica + 1;

          BEGIN

            INSERT INTO craplci(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,nrdconta
               ,nrdocmto
               ,nrseqdig
               ,vllanmto
               ,cdhistor
               ,nraplica)
             VALUES(
               rw_craplot.cdcooper
              ,rw_craplot.dtmvtolt
              ,rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt
              ,rw_craplot.nrdolote
              ,rw_aplica.nrdconta
              ,vr_nrdocmto
              ,rw_craplot.nrseqdig
              ,vr_vlaplica         -- Valor do resgate
              ,490
              ,vr_nrdocmto)
               RETURNING
              craplci.rowid
             INTO
              vr_craplci_rowid;

          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao inserir registro de credito(CRAPLCI). Erro: ' || SQLERRM;
              erro3(pr_dscritic);
              RAISE vr_excsaida;
          END;
         backup3('delete from craplci where rowid = '||vr_craplci_rowid||';'); 
        -- Consulta de registro de saldo        
        OPEN cr_crapsli(pr_cdcooper => rw_aplica.cdcooper
                       ,pr_nrdconta => rw_aplica.nrdconta
                       ,pr_dtrefere => rw_crapdat.dtultdia);

        FETCH cr_crapsli INTO rw_crapsli;
          -- Fecha cursor
          CLOSE cr_crapsli;

          -- Atualiza resgistro de saldo
          BEGIN
            UPDATE
              crapsli
            SET
              crapsli.vlsddisp = (crapsli.vlsddisp + vr_vlaplica)
            WHERE
              crapsli.rowid = rw_crapsli.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gera critica
              pr_dscritic := 'Erro ao atualizar registro de saldo(CRAPSLI). Erro: ' || SQLERRM;
              erro3(pr_dscritic);
              RAISE vr_excsaida;
          END;
    apli0005.pc_cadastra_aplic(pr_cdcooper => rw_aplica.cdcooper,
                               pr_cdoperad => '1',
                               pr_nmdatela => 'CRPS145',
                               pr_idorigem => 5,
                               pr_nrdconta => rw_aplica.nrdconta,
                               pr_idseqttl => 1,
                               pr_nrdcaixa => vr_cdbccxlt,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt,
                               pr_cdprodut => rw_craprac.cdprodut,
                               pr_qtdiaapl => vr_tab_care(1).qtdiaprz,
                               pr_dtvencto => rw_crapdat.dtmvtolt + vr_tab_care(1).qtdiaprz,
                               pr_qtdiacar => vr_tab_care(1).qtdiacar,
                               pr_qtdiaprz => vr_tab_care(1).qtdiaprz,
                               pr_vlaplica => vr_vlaplica,
                               pr_iddebcti => 1,
                               pr_idorirec => 0,
                               pr_idgerlog => 1,
                               pr_nrctrrpp => rw_aplica.nrctrrpp, -- Número da RPP
                               pr_nraplica => vr_nraplica,
                               pr_cdcritic => pr_cdcritic,
                               pr_dscritic => pr_dscritic);
                                 
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_excsaida;  
    END IF;  

-- Atualiza resgistro de saldo
          BEGIN
            UPDATE
              crapsli
            SET
              crapsli.vlsddisp = vr_vlsldsli1
            WHERE
              crapsli.rowid = rw_crapsli.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gera critica
              pr_dscritic := 'Erro ao atualizar registro de saldo(CRAPSLI). Erro: ' || SQLERRM;
              erro3(pr_dscritic);
              RAISE vr_excsaida;
          END;
      -------------------------------------------
                                                                                                     
  END LOOP;
  COMMIT;
  loga3('FIM ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
  fecha_arquivos;
  EXCEPTION
    WHEN vr_excsaida then 
      pr_dscritic := 'ERRO ' || pr_dscritic;  
      loga3('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
      erro3(pr_dscritic);
      fecha_arquivos;       
      ROLLBACK;
    WHEN OTHERS then
      pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
      loga3('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
      erro3(pr_dscritic);
      fecha_arquivos; 
      ROLLBACK;   
END;
0
0
