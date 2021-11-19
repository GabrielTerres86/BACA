BEGIN
  UPDATE crapepr e SET e.cdlcremp = 203 WHERE e.cdcooper = 13 AND e.nrdconta = 344427 AND e.nrctremp = 44753; 
  UPDATE crapris r SET r.cdmodali = 499 WHERE r.cdcooper = 13 AND r.nrdconta = 344427 AND r.nrctremp = 44753 AND r.cdmodali = 299;
  UPDATE crapvri v SET v.cdmodali = 499 WHERE v.cdcooper = 13 AND v.nrdconta = 344427 AND v.nrctremp = 44753 AND v.cdmodali = 299;
  COMMIT;
END;


