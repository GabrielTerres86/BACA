BEGIN
  UPDATE cecred.tbcrd_cessao_credito cc
	 SET cc.dtvencto = to_date('18/10/2023', 'dd/mm/YYYY') 
   WHERE cc.nrctremp = 7505059
	 AND cc.nrdconta = 87838702
	 AND cc.cdcooper = 1;
   
  UPDATE cecred.crapcyb cc
     SET cc.dtefetiv = to_date('18/10/2023', 'DD/MM/RRRR')
   WHERE cc.nrdconta = 87838702
     AND cc.cdcooper = 1
     AND cc.nrctremp = 7505059;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;