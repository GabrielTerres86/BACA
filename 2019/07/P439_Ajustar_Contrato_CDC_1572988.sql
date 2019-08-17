  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 1
     AND nrdconta = 8538581
     AND nrctremp = 1572988;
	 
   
COMMIT;
/*

Viacredi
CNPJ: 03734219000102
Proposta 3530592
Conta: 853858-1  
Contrato: 1572988
 



Rollback
UPDATE crawepr
     SET insitapr = 2,
         dtenvest = NULL,
         hrenvest = 0,
         cdopeste = ' '
   WHERE cdcooper = 1
     AND nrdconta = 8538581
     AND nrctremp = 1572988;

*/




