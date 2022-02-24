
DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';
   vr_nraplica             craprac.nraplica%TYPE;     
   vr_dtcalcul_considerado crapdat.dtmvtolt%TYPE;
   vr_negativo             BOOLEAN;
   vr_exc_erro             EXCEPTION;
   vr_cdhistor             craphis.cdhistor%TYPE; 
   vr_nrdocmto             craplci.nrdocmto%TYPE;
   vr_tab_retorno          LANC0001.typ_reg_retorno;
   vr_incrineg             INTEGER;
   vidtxfixa               NUMBER;
   vcddindex               NUMBER;
   
   
   vr_idtipbas NUMBER := 1;
   vr_idgravir NUMBER := 0;
   vr_vlbascal NUMBER := 0; 
   vr_vlsldtot NUMBER := 0;
   vr_vlsldrgt NUMBER := 0;
   vr_vlultren NUMBER := 0;
   vr_vlrentot NUMBER := 0;
   vr_vlrevers NUMBER := 0;
   vr_vlrdirrf NUMBER := 0;
   vr_percirrf NUMBER := 0;
   vr_vllanmto NUMBER := 0;
   vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
   
   vr_dslog VARCHAR2(4000) := '';
   
   CURSOR cr_crapcpc IS
      SELECT cdprodut
            ,cddindex
            ,nmprodut
            ,idsitpro
            ,idtippro
            ,idtxfixa
            ,idacumul
            ,cdhscacc
            ,cdhsvrcc
            ,cdhsraap
            ,cdhsnrap
            ,cdhsprap
            ,cdhsrvap
            ,cdhsrdap
            ,cdhsirap
            ,cdhsrgap
            ,cdhsvtap
        FROM crapcpc cpc
       WHERE cpc.cddindex = 5
         AND cpc.indanive = 1
         AND cpc.idsitpro = 1
         AND cpc.cdprodut = 1057;
   
         rw_crapcpc cr_crapcpc%ROWTYPE;      
   
   CURSOR cr_craprac IS
     SELECT rac.cdcooper, 
            rac.nrdconta, 
            rac.nraplica, 
            rac.dtaniver,
            rac.dtmvtolt,
            rac.txaplica,            
            rac.qtdiacar,
            rac.vlaplica,
            rac.vlsldatl,
            rac.dtatlsld,
            rac.dtsldant,
            rac.vlsldant,
            rac.rowid,
            cpc.cdhsvrcc
       FROM craprac rac,
            crapcpc cpc
      WHERE rac.cdprodut = cpc.cdprodut        
        AND rac.idsaqtot = 0
        AND rac.cdprodut = 1057
        AND NOT EXISTS (SELECT 1 FROM craplac l
                        WHERE l.cdcooper = rac.cdcooper
                          AND l.nrdconta = rac.nrdconta
                          AND l.nraplica = rac.nraplica
                          AND l.cdhistor = 3333)
        AND EXTRACT(DAY FROM rac.dtmvtolt) IN (27,28,29,30,31) 
        AND EXTRACT(YEAR FROM rac.dtmvtolt) = 2021;
   
        rw_craprac cr_craprac%ROWTYPE;
   
              
