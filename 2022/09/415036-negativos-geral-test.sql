DECLARE
   vr_excsaida     EXCEPTION;
   vr_cdcritic     crapcri.cdcritic%TYPE;
   vr_dscritic     VARCHAR2(5000) := ' ';
   vr_nrseqdig     NUMBER := 0;
   vr_tab_retorno  LANC0001.typ_reg_retorno;
   vr_incrineg     INTEGER;
   vr_dslog        VARCHAR2(4000) := '';
   vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;
  vr_vllanmto      NUMBER;
   rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

   CURSOR cr_craprda IS
     SELECT rda.cdcooper, 
            rda.nrdconta, 
            rda.nraplica, 
            rda.vlsdrdca,
            rda.cdagenci, 
            rda.vlsltxmx,
            rda.vlsltxmm
       FROM cecred.craplap lap, cecred.craprda rda
      WHERE lap.cdcooper = rda.cdcooper
        AND lap.nrdconta = rda.nrdconta
        AND lap.nraplica = rda.nraplica
        AND lap.dtmvtolt = to_date('01/06/2022','dd/mm/yyyy')
        AND lap.cdhistor = 529
        AND rda.insaqtot = 1
        AND rda.vlsdrdca < 0
      GROUP BY rda.cdcooper, rda.nrdconta, rda.nraplica, rda.vlsdrdca, rda.cdagenci,rda.vlsltxmx,rda.vlsltxmm;
    rw_craprda cr_craprda%ROWTYPE;     
    
    CURSOR cr_craplap (pr_cdcooper NUMBER
                      ,pr_nrdconta NUMBER
                      ,pr_nraplica NUMBER) IS
    SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lap.vllanmto) vllanmto
      FROM cecred.craplap lap, cecred.craphis his
     WHERE lap.cdcooper = his.cdcooper
       AND lap.CDHISTOR = his.CDHISTOR
       AND lap.cdcooper = pr_cdcooper
       AND lap.nrdconta = pr_nrdconta
       AND lap.nraplica = pr_nraplica; 
     rw_craplap cr_craplap%ROWTYPE;     

BEGIN

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 13);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND THEN        
    CLOSE btch0001.cr_crapdat;       
    RAISE vr_excsaida;
  ELSE      
    CLOSE btch0001.cr_crapdat;
  END IF;
      
  FOR rw_craprda in cr_craprda LOOP 
    vr_nrseqdig := vr_nrseqdig + 1;

    vr_dslog := 'UPDATE cecred.crarda SET vlsltxmx = '|| REPLACE(rw_craprda.vlsltxmx,',','.') ||
                                       ', vlsltxmm = '|| REPLACE(rw_craprda.vlsltxmm,',','.') || 
                                       ', vlsdrdca = '|| REPLACE(rw_craprda.vlsdrdca,',','.') ||                               
                ' WHERE CDCOOPER = '||rw_craprda.cdcooper ||
                  ' AND NRDCONTA = '||rw_craprda.nrdconta||
                  ' AND NRAPLICA = '||rw_craprda.nraplica||';';

     CECRED.pc_log_programa(pr_dstiplog      => 'O'
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 444
                           ,pr_cdprograma    => 'INC020985_TOTAL_INVEST'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
    
   OPEN cr_craplap(rw_craprda.cdcooper
                  ,rw_craprda.nrdconta
                  ,rw_craprda.nraplica);
          FETCH cr_craplap INTO rw_craplap;

  vr_vllanmto := NVL(rw_craplap.vllanmto,0);
  CLOSE cr_craplap; 
  vr_dslog := rw_craprda.cdcooper || ';'||rw_craprda.nrdconta||';'||rw_craprda.nraplica||';'|| vr_vllanmto ||';'|| rw_craprda.cdagenci || '; ';

  CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                        ,pr_tpocorrencia  => 4 
                        ,pr_cdcriticidade => 0 
                        ,pr_tpexecucao    => 3 
                        ,pr_dsmensagem    => vr_dslog
                        ,pr_cdmensagem    => 123
                        ,pr_cdprograma    => 'INC020985_TOTAL_INVEST'
                        ,pr_cdcooper      => 3 
                        ,pr_idprglog      => vr_idprglog); 
  IF vr_vllanmto > 0 THEN                  
    BEGIN    
      INSERT INTO cecred.craplap(cdcooper
                         ,dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,nrdconta
                         ,nraplica
                         ,nrdocmto
                         ,txaplica
                         ,txaplmes
                         ,cdhistor
                         ,nrseqdig
                         ,vllanmto
                         ,dtrefere
                         ,vlrendmm)
            VALUES(rw_craprda.cdcooper
                  ,rw_crapdat.dtmvtolt
                  ,rw_craprda.cdagenci
                  ,100
                  ,321999 
                  ,rw_craprda.nrdconta
                  ,rw_craprda.nraplica
                  ,rw_craprda.nraplica + 555000
                  ,0
                  ,0
                  ,531
                  , vr_nrseqdig
                  ,vr_vllanmto
                  ,rw_crapdat.dtmvtolt
                  ,0) ;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir craplap. Detalhes: '||sqlerrm;
          RAISE vr_excsaida;
    END;
  END IF;
  BEGIN 
    UPDATE cecred.craprda a
       SET a.vlsltxmx = 0
         , a.vlsltxmm = 0
         , a.vlsdrdca = 0
     WHERE a.cdcooper = rw_craprda.cdcooper
       AND a.nrdconta = rw_craprda.nrdconta
       AND a.nraplica = rw_craprda.nraplica;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar craprda. Detalhes: '||sqlerrm;
        RAISE vr_excsaida;
  END;     
      

  END LOOP;

 COMMIT;

  EXCEPTION 
     WHEN vr_excsaida then  
     CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 888
                           ,pr_cdprograma    => 'INC020985_TOTAL_INVEST'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);   
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
     CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dscritic
                           ,pr_cdmensagem    => 999
                           ,pr_cdprograma    => 'INC020985_TOTAL_INVEST'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
         ROLLBACK; 

END;
