
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
   pr_dtmvtolt_fim         DATE;
   
   
   vr_idtipbas NUMBER := 2;
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
   vr_split  gene0002.typ_split;
   vr_dslog VARCHAR2(4000) := '';
   
   rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
   
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
            rac.dtinical,
            rac.rowid,
            cpc.cdhsvrcc,
            ass.cdagenci
       FROM craprac rac,
            crapcpc cpc,
            crapass ass
      WHERE rac.cdcooper = ass.cdcooper
        AND rac.nrdconta = ass.nrdconta
        AND rac.cdprodut = cpc.cdprodut        
        AND rac.idsaqtot = 0
        AND rac.cdprodut = 1057
        AND rac.dtaniver in (to_date('12/05/2022','dd/mm/yyyy'),
                             to_date('13/05/2022','dd/mm/yyyy'),
                             to_date('19/05/2022','dd/mm/yyyy'),
                             to_date('20/05/2022','dd/mm/yyyy'),
                             to_date('26/05/2022','dd/mm/yyyy'),
                             to_date('27/05/2022','dd/mm/yyyy'));
        rw_craprac cr_craprac%ROWTYPE;
        
   CURSOR cr_resgate (pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_nraplica NUMBER
                     ,pr_dtmvtolt_ini DATE
                     ,pr_dtmvtolt_fim DATE) IS 
    SELECT 1 lanc FROM craplac l
     WHERE l.cdcooper = pr_cdcooper
       AND l.nrdconta = pr_nrdconta
       AND l.nraplica = pr_nraplica
       AND l.dtmvtolt BETWEEN pr_dtmvtolt_ini AND pr_dtmvtolt_fim
       AND l.cdhistor = 3333;
   rw_resgate cr_resgate%ROWTYPE;

     
