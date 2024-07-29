BEGIN
UPDATE tbcrd_cessao_credito cc
   SET cc.dtvencto = to_date('18/07/2023', 'dd/mm/YYYY') 
 WHERE cc.nrctremp = 7505059
   AND cc.nrdconta = 87838702
   AND cc.cdcooper = 1;
COMMIT;
END;