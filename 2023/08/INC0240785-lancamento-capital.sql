 DECLARE 
        vr_exc_erro      EXCEPTION;
        vr_nrseqdig_lot  craplot.nrseqdig%TYPE;
        vr_busca         VARCHAR2(100);
        vr_nrdocmto      craplct.nrdocmto%TYPE;
        vr_nrdolote      craplot.nrdolote%TYPE;
        pr_cdcooper      craplct.cdcooper%TYPE := 14;
        pr_nrdconta      craplct.nrdconta%TYPE := 61930;
        pr_vllanmto      craplct.vllanmto%TYPE := 55.47;
        pr_dtmvtolt      craplct.dtmvtolt%TYPE := to_date(SYSDATE,'dd/mm/yyyy');
        pr_dscritic      VARCHAR2(4000);
        vr_cdprograma    VARCHAR2(15) := 'INC0240785';
        vr_idprglog      tbgen_prglog.idprglog%TYPE := 0;
        vr_saldo_capital crapcot.vldcotas%TYPE;
       
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
          pr_dscritic := 'Associado nao encontrado - ' || pr_cdcooper || ' Conta: ' || pr_nrdconta;
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
                    
    SELECT SUM(DECODE(his.indebcre, 'D', -1, 1) * lct.vllanmto)
      INTO vr_saldo_capital   
      FROM cecred.craplct lct, cecred.craphis his
     WHERE lct.cdcooper = his.cdcooper
      AND lct.cdhistor = his.cdhistor
      AND lct.cdcooper = pr_cdcooper
      AND lct.nrdconta = pr_nrdconta;          
   
    UPDATE cecred.crapcot a
       SET a.vldcotas = vr_saldo_capital
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta;                  
     COMMIT;      
      EXCEPTION
     WHEN OTHERS THEN
    pr_dscritic := pr_dscritic || sqlerrm;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 111
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);    
    ROLLBACK;        
    END;
