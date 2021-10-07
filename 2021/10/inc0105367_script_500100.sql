DECLARE

  CURSOR cr_parcelas IS
    SELECT pep.cdcooper
          ,pep.nrdconta
          ,pep.nrctremp
          ,pep.dtultpag
          ,pep.vlsdvatu
          ,pep.inliquid
          ,pep.nrparepr
          ,pep.vlsdvpar
          ,pep.vlpagpar
      FROM tbepr_consignado_pagamento tcp
          ,crappep                    pep
     WHERE tcp.cdcooper = pep.cdcooper
       AND tcp.nrdconta = pep.nrdconta
       AND tcp.nrctremp = pep.nrctremp
       AND tcp.nrparepr = pep.nrparepr
       AND pep.inliquid = 0
       AND tcp.instatus = 3
       AND tcp.cdcooper = 13
       AND tcp.nrdconta = 500100
       AND tcp.nrctremp = 129765;
  rw_parcelas cr_parcelas%ROWTYPE;

BEGIN

  OPEN cr_parcelas;
  LOOP
  
    FETCH cr_parcelas
      INTO rw_parcelas;
    EXIT WHEN cr_parcelas%NOTFOUND;

    UPDATE crappep
       SET vlsdvpar = 0
          ,vlpagpar = to_char(rw_parcelas.vlsdvpar)
          ,vlsdvatu = 0
          ,inliquid = 1
     WHERE cdcooper = rw_parcelas.cdcooper
       AND nrdconta = rw_parcelas.nrdconta
       AND nrctremp = rw_parcelas.nrctremp
       AND inliquid = 0
       AND nrparepr = rw_parcelas.nrparepr;
  
  END LOOP;
  CLOSE cr_parcelas;

  UPDATE crapepr
     SET inliquid = 1
        ,vlsdeved = 0
        ,vlsdvctr = 0
        ,vlsdevat = 0
        ,vlpapgat = 0
   WHERE cdcooper = 13
     AND nrdconta = 242470
     AND nrctremp = 53912;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