BEGIN
    
  FOR rw_crapcpc IN cr_crapcpc LOOP                        
      vidtxfixa := rw_crapcpc.idtxfixa;  
      vcddindex := rw_crapcpc.cddindex;  
  END LOOP;
   
  FOR rw_craprac in cr_craprac LOOP
   
     vr_dslog := 'UPDATE CRAPRAC SET vlsldatl = '|| REPLACE(rw_craprac.vlsldatl,',','.') ||
                                  ', dtatlsld = '''|| to_date(rw_craprac.dtatlsld,'dd/mm/yyyy') || ''' '|| 
                                  ', vlsldant = '|| REPLACE(rw_craprac.vlsldant,',','.') ||
                                  ', dtsldant = '''|| to_date(rw_craprac.dtsldant,'dd/mm/yyyy') ||''' '||  
                                  ', dtaniver = '''|| to_date(rw_craprac.dtaniver,'dd/mm/yyyy') ||''' '||  
           ' WHERE CDCOOPER = '||rw_craprac.cdcooper ||
             ' AND NRDCONTA = '||rw_craprac.nrdconta||
             ' AND NRAPLICA = '||rw_craprac.nraplica||';';
             
     CECRED.pc_log_programa(pr_dstiplog      => 'O'
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 0
                           ,pr_cdprograma    => 'INC0120884_IPCA'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);         
    
     vr_vlbascal := rw_craprac.vlaplica;
       
     APLI0006.pc_posicao_saldo_aplicacao_pos( pr_cdcooper => rw_craprac.cdcooper,
                                              pr_nrdconta => rw_craprac.nrdconta,
                                              pr_nraplica => rw_craprac.nraplica,
                                              pr_dtiniapl => rw_craprac.dtmvtolt,
                                              pr_txaplica => rw_craprac.txaplica,
                                              pr_idtxfixa => vidtxfixa,
                                              pr_cddindex => vcddindex,
                                              pr_qtdiacar => rw_craprac.qtdiacar,
                                              pr_idgravir => vr_idgravir,
                                              pr_flgcaren => 2,
                                              pr_idaplpgm => 0,
                                              pr_dtinical => rw_craprac.dtmvtolt,
                                              pr_dtfimcal => add_months(rw_craprac.dtaniver,-1),
                                              pr_idtipbas => vr_idtipbas,
                                              pr_incalliq => 0,
                                              
                                              pr_vlbascal => vr_vlbascal,                                                              
                                              pr_vlsldtot => vr_vlsldtot,
                                              pr_vlsldrgt => vr_vlsldrgt,
                                              pr_vlultren => vr_vlultren,
                                              pr_vlrentot => vr_vlrentot,
                                              pr_vlrevers => vr_vlrevers,
                                              pr_vlrdirrf => vr_vlrdirrf,
                                              pr_percirrf => vr_percirrf,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);    
       
     
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_dslog := 'Erro pc_posicao_saldo_aplicacao_pos. ' || vr_dscritic;
        RAISE vr_excsaida;
      END IF;
                
      vr_negativo := false;
      vr_cdhistor := rw_crapcpc.cdhsprap;
                
     
      IF vr_vlultren < 0 THEN
     
        vr_vlultren := vr_vlultren * -1;
        vr_cdhistor := rw_crapcpc.cdhsrvap;
        vr_negativo := true;
      END IF;
     
      vr_vllanmto := vr_vlsldtot - rw_craprac.vlsldatl; 
        
      IF vr_vllanmto >= 1 THEN
        
        vr_dslog := rw_craprac.cdcooper || ';'||rw_craprac.nrdconta||';'||rw_craprac.nraplica||';'|| vr_vllanmto || ' ';
         
        CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                              ,pr_tpocorrencia  => 4 
                              ,pr_cdcriticidade => 0 
                              ,pr_tpexecucao    => 3 
                              ,pr_dsmensagem    => vr_dslog
                              ,pr_cdmensagem    => 0
                              ,pr_cdprograma    => 'INC0120884_IPCA_LANC'
                              ,pr_cdcooper      => 3 
                              ,pr_idprglog      => vr_idprglog); 
                               
        apli0010.pc_credita_aniversario_lctos(pr_cdcooper => rw_craprac.cdcooper,
                                              pr_nrdconta => rw_craprac.nrdconta,
                                              pr_nraplica => rw_craprac.nraplica,
                                              pr_dtaplica => rw_craprac.dtmvtolt,
                                              pr_dtaniver => rw_craprac.dtaniver,
                                              pr_cdhistor => 3328,
                                              pr_dtmvtolt => trunc(SYSDATE),
                                              pr_vllanmto => vr_vllanmto,
                                              pr_dtatlsld => rw_craprac.dtatlsld,
                                              pr_vlsldatl => rw_craprac.vlsldatl,
                                              pr_dtsldant => rw_craprac.dtsldant,
                                              pr_vlsldant => rw_craprac.vlsldant,
                                              pr_rowid    => rw_craprac.rowid,
                                              pr_negativo => vr_negativo,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
                                                
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           vr_dslog := 'Erro pc_credita_aniversario_lctos. ' || vr_dscritic;
           RAISE vr_excsaida;
        END IF;
      END IF;
                                                                         
  END LOOP;
    
  COMMIT;
       
  EXCEPTION 
     WHEN vr_excsaida then  
         CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 0
                           ,pr_cdprograma    => 'INC0120884_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);   
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                           ,pr_tpocorrencia  => 4 
                           ,pr_cdcriticidade => 0 
                           ,pr_tpexecucao    => 3 
                           ,pr_dsmensagem    => vr_dslog || '. ' || vr_dscritic
                           ,pr_cdmensagem    => 0
                           ,pr_cdprograma    => 'INC0120884_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
         ROLLBACK; 

END;