PROCEDURE pc_credita_aniversario_lctos(pr_cdcooper IN craprac.cdcooper%TYPE 
                                        ,pr_nrdconta IN craprac.nrdconta%TYPE 
                                        ,pr_nraplica IN craprac.nraplica%TYPE 
                                        ,pr_dtaplica IN craprac.dtmvtolt%TYPE 
                                        ,pr_dtaniver IN craprac.dtaniver%TYPE 
                                        ,pr_cdhistor IN craphis.cdhistor%TYPE 
                                        ,pr_dtmvtolt IN craplac.dtmvtolt%TYPE 
                                        ,pr_vllanmto IN craplac.vllanmto%TYPE 
                                        ,pr_dtatlsld IN craprac.dtatlsld%TYPE 
                                        ,pr_vlsldatl IN craprac.vlsldatl%TYPE 
                                        ,pr_dtsldant IN craprac.dtsldant%TYPE 
                                        ,pr_vlsldant IN craprac.vlsldant%TYPE 
                                        ,pr_rowid    IN ROWID                 
                                        ,pr_negativo IN boolean               
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_nrseqdig craplot.nrseqdig%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_vlsldant craprac.vlsldant%TYPE;
      vr_dtsldant craprac.dtsldant%TYPE;
      vr_vllanmto craplac.vllanmto%TYPE;
      vr_new_dtaniver  craprac.dtaniver%TYPE;
      vr_dtaniver_util craprac.dtaniver%TYPE;
      vr_exc_saida EXCEPTION;
      
    BEGIN

      IF pr_vllanmto <> 0 THEN
        APLI0010.pc_processa_lote_aniv(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_cdagenci => 1
                                      ,pr_cdbccxlt => 100
                                      ,pr_nrdolote => 558506
                                      ,pr_cdoperad => '1'
                                      ,pr_vllanmto => case when pr_negativo then 0 else pr_vllanmto end
                                      ,pr_vllanneg => case when pr_negativo then pr_vllanmto else 0 end
                                      ,pr_nrseqdig => vr_nrseqdig
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Erro criando lote - ' || nvl(vr_dscritic,' ');
          RAISE vr_exc_saida;
        END IF;
      END IF;
      

      IF pr_vllanmto <> 0 THEN
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
                             ,cdhistor)
                       VALUES(pr_cdcooper
                             ,pr_dtmvtolt
                             ,1 
                             ,100 
                             ,558506 
                             ,pr_nrdconta
                             ,pr_nraplica
                             ,vr_nrseqdig
                             ,vr_nrseqdig
                             ,pr_vllanmto
                             ,pr_cdhistor);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir lancamentos(craplac). Detalhes: '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      END IF;
      
      
      IF pr_dtatlsld <> pr_dtmvtolt THEN
        
        vr_vlsldant := pr_vlsldatl;
        vr_dtsldant := pr_dtatlsld;
      ELSE 
        vr_vlsldant := pr_vlsldant;
        vr_dtsldant := pr_dtsldant;
      END IF;
    
      vr_vllanmto := pr_vllanmto;
      IF pr_negativo THEN
        vr_vllanmto := vr_vllanmto * -1;
      END IF;


      BEGIN
        UPDATE craprac SET vlsldatl = vlsldatl + vr_vllanmto
                          ,dtatlsld = pr_dtmvtolt

                          ,vlsldant = vr_vlsldant
                          ,dtsldant = vr_dtsldant

                     WHERE craprac.rowid = pr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
         pr_dscritic := nvl(vr_dscritic,' ') || 
                        ' - Cooper '|| pr_cdcooper || ' Conta ' || pr_nrdconta || ' Aplica ' || pr_nraplica;
      WHEN OTHERS THEN
         pr_dscritic := 'Erro nao especificado! APLI0010.pc_credita_aniversario_lctos ' ||
                        nvl(vr_dscritic,' ') || ' - Cooper '|| pr_cdcooper || ' Conta ' || pr_nrdconta || ' Aplica ' || pr_nraplica ||
                        SQLERRM;
    END;
  END pc_credita_aniversario_lctos;
                 
BEGIN
    
  FOR rw_crapcpc IN cr_crapcpc LOOP                        
      vidtxfixa := rw_crapcpc.idtxfixa;  
      vcddindex := rw_crapcpc.cddindex;  
  END LOOP;
  
   OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      
      IF btch0001.cr_crapdat%NOTFOUND THEN
        
        CLOSE btch0001.cr_crapdat;
       
        RAISE vr_excsaida;
      ELSE
      
        CLOSE btch0001.cr_crapdat;
      END IF;
  FOR rw_craprac in cr_craprac LOOP    
     
     OPEN cr_resgate(rw_craprac.cdcooper
                    ,rw_craprac.nrdconta
                    ,rw_craprac.nraplica
                    ,add_months(rw_craprac.dtaniver,-1) 
                    ,rw_crapdat.dtmvtolt);
       FETCH cr_resgate INTO rw_resgate;
     CLOSE cr_resgate;
     
     IF rw_resgate.lanc = 1 THEN
        vr_dslog := 'RESGATE: ' || rw_craprac.cdcooper || ';'||rw_craprac.nrdconta||';'||rw_craprac.nraplica||';';
         
        CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                              ,pr_tpocorrencia  => 4 
                              ,pr_cdcriticidade => 0 
                              ,pr_tpexecucao    => 3 
                              ,pr_dsmensagem    => vr_dslog
                              ,pr_cdmensagem    => 0
                              ,pr_cdprograma    => 'INC0136232_IPCA_RESG'
                              ,pr_cdcooper      => 3 
                              ,pr_idprglog      => vr_idprglog);  
        CONTINUE;    
     END IF; 
     
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
                           ,pr_cdprograma    => 'INC0136232_IPCA1'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);         
    
     vr_vlbascal := rw_craprac.vlaplica;
     
     BEGIN
        UPDATE craprac SET dtinical = to_date(EXTRACT(DAY FROM rw_craprac.dtmvtolt) || '/03/2022','dd/mm/yyyy')
                     WHERE craprac.rowid = rw_craprac.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||SQLERRM;
          RAISE vr_excsaida;
      END;
        
     apli0006.pc_posicao_saldo_aplicacao_pos( pr_cdcooper => rw_craprac.cdcooper,
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
                                              pr_dtinical => rw_craprac.dtinical,
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
     
      
        
      IF vr_vlultren > 0 THEN
        
        vr_dslog := rw_craprac.cdcooper || ';'||rw_craprac.nrdconta||';'||rw_craprac.nraplica||';'|| vr_vlultren ||';'|| rw_craprac.cdagenci || '; ';
         
        CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                              ,pr_tpocorrencia  => 4 
                              ,pr_cdcriticidade => 0 
                              ,pr_tpexecucao    => 3 
                              ,pr_dsmensagem    => vr_dslog
                              ,pr_cdmensagem    => 999
                              ,pr_cdprograma    => 'INC0136232_IPCA_LANC'
                              ,pr_cdcooper      => 3 
                              ,pr_idprglog      => vr_idprglog); 
                               
        pc_credita_aniversario_lctos(pr_cdcooper => rw_craprac.cdcooper,
                                     pr_nrdconta => rw_craprac.nrdconta,
                                     pr_nraplica => rw_craprac.nraplica,
                                     pr_dtaplica => rw_craprac.dtmvtolt,
                                     pr_dtaniver => rw_craprac.dtaniver,
                                     pr_cdhistor => 3328,
                                     pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                     pr_vllanmto => vr_vlultren,
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
      
      BEGIN
        UPDATE craprac SET dtinical = add_months(rw_craprac.dtaniver,-1)
                     WHERE craprac.rowid = rw_craprac.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar aplicação(craprac). Detalhes: '||SQLERRM;
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
                           ,pr_dsmensagem    => vr_dslog
                           ,pr_cdmensagem    => 0
                           ,pr_cdprograma    => 'INC0136232_IPCA_ERRO'
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
                           ,pr_cdprograma    => 'INC0136232_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
         ROLLBACK; 

END;
