DECLARE

  vr_aux_ambiente INTEGER       := 3;                       
  vr_aux_diretor  VARCHAR2(100) := 'INC0126506_INC0129426'; 
  vr_aux_arquivo  VARCHAR2(100) := 'difcontab';             

  vr_handle         UTL_FILE.FILE_TYPE; 
  vr_handle_log     UTL_FILE.FILE_TYPE;
  vr_handle_contab  UTL_FILE.FILE_TYPE;
  vr_nmarq_carga    VARCHAR2(200);
  vr_nmarq_log      VARCHAR2(200);
  vr_nmarq_rollback VARCHAR2(200);
  vr_des_erro       VARCHAR2(10000); 
  vr_nmarq_contab   VARCHAR2(200);

  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  
  vr_aux_cdcoop   VARCHAR2(300) := '2;1;1|' ||
                                   '5;1;1|' ||
                                   '6;1;0|' ||
                                   '7;0;1|' ||
                                   '8;0;1|' ||
                                   '9;1;1|' ||
                                   '11;1;1|' ||
                                   '12;1;1|' ||
                                   '14;0;1|' ||
                                   '16;1;1';                    
                              
  vr_aux_arrcoop    gene0002.typ_split;
  vr_aux_arrtemdiff gene0002.typ_split;
  vr_indexcoop      INTEGER;
  rw_crapdat        btch0001.cr_crapdat%rowtype;
  vlr_mes_ant    NUMBER := 0;
  vlr_lanc_mes   NUMBER := 0;
  vlr_diff       NUMBER := 0;
  vlr_diff_tot   NUMBER := 0;
  vlr_final_ctr  NUMBER := 0;
  vlr_tot_cont   NUMBER := 0;
  vlr_tot_crps   NUMBER := 0;
  qtd_cont_ctr   NUMBER := 0;
  vlr_tot_lanc   NUMBER := 0;
  vlr_diff_iff   NUMBER := 0;
  vlr_diff_real  NUMBER := 0;
  vlr_mes_ant_ris  NUMBER := 0;
  vlr_lanc_mes_ris NUMBER := 0;
  vlr_tot_ant_crps NUMBER := 0;
  vlr_diff_tot_real NUMBER := 0;
  vr_renda        NUMBER := 0;
  vr_vldivida_ant NUMBER := 0;
  vr_dif          NUMBER := 0;
  vr_lancto       NUMBER := 0;
  vr_total_dif    NUMBER := 0;
  vl_aux_preju    NUMBER := ''; 
  
  vl_aux_tot    NUMBER := 0; 
  
  CURSOR cr_crps_mes_atual(pr_cdcooper crapvri.cdcooper%TYPE,
                           pr_nrdconta crapvri.nrdconta%TYPE, 
                           pr_nrborder crapvri.nrctremp%TYPE,
                           pr_dtrefere crapvri.dtrefere%TYPE) IS 
     select sum(crapvri.vldivida) vri_div, crapris.vldivida ris_div
      from crapris
          ,crapvri
      WHERE crapvri.cdcooper = crapris.cdcooper
       and crapvri.nrdconta = crapris.nrdconta
       and crapvri.dtrefere = crapris.dtrefere
       and crapvri.innivris = crapris.innivris
       and crapvri.cdmodali = crapris.cdmodali
       and crapvri.nrctremp = crapris.nrctremp
       and crapvri.nrseqctr = crapris.nrseqctr
       and crapris.cdcooper = pr_cdcooper
       and crapris.dtrefere = pr_dtrefere
       and crapris.cdorigem IN (4,5)
       AND crapris.inddocto = 1
       and crapvri.cdvencto BETWEEN 110 AND 290
       AND crapvri.nrdconta = pr_nrdconta
       AND crapvri.nrctremp = pr_nrborder
     GROUP BY crapris.vldivida;

  CURSOR cr_crps_mes_anterior(pr_cdcooper crapvri.cdcooper%TYPE,
                              pr_nrdconta crapvri.nrdconta%TYPE, 
                              pr_nrborder crapvri.nrctremp%TYPE,
                              pr_dtrefere crapvri.dtrefere%TYPE ) IS 
     select sum(crapvri.vldivida), crapris.vldivida ris_div
        from crapris
            ,crapvri
        WHERE crapvri.cdcooper = crapris.cdcooper
         and crapvri.nrdconta = crapris.nrdconta
         and crapvri.dtrefere = crapris.dtrefere
         and crapvri.innivris = crapris.innivris
         and crapvri.cdmodali = crapris.cdmodali
         and crapvri.nrctremp = crapris.nrctremp
         and crapvri.nrseqctr = crapris.nrseqctr
         and crapris.cdcooper = pr_cdcooper
         and crapris.dtrefere = TRUNC(pr_dtrefere, 'MM') -1
         and crapris.cdorigem IN (4,5)
         AND crapris.inddocto = 1
         and crapvri.cdvencto BETWEEN 110 AND 290
         AND crapvri.nrdconta = pr_nrdconta
         AND crapvri.nrctremp = pr_nrborder
      GROUP BY crapris.vldivida;

  CURSOR cr_lanctos (pr_cdcooper tbdsct_lancamento_bordero.cdcooper%TYPE,
                     pr_dtmvtolt_ini tbdsct_lancamento_bordero.dtmvtolt%TYPE,
                     pr_dtmvtolt_fim tbdsct_lancamento_bordero.dtmvtolt%TYPE) IS 
    SELECT x.cdcooper, x.nrdconta, x.nrborder,SUM(x.tot) AS lanc
      FROM 
      (SELECT (case when h.indebcre = 'D' then c.vllanmto else c.vllanmto * -1 end) as tot
              ,c.cdcooper
              ,c.nrdconta
              ,c.nrborder
              ,c.nrdocmto
              FROM TBDSCT_LANCAMENTO_BORDERO c, craphis h
             WHERE c.dtmvtolt >= pr_dtmvtolt_ini
               AND c.dtmvtolt <= pr_dtmvtolt_fim
               AND c.cdcooper = pr_cdcooper
               AND h.cdcooper = c.cdcooper
               AND h.cdhistor = c.cdhistor
               AND (h.nrctacrd = 1630 OR h.nrctadeb = 1630)
               AND c.cdhistor <> 2679
            UNION ALL
            SELECT (case when h.indebcre = 'C' then c.vllanmto else c.vllanmto * -1 end) as tot
             ,c.cdcooper
             ,c.nrdconta
             ,to_number(SUBSTR(c.cdpesqbb,31, LENGTH(c.cdpesqbb) - 30)) nrborder
             ,c.nrdocmto
              FROM CRAPLCM c, craphis h
             WHERE c.dtmvtolt >= pr_dtmvtolt_ini
               AND c.dtmvtolt <= pr_dtmvtolt_fim
               AND c.cdcooper = pr_cdcooper
               AND h.cdcooper = c.cdcooper
               AND h.cdhistor = c.cdhistor
               AND (h.nrctacrd = 1630 OR h.nrctadeb = 1630)) x
               GROUP BY x.cdcooper, x.nrdconta, x.nrborder;
  rw_lanctos cr_lanctos%ROWTYPE; 

  CURSOR renda_s_resgate(pr_cdcooper IN tbdsct_lancamento_bordero.cdcooper%TYPE
                        ,pr_nrdconta IN tbdsct_lancamento_bordero.nrdconta%TYPE
                        ,pr_nrborder IN tbdsct_lancamento_bordero.nrborder%TYPE
                        ,pr_dtmvtolt_ini tbdsct_lancamento_bordero.dtmvtolt%TYPE
                        ,pr_dtmvtolt_fim tbdsct_lancamento_bordero.dtmvtolt%TYPE) IS 
    SELECT SUM(decode(h.indebcre, 'C', c.vllanmto * (-1), c.vllanmto)) vllanmto
      FROM TBDSCT_LANCAMENTO_BORDERO c
          ,craphis                   h
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.nrborder = pr_nrborder
       AND c.dtmvtolt >= pr_dtmvtolt_ini
       AND c.dtmvtolt <= pr_dtmvtolt_fim
       AND h.cdcooper = c.cdcooper
       AND h.cdhistor = c.cdhistor
       AND (h.nrctacrd = 1630 OR h.nrctadeb = 1630)
       AND c.cdhistor = 2679;

   CURSOR cr_crapbdt(pr_cdcooper IN crapbdt.cdcooper%TYPE
                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                    ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
       SELECT a.cdcooper
             ,a.nrborder
             ,a.nrdconta
             ,a.inprejuz
             ,c.nmpasite
         FROM crapbdt a,
              crapass b,
              crapage c
        WHERE a.cdcooper = b.cdcooper
          AND a.nrdconta = b.nrdconta
          AND a.cdcooper = c.cdcooper
          AND b.cdagenci = c.cdagenci
          AND a.cdcooper = pr_cdcooper
          AND a.nrdconta = pr_nrdconta
          AND a.nrborder = pr_nrborder;
       rw_crapbdt cr_crapbdt%ROWTYPE;       
       

   CURSOR cr_prejuizos(pr_cdcooper IN crapbdt.cdcooper%TYPE
                      ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                      ,pr_nrborder IN crapbdt.nrborder%TYPE) IS 
        SELECT bor.cdcooper
              ,bor.nrdconta
              ,bor.nrborder
              ,bor.nrdocmto
              ,bor.nrtitulo
              ,SUM(bor.vllanmto) AS vllanmtotal
              ,tdb.vlmratit
              ,tdb.vlsdprej 
              ,tdb.vlprejuz
              ,NVL(SUM(bor.vllanmto),0) - NVL(tdb.vlmratit,0) AS vlprejdiff
              ,NVL(tdb.vlsdprej,0) + NVL(SUM(bor.vllanmto),0) - NVL(tdb.vlmratit,0) AS vlprejtotal       
          FROM crapbdt                   bdt
              ,craptdb                   tdb
              ,tbdsct_lancamento_bordero bor
              ,craphis                   h
         WHERE bdt.cdcooper = pr_cdcooper
           AND bdt.nrdconta = pr_nrdconta
           AND bdt.nrborder = pr_nrborder
           AND bdt.cdcooper = tdb.cdcooper
           AND bdt.nrdconta = tdb.nrdconta
           AND bdt.nrborder = tdb.nrborder
           AND (tdb.insittit = 4 OR (tdb.insittit = 3 AND bdt.dtliqprj IS NOT NULL))
           AND bdt.inprejuz = 1
           AND bdt.cdcooper = bor.cdcooper
           AND bdt.nrdconta = bor.nrdconta
           AND bdt.nrborder = bor.nrborder
           AND tdb.nrdocmto = bor.nrdocmto
           AND h.cdcooper = bor.cdcooper
           AND h.cdhistor = bor.cdhistor
           AND (h.nrctacrd = 1630 OR h.nrctadeb = 1630)
           AND bor.cdhistor <> 2679
           AND bor.cdhistor = 2668 
         GROUP BY bor.cdcooper
                 ,bor.nrdconta
                 ,bor.nrborder
                 ,bor.nrdocmto
                 ,bor.nrtitulo
                 ,tdb.vlmratit
                 ,tdb.vlsdprej
                 ,tdb.vlprejuz;     
      rw_prejuizos cr_prejuizos%ROWTYPE; 
       

    PROCEDURE pc_diferenca_contabil(pr_cdcooper     IN crapcop.cdcooper%TYPE,
                                    pr_dtrefere     IN crapris.dtrefere%TYPE, 
                                    pr_dtmvtolt_ini IN tbdsct_lancamento_bordero.dtmvtolt%TYPE,     
                                    pr_dtmvtolt_fim IN tbdsct_lancamento_bordero.dtmvtolt%TYPE)IS 
      BEGIN 
          
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;
        
      
      FOR rw_lanctos IN cr_lanctos(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt_ini => pr_dtmvtolt_ini,
                                   pr_dtmvtolt_fim => pr_dtmvtolt_fim) LOOP

          vlr_lanc_mes_ris := 0;
          vlr_mes_ant_ris  := 0;
          vr_renda        := 0;
          vlr_mes_ant  := 0;
          vlr_lanc_mes := 0;
          vlr_final_ctr:= 0;
          vlr_tot_lanc := vlr_tot_lanc + nvl(rw_lanctos.lanc, 0); 
          vl_aux_preju := '';  
          vl_aux_tot:= 0;        
          
          OPEN cr_crps_mes_atual(rw_lanctos.cdcooper, rw_lanctos.nrdconta, rw_lanctos.nrborder, pr_dtrefere);
          FETCH cr_crps_mes_atual INTO vlr_lanc_mes, vlr_lanc_mes_ris;
          CLOSE cr_crps_mes_atual;
            
          OPEN cr_crps_mes_anterior(rw_lanctos.cdcooper, rw_lanctos.nrdconta, rw_lanctos.nrborder, pr_dtrefere);
          FETCH cr_crps_mes_anterior INTO vlr_mes_ant, vlr_mes_ant_ris;
          CLOSE cr_crps_mes_anterior;
            
          FOR C2 IN renda_s_resgate(rw_lanctos.cdcooper, rw_lanctos.nrdconta, rw_lanctos.nrborder, pr_dtmvtolt_ini, pr_dtmvtolt_fim) LOOP
            vr_renda := nvl(C2.vllanmto, 0);
          END LOOP; 
    
          vlr_diff := nvl(vlr_mes_ant, 0) + nvl(rw_lanctos.lanc, 0) - nvl(vlr_lanc_mes, 0) - vr_renda; 
          vlr_diff_real := nvl(vlr_mes_ant_ris, 0) + nvl(rw_lanctos.lanc, 0) - nvl(vlr_lanc_mes_ris, 0) - vr_renda;
            
             
          IF abs(vlr_diff) > 0.1 THEN
            
             OPEN  cr_crapbdt(pr_cdcooper => rw_lanctos.cdcooper,
                              pr_nrdconta => rw_lanctos.nrdconta,
                              pr_nrborder => rw_lanctos.nrborder);
             FETCH cr_crapbdt INTO rw_crapbdt;
               
             IF cr_crapbdt%NOTFOUND THEN
                CLOSE cr_crapbdt;

                vr_dscritic := 'Bordero nao encontrado. ' || SQLERRM;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => rw_lanctos.cdcooper || ';' || 
                                                              rw_lanctos.nrdconta || ';' ||
                                                              rw_lanctos.nrborder || ';' ||
                                                              vlr_diff || ';' ||
                                                              vr_dscritic);
             ELSE    
               

               IF rw_crapbdt.inprejuz = 0 THEN

                  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_lanctos.cdcooper, 
                                                         pr_nrdconta => rw_lanctos.nrdconta, 
                                                         pr_nrborder => rw_lanctos.nrborder,
                                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                         pr_cdorigem => 1, 
                                                         pr_cdhistor => 2686, 
                                                         pr_vllanmto => NVL(vlr_diff,0), 
                                                         pr_cdbandoc => 0, 
                                                         pr_nrdctabb => 0, 
                                                         pr_nrcnvcob => 0, 
                                                         pr_nrdocmto => 0, 
                                                         pr_nrtitulo => 0, 
                                                         pr_dscritic => vr_dscritic);
                   IF vr_dscritic IS NOT NULL THEN

                      vr_dscritic := 'Erro ao fazer lancamento(pc_inserir_lancamento_bordero) - cdhistor 2686. ' || SQLERRM;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                    ,pr_des_text => rw_lanctos.cdcooper || ';' || 
                                                                    rw_lanctos.nrdconta || ';' ||
                                                                    rw_lanctos.nrborder || ';' ||
                                                                    vlr_diff || ';' ||
                                                                    vr_dscritic);
                   ELSE 

                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                   ,pr_des_text => 'DELETE tbdsct_lancamento_bordero'
                                                                 ||' WHERE cdcooper = '||rw_lanctos.cdcooper
                                                                 ||'   AND nrdconta = '||rw_lanctos.nrdconta
                                                                 ||'   AND nrborder = '||rw_lanctos.nrborder
                                                                 ||'   AND nrtitulo = 0'
                                                                 ||'   AND nrdocmto = 0'
                                                                 ||'   AND cdhistor = 2686' ||';');  
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                   ,pr_des_text => 'COMMIT;');  
                                                   
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_contab
                                                   ,pr_des_text => rw_lanctos.cdcooper || ';' || 
                                                                   rw_lanctos.nrdconta || ';' || 
                                                                   rw_lanctos.nrborder||  ';' || 
                                                                   '2686' || ';' || 
                                                                   rw_crapbdt.nmpasite);                             
                                                                                                                                                
                   END IF;
                                                                    
               ELSE 

                  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_lanctos.cdcooper, 
                                                         pr_nrdconta => rw_lanctos.nrdconta, 
                                                         pr_nrborder => rw_lanctos.nrborder,
                                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                         pr_cdorigem => 1, 
                                                         pr_cdhistor => 2761, 
                                                         pr_vllanmto => NVL(vlr_diff,0), 
                                                         pr_cdbandoc => 0, 
                                                         pr_nrdctabb => 0, 
                                                         pr_nrcnvcob => 0, 
                                                         pr_nrdocmto => 0, 
                                                         pr_nrtitulo => 0, 
                                                         pr_dscritic => vr_dscritic);
                   IF vr_dscritic IS NOT NULL THEN

                      vr_dscritic := 'Erro ao fazer lancamento(pc_inserir_lancamento_bordero) - cdhistor 2761. ' || vr_dscritic || SQLERRM;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                    ,pr_des_text => rw_lanctos.cdcooper || ';' || 
                                                                    rw_lanctos.nrdconta || ';' ||
                                                                    rw_lanctos.nrborder || ';' ||
                                                                    vlr_diff || ';' ||
                                                                    vr_dscritic);
                   ELSE 

                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                   ,pr_des_text => 'DELETE tbdsct_lancamento_bordero'
                                                                 ||' WHERE cdcooper = '||rw_lanctos.cdcooper
                                                                 ||'   AND nrdconta = '||rw_lanctos.nrdconta
                                                                 ||'   AND nrborder = '||rw_lanctos.nrborder
                                                                 ||'   AND nrtitulo = 0'
                                                                 ||'   AND nrdocmto = 0'
                                                                 ||'   AND cdhistor = 2761' ||';');  
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                   ,pr_des_text => 'COMMIT;');
                                                   
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_contab
                                                   ,pr_des_text => rw_lanctos.cdcooper || ';' || 
                                                                   rw_lanctos.nrdconta || ';' || 
                                                                   rw_lanctos.nrborder||  ';' || 
                                                                   '2761' || ';' || 
                                                                   rw_crapbdt.nmpasite);                             
                   END IF;
               
               

                   DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_lanctos.cdcooper, 
                                                          pr_nrdconta => rw_lanctos.nrdconta, 
                                                          pr_nrborder => rw_lanctos.nrborder,
                                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                          pr_cdorigem => 1, 
                                                          pr_cdhistor => 2765, 
                                                          pr_vllanmto => NVL(vlr_diff,0), 
                                                          pr_cdbandoc => 0, 
                                                          pr_nrdctabb => 0, 
                                                          pr_nrcnvcob => 0, 
                                                          pr_nrdocmto => 0, 
                                                          pr_nrtitulo => 0, 
                                                          pr_dscritic => vr_dscritic);
                   IF vr_dscritic IS NOT NULL THEN

                      vr_dscritic := 'Erro ao fazer lancamento(pc_inserir_lancamento_bordero) - cdhistor 2765. ' || vr_dscritic || SQLERRM;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                    ,pr_des_text => rw_lanctos.cdcooper || ';' || 
                                                                    rw_lanctos.nrdconta || ';' ||
                                                                    rw_lanctos.nrborder || ';' ||
                                                                    vlr_diff || ';' ||
                                                                    vr_dscritic);
                   ELSE 

                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                   ,pr_des_text => 'DELETE tbdsct_lancamento_bordero'
                                                                 ||' WHERE cdcooper = '||rw_lanctos.cdcooper
                                                                 ||'   AND nrdconta = '||rw_lanctos.nrdconta
                                                                 ||'   AND nrborder = '||rw_lanctos.nrborder
                                                                 ||'   AND nrtitulo = 0'
                                                                 ||'   AND nrdocmto = 0'
                                                                 ||'   AND cdhistor = 2765' ||';');  
                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                   ,pr_des_text => 'COMMIT;');
                                                   

                     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_contab
                                                   ,pr_des_text => rw_lanctos.cdcooper || ';' || 
                                                                   rw_lanctos.nrdconta || ';' || 
                                                                   rw_lanctos.nrborder||  ';' || 
                                                                   '2765' || ';' || 
                                                                   rw_crapbdt.nmpasite);
                   END IF;
                
                   
                   FOR rw_prejuizos IN cr_prejuizos(pr_cdcooper => rw_lanctos.cdcooper,
                                                    pr_nrdconta => rw_lanctos.nrdconta,
                                                    pr_nrborder => rw_lanctos.nrborder) LOOP
                                                    
                       vl_aux_preju := rw_prejuizos.vlsdprej;

                        BEGIN
                          UPDATE craptdb
                             SET vlsdprej = rw_prejuizos.vlprejtotal
                           WHERE cdcooper = rw_prejuizos.cdcooper
                             AND nrdconta = rw_prejuizos.nrdconta
                             AND nrborder = rw_prejuizos.nrborder
                             AND nrdocmto = rw_prejuizos.nrdocmto
                             AND nrtitulo = rw_prejuizos.nrtitulo; 
                             
                            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                         ,pr_des_text => 'UPDATE craptdb SET vlsdprej = '|| REPLACE(vl_aux_preju, ',','.')
                                                                       ||' WHERE cdcooper = '||rw_prejuizos.cdcooper
                                                                       ||'   AND nrdconta = '||rw_prejuizos.nrdconta
                                                                       ||'   AND nrborder = '||rw_prejuizos.nrborder
                                                                       ||'   AND nrdocmto = '||rw_prejuizos.nrdocmto
                                                                       ||'   AND nrtitulo = '||rw_prejuizos.nrtitulo || ';');    
                           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                         ,pr_des_text => 'COMMIT;');
                       EXCEPTION
                          WHEN OTHERS THEN

                          vr_dscritic := 'Erro ao gravar registro na tabela craptdb. ' || SQLERRM;
                          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                        ,pr_des_text => rw_prejuizos.cdcooper || ';' || 
                                                                        rw_prejuizos.nrdconta || ';' ||
                                                                        rw_prejuizos.nrborder || ';' ||
                                                                        rw_prejuizos.nrdocmto || ';' ||
                                                                        rw_prejuizos.nrtitulo || ';' ||
                                                                        vlr_diff || ';' ||
                                                                        vr_dscritic);
                       END;                              

                   END LOOP; 
                                    
               END IF;
               CLOSE cr_crapbdt;  
             END IF;
                 
          END IF ;
       COMMIT;     
       END LOOP;                                          
    END pc_diferenca_contabil;    

