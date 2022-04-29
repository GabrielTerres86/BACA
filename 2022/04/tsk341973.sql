declare 
  vr_exc_saida     EXCEPTION;
  
  vr_cdcoopera      crapcop.cdcooper%TYPE := 16;
  vr_nrdcontaa      crapass.nrdconta%TYPE := 395544;
  vr_nrctrempa      craplem.nrctremp%TYPE := 162510;
  vr_vlsdeveda      crapepr.vlsdeved%TYPE := 462.95;
  vr_vlparepra      crappep.vlpagpar%TYPE := 21.50;
  
  vr_cdcooperb      crapcop.cdcooper%TYPE := 16;
  vr_nrdcontab      crapass.nrdconta%TYPE := 6521096;
  vr_nrctrempb      craplem.nrctremp%TYPE := 302190;
  vr_vlsdevedb      crapepr.vlsdeved%TYPE := 575.94;
  vr_vlpareprb      crappep.vlpagpar%TYPE := 17.94;
BEGIN
  BEGIN
    UPDATE crappep c
       SET vlparepr = vr_vlparepra,
           vlsdvatu = vr_vlparepra - (nvl(vlpagpar, 0) + nvl(vldespar, 0)),
           vlsdvpar = vr_vlparepra
     WHERE c.cdcooper = vr_cdcoopera
       AND c.nrdconta = vr_nrdcontaa
       AND c.nrctremp = vr_nrctrempa
       and c.inliquid = 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  BEGIN
    UPDATE crapepr
       SET crapepr.vlsdeved = vr_vlsdeveda,
           crapepr.vlsdevat = vr_vlsdeveda,
           crapepr.vlsprojt = vr_vlsdeveda,
           crapepr.vlpreemp = vr_vlparepra
     WHERE crapepr.cdcooper = vr_cdcoopera
       AND crapepr.nrdconta = vr_nrdcontaa
       AND crapepr.nrctremp = vr_nrctrempa;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  BEGIN
    UPDATE crappep c
       SET vlparepr = vr_vlpareprb,
           vlsdvatu = vr_vlpareprb - (nvl(vlpagpar, 0) + nvl(vldespar, 0)),
           vlsdvpar = vr_vlpareprb
     WHERE c.cdcooper = vr_cdcooperb
       AND c.nrdconta = vr_nrdcontab
       AND c.nrctremp = vr_nrctrempb
       AND c.inliquid = 0
       AND c.nrparepr > 2;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  BEGIN
    UPDATE crapepr
       SET crapepr.vlsdeved = vr_vlsdevedb,
           crapepr.vlsdevat = vr_vlsdevedb,
           crapepr.vlsprojt = vr_vlsdevedb,
           crapepr.vlpreemp = vr_vlpareprb
     WHERE crapepr.cdcooper = vr_cdcooperb
       AND crapepr.nrdconta = vr_nrdcontab
       AND crapepr.nrctremp = vr_nrctrempb;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
end;
