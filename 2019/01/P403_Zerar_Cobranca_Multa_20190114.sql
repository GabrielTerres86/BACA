UPDATE crapbdt bdt
    SET bdt.vltxmult = 0
  WHERE bdt.cdcooper = 12
    AND bdt.nrdconta = 115320
    AND bdt.nrborder = 14791;
	
COMMIT;