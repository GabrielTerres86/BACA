BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsaldorecuperar = a.vlsolicitacaohonra
   WHERE a.idpeac_contrato = 466;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
