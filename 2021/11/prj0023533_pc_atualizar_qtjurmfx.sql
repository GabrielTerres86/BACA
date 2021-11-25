CREATE OR REPLACE PROCEDURE CECRED.pc_atualizar_qtjurmfx(pr_cdcooper IN crapcop.cdcooper%TYPE
                                                        ,pr_cdagenci IN crapage.cdagenci%TYPE ) IS


  pr_dscritic          VARCHAR2(5000) := ' ';
  vr_nmarqimp1         VARCHAR2(100) := ' ';
  vr_nmarqimp2         VARCHAR2(100) := ' ';
  vr_nmarqimp3         VARCHAR2(100) := ' ';
  vr_nmarqimp11        VARCHAR2(100)  := 'backup_';
  vr_nmarqimp22        VARCHAR2(100)  := 'loga_';
  vr_nmarqimp33        VARCHAR2(100)  := 'erro_';
  vr_rootmicros        VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); -- '/progress/f0030248/micros/'; -- 
  vr_nmdireto          VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/prj0023533'; 
  vr_excsaida          EXCEPTION;
  
  vr_des_xml_1         CLOB;  
  vr_des_xml_2         CLOB;    
  vr_des_xml_3         CLOB;    
  vr_texto_completo_1  VARCHAR2(32600);
  vr_texto_completo_2  VARCHAR2(32600);
  vr_texto_completo_3  VARCHAR2(32600);    
  
    TYPE typ_reg_crapcot IS
         RECORD (nrdconta crapsda.nrdconta%type
                ,cdcooper crapcot.cdcooper%TYPE
                ,qtjurmfx crapcot.qtjurmfx%TYPE
                ,qtjurbkp crapcot.qtjurmfx%TYPE
                ,qtjurcalc crapcot.qtjurmfx%TYPE);
    
    TYPE typ_tab_crapcot IS TABLE OF typ_reg_crapcot INDEX BY PLS_INTEGER;
 
    --todas as contas de uma agencia(PA)
    CURSOR cr_crapass(pr_cdcooper crapcop.CDCOOPER%TYPE
                     ,pr_cdagenci crapage.CDAGENCI%TYPE) IS
      SELECT a.cdcooper
            ,a.cdagenci
            ,a.nrdconta
        FROM crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.CDAGENCI = pr_cdagenci;
  
    --todos os contratos de emprestimos em aberto ou que foram liquidados dentro do ano
    CURSOR cr_crapepr(pr_cdcooper crapcop.CDCOOPER%TYPE
                     ,pr_nrdconta crapass.NRDCONTA%TYPE) IS
      SELECT epr.cdcooper
            ,epr.NRDCONTA
            ,epr.NRCTREMP
            ,epr.INPREJUZ
            ,epr.DTPREJUZ
            ,epr.TPDESCTO
            ,epr.TPEMPRST
            ,(SELECT COUNT(1) FROM tbepr_renegociacao_crapepr eee
               WHERE eee.cdcooper = epr.cdcooper
                 AND eee.nrdconta = epr.nrdconta
                 AND eee.nrctremp = epr.nrctremp) qtreneg
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         ;

    CURSOR cr_calculo(pr_cdcooper crapcop.CDCOOPER%TYPE
                     ,pr_nrdconta crapass.NRDCONTA%TYPE
                     ,pr_nrctremp crapepr.NRCTREMP%TYPE
                     ,pr_dtmvtolt crapdat.DTMVTOLT%TYPE) IS
                     
      SELECT t.tabela,
           t.cdcooper, 
           t.nrdconta, 
           t.nrctremp, 
           t.cdlcremp, 
           t.dtprejuz, 
           t.dtultpag,
           t.inliquid, 
           t.inprejuz,
           t.tpemprst,
           t.tpdescto,
           SUM(t.vlrant) vlr_ant,
           SUM(
           CASE WHEN t.cdlcremp IN (6901,800,850,900) THEN 0 
                WHEN t.dtprejuz IS NOT NULL THEN 0
                ELSE t.vlr END) VLR_CALC
      FROM (                     
          SELECT tab.*
               , CASE 
                   WHEN dtmvtolt-dtpgtant <= 59 
                    AND indebcre = 'D' 
                   THEN 
                     vllanmto 
                   ELSE 
                     0 
                 END VLR 
            FROM (
              SELECT  'craplem' tabela
                    , lem.cdcooper
                    , lem.nrdconta
                    , lem.nrctremp
                    , lem.dtmvtolt
                    , lem.cdhistor
                    , CASE 
                        WHEN epr.inliquid = 1 
                         AND epr.tpemprst = 2 
                         AND to_char(epr.dtultpag,'MM') = to_char(lem.dtmvtolt,'MM') THEN 
                           0 
                         ELSE 
                           lem.vllanmto 
                      END vlrant
                    , lem.vllanmto
                    , his.indebcre
                    , lem.progress_recid
                    , epr.cdlcremp
                    , epr.dtultpag
                    , epr.inprejuz
                    , epr.tpemprst
                    , epr.tpdescto
                    , (SELECT MAX(ll.dtmvtolt) 
                         FROM craplem ll
                        WHERE ll.cdcooper = lem.cdcooper
                          AND ll.nrdconta = lem.nrdconta
                          AND ll.nrctremp = lem.nrctremp
                          AND ll.cdhistor IN (2326,2327,2330,2331,1036,1044,1045,3654,1039,1057,1059,91,92,95,2335,2330,2331,3026,3027,2013,2014,3279,99)
                          AND ll.dtmvtolt <= lem.dtmvtolt) dtpgtant
                    , epr.dtprejuz
                    , epr.inliquid
                FROM crapepr epr
                   , craplem lem
                   , craphis his
               WHERE epr.cdcooper = pr_cdcooper
                 AND epr.nrdconta = pr_nrdconta
                 AND epr.nrctremp = pr_nrctremp
                 AND lem.cdcooper = epr.cdcooper
                 AND lem.nrdconta = epr.nrdconta
                 AND lem.nrctremp = epr.nrctremp
                 AND lem.cdhistor IN (98,1037,1038,2342,2343,2344,2345) -- juros remuneratorios          
                 AND lem.dtmvtolt BETWEEN to_date('01/01/2021','DD/MM/RRRR') AND pr_dtmvtolt
                 AND lem.cdagenci > 0
                 AND his.cdcooper = lem.cdcooper
                 AND his.cdhistor = lem.cdhistor                 
            ) tab
          ) t
         GROUP BY t.tabela,
                  t.cdcooper, 
                  t.nrdconta, 
                  t.nrctremp, 
                  t.dtprejuz, 
                  t.cdlcremp, 
                  t.dtultpag, 
                  t.inliquid,
                  t.inprejuz,
                  t.tpemprst,
                  t.tpdescto
         ORDER BY t.cdcooper, t.nrdconta;
         
    CURSOR cr_reneg  (pr_cdcooper crapcop.CDCOOPER%TYPE
                     ,pr_nrdconta crapass.NRDCONTA%TYPE
                     ,pr_nrctremp crapepr.NRCTREMP%TYPE
                     ,pr_dtmvtolt crapdat.DTMVTOLT%TYPE) IS
                     
      SELECT t.tabela,
           t.cdcooper, 
           t.nrdconta, 
           t.nrctremp, 
           t.cdlcremp, 
           t.dtprejuz, 
           t.dtultpag,
           t.inliquid, 
           t.inprejuz,
           t.tpemprst,
           t.tpdescto,
           SUM(t.vlrant) vlr_ant,
           SUM(
           CASE WHEN t.cdlcremp IN (6901,800,850,900) THEN 0 
                WHEN t.dtprejuz IS NOT NULL THEN 0
                ELSE t.vlr END) VLR_CALC
      FROM (  
      
          SELECT tab.*
               , CASE 
                   WHEN dtmvtolt-dtpgtant <= 59 
                    AND indebcre = 'D' 
                   THEN 
                     vllanmto 
                   ELSE 
                     0 
                 END VLR 
            FROM (                                          
            SELECT  '***' || to_char(epr.nrversao) tabela
                    , lem.cdcooper
                    , lem.nrdconta
                    , lem.nrctremp
                    , lem.dtmvtolt
                    , lem.cdhistor
                    , CASE 
                        WHEN epr.inliquid = 1 
                         AND epr.tpemprst = 2 
                         AND to_char(epr.dtultpag,'MM') = to_char(lem.dtmvtolt,'MM') THEN 
                           0 
                         ELSE 
                           lem.vllanmto 
                      END vlrant
                    , lem.vllanmto
                    , his.indebcre
                    , lem.progress_recid
                    , epr.cdlcremp
                    , epr.dtultpag
                    , epr.inprejuz
                    , epr.tpemprst
                    , epr.tpdescto
                    , (SELECT MAX(ll.dtmvtolt) 
                         FROM tbepr_renegociacao_craplem ll
                        WHERE ll.cdcooper = lem.cdcooper
                          AND ll.nrdconta = lem.nrdconta
                          AND ll.nrctremp = lem.nrctremp
                          AND ll.cdhistor IN (2326,2327,2330,2331,1036,1044,1045,3654,1039,1057,1059,91,92,95,2335,2330,2331,3026,3027,2013,2014,3279,99)
                          AND ll.dtmvtolt <= lem.dtmvtolt) dtpgtant
                    , epr.dtprejuz
                    , epr.inliquid
                FROM tbepr_renegociacao_crapepr epr
                   , tbepr_renegociacao_craplem lem
                   , craphis his
               WHERE epr.cdcooper = pr_cdcooper
                 AND epr.nrdconta = pr_nrdconta
                 AND epr.nrctremp = pr_nrctremp
                 AND lem.cdcooper = epr.cdcooper
                 AND lem.nrdconta = epr.nrdconta
                 AND lem.nrctremp = epr.nrctremp
                 AND lem.nrversao = epr.nrversao
                 AND lem.cdhistor IN (98,1037,1038,2342,2343,2344,2345) -- juros remuneratorios          
                 AND lem.dtmvtolt BETWEEN to_date('01/01/2021','DD/MM/RRRR') AND pr_dtmvtolt
                 AND lem.cdagenci > 0
                 AND his.cdcooper = lem.cdcooper
                 AND his.cdhistor = lem.cdhistor 
            ) tab                                 
          ) t
         GROUP BY t.tabela,
                  t.cdcooper, 
                  t.nrdconta, 
                  t.nrctremp, 
                  t.dtprejuz, 
                  t.cdlcremp, 
                  t.dtultpag, 
                  t.inliquid,
                  t.inprejuz,
                  t.tpemprst,
                  t.tpdescto
         ORDER BY t.cdcooper, t.nrdconta;                  
         
             
    CURSOR cr_crapdat(pr_cdcooper crapcop.CDCOOPER%TYPE) IS
      SELECT dat.dtmvtolt
        FROM crapdat dat
       WHERE dat.CDCOOPER = pr_cdcooper;
    rw_crapdat cr_crapdat%ROWTYPE;
 
    CURSOR cr_crapcot(pr_cdcooper crapcot.cdcooper%TYPE,
                      pr_nrdconta crapcot.nrdconta%TYPE) IS
      SELECT cot.cdcooper,
             cot.nrdconta,
             cot.qtjurmfx
        FROM crapcot cot
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    rw_crapcot cr_crapcot%ROWTYPE;

  CURSOR cr_jurlcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    select cdcooper, nrdconta, 38 tipo, sum(vllanmto) vlrjur
      from craplcm 
     WHERE cdcooper = pr_cdcooper 
       and nrdconta = pr_nrdconta
       and dtmvtolt between to_date('31/01/2021','DD/MM/RRRR') and to_date('31/01/2022','DD/MM/RRRR')
       and cdhistor = 38  --Juros limite
       GROUP BY cdcooper, nrdconta, 3
     UNION
    select cdcooper, nrdconta, 37 tipo, sum(vllanmto) vlrjur
      from craplcm 
     where cdcooper = pr_cdcooper 
       and nrdconta = pr_nrdconta
       and dtmvtolt between to_date('01/01/2021','DD/MM/RRRR') and to_date('31/12/2021','DD/MM/RRRR') 
       and cdhistor = 37  --Juros adiant depto
       GROUP BY cdcooper, nrdconta, 3
     UNION       
    select cdcooper, nrdconta, 57 tipo, sum(vllanmto) vlrjur
      from craplcm 
     WHERE cdcooper = pr_cdcooper 
       and nrdconta = pr_nrdconta
       and dtmvtolt between to_date('01/01/2021','DD/MM/RRRR') and to_date('31/12/2021','DD/MM/RRRR')
       and cdhistor = 57  --Juros saque dep blq
       GROUP BY cdcooper, nrdconta, 3;       

    --Variaveis
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;
    vr_tab_crapcot typ_tab_crapcot;  
    
    PROCEDURE backup (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_1, 
                              pr_texto_completo => vr_texto_completo_1,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);
    END;  
  
    PROCEDURE loga (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_2, 
                              pr_texto_completo => vr_texto_completo_2,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

    END; 
  
    PROCEDURE erro (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_3, 
                              pr_texto_completo => vr_texto_completo_3,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

    END; 
    
    PROCEDURE abre_arquivos IS
	  BEGIN
      vr_nmarqimp1 := pr_cdcooper || '_PA' || to_char(pr_cdagenci) || '_' || vr_nmarqimp11 ||to_char(sysdate,'HH24MISS');
      vr_nmarqimp2 := pr_cdcooper || '_PA' || to_char(pr_cdagenci) || '_' || vr_nmarqimp22 ||to_char(sysdate,'HH24MISS');
      vr_nmarqimp3 := pr_cdcooper || '_PA' || to_char(pr_cdagenci) || '_' || vr_nmarqimp33 ||to_char(sysdate,'HH24MISS');
        
      vr_des_xml_1 := NULL;
      dbms_lob.createtemporary(vr_des_xml_1, TRUE);
      dbms_lob.open(vr_des_xml_1, dbms_lob.lob_readwrite);

      vr_des_xml_2 := NULL;
      dbms_lob.createtemporary(vr_des_xml_2, TRUE);
      dbms_lob.open(vr_des_xml_2, dbms_lob.lob_readwrite);
        
      vr_des_xml_3 := NULL;
      dbms_lob.createtemporary(vr_des_xml_3, TRUE);
      dbms_lob.open(vr_des_xml_3, dbms_lob.lob_readwrite);  			
    END;		 
  
    PROCEDURE fecha_arquivos IS
      vr_dscritic VARCHAR2(1000);
    BEGIN
        
      --- arq 1
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_1,
                              pr_texto_completo => vr_texto_completo_1,
                              pr_texto_novo     => ' ',
                              pr_fecha_xml      => TRUE);
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_1
                                   ,pr_caminho  => vr_nmdireto
                                   ,pr_arquivo  => vr_nmarqimp1 || '.txt'
                                   ,pr_des_erro => vr_dscritic);     
      dbms_lob.close(vr_des_xml_1);
      dbms_lob.freetemporary(vr_des_xml_1);     
                                   
               
      --- arq 2                        
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_2,
                              pr_texto_completo => vr_texto_completo_2,
                              pr_texto_novo     => ' ',
                              pr_fecha_xml      => TRUE);
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_2
                                   ,pr_caminho  => vr_nmdireto
                                   ,pr_arquivo  => vr_nmarqimp2 || '.txt'
                                   ,pr_des_erro => vr_dscritic);     
      dbms_lob.close(vr_des_xml_2);
      dbms_lob.freetemporary(vr_des_xml_2);                                      
               
      --- arq 3                        
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_3,
                              pr_texto_completo => vr_texto_completo_3,
                              pr_texto_novo     => ' ',
                              pr_fecha_xml      => TRUE);                            
      gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_3
                                   ,pr_caminho  => vr_nmdireto
                                   ,pr_arquivo  => vr_nmarqimp3 || '.txt'
                                   ,pr_des_erro => vr_dscritic);          
      dbms_lob.close(vr_des_xml_3);
      dbms_lob.freetemporary(vr_des_xml_3);                                      
      
    END;       
    
  BEGIN  
	 
    /* ####################################################################### */
    /* ############              INICIO               ######################## */
    /* ####################################################################### */  
    
    OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;    
    CLOSE cr_crapdat;
    
    vr_tab_crapcot.delete; 
    
    abre_arquivos;
    
    loga('INICIO - ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));        
        
    FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci) LOOP      

      /* ####################################################################### */
      /* ############              <CRAPEPR>            ######################## */
      /* ####################################################################### */
      
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => rw_crapass.cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta) LOOP
                                                                    
        CASE 
          WHEN rw_crapepr.inprejuz = 1 THEN                          
            vr_dtmvtolt := last_day(add_months(rw_crapepr.dtprejuz,-1));            
          WHEN rw_crapepr.inprejuz = 0 
           AND rw_crapepr.tpemprst = 1 
           AND rw_crapepr.tpdescto = 2 THEN
            vr_dtmvtolt := rw_crapdat.DTMVTOLT;
          ELSE
            vr_dtmvtolt := last_day(add_months(rw_crapdat.dtmvtolt,-1));
        END CASE;              
                                          
        IF rw_crapepr.qtreneg > 0 THEN
          --DBMS_OUTPUT.put_line(rw_crapepr.nrctremp);                                                   
          FOR rw_calculo IN cr_reneg  (pr_cdcooper => rw_crapepr.cdcooper
                                      ,pr_nrdconta => rw_crapepr.nrdconta
                                      ,pr_nrctremp => rw_crapepr.nrctremp
                                      ,pr_dtmvtolt => vr_dtmvtolt) LOOP
                      
            IF NOT vr_tab_crapcot.exists(rw_calculo.nrdconta) THEN
                 
               OPEN cr_crapcot (pr_cdcooper => rw_calculo.cdcooper,
                                pr_nrdconta => rw_calculo.nrdconta);
               FETCH cr_crapcot INTO rw_crapcot;
               CLOSE cr_crapcot;
                 
               backup('update crapcot set qtjurmfx = ' || replace(rw_crapcot.qtjurmfx,',','.') || ' where cdcooper = ' || rw_crapcot.cdcooper ||' and nrdconta =  '||rw_crapcot.nrdconta||';');
               vr_tab_crapcot(rw_calculo.nrdconta).cdcooper := rw_calculo.cdcooper;
               vr_tab_crapcot(rw_calculo.nrdconta).nrdconta := rw_calculo.nrdconta;
               vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx := 0; -- rw_crapcot.qtjurmfx;
               vr_tab_crapcot(rw_calculo.nrdconta).qtjurbkp := rw_crapcot.qtjurmfx;
            END IF;                       
            
            vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx := NVL(vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx,0) + round(rw_calculo.vlr_calc / 0.82870000,4);
            
            loga(rw_calculo.cdcooper||';'||
                 rw_calculo.nrdconta||';'||
                 rw_calculo.nrctremp||';'||
                 (case WHEN rw_calculo.tpemprst = 1 AND rw_calculo.tpdescto = 2 THEN 3 ELSE rw_calculo.tpemprst END) ||';'||
                 rw_calculo.cdlcremp||';'||
                 rw_calculo.inprejuz||';'||
                 to_char(rw_calculo.dtultpag,'DD/MM/RRRR')||';'||
                 round(rw_calculo.vlr_ant,2) || ';' ||
                 round(rw_calculo.vlr_calc,2) || ';' ||
                 (CASE WHEN rw_calculo.inprejuz = 1 THEN 'Prejuizo' 
                       WHEN rw_calculo.cdlcremp IN (6901,900) THEN 'LC' 
                       WHEN rw_calculo.vlr_ant <> rw_calculo.vlr_calc THEN 'INADIMP' ELSE '-' END) ||
                         (CASE WHEN rw_calculo.tabela LIKE '***%' THEN ' (reneg)' END ) || ';' ||
                 round(vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx * 0.8287,2) || ';' ||
                 round(vr_tab_crapcot(rw_calculo.nrdconta).qtjurbkp * 0.8287,2)
                 );                    
            
          END LOOP; -- fim cr_reneg               
          				 
        END IF; -- if qtreneg
        
        FOR rw_calculo IN cr_calculo(pr_cdcooper => rw_crapepr.cdcooper
                                    ,pr_nrdconta => rw_crapepr.nrdconta
                                    ,pr_nrctremp => rw_crapepr.nrctremp
                                    ,pr_dtmvtolt => vr_dtmvtolt) LOOP
          
          
          IF NOT vr_tab_crapcot.exists(rw_calculo.nrdconta) THEN
               
             OPEN cr_crapcot (pr_cdcooper => rw_calculo.cdcooper,
                              pr_nrdconta => rw_calculo.nrdconta);
             FETCH cr_crapcot INTO rw_crapcot;
             CLOSE cr_crapcot;
               
             backup('update crapcot set qtjurmfx = ' || replace(rw_crapcot.qtjurmfx,',','.') || ' where cdcooper = ' || rw_crapcot.cdcooper ||' and nrdconta =  '||rw_crapcot.nrdconta||';');
             vr_tab_crapcot(rw_calculo.nrdconta).cdcooper := rw_calculo.cdcooper;
             vr_tab_crapcot(rw_calculo.nrdconta).nrdconta := rw_calculo.nrdconta;
             vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx := 0; -- rw_crapcot.qtjurmfx;
             vr_tab_crapcot(rw_calculo.nrdconta).qtjurbkp := rw_crapcot.qtjurmfx;
          END IF;                       
          
          vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx := NVL(vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx,0) + round(rw_calculo.vlr_calc / 0.82870000,4);
          
          loga(rw_calculo.cdcooper||';'||
               rw_calculo.nrdconta||';'||
               rw_calculo.nrctremp||';'||
               (case WHEN rw_calculo.tpemprst = 1 AND rw_calculo.tpdescto = 2 THEN 3 ELSE rw_calculo.tpemprst END) ||';'||
               rw_calculo.cdlcremp||';'||
               rw_calculo.inprejuz||';'||
               to_char(rw_calculo.dtultpag,'DD/MM/RRRR')||';'||
               round(rw_calculo.vlr_ant,2) || ';' ||
               round(rw_calculo.vlr_calc,2) || ';' ||
               (CASE WHEN rw_calculo.inprejuz = 1 THEN 'Prejuizo' 
                     WHEN rw_calculo.cdlcremp IN (6901,900) THEN 'LC' 
                     WHEN rw_calculo.vlr_ant <> rw_calculo.vlr_calc THEN 'INADIMP' ELSE '-' END) ||
                       (CASE WHEN rw_calculo.tabela LIKE '***%' THEN ' (reneg)' END ) || ';' ||
               round(vr_tab_crapcot(rw_calculo.nrdconta).qtjurmfx * 0.8287,2) || ';' ||
               round(vr_tab_crapcot(rw_calculo.nrdconta).qtjurbkp * 0.8287,2)
               );                    
          
        END LOOP; -- fim cr_calculo        
        
      END LOOP; -- fim cr_crapepr
      
      
      /* ####################################################################### */
      /* ############              <CRAPLCM>            ######################## */
      /* ####################################################################### */
      FOR rw_jurlcm IN cr_jurlcm(pr_cdcooper => rw_crapass.CDCOOPER
                                ,pr_nrdconta => rw_crapass.nrdconta) LOOP
                                
                                
        IF vr_tab_crapcot.exists(rw_jurlcm.nrdconta) THEN
									
           -- atualizar qtjurmfx
           vr_tab_crapcot(rw_jurlcm.nrdconta).qtjurmfx := 
             nvl(vr_tab_crapcot(rw_jurlcm.nrdconta).qtjurmfx,0) + round(rw_jurlcm.vlrjur / 0.82870000,4);
             
           loga(rw_jurlcm.cdcooper||';'|| -- cdcooper
                rw_jurlcm.nrdconta||';'|| -- nrconta
                '9999' || rw_jurlcm.tipo ||';'|| -- contrato
                '9;'|| -- tipo emprest
                '0;'|| -- LC
                '0;'|| -- prejuizo
                to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ';' || -- ult pagto
                rw_jurlcm.vlrjur || ';' || -- vlr ant
                rw_jurlcm.vlrjur || ';' || -- vlr ajustado
                (CASE WHEN rw_jurlcm.tipo = 37 THEN 'JLIM' 
                      WHEN rw_jurlcm.tipo = 38 THEN 'JADP' 
 										  WHEN rw_jurlcm.tipo = 57 THEN 'JSDB' END ) || ';' || -- cenario
                round(vr_tab_crapcot(rw_jurlcm.nrdconta).qtjurmfx * 0.8287,2) || ';' || -- vlr base ajustado
                round(vr_tab_crapcot(rw_jurlcm.nrdconta).qtjurbkp * 0.8287,2) -- vlr base bkp
                );
             
        END IF;
        
      END LOOP;
      
    END LOOP; -- fim cr_crapass
    
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crapcot SAVE EXCEPTIONS
          UPDATE crapcot
             SET crapcot.qtjurmfx = case when vr_tab_crapcot(idx).qtjurmfx < 0 then 0 else vr_tab_crapcot(idx).qtjurmfx end
           WHERE crapcot.cdcooper  = vr_tab_crapcot(idx).cdcooper
             AND crapcot.nrdconta  = vr_tab_crapcot(idx).nrdconta;                     
      EXCEPTION
        WHEN OTHERS THEN
          erro('Erro ao atualizar tabela crapcot. '||
                   SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          --Levantar Exceção
          RAISE vr_excsaida;
    END;
    
   loga('TOTAL CONTAS - ' || to_char(vr_tab_crapcot.count) || ' - ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
          
   loga('FIM ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')||' cooperativa: '|| pr_cdcooper || ' PA: ' || pr_cdagenci);    
    
   fecha_arquivos;
   
   COMMIT;
   
  EXCEPTION
    WHEN vr_excsaida then 
      pr_dscritic := 'ERRO ' || pr_dscritic;  
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos;       
      ROLLBACK;
    WHEN OTHERS then
      pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos; 
      ROLLBACK;          
        
END;
/
