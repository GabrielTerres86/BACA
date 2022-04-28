BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 30000
        ,a.vltotalrepassefgi  = 1438.15
        ,a.cdsituacaohonra    = 2
   WHERE (a.cdcooper, a.nrdconta, a.nrcontrato) IN ((1, 941336, 2982737));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 50000
        ,a.vltotalrepassefgi  = 4200
        ,a.cdsituacaohonra    = 2
   WHERE (a.cdcooper, a.nrdconta, a.nrcontrato) IN ((1, 11037, 3137268));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 25500
        ,a.vltotalrepassefgi  = 0
        ,a.cdsituacaohonra    = 2
   WHERE (a.cdcooper, a.nrdconta, a.nrcontrato) IN ((1, 925250, 2977247));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 20000
        ,a.vltotalrepassefgi  = 0
        ,a.cdsituacaohonra    = 2
   WHERE (a.cdcooper, a.nrdconta, a.nrcontrato) IN ((6, 85626, 235744));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 45000
        ,a.vltotalrepassefgi  = 6000
        ,a.cdsituacaohonra    = 2
   WHERE (a.cdcooper, a.nrdconta, a.nrcontrato) IN ((6, 118460, 236027));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 40000
        ,a.vltotalrepassefgi  = 3000
        ,a.cdsituacaohonra    = 2
   WHERE (a.cdcooper, a.nrdconta, a.nrcontrato) IN ((6, 178845, 236037));

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
