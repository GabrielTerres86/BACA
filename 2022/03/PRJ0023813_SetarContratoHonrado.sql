BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.nrcontrolestr      = 'STR20220117033189025'
        ,a.cdsituacaohonra    = 2
        ,a.dtsolicitacaohonra = to_date('10/12/2021 07:09:31', 'DD/MM/RRRR HH24:MI:SS')
        ,a.vlsolicitacaohonra = 560000
        ,a.vlsaldorecuperar   = 560000
   WHERE a.cdcooper = 14
     AND a.nrdconta = 202320
     AND a.nrcontrato = 19124;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
