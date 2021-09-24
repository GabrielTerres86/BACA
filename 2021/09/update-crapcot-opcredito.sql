-- Created on 22/09/2021 by F0032999 
DECLARE 

  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_vllanmto NUMBER(20,4):= 0;
  vr_qtjurmfx crapcot.qtjurmfx%TYPE;
  pr_dscritic   VARCHAR2(5000) := ' ';
  vr_nmarqimp1  VARCHAR2(100) := ' ';
  vr_nmarqimp2  VARCHAR2(100) := ' ';
  vr_nmarqimp3  VARCHAR2(100) := ' ';
  vr_nmarqimp11       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv1     utl_file.file_type;
  vr_nmarqimp22       VARCHAR2(100)  := 'loga.txt';
  vr_ind_arquiv2     utl_file.file_type;
  vr_nmarqimp33       VARCHAR2(100)  := 'erro.txt';
  vr_ind_arquiv3     utl_file.file_type;
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/prj0023533'; 
  vr_excsaida   EXCEPTION;
  
  CURSOR cr_crapcot(pr_cdcooper crapcot.cdcooper%TYPE,
                    pr_nrdconta crapcot.nrdconta%TYPE) IS
    SELECT cot.cdcooper,
           cot.nrdconta,
           cot.qtjurmfx
      FROM crapcot cot
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
       rw_crapcot cr_crapcot%ROWTYPE;
       
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
           last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.        
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
     rw_crapdat cr_crapdat%ROWTYPE; 
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1
	   AND cdcooper <> 3;
     rw_crapcop cr_crapcop%ROWTYPE;
   
  CURSOR cr_craplemll (pr_cdcooper IN craplem.cdcooper%TYPE,
                       pr_nrdconta IN craplem.nrdconta%TYPE,
                       pr_nrctremp IN craplem.nrctremp%TYPE)  IS
    SELECT SUM(ll.vllanmto) vlrjuros_calc
      FROM craplem ll, 
           crapepr epr
     WHERE epr.cdcooper = ll.cdcooper
       AND epr.nrdconta = ll.nrdconta
       AND epr.nrctremp = ll.nrctremp
       AND ll.cdcooper = pr_cdcooper
       AND ll.nrdconta = pr_nrdconta
       AND ll.nrctremp = pr_nrctremp
       AND ll.dtmvtolt BETWEEN to_date('01/01/2021','dd/mm/yyyy') AND epr.dtultpag + 59
       AND ll.cdhistor IN (1037, 1038, 2342, 2344);
       rw_craplemll cr_craplemll%ROWTYPE;
             
  CURSOR cr_craplem (pr_cdcooper IN craplem.cdcooper%TYPE
                     pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
    SELECT sum(vllanmto) vllanmto,           
           epr.cdcooper,
           epr.nrdconta,
           epr.nrctremp,
           epr.cdlcremp,
           epr.inprejuz,
           epr.dtultpag,
           epr.tpemprst        
      FROM craplem lem,
           crapepr epr
     WHERE lem.nrdconta > 0
       AND lem.cdagenci > 0
       AND lem.cdcooper = pr_cdcooper
       AND epr.cdcooper = lem.cdcooper
       AND epr.nrdconta = lem.nrdconta
       AND epr.nrctremp = lem.nrctremp
       AND lem.dtmvtolt BETWEEN to_date('01/01/2021','dd/mm/yyyy') 
       AND (case when epr.inprejuz = 0 then last_day(add_months(dat.dtmvtolt,-1))
            else last_day(add_months(epr.dtprejuz,-1)) end)
       AND lem.cdhistor in (98, 1037, 1038, 2342, 2344)
     GROUP BY epr.cdcooper,
              epr.nrdconta,
              epr.nrctremp,
              epr.cdlcremp,
              epr.inprejuz,
              epr.dtultpag,
              epr.tpemprst;
      TYPE typ_tab_craplem IS TABLE OF cr_craplem%ROWTYPE INDEX BY PLS_INTEGER;
       vr_tab_craplem_bulk typ_tab_craplem; 
        
  procedure backup (pr_msg VARCHAR2) IS
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
 
  FOR rw_crapcop IN cr_crapcop LOOP 
    
    OPEN cr_crapdat (pr_cdcooper => rw_crapcop.cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
      
    OPEN cr_craplem(pr_cdcooper => rw_crapcop.cdcooper
                    pr_dtmvtolt => rw_crapdat.dtmvtolt);
    vr_nmarqimp1 := rw_crapcop.cdcooper || vr_nmarqimp11 ||to_char(sysdate,'HH24:MI:SS');
      vr_nmarqimp2 := rw_crapcop.cdcooper || vr_nmarqimp22 ||to_char(sysdate,'HH24:MI:SS');
      vr_nmarqimp3 := rw_crapcop.cdcooper || vr_nmarqimp33 ||to_char(sysdate,'HH24:MI:SS');
      --Criar arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarqimp1
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
    LOOP     
      FETCH cr_craplem BULK COLLECT INTO vr_tab_craplem_bulk LIMIT 1000;
      EXIT WHEN vr_tab_craplem_bulk.COUNT = 0; 
          
      loga('INICIO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS'));
      FOR idx IN vr_tab_craplem_bulk.first..vr_tab_craplem_bulk.last LOOP
        
        IF (vr_tab_craplem_bulk(idx).cdlcremp IN(6901,900) OR vr_tab_craplem_bulk(idx).inprejuz = 1) THEN
          
          vr_vllanmto := vr_vllanmto + vr_tab_craplem_bulk(idx).vllanmto;     
        
        ELSIF TO_DATE(rw_crapdat.dtmvtolt) > vr_tab_craplem_bulk(idx).dtultpag + 59 THEN
          
          OPEN cr_craplemll (pr_cdcooper => vr_tab_craplem_bulk(idx).cdcooper,
                             pr_nrdconta => vr_tab_craplem_bulk(idx).nrdconta,
                             pr_nrctremp => vr_tab_craplem_bulk(idx).nrctremp);
          FETCH cr_craplemll INTO rw_craplemll;
          
          vr_vllanmto := vr_vllanmto + (vr_tab_craplem_bulk(idx).vllanmto - NVL(rw_craplemll.vlrjuros_calc, 0));        
          
          CLOSE cr_craplemll;        
        
        END IF;  
        
        IF vr_vllanmto > 0 THEN
          vr_vllanmto := ROUND(vr_vllanmto / 0.82870000,4);
          OPEN cr_crapcot (pr_cdcooper => vr_tab_craplem_bulk(idx).cdcooper,
                             pr_nrdconta => vr_tab_craplem_bulk(idx).nrdconta);
          FETCH cr_crapcot INTO rw_crapcot;
          backup('update crapcot set qtjurmfx = ' || replace(rw_crapcot.qtjurmfx,',','.') || ' where cdcooper = ' || rw_crapcot.cdcooper ||' and nrdconta =  '||rw_crapcot.nrdconta||';');      
          CLOSE cr_crapcot;                              
          
          loga(vr_tab_craplem_bulk(idx).cdcooper||';'||vr_tab_craplem_bulk(idx).nrdconta||';'||vr_tab_craplem_bulk(idx).nrctremp||';'||vr_tab_craplem_bulk(idx).cdlcremp||';'||vr_tab_craplem_bulk(idx).inprejuz||';'||vr_tab_craplem_bulk(idx).dtultpag||';'||vr_vllanmto);
          
          BEGIN
          UPDATE crapcot 
             SET qtjurmfx = qtjurmfx - vr_vllanmto
           WHERE cdcooper = vr_tab_craplem_bulk(idx).cdcooper
             AND nrdconta = vr_tab_craplem_bulk(idx).nrdconta
              RETURNING qtjurmfx INTO vr_qtjurmfx;
          EXCEPTION
           WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar CRAPCOT1. cdcooper: ' ||rw_crapcot.cdcooper || ' - Conta: '||rw_crapcot.nrdconta;
           RAISE vr_excsaida;
           END;  
           
          IF vr_qtjurmfx < 0 THEN
          BEGIN
            UPDATE crapcot 
              SET qtjurmfx = 0 
             WHERE cdcooper = rw_crapcot.cdcooper
              AND nrdconta = rw_crapcot.nrdconta;
           EXCEPTION
           WHEN OTHERS THEN
            pr_dscritic := 'Erro ao atualizar CRAPCOT2. cdcooper: ' ||rw_crapcot.cdcooper || ' - Conta: '||rw_crapcot.nrdconta;
           RAISE vr_excsaida;
           END;  
          END IF;

        END IF; 
      vr_vllanmto := 0;   
      END LOOP; --vr_tab_craplem_bulk
      
    END LOOP;  --cr_craplem    
    loga('FIM ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')||' cooperativa: '||rw_crapcop.cdcooper);
     fecha_arquivos;
    close cr_craplem;
  END LOOP; --cr_crapcop      
  commit;
 
  EXCEPTION
    WHEN vr_excsaida then 
      pr_dscritic := 'ERRO ' || pr_dscritic;  
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos;       
      ROLLBACK;
    WHEN OTHERS then
      pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos; 
      ROLLBACK;       
END;
