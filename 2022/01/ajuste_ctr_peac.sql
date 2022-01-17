BEGIN
  UPDATE credito.tbcred_peac_contrato peac
     SET peac.tpsituacaohonra = 1
   WHERE nrdconta = 118478
     AND cdcooper = 10;

  UPDATE credito.tbcred_peac_contrato peac
     SET peac.tpsituacaohonra = 3
   WHERE nrdconta = 172073
     AND cdcooper = 10;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
END;
