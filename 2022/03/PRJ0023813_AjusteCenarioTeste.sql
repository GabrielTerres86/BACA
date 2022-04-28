BEGIN
  UPDATE credito.tbcred_peac_contrato a
     SET a.nrcontrolestr = 'STR20220117033189025'
   WHERE a.cdcooper = 1
     AND a.nrdconta = 4197
     AND a.nrcontrato = 2983022;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
