DECLARE

  vr_busca        VARCHAR2(100);
  vr_nrdocmto     craplct.nrdocmto%TYPE;
  vr_nrseqdig_lot craplot.nrseqdig%TYPE;
  rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
  pr_dtmvtolt DATE;
  
  pr_cdcooper NUMBER(2) := 1;
  pr_nrdconta NUMBER(8) := 7076460;
  pr_cdagenci NUMBER(23) := 224;
  pr_vllanmto NUMBER(6,2) := 2600.00;
  vr_nrdolote     craplot.nrdolote%TYPE := 800039;

BEGIN
     
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  pr_dtmvtolt := rw_crapdat.dtmvtolt;
  
  vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
              TRIM(to_char(pr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
              TRIM(to_char(pr_cdagenci)) || ';' ||
                   '100;' ||
                    vr_nrdolote || ';' || 
              TRIM(to_char(pr_nrdconta));

  vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca); 
    
  vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||pr_cdcooper||';'||
                                 to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                 pr_cdagenci||
                                 ';100;'||
                                  vr_nrdolote);      
           
   INSERT INTO cecred.craplct(cdcooper
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
                      VALUES (pr_cdcooper
                             ,pr_cdagenci
                             ,100
                             ,vr_nrdolote
                             ,pr_dtmvtolt
                             ,954
                             ,pr_nrdconta
                             ,pr_nrdconta
                             ,vr_nrdocmto
                             ,vr_nrseqdig_lot
                             ,pr_vllanmto);                                                                      
                             
    UPDATE cecred.crapcot
       SET vldcotas = vldcotas - pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;  
       
  COMMIT;                    
  EXCEPTION                                
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0307607');
    ROLLBACK;
END;
