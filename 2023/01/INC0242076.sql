BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.cdsituacaohonra    = 0
        ,a.dtsolicitacaohonra = NULL
        ,a.vlsolicitacaohonra = 0
        ,a.vlsaldorecuperar   = 0
        ,a.flbloqueiohonra    = 1
   WHERE a.idpeac_contrato IN (1435, 1998, 2071);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
