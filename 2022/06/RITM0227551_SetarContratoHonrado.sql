BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.cdsituacaohonra    = 2
        ,a.dtsolicitacaohonra = to_date('14/06/2022 16:38:20', 'DD/MM/RRRR HH24:MI:SS')
        ,a.vlsolicitacaohonra = 33387.90
        ,a.vlsaldorecuperar   = 33387.90
   WHERE a.cdcooper = 1
     AND a.nrdconta = 8277010
     AND a.nrcontrato = 2986070;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
