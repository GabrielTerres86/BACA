BEGIN
  UPDATE crapris ris
     SET ris.qtdiaatr = 350
   WHERE ris.dtrefere >= to_date('27/12/2021', 'dd/mm/rrrr')
     AND ris.cdcooper = 10
     AND ris.nrdconta = 118478
     AND ris.nrctremp = 18507;
  UPDATE crapris ris
     SET ris.qtdiaatr = 100
   WHERE ris.dtrefere >= to_date('27/12/2021', 'dd/mm/rrrr')
     AND ris.cdcooper = 10
     AND ris.nrdconta = 172073
     AND ris.nrctremp = 18242;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
