BEGIN
  UPDATE credito.tbcred_peac_contrato peac
     SET peac.tpsituacaohonra = 0
   WHERE nrdconta = 118478
     AND cdcooper = 10;
  UPDATE crapris ris
     SET ris.qtdiaatr = 350
   WHERE ris.dtrefere = to_date('11/01/2022', 'dd/mm/rrrr')
     AND ris.cdcooper = 10
     AND ris.nrdconta = 118478
     AND ris.nrctremp = 18507;
  UPDATE credito.tbcred_peac_contrato peac
     SET peac.tpsituacaohonra = 0
   WHERE nrdconta = 172073
     AND cdcooper = 10;
  UPDATE crapris ris
     SET ris.qtdiaatr = 100
   WHERE ris.dtrefere = to_date('11/01/2022', 'dd/mm/rrrr')
     AND ris.cdcooper = 10
     AND ris.nrdconta = 172073
     AND ris.nrctremp = 18242;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
