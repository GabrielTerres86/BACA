DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';
   vr_nraplica             craprac.nraplica%TYPE;     
   vr_dtcalcul_considerado crapdat.dtmvtolt%TYPE;
   vr_negativo             BOOLEAN;
   vr_lancamento           NUMBER;
   vr_vencimento           NUMBER;
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
   vr_vlaplica NUMBER := 0;
   vr_cdmensagem NUMBER :=0;
   vr_nrseqdig   NUMBER := 0;
   vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
   vr_split  gene0002.typ_split;
   vr_dslog VARCHAR2(4000) := '';
   vr_dtinical DATE;

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
        FROM cecred.crapcpc cpc
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
            rac.cdprodut,
            rac.idsaqtot,
            rac.dtvencto,
            rac.rowid,
            cpc.cdhsvrcc,
            ass.cdagenci
       FROM cecred.craprac rac,
            cecred.crapcpc cpc,
            cecred.crapass ass
      WHERE rac.cdcooper = ass.cdcooper
        AND rac.nrdconta = ass.nrdconta
        AND rac.cdprodut = cpc.cdprodut              
        AND rac.cdprodut = 1057
        AND rac.idsaqtot in (0,2)
        AND rac.dtmvtolt < to_date('01/07/2022','dd/mm/yyyy')
         AND rac.dtaniver in (to_date('09/08/2022','dd/mm/yyyy'),
                              to_date('10/08/2022','dd/mm/yyyy'),
                              to_date('11/08/2022','dd/mm/yyyy'));
         
       
        rw_craprac cr_craprac%ROWTYPE;        

   CURSOR cr_saldoapp (pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_nraplica NUMBER
                     ,pr_dtmvtini DATE
                     ,pr_dtmvtfim DATE) IS
   SELECT nvl(SUM(decode(his.indebcre,
                          'C',
                          lac.vllanmto,
                          lac.vllanmto * -1)),
               0) saldo
    FROM cecred.craplac lac,
         cecred.craphis his
   WHERE lac.cdcooper = his.cdcooper
     AND lac.cdhistor = his.cdhistor
     AND lac.cdcooper = pr_cdcooper
     AND lac.nrdconta = pr_nrdconta
     AND lac.nraplica = pr_nraplica
     AND lac.dtmvtolt >= pr_dtmvtini 
     AND lac.dtmvtolt <  pr_dtmvtfim;  
     rw_saldoapp cr_saldoapp%ROWTYPE;        
    
  CURSOR cr_provisao (pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_nraplica NUMBER) IS  
   SELECT nvl(SUM(lac.vllanmto),0) vllanmto
     FROM cecred.craplac lac, 
          cecred.craprac rac
    WHERE lac.cdcooper = rac.cdcooper
      AND lac.nrdconta = rac.nrdconta
      AND lac.nraplica = rac.nraplica
      AND lac.cdcooper = pr_cdcooper
      AND lac.nrdconta = pr_nrdconta
      AND lac.nraplica = pr_nraplica
      AND lac.cdhistor  = 3328
      AND lac.dtmvtolt = gene0005.fn_valida_dia_util(pr_cdcooper => rac.cdcooper
                                                    ,pr_dtmvtolt => add_months(rac.dtaniver,-1)
                                                    ,pr_tipo     => 'P'  );    
     rw_provisao cr_provisao%ROWTYPE;                                                         

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
                                        ,pr_vencimento IN NUMBER              
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
        cecred.APLI0010.pc_processa_lote_aniv(pr_cdcooper => pr_cdcooper
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
       
        IF pr_vencimento = 1 THEN
            cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => pr_dtmvtolt
                                                     ,pr_cdagenci => 1 
                                                     ,pr_cdbccxlt => 100 
                                                     ,pr_nrdolote => 8599
                                                     ,pr_nrdconta => pr_nrdconta
                                                     ,pr_nrdctabb => pr_nrdconta
                                                     ,pr_nrdocmto => pr_nraplica
                                                     ,pr_nrseqdig => vr_nrseqdig
                                                     ,pr_dtrefere => pr_dtmvtolt
                                                     ,pr_vllanmto => pr_vllanmto
                                                     ,pr_cdhistor => 362
                                                     ,pr_nraplica => pr_nraplica       
                                                     ,pr_tab_retorno => vr_tab_retorno
                                                     ,pr_incrineg => vr_incrineg
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;                                         
        
        ELSIF pr_vencimento = 0 THEN
          BEGIN
            INSERT INTO cecred.craplac(cdcooper
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
            UPDATE cecred.craprac 
               SET vlsldatl = vlsldatl + vr_vllanmto
                  ,dtatlsld = pr_dtmvtolt
                  ,vlsldant = vr_vlsldant
                  ,dtsldant = vr_dtsldant
             WHERE craprac.rowid = pr_rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar aplica��o(craprac). Detalhes: '||SQLERRM;
          RAISE vr_exc_saida;
          END;
        END IF;
      END IF;
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

   OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 3);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      IF btch0001.cr_crapdat%NOTFOUND THEN        
        CLOSE btch0001.cr_crapdat;       
        RAISE vr_excsaida;
      ELSE      
        CLOSE btch0001.cr_crapdat;
      END IF;
  UPDATE cecred.craptxi 
     SET dtcadast = to_date('09/07/2022','dd/mm/yyyy')
   WHERE cddindex = 5
     AND dtiniper = to_date('01/06/2022','dd/mm/yyyy');  
     
  UPDATE cecred.craprac
   SET dtaniver = to_date('10/08/2022','dd/mm/yyyy')
 WHERE cdcooper = 9
   AND nrdconta = 204129
   AND  nraplica = 38;   
      
  FOR rw_craprac in cr_craprac LOOP 
    vr_vlultren := 0;
    vr_vlsldtot := 0;
    vr_vlsldrgt := 0;
    vr_vlrentot := 0;
    vr_vlrevers := 0;
    vr_vlrdirrf := 0;
    vr_percirrf := 0;
    vr_vlaplica := 0;
    vr_cdmensagem := 0;
    vr_lancamento := 0;
    vr_vencimento :=0;
    
    IF rw_craprac.idsaqtot = 2 THEN
      IF rw_craprac.dtvencto = add_months(rw_craprac.dtaniver,-1) THEN
        vr_vencimento := 1;
      ELSE
        CONTINUE;
      END IF;
    END IF;
     vr_dslog := 'UPDATE cecred.CRAPRAC SET vlsldatl = '|| REPLACE(rw_craprac.vlsldatl,',','.') ||
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
                           ,pr_cdmensagem    => 444
                           ,pr_cdprograma    => 'INC0192572_IPCA22'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
                                  

      OPEN cr_saldoapp(rw_craprac.cdcooper
                      ,rw_craprac.nrdconta
                      ,rw_craprac.nraplica
                      ,rw_craprac.dtmvtolt
                      ,add_months(rw_craprac.dtaniver,-1));
          FETCH cr_saldoapp INTO rw_saldoapp;

       vr_vlaplica := rw_saldoapp.saldo;
       vr_cdmensagem := 1;
       CLOSE cr_saldoapp; 

     vr_vlbascal := rw_craprac.vlaplica;
     vr_dtinical := to_date(EXTRACT(DAY FROM rw_craprac.dtmvtolt) || '/06/2022','dd/mm/yyyy');

            cecred.APLI0006.pc_posicao_saldo_aplicacao_ani(pr_cdcooper => rw_craprac.cdcooper,
                                                    pr_nrdconta => rw_craprac.nrdconta,
                                                    pr_nraplica => rw_craprac.nraplica,
                                                    pr_dtiniapl => rw_craprac.dtmvtolt,
                                                    pr_dtatlsld => vr_dtinical,
                                                    pr_vlaplica => vr_vlaplica,
                                                    pr_txaplica => rw_craprac.txaplica,
                                                    pr_idtxfixa => vidtxfixa,
                                                    pr_cddindex => vcddindex,
                                                    pr_qtdiacar => rw_craprac.qtdiacar,
                                                    pr_idgravir => vr_idgravir,
                                                    pr_cdprodut => rw_craprac.cdprodut,
                                                    pr_dtfimcal => add_months(rw_craprac.dtaniver,-1),
                                                    pr_idtipbas => vr_idtipbas,
                                                    pr_flgcaren => 2,
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
              vr_dslog := 'Erro pc_posicao_saldo_aplicacao_ani. ' || vr_dscritic;
            RAISE vr_excsaida;
         END IF;                 

      vr_negativo := false;
      
      vr_cdhistor := rw_crapcpc.cdhsprap;
      
      IF vr_vlultren > 0 THEN

        OPEN cr_provisao(rw_craprac.cdcooper
                        ,rw_craprac.nrdconta
                        ,rw_craprac.nraplica);
        FETCH cr_provisao INTO rw_provisao;
        
        vr_lancamento := vr_vlultren - rw_provisao.vllanmto;
        
        IF vr_lancamento <= 0 THEN
          CLOSE cr_provisao;
          CONTINUE;               
        ELSE
          CLOSE cr_provisao;        
        END IF;

        vr_dslog := rw_craprac.cdcooper || ';'||rw_craprac.nrdconta||';'||rw_craprac.nraplica||';'|| vr_lancamento ||';'|| rw_craprac.cdagenci || '; ';

        CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                              ,pr_tpocorrencia  => 4 
                              ,pr_cdcriticidade => 0 
                              ,pr_tpexecucao    => 3 
                              ,pr_dsmensagem    => vr_dslog
                              ,pr_cdmensagem    => 123 || vr_vencimento
                              ,pr_cdprograma    => 'INC0192572_IPCA22'
                              ,pr_cdcooper      => 3 
                              ,pr_idprglog      => vr_idprglog); 
       
        pc_credita_aniversario_lctos(pr_cdcooper => rw_craprac.cdcooper,
                                     pr_nrdconta => rw_craprac.nrdconta,
                                     pr_nraplica => rw_craprac.nraplica,
                                     pr_dtaplica => rw_craprac.dtmvtolt,
                                     pr_dtaniver => rw_craprac.dtaniver,
                                     pr_cdhistor => 3328,
                                     pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                     pr_vllanmto => vr_lancamento,
                                     pr_dtatlsld => rw_craprac.dtatlsld,
                                     pr_vlsldatl => rw_craprac.vlsldatl,
                                     pr_dtsldant => rw_craprac.dtsldant,
                                     pr_vlsldant => rw_craprac.vlsldant,
                                     pr_rowid    => rw_craprac.rowid,
                                     pr_negativo => vr_negativo,
                                     pr_vencimento => vr_vencimento,
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
                           ,pr_cdmensagem    => 888
                           ,pr_cdprograma    => 'INC0192572_IPCA_ERRO'
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
                           ,pr_cdmensagem    => 999
                           ,pr_cdprograma    => 'INC0192572_IPCA_ERRO'
                           ,pr_cdcooper      => 3 
                           ,pr_idprglog      => vr_idprglog);
         ROLLBACK; 

END;