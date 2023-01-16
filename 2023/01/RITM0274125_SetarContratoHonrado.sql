BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.cdsituacaohonra    = 2
        ,a.dtsolicitacaohonra = to_date('06/12/2022 14:55:20', 'DD/MM/RRRR HH24:MI:SS')
        ,a.vlsolicitacaohonra = 38556.29
        ,a.vlsaldorecuperar   = 38556.29
   WHERE a.idpeac_contrato = 945;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
