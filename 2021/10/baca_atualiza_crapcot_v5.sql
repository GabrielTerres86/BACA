PL/SQL Developer Test script 3.0
498
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
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); -- '/progress/f0030248/micros/'; -- 
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/prj0023533'; 
  vr_excsaida   EXCEPTION;
  
  vr_des_xml_1         CLOB;  
  vr_des_xml_2         CLOB;    
  vr_des_xml_3         CLOB;    
  vr_texto_completo_1    VARCHAR2(32600);
  vr_texto_completo_2    VARCHAR2(32600);
  vr_texto_completo_3    VARCHAR2(32600);    
  
  TYPE typ_reg_crapcot IS
       RECORD (nrdconta crapsda.nrdconta%type
              ,cdcooper crapcot.cdcooper%TYPE
              ,qtjurmfx crapcot.qtjurmfx%TYPE
              ,qtjurcalc crapcot.qtjurmfx%TYPE);
  
  TYPE typ_tab_crapcot IS TABLE OF typ_reg_crapcot INDEX BY PLS_INTEGER;
  vr_tab_crapcot typ_tab_crapcot;  
  vr_tab_bkp     typ_tab_crapcot;

  
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
     AND cdcooper <> 3
     AND cdcooper = 13;
     rw_crapcop cr_crapcop%ROWTYPE;
     
  CURSOR cr_lem_pagto (pr_cdcooper IN craplem.cdcooper%TYPE,
                       pr_nrdconta IN craplem.nrdconta%TYPE,
                       pr_nrctremp IN craplem.nrctremp%TYPE)  IS
    SELECT SUM(ll.vllanmto) vlrjuros_liq
      FROM craplem ll, 
           crapepr epr
     WHERE epr.cdcooper = ll.cdcooper
       AND epr.nrdconta = ll.nrdconta
       AND epr.nrctremp = ll.nrctremp
       AND ll.cdcooper = pr_cdcooper
       AND ll.nrdconta = pr_nrdconta
       AND ll.nrctremp = pr_nrctremp
       AND ll.cdagenci > 0       
       AND ll.cdhistor IN (98,1037,1038,2342,2343,2344,2345) -- juros remuneratorios       
