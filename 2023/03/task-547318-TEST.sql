DECLARE
  vr_exc_saida    EXCEPTION;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_incrineg     INTEGER;
  vr_cdcritic     crapcri.cdcritic%TYPE := 0;
  vr_dscritic     crapcri.dscritic%TYPE := NULL;  
  vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;
  vr_nrseqrgt     craprga.nrseqrgt%TYPE := 0;

  
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE    
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE    
                   ,pr_cdagenci IN craplot.cdagenci%TYPE    
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE    
                   ,pr_nrdolote IN craplot.nrdolote%TYPE    
                   ,pr_tplotmov IN craplot.tplotmov%TYPE) IS
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
        cecred.craplot lot
      WHERE
            lot.cdcooper = pr_cdcooper
        AND lot.dtmvtolt = pr_dtmvtolt
        AND lot.cdagenci = pr_cdagenci
        AND lot.cdbccxlt = pr_cdbccxlt
        AND lot.nrdolote = pr_nrdolote
        AND lot.tplotmov = pr_tplotmov;
      rw_craplot cr_craplot%ROWTYPE;
      rw_craplot_II cr_craplot%ROWTYPE;

  CURSOR cr_craprac IS
    select  16 cdcooper, 99812541 nrdconta, 26 nraplica,  0.78 vllanmto from dual union all
    select  1  cdcooper, 88511855 nrdconta,  5 nraplica, 58.82 vllanmto from dual union all
    select  1  cdcooper, 97424218 nrdconta,  4 nraplica, 16.40 vllanmto from dual union all    
    select  1  cdcooper, 92336310 nrdconta, 43 nraplica, 18.90 vllanmto from dual union all
    select  1  cdcooper, 93201982 nrdconta, 72 nraplica,  1.88 vllanmto from dual union all    
    select  1  cdcooper, 85594032 nrdconta, 11 nraplica,  0.70 vllanmto from dual union all        
    select  1  cdcooper, 86693905 nrdconta,  1 nraplica,  9.28 vllanmto from dual union all
    select  1  cdcooper, 87978199 nrdconta, 34 nraplica,  2.14 vllanmto from dual ;
    rw_craprac cr_craprac%ROWTYPE; 
        
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
BEGIN

  CECRED.pc_log_programa(pr_dstiplog      => 'O'
                        ,pr_tpocorrencia  => 4 
                        ,pr_cdcriticidade => 0 
                        ,pr_tpexecucao    => 3 
                        ,pr_dsmensagem    => 'Inicio da execucao'
                        ,pr_cdmensagem    => 111
                        ,pr_cdprograma    => 'INC0255463'
                        ,pr_cdcooper      => 3 
                        ,pr_idprglog      => vr_idprglog);                  
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat
  INTO rw_crapdat;


  IF btch0001.cr_crapdat%NOTFOUND THEN

    CLOSE btch0001.cr_crapdat;
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE

    CLOSE btch0001.cr_crapdat;
  END IF;
      
  FOR rw_craprac IN cr_craprac LOOP  
                 
    OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                   ,pr_cdagenci => 1          
                   ,pr_cdbccxlt => 100        
                   ,pr_nrdolote => 8502       
                   ,pr_tplotmov => 9);        

    FETCH cr_craplot INTO rw_craplot_II;

    IF cr_craplot%NOTFOUND THEN

      CLOSE cr_craplot;

      BEGIN

        INSERT INTO
           cecred.craplot(
           cdcooper
          ,dtmvtolt
          ,cdagenci
          ,cdbccxlt
          ,nrdolote
          ,tplotmov
          ,nrseqdig
          ,qtinfoln
          ,qtcompln
           )VALUES(
           rw_craprac.cdcooper
          ,rw_crapdat.dtmvtolt
          ,1
          ,100
          ,8502
          ,9
          ,0
          ,0
          ,0)
          RETURNING
            cdcooper, dtmvtolt, cdagenci, cdbccxlt,
            nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln, ROWID
          INTO
            rw_craplot_II.cdcooper, rw_craplot_II.dtmvtolt, rw_craplot_II.cdagenci,
            rw_craplot_II.cdbccxlt, rw_craplot_II.nrdolote, rw_craplot_II.tplotmov,
            rw_craplot_II.nrseqdig, rw_craplot_II.qtinfoln, rw_craplot_II.qtcompln, rw_craplot_II.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;          
        END;
    ELSE
      CLOSE cr_craplot;
    END IF;
                                   
    BEGIN

      UPDATE
        cecred.craplot
      SET
        craplot.nrseqdig = (NVL(craplot.nrseqdig,0) + 1)
       ,craplot.qtinfoln = (NVL(craplot.qtinfoln,0) + 1)
       ,craplot.qtcompln = (NVL(craplot.qtcompln,0) + 1)
       ,craplot.vlinfodb = (NVL(craplot.vlinfodb,0) + NVL(rw_craprac.vllanmto,0))
       ,craplot.vlcompdb = (NVL(craplot.vlcompdb,0) + NVL(rw_craprac.vllanmto,0))
      WHERE craplot.cdcooper = rw_craprac.cdcooper
        AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
        AND craplot.cdagenci = 1          
        AND craplot.cdbccxlt = 100        
        AND craplot.nrdolote = 8502       
        AND craplot.tplotmov = 9
      RETURNING
        nrseqdig, qtinfoln, qtcompln,
        vlinfodb, vlcompdb, ROWID
      INTO
        rw_craplot.nrseqdig, rw_craplot.qtinfoln, rw_craplot.qtcompln,
        rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.ROWID;

    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar lote de ' || '. Erro' || SQLERRM;
        RAISE vr_exc_saida;
    END;
      
    vr_nrseqrgt := CECRED.fn_sequence(pr_nmtabela => 'CRAPRGA'
                                     ,pr_nmdcampo => 'NRSEQRGT'
                                     ,pr_dsdchave => rw_craprac.cdcooper || ';' || rw_craprac.nrdconta || ';' || rw_craprac.nraplica
                                     ,pr_flgdecre => 'N');  
    BEGIN
      INSERT INTO
          cecred.craplac(
           cdcooper
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
          ,cdcanal
          ,cdoperad)
      VALUES(
           rw_craprac.cdcooper
          ,rw_crapdat.dtmvtolt
          ,1
          ,100
          ,8502
          ,rw_craprac.nrdconta
          ,rw_craprac.nraplica
          ,rw_craplot.nrseqdig
          ,rw_craplot.nrseqdig
          ,rw_craprac.vllanmto
          ,3528
          ,vr_nrseqrgt
          ,0
          ,0
          ,5
          ,1);

    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir registro de lancamento de aplicacao. Erro: ' || SQLERRM;        
        RAISE vr_exc_saida;
    END;
                                 
                                       
    cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => rw_craprac.cdcooper
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt                         
                                      ,pr_cdagenci    => 1
                                      ,pr_cdbccxlt    => 100
                                      ,pr_nrdolote    => 8599
                                      ,pr_nrdconta    => rw_craprac.nrdconta
                                      ,pr_nrdctabb    => rw_craprac.nrdconta
                                      ,pr_nrdocmto    => rw_craprac.nraplica
                                      ,pr_nrseqdig    => rw_craplot.nrseqdig
                                      ,pr_dtrefere    => rw_crapdat.dtmvtolt
                                      ,pr_vllanmto    => rw_craprac.vllanmto
                                      ,pr_cdhistor    => 3529 
                                      ,pr_nraplica    => rw_craprac.nraplica                        
                                      ,pr_tab_retorno => vr_tab_retorno
                                      ,pr_incrineg    => vr_incrineg
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN                
      vr_dscritic := 'Erro ao inserir registro de lancamento de credito. Erro: ' || SQLERRM;
      RAISE vr_exc_saida;
    END IF;                   
  
  END LOOP;
  
  COMMIT;
EXCEPTION 
  WHEN vr_exc_saida THEN  
    CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                          ,pr_tpocorrencia  => 4 
                          ,pr_cdcriticidade => 0 
                          ,pr_tpexecucao    => 3 
                          ,pr_dsmensagem    => vr_dscritic
                          ,pr_cdmensagem    => 888
                          ,pr_cdprograma    => 'INC0255463'
                          ,pr_cdcooper      => 13 
                          ,pr_idprglog      => vr_idprglog);   
    ROLLBACK;    
  WHEN OTHERS THEN
    vr_dscritic :=  sqlerrm;
    CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                          ,pr_tpocorrencia  => 4 
                          ,pr_cdcriticidade => 0 
                          ,pr_tpexecucao    => 3 
                          ,pr_dsmensagem    => vr_dscritic
                          ,pr_cdmensagem    => 999
                          ,pr_cdprograma    => 'INC0255463'
                          ,pr_cdcooper      => 13 
                          ,pr_idprglog      => vr_idprglog);
    ROLLBACK;  
END;
