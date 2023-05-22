DECLARE
  vr_cdprograma VARCHAR2(15) := 'DIF-COTAS';
  vr_cdcritic crapcri.cdcritic%TYPE := 0;
  vr_dscritic VARCHAR2(4000);
  vr_dslog VARCHAR2(4000) := ''; 
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
  vr_exc_saida  EXCEPTION;
  pr_dscritic   VARCHAR2(4000);

  CURSOR cr_crapcot(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapcot cr_crapcot%ROWTYPE;

  CURSOR cr_crapcot_base IS
    select  1 cdcooper, 80275540 nrdconta,    0.01 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 80114636 nrdconta,   -0.99 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 6792022  nrdconta,  187.56 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 6731902  nrdconta,    1.00 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 2388316  nrdconta,   20.00 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 6939830  nrdconta,    1.00 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 2544989  nrdconta,    1.00 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 6238947  nrdconta,    3.31 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 2790084  nrdconta,   43.83 vldcotas,   0.00 vllanmto from dual union all
    select  1 cdcooper, 3622738  nrdconta,    2.15 vldcotas,   0.00 vllanmto from dual union all
    select 11 cdcooper, 852929   nrdconta, -145.82 vldcotas,   0.00 vllanmto from dual union all
    select 11 cdcooper, 793868   nrdconta,  -69.18 vldcotas,   0.00 vllanmto from dual union all
    select  2 cdcooper, 539910   nrdconta,    1.77 vldcotas,   0.00 vllanmto from dual union all
    select 11 cdcooper, 866270   nrdconta,    0.00 vldcotas,  84.50 vllanmto from dual union all
    select 11 cdcooper, 13985779 nrdconta,  -47.63 vldcotas,   0.00 vllanmto from dual union all
    select 11 cdcooper, 872121   nrdconta,   -0.27 vldcotas,   0.00 vllanmto from dual union all
    select 11 cdcooper, 857823   nrdconta, -132.14 vldcotas,   0.00 vllanmto from dual union all
    select  2 cdcooper, 576611   nrdconta,    1.10 vldcotas,   0.00 vllanmto from dual union all
    select 12 cdcooper, 34274    nrdconta,   17.68 vldcotas,   0.00 vllanmto from dual union all
    select 11 cdcooper, 878120   nrdconta, -217.60 vldcotas,   0.00 vllanmto from dual union all
    select 11 cdcooper, 840920   nrdconta,    0.00 vldcotas, 278.50 vllanmto from dual union all
    select 11 cdcooper, 867152   nrdconta,    0.00 vldcotas, 224.57 vllanmto from dual ;
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
    vr_dslog := 'UPDATE cecred.crapcot SET vldcotas = '|| rw_crapcot_base.vldcotas ||' WHERE cdcooper = '|| rw_crapcot_base.cdcooper || ' and nrdconta = ' || rw_crapcot_base.nrdconta;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => vr_dslog
                          ,pr_cdmensagem    => 111
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);
    IF  rw_crapcot_base.vllanmto > 0 THEN 
      lancamento_craplct (pr_cdcooper => rw_crapcot_base.cdcooper
                         ,pr_nrdconta => rw_crapcot_base.nrdconta
                         ,pr_vllanmto => rw_crapcot_base.vllanmto
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
      IF vr_cdcritic > 0 THEN
        pr_dscritic := vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
    END IF;
   
    UPDATE cecred.crapcot a
       SET a.vldcotas = a.vldcotas + (rw_crapcot_base.vldcotas)
     WHERE a.cdcooper = rw_crapcot_base.cdcooper
       AND a.nrdconta = rw_crapcot_base.nrdconta;
   
  END LOOP;
  COMMIT;
EXCEPTION 
  WHEN vr_exc_saida THEN  
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 111
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);                             
    ROLLBACK;    
  WHEN OTHERS THEN
    pr_dscritic :=  sqlerrm;
    CECRED.pc_log_programa(pr_dstiplog      => 'O'
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => 111
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => 3 
                          ,pr_idprglog      => vr_idprglog);    
    ROLLBACK;  
END;    
