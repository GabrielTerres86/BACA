  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 1
     AND nrdconta = 2681960
     AND nrctremp = 1574357;
	 
   
COMMIT;
/*
Viacredi
CNPJ: 18.405.807/0001-70
Proposta: 3530918
Conta: 2681960
Contrato: 1574357

Rollback
UPDATE crawepr
     SET insitapr = 2,
         dtenvest = NULL,
         hrenvest = 0,
         cdopeste = ' '
   WHERE cdcooper = 1
     AND nrdconta = 2681960
     AND nrctremp = 1574357;

*/
