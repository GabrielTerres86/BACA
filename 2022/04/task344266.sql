BEGIN
  UPDATE crapepr e
     SET e.qtprecal = 7
   WHERE e.cdcooper = 1
     AND e.nrdconta = 9193120
     AND e.nrctremp = 4390840
     AND e.qtprecal = 2;
  COMMIT;
END;
