  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 1
     AND nrdconta = 7563086
     AND nrctremp = 1564234;
	 
   
COMMIT;
/*
CNPJ: 02768206000191
Proposta: 3530787
Conta: 7563086
Ctro: 1564234
*/
