BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 33154.89
        ,a.vlsaldorecuperar   = 33154.89
   WHERE a.idcontratoexterno = 3116652;

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 40000
        ,a.vlsaldorecuperar   = 40000
   WHERE a.idcontratoexterno = 30842;

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 30934.01
        ,a.vlsaldorecuperar   = 30934.01
   WHERE a.idcontratoexterno = 235748;

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 78690.62
        ,a.vlsaldorecuperar   = 78690.62
   WHERE a.idcontratoexterno = 43298;

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 23782.72
        ,a.vlsaldorecuperar   = 23782.72
   WHERE a.idcontratoexterno = 84455;

  UPDATE credito.tbcred_peac_contrato a
     SET a.cdsituacaohonra    = 2
        ,a.dtsolicitacaohonra = to_date('23/06/2022 16:27:20', 'DD/MM/RRRR HH24:MI:SS')
        ,a.vlsolicitacaohonra = 54651.76
        ,a.vlsaldorecuperar   = 54651.76
   WHERE a.cdcooper = 1
     AND a.nrdconta = 9137041
     AND a.nrcontrato = 3141164;

  UPDATE credito.tbcred_peac_contrato a
     SET a.cdsituacaohonra    = 2
        ,a.dtsolicitacaohonra = to_date('23/06/2022 16:27:20', 'DD/MM/RRRR HH24:MI:SS')
        ,a.vlsolicitacaohonra = 71233.08
        ,a.vlsaldorecuperar   = 71233.08
   WHERE a.cdcooper = 11
     AND a.nrdconta = 579637
     AND a.nrcontrato = 100753;

  UPDATE credito.tbcred_peac_contrato a
     SET a.vltotalrepassefgi = 333.95
   WHERE a.cdcooper = 14
     AND a.nrdconta = 202320
     AND a.nrcontrato = 19124;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