--       AND ll.dtmvtolt >= '01/01/2021'
       AND ll.dtmvtolt BETWEEN to_date('01/' || to_char(epr.dtultpag, 'MM/RRRR'),'DD/MM/RRRR')
                           AND epr.dtultpag
       ;
  rw_lem_pagto cr_lem_pagto%ROWTYPE;
  
  CURSOR cr_contratos (pr_cdcooper IN craplem.cdcooper%TYPE) IS
    SELECT lem.cdcooper,
           lem.nrdconta,
           lem.nrctremp
      FROM craplem lem
     WHERE lem.cdcooper = pr_cdcooper
       AND lem.nrdconta > 0
       AND lem.nrctremp > 0
       AND lem.dtmvtolt BETWEEN '01/01/2021' AND '31/12/2021'
       GROUP BY lem.cdcooper, lem.nrdconta, lem.nrctremp
       ;
       
   TYPE typ_tab_contratos IS TABLE OF cr_contratos%ROWTYPE INDEX BY PLS_INTEGER;
   vr_tab_contratos_bulk typ_tab_contratos;          
  
   
  CURSOR cr_craplemll (pr_cdcooper IN craplem.cdcooper%TYPE,
                       pr_nrdconta IN craplem.nrdconta%TYPE,
                       pr_nrctremp IN craplem.nrctremp%TYPE)  IS       
    SELECT SUM(vllanmto) vlrjuros_calc FROM (
    SELECT NVL(SUM(lem.vllanmto),0) vllanmto
      FROM craplem lem, 
           crapepr epr,
           crapdat dat
     WHERE epr.cdcooper = lem.cdcooper
       AND epr.nrdconta = lem.nrdconta
       AND epr.nrctremp = lem.nrctremp
       AND dat.cdcooper = epr.cdcooper
       AND lem.cdcooper = pr_cdcooper
       AND lem.nrdconta = pr_nrdconta
       AND lem.nrctremp = pr_nrctremp
       AND lem.cdagenci > 0       
       AND lem.cdhistor IN (98,1037,1038,2342,2343,2344,2345) -- juros remuneratorios       
       AND lem.dtmvtolt BETWEEN '01/01/2021'
          AND  (case when epr.inprejuz = 0 AND epr.tpemprst <> 2 then last_day(add_months(dat.dtmvtolt,-1))
                     WHEN epr.inprejuz = 0 AND epr.tpemprst = 2 then last_day(add_months(dat.dtmvtolt,-1))
                     WHEN epr.inprejuz = 1 AND epr.tpemprst = 2 THEN epr.dtprejuz
                     else last_day(add_months(epr.dtprejuz,-1)) END)
      UNION
    SELECT NVL(SUM(lem.vllanmto),0) vllanmto
      FROM tbepr_renegociacao_craplem lem, 
           tbepr_renegociacao_crapepr epr,
           crapdat dat
     WHERE epr.cdcooper = lem.cdcooper
       AND epr.nrdconta = lem.nrdconta
       AND epr.nrctremp = lem.nrctremp
       AND dat.cdcooper = epr.cdcooper
       AND lem.cdcooper = pr_cdcooper
       AND lem.nrdconta = pr_nrdconta
       AND lem.nrctremp = pr_nrctremp
       AND lem.nrversao = epr.nrversao
       AND lem.cdagenci > 0       
       AND lem.cdhistor IN (98,1037,1038,2342,2343,2344,2345) -- juros remuneratorios       
       AND lem.dtmvtolt BETWEEN '01/01/2021'
          AND  (case when epr.inprejuz = 0 AND epr.tpemprst <> 2 then last_day(add_months(dat.dtmvtolt,-1))
                     WHEN epr.inprejuz = 0 AND epr.tpemprst = 2 then last_day(add_months(dat.dtmvtolt,-1))
                     WHEN epr.inprejuz = 1 AND epr.tpemprst = 2 THEN epr.dtprejuz
                     else last_day(add_months(epr.dtprejuz,-1)) END)
       );
       rw_craplemll cr_craplemll%ROWTYPE;
             
  CURSOR cr_craplem (pr_cdcooper IN craplem.cdcooper%TYPE,
                     pr_nrdconta IN craplem.nrdconta%TYPE,
                     pr_nrctremp IN craplem.nrctremp%TYPE
                     ) IS
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
      SELECT tab.*, CASE WHEN dtmvtolt-dtpgtant <= 59 AND indebcre = 'D' THEN vllanmto ELSE 0 END VLR FROM (
        SELECT 'craplem' tabela, lem.cdcooper,lem.nrdconta, lem.nrctremp, lem.dtmvtolt, lem.cdhistor, CASE WHEN epr.inliquid = 1 AND epr.tpemprst = 2 AND to_char(epr.dtultpag,'MM') = to_char(lem.dtmvtolt,'MM') THEN 0 ELSE lem.vllanmto END vlrant,lem.vllanmto,his.indebcre,lem.progress_recid,epr.cdlcremp,epr.dtultpag,epr.inprejuz,epr.tpemprst,epr.tpdescto,
        (SELECT MAX(ll.dtmvtolt) FROM craplem ll
            WHERE ll.cdcooper = lem.cdcooper
              AND ll.nrdconta = lem.nrdconta
              AND ll.nrctremp = lem.nrctremp
              AND ll.cdhistor IN (2326,2327,2330,2331,1036,1044,1045,3654,1039,1057,1059,91,92,95,2335,2330,2331,3026,3027)
              AND ll.dtmvtolt <= lem.dtmvtolt) dtpgtant
         ,epr.dtprejuz
         ,epr.inliquid
         FROM crapepr epr, craplem lem, craphis his, crapdat dat--, crapass ass
        WHERE epr.cdcooper = pr_cdcooper
          AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp
        -- AND epr.inprejuz = 1
--          AND ass.cdcooper = epr.cdcooper
--          AND ass.nrdconta = epr.nrdconta
--          AND ass.cdagenci = 1
          AND dat.cdcooper = epr.cdcooper
          AND lem.cdcooper = epr.cdcooper
          AND lem.nrdconta = epr.nrdconta
          AND lem.nrctremp = epr.nrctremp
          AND lem.cdhistor IN (98,1037,1038,2342,2343,2344,2345) -- juros remuneratorios          
          AND lem.dtmvtolt BETWEEN '01/01/2021'
              AND  (case when epr.inprejuz = 0 AND epr.tpemprst <> 2 then last_day(add_months(dat.dtmvtolt,-1))
                         WHEN epr.inprejuz = 0 AND epr.tpemprst = 2 then last_day(add_months(dat.dtmvtolt,-1))
                         WHEN epr.inprejuz = 1 AND epr.tpemprst = 2 THEN epr.dtprejuz
                         else last_day(add_months(epr.dtprejuz,-1)) END)
          AND lem.cdagenci > 0
          AND his.cdcooper = lem.cdcooper
          AND his.cdhistor = lem.cdhistor
        ) tab
      UNION
      SELECT tab.*, CASE WHEN dtmvtolt-dtpgtant <= 59 AND indebcre = 'D' THEN vllanmto ELSE 0 END VLR 
        FROM (
        SELECT '***' || to_char(epr.nrversao), lem.cdcooper,lem.nrdconta, lem.nrctremp, lem.dtmvtolt, lem.cdhistor, lem.vllanmto vlrant, lem.vllanmto,his.indebcre,lem.progress_recid,epr.cdlcremp,epr.dtultpag,epr.inprejuz,epr.tpemprst,epr.tpdescto,
        (SELECT MAX(ll.dtmvtolt) FROM tbepr_renegociacao_craplem ll
            WHERE ll.cdcooper = lem.cdcooper
              AND ll.nrdconta = lem.nrdconta
              AND ll.nrctremp = lem.nrctremp
              AND ll.nrversao = lem.nrversao
              AND ll.cdhistor IN (2326,2327,2330,2331,1036,1044,1045,3654,1039,1057,1059,91,92,95,2335,2330,2331,3026,3027)
              AND ll.dtmvtolt <= lem.dtmvtolt) dtpgtant
         ,epr.dtprejuz
         ,epr.inliquid
         FROM tbepr_renegociacao_crapepr epr, tbepr_renegociacao_craplem lem, craphis his, crapdat dat, crapepr eee--, crapass ass
        WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
          -- AND epr.inprejuz = 1
--          AND ass.cdcooper = epr.cdcooper
--          AND ass.nrdconta = epr.nrdconta
--          AND ass.cdagenci = 1          
          AND dat.cdcooper = epr.cdcooper
          AND lem.cdcooper = epr.cdcooper
          AND lem.nrdconta = epr.nrdconta
          AND lem.nrctremp = epr.nrctremp
          AND lem.nrversao = epr.nrversao
          AND eee.cdcooper = lem.cdcooper
          AND eee.nrdconta = lem.nrdconta
          AND eee.nrctremp = lem.nrctremp
          AND lem.cdhistor IN (98,1037,1038,2342,2343,2344,2345) -- juros remuneratorios          
          AND lem.dtmvtolt BETWEEN '01/01/2021'
              AND  (case when epr.inprejuz = 0 AND epr.tpemprst <> 2 then last_day(add_months(eee.dtmvtolt,-1))
                         WHEN epr.inprejuz = 0 AND epr.tpemprst = 2 then last_day(add_months(eee.dtmvtolt,-1))
                         WHEN epr.inprejuz = 1 AND epr.tpemprst = 2 THEN epr.dtprejuz
                         else last_day(add_months(epr.dtprejuz,-1)) END)
          AND lem.cdagenci > 0
          AND his.cdcooper = lem.cdcooper
          AND his.cdhistor = lem.cdhistor
        ) tab 
        --WHERE dtmvtolt - dtpgtant <= 59
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
       
      TYPE typ_tab_craplem IS TABLE OF cr_craplem%ROWTYPE INDEX BY PLS_INTEGER;
       vr_tab_craplem_bulk typ_tab_craplem;  
               
  procedure backup (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_1, 
                              pr_texto_completo => vr_texto_completo_1,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);
    END;  
  
  procedure loga (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_2, 
                              pr_texto_completo => vr_texto_completo_2,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

    END; 
  
  procedure erro (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_3, 
                              pr_texto_completo => vr_texto_completo_3,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

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
                                 ,pr_arquivo  => rw_crapcop.cdcooper || vr_nmarqimp1 || '.txt'
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
                                 ,pr_arquivo  => rw_crapcop.cdcooper || vr_nmarqimp2 || '.txt'
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
                                 ,pr_arquivo  => rw_crapcop.cdcooper || vr_nmarqimp3 || '.txt'
                                 ,pr_des_erro => vr_dscritic);     			
    dbms_lob.close(vr_des_xml_3);
    dbms_lob.freetemporary(vr_des_xml_3);                                      
    
    END;        
BEGIN
 
  FOR rw_crapcop IN cr_crapcop LOOP 
  
    vr_tab_crapcot.delete;  
  
    OPEN cr_crapdat (pr_cdcooper => rw_crapcop.cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
                          
    vr_nmarqimp1 := rw_crapcop.cdcooper || vr_nmarqimp11 ||to_char(sysdate,'HH24:MI:SS');
    vr_nmarqimp2 := rw_crapcop.cdcooper || vr_nmarqimp22 ||to_char(sysdate,'HH24:MI:SS');
    vr_nmarqimp3 := rw_crapcop.cdcooper || vr_nmarqimp33 ||to_char(sysdate,'HH24:MI:SS');
      
    vr_des_xml_1 := NULL;
    dbms_lob.createtemporary(vr_des_xml_1, TRUE);
    dbms_lob.open(vr_des_xml_1, dbms_lob.lob_readwrite);

    vr_des_xml_2 := NULL;
    dbms_lob.createtemporary(vr_des_xml_2, TRUE);
    dbms_lob.open(vr_des_xml_2, dbms_lob.lob_readwrite);
      
    vr_des_xml_3 := NULL;
    dbms_lob.createtemporary(vr_des_xml_3, TRUE);
    dbms_lob.open(vr_des_xml_3, dbms_lob.lob_readwrite);
    
    OPEN cr_contratos(pr_cdcooper => rw_crapcop.cdcooper);
    LOOP
      FETCH cr_contratos BULK COLLECT INTO vr_tab_contratos_bulk LIMIT 1000;
      EXIT WHEN vr_tab_contratos_bulk.count = 0;
      
      loga('CONTRATOS - LIMIT 1000 - ' || to_char(vr_tab_contratos_bulk.COUNT) || ' - ' || to_char(vr_tab_crapcot.count) || ' - ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));      

      FOR idx2 IN vr_tab_contratos_bulk.first..vr_tab_contratos_bulk.last LOOP
      
        IF cr_craplem%ISOPEN THEN
          CLOSE cr_craplem; 
        END IF;
        
        OPEN cr_craplem(pr_cdcooper => vr_tab_contratos_bulk(idx2).cdcooper,
                        pr_nrdconta => vr_tab_contratos_bulk(idx2).nrdconta,
                        pr_nrctremp => vr_tab_contratos_bulk(idx2).nrctremp
                        );
          
        LOOP     
          FETCH cr_craplem BULK COLLECT INTO vr_tab_craplem_bulk LIMIT 1000;
          EXIT WHEN vr_tab_craplem_bulk.COUNT = 0; 
                       
          FOR idx IN vr_tab_craplem_bulk.first..vr_tab_craplem_bulk.last LOOP
            
            IF (vr_tab_craplem_bulk(idx).cdlcremp IN(6901999,900999) OR vr_tab_craplem_bulk(idx).inprejuz = 1) THEN         
            --
              OPEN cr_craplemll (pr_cdcooper => vr_tab_craplem_bulk(idx).cdcooper,
                                 pr_nrdconta => vr_tab_craplem_bulk(idx).nrdconta,
                                 pr_nrctremp => vr_tab_craplem_bulk(idx).nrctremp);
              FETCH cr_craplemll INTO rw_craplemll;          
              vr_vllanmto := vr_vllanmto - nvl(rw_craplemll.vlrjuros_calc,0);
              CLOSE cr_craplemll;          
            --
            ELSE           
              vr_vllanmto := vr_vllanmto - vr_tab_craplem_bulk(idx).vlr_ant + vr_tab_craplem_bulk(idx).vlr_calc;          
            END IF;  
            
            IF NOT vr_tab_bkp.exists(vr_tab_craplem_bulk(idx).nrdconta) THEN
               vr_tab_bkp(vr_tab_craplem_bulk(idx).nrdconta).cdcooper := vr_tab_craplem_bulk(idx).cdcooper;
               vr_tab_bkp(vr_tab_craplem_bulk(idx).nrdconta).nrdconta := vr_tab_craplem_bulk(idx).nrdconta;           
            END IF;
            
            vr_tab_bkp(vr_tab_craplem_bulk(idx).nrdconta).qtjurcalc := 
              nvl(vr_tab_bkp(vr_tab_craplem_bulk(idx).nrdconta).qtjurcalc,0) + 
              nvl(vr_tab_craplem_bulk(idx).vlr_calc,0);
            
            IF (abs(vr_vllanmto) > 0) THEN
              vr_vllanmto := ROUND(vr_vllanmto / 0.82870000,4);
              
              IF NOT vr_tab_crapcot.exists(vr_tab_craplem_bulk(idx).nrdconta) THEN
               
                OPEN cr_crapcot (pr_cdcooper => vr_tab_craplem_bulk(idx).cdcooper,
                                 pr_nrdconta => vr_tab_craplem_bulk(idx).nrdconta);
                FETCH cr_crapcot INTO rw_crapcot;
                CLOSE cr_crapcot;
               
                backup('update crapcot set qtjurmfx = ' || replace(rw_crapcot.qtjurmfx,',','.') || ' where cdcooper = ' || rw_crapcot.cdcooper ||' and nrdconta =  '||rw_crapcot.nrdconta||';');          
                vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).cdcooper := vr_tab_craplem_bulk(idx).cdcooper;
                vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).nrdconta := vr_tab_craplem_bulk(idx).nrdconta;
                vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx := rw_crapcot.qtjurmfx;
              END IF;          
              
              vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx := NVL(vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx,0) + vr_vllanmto;          
              
              loga(vr_tab_craplem_bulk(idx).cdcooper||';'||
                   vr_tab_craplem_bulk(idx).nrdconta||';'||
                   vr_tab_craplem_bulk(idx).nrctremp||';'||
                   (case WHEN vr_tab_craplem_bulk(idx).tpemprst = 1 AND vr_tab_craplem_bulk(idx).tpdescto = 2 THEN 3 ELSE vr_tab_craplem_bulk(idx).tpemprst END) ||';'||
                   vr_tab_craplem_bulk(idx).cdlcremp||';'||
                   vr_tab_craplem_bulk(idx).inprejuz||';'||
                   to_char(vr_tab_craplem_bulk(idx).dtultpag,'DD/MM/RRRR')||';'||
                   (vr_vllanmto * 0.8287) || ';' ||
                   (CASE WHEN vr_tab_craplem_bulk(idx).inprejuz = 1 THEN 'Prejuizo' 
                         WHEN vr_tab_craplem_bulk(idx).cdlcremp IN (6901,900) THEN 'LC' 
                         WHEN vr_tab_craplem_bulk(idx).vlr_ant <> vr_tab_craplem_bulk(idx).vlr_calc THEN 'INADIMP' ELSE '-' END) ||
                           (CASE WHEN vr_tab_craplem_bulk(idx).tabela LIKE '***%' THEN ' (reneg)' END ) || ';' ||
                   vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx * 0.8287                       
                   );
                                                    
            END IF; 
                            
            vr_vllanmto := 0;   
          
          END LOOP; --vr_tab_craplem_bulk
        
        END LOOP;  --cr_craplem  
      
      END LOOP; -- vr_tab_contratos_bulk      
      
    END LOOP; -- cr_contratos
    
    IF cr_craplem%ISOPEN THEN
       CLOSE cr_craplem;
    END IF;
    
    IF cr_contratos%ISOPEN THEN
       CLOSE cr_contratos;
    END IF;
    
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
          
    loga('FIM ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')||' cooperativa: '||rw_crapcop.cdcooper);
    
    fecha_arquivos;   
    
    COMMIT;    
    
  END LOOP; --cr_crapcop        
  commit;
 
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
0
2
vr_tab_bpk(6181).qtjurcalc
vr_tab_crapcot(6181).qtjurmfx