BEGIN

    IF vr_aux_ambiente = 1 THEN      
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';  
      vr_nmarq_contab   := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOGCONTABILIDADE.txt';       
    ELSIF vr_aux_ambiente = 2 THEN      
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
      vr_nmarq_contab   := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOGCONTABILIDADE.txt';  
 ELSIF vr_aux_ambiente = 3 THEN 
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
      vr_nmarq_contab   := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOGCONTABILIDADE.txt';  
    ELSE
      vr_dscritic := 'Erro ao apontar ambiente de execucao.';
      RAISE vr_exc_erro;
    END IF;

      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle_log   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if;

      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if; 

      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_contab
                              ,pr_tipabert => 'W'              
                              ,pr_utlfileh => vr_handle_contab   
                              ,pr_des_erro => vr_des_erro);
      if vr_des_erro is not null then
        vr_dscritic := 'Erro ao abrir arquivo da contabilidade: ' || vr_des_erro;
        RAISE vr_exc_erro;
      end if; 

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Inicio da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Cooperativa;Conta;Bordero;Diferenca;prejuizo');  
                                                                        
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_contab
                                    ,pr_des_text => 'Cooperativa;Conta;Bordero;Historico;PA');                                      

    vr_aux_arrcoop := gene0002.fn_quebra_string(vr_aux_cdcoop,'|');
    FOR vr_indexcoop IN 1..vr_aux_arrcoop.COUNT LOOP
      
        vr_aux_arrtemdiff := gene0002.fn_quebra_string(vr_aux_arrcoop(vr_indexcoop),';');
        
        IF vr_aux_arrtemdiff(2) = 1 THEN 

           pc_diferenca_contabil(pr_cdcooper     => vr_aux_arrtemdiff(1)   
                                ,pr_dtrefere     => to_date('31/01/2022', 'dd/mm/RRRR')  
                                ,pr_dtmvtolt_ini => to_date('01/01/2022', 'dd/mm/RRRR')
                                ,pr_dtmvtolt_fim => to_date('31/01/2022', 'dd/mm/RRRR'));
        END IF;
            
        IF vr_aux_arrtemdiff(3) = 1 THEN 
           
           pc_diferenca_contabil(pr_cdcooper     => vr_aux_arrtemdiff(1)  
                                ,pr_dtrefere     => to_date('28/02/2022', 'dd/mm/RRRR') 
                                ,pr_dtmvtolt_ini => to_date('01/02/2022', 'dd/mm/RRRR')  
                                ,pr_dtmvtolt_fim => to_date('28/02/2022', 'dd/mm/RRRR'));
        END IF;
           
    END LOOP;

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);          
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log); 
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_contab);                 

EXCEPTION  
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
