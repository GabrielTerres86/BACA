DECLARE 
  vr_exc_saida     EXCEPTION; 
    
  vr_vlmrapar      crappep.vlmrapar%type;
  vr_vlmtapar      crappep.vlmtapar%TYPE;
  vr_vlpagpar      crappep.vlpagpar%TYPE;
  vr_vllanmto      craplem.vllanmto%TYPE;

  CURSOR cr_nrparepr IS
    SELECT c.cdcooper,
           c.nrdconta,
           c.nrctremp,
           c.nrparepr,
           c.vlmrapar,
           c.vlmtapar,
           c.vlpagpar
      FROM cecred.crappep c
     WHERE c.cdcooper = 1
       AND c.nrdconta = 3911160
       AND c.nrctremp = 4815408
       and c.nrparepr in (2,3,4,5,6,7,8);
  rw_nrparepr cr_nrparepr%ROWTYPE;
  
BEGIN
  
  FOR rw_nrparepr IN cr_nrparepr LOOP
    
    vr_vlmrapar := rw_nrparepr.vlmrapar;
    vr_vlmtapar := rw_nrparepr.vlmtapar;
    vr_vlpagpar := rw_nrparepr.vlpagpar;
  
  vr_vllanmto := vr_vlpagpar + vr_vlmtapar + vr_vlmrapar;
  
  BEGIN
    UPDATE cecred.crappep
       SET crappep.vlsdvpar = vr_vlpagpar,
           crappep.vlsdvatu = vr_vlpagpar,
           crappep.vlsdvsji = 213.80,
           crappep.vlpagjin = 0,
           crappep.vlpagmra = 0, 
           crappep.vlpagmta = 0,
           crappep.inliquid = 0,
           crappep.vlpagpar = 0,
           crappep.dtultpag = null
     WHERE crappep.cdcooper = rw_nrparepr.cdcooper
       AND crappep.nrdconta = rw_nrparepr.nrdconta
       AND crappep.nrctremp = rw_nrparepr.nrctremp
       and crappep.nrparepr = rw_nrparepr.nrparepr;        
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
    
  BEGIN
    UPDATE cecred.crapepr
       SET crapepr.vlsdeved = crapepr.vlsdeved + vr_vllanmto,
           crapepr.vlsprojt = crapepr.vlsprojt + vr_vlpagpar,
           crapepr.dtultpag = to_date('29/03/2022','dd/mm/yyyy'),
           crapepr.qtprecal = 1,
           crapepr.qtprepag = 1
     WHERE crapepr.cdcooper = rw_nrparepr.cdcooper
       AND crapepr.nrdconta = rw_nrparepr.nrdconta
       AND crapepr.nrctremp = rw_nrparepr.nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  END LOOP;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
end;
