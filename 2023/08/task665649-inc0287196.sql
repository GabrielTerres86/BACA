DECLARE
  vr_cdprograma VARCHAR2(15) := 'INC0287196';
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic VARCHAR2(4000);
  vr_dslog VARCHAR2(4000) := ''; 
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
  vr_exc_saida  EXCEPTION;
  pr_dscritic   VARCHAR2(4000);
  vr_vllanmto   craplct.vllanmto%TYPE;

  CURSOR cr_crapcot(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT cot.nrdconta
          ,cot.vldcotas
      FROM cecred.crapcot cot
     WHERE cot.cdcooper = pr_cdcooper
       AND cot.nrdconta = pr_nrdconta;
    rw_crapcot cr_crapcot%ROWTYPE;

  CURSOR cr_crapcot_base IS
    SELECT lct.cdcooper,lct.nrdconta,SUM(decode(his.indebcre, 'D', -1, 1) * lct.vllanmto) vllanmto
      FROM craplct lct, craphis his
     WHERE lct.cdcooper = his.cdcooper
       AND lct.cdhistor = his.cdhistor
       AND lct.cdcooper = 11
       AND lct.nrdconta in (14162733,14442698,14575566,14789930)
   GROUP BY  lct.cdcooper,lct.nrdconta;
    rw_crapcot_base cr_crapcot_base%ROWTYPE;

    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
  PROCEDURE lancamento_craplct (pr_cdcooper IN  craplct.cdcooper%TYPE 
                               ,pr_nrdconta IN  craplct.nrdconta%TYPE  
                               ,pr_vllanmto IN  craplct.vllanmto%TYPE 
                               ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
    BEGIN
      DECLARE 
        vr_exc_erro     EXCEPTION;
        vr_nrseqdig_lot craplot.nrseqdig%TYPE;
        vr_busca        VARCHAR2(100);
        vr_nrdocmto     craplct.nrdocmto%TYPE;
        vr_nrdolote     craplot.nrdolote%TYPE;
       
        CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
          SELECT ass.nrdconta
                ,ass.cdagenci
            FROM cecred.crapass ass
           WHERE ass.cdcooper = pr_cdcooper
             AND ass.nrdconta = pr_nrdconta;
          rw_crapass cr_crapass%ROWTYPE;

      BEGIN  
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper, 
                        pr_nrdconta => pr_nrdconta);

        FETCH cr_crapass
        INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Associado nao encontrado - ' || pr_cdcooper || ' Conta: ' || pr_nrdconta;
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;
        
        vr_nrdolote := 900039;
        vr_busca := TRIM(to_char(pr_cdcooper)) || ';' || TRIM(to_char(pr_dtmvtolt, 'DD/MM/RRRR')) || ';' ||
                    TRIM(to_char(rw_crapass.cdagenci)) || ';' || '100;' || vr_nrdolote || ';' ||
                    TRIM(to_char(pr_nrdconta));

        vr_nrdocmto := fn_sequence('CRAPLCT', 'NRDOCMTO', vr_busca);
        vr_nrseqdig_lot := fn_sequence('CRAPLOT',
                                       'NRSEQDIG',
                                      '' || pr_cdcooper || ';' || to_char(pr_dtmvtolt, 'DD/MM/RRRR') || ';' ||
                                      rw_crapass.cdagenci || ';100;' || vr_nrdolote);
                               
        INSERT INTO cecred.craplct
                    (cdcooper
                    ,cdagenci
                    ,cdbccxlt
                    ,nrdolote
                    ,dtmvtolt
                    ,cdhistor
                    ,nrctrpla
                    ,nrdconta
                    ,nrdocmto
                    ,nrseqdig
                    ,vllanmto)
              VALUES
                    (pr_cdcooper
                    ,rw_crapass.cdagenci
                    ,100
                    ,vr_nrdolote
                    ,pr_dtmvtolt
                    ,61
                    ,pr_nrdconta
                    ,pr_nrdconta
                    ,vr_nrdocmto
                    ,vr_nrseqdig_lot
                    ,pr_vllanmto);
      
      EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := 999;
        pr_dscritic := vr_dscritic;
             
      WHEN OTHERS THEN                 
        pr_cdcritic := 999;
        pr_dscritic := 'Erro no lancamento craplct --> '|| SQLERRM;      
    END;
  END lancamento_craplct;
    
BEGIN

  CECRED.pc_log_programa(pr_dstiplog   => 'O'
                        ,pr_dsmensagem => 'Inicio da execucao'
                        ,pr_cdmensagem => 111
                        ,pr_cdprograma => vr_cdprograma
                        ,pr_cdcooper   => 3 
                        ,pr_idprglog   => vr_idprglog);                                        
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat
  INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE btch0001.cr_crapdat;
    pr_dscritic := 'Data nao encontrada';
    RAISE vr_exc_saida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;
      
  FOR rw_crapcot_base IN cr_crapcot_base LOOP
    vr_vllanmto := 0;
    OPEN cr_crapcot(pr_cdcooper => rw_crapcot_base.cdcooper, 
                    pr_nrdconta => rw_crapcot_base.nrdconta);

    FETCH cr_crapcot
    INTO rw_crapcot;

    IF cr_crapcot%NOTFOUND THEN
      CLOSE cr_crapcot;
      pr_dscritic := 'Associado nao encontrado na crapcot- ' || rw_crapcot_base.cdcooper || ' Conta: ' || rw_crapcot_base.nrdconta;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcot;  
    vr_dslog := 'UPDATE cecred.crapcot SET vldcotas = '|| rw_crapcot.vldcotas ||' WHERE cdcooper = '|| rw_crapcot_base.cdcooper || ' and nrdconta = ' || rw_crapcot_base.nrdconta;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 222
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);
    IF rw_crapcot_base.vllanmto <> rw_crapcot.vldcotas THEN
      IF  rw_crapcot_base.vllanmto < 0 THEN 
        vr_vllanmto := (rw_crapcot_base.vllanmto * -1) + 1;
        lancamento_craplct (pr_cdcooper => rw_crapcot_base.cdcooper
                           ,pr_nrdconta => rw_crapcot_base.nrdconta
                           ,pr_vllanmto => vr_vllanmto
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic > 0 THEN
          pr_dscritic := vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;
    
   
      UPDATE cecred.crapcot a
         SET a.vldcotas = rw_crapcot_base.vllanmto + vr_vllanmto
       WHERE a.cdcooper = rw_crapcot_base.cdcooper
         AND a.nrdconta = rw_crapcot_base.nrdconta;
    ELSE  
      vr_dslog := 'Valores iguais';
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 333
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);
    
    END IF;
   
  END LOOP;
  COMMIT;
EXCEPTION 
  WHEN vr_exc_saida THEN  
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 444
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);                             
    ROLLBACK;    
  WHEN OTHERS THEN
    pr_dscritic :=  sqlerrm;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 555
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);    
    ROLLBACK;  
END;    
