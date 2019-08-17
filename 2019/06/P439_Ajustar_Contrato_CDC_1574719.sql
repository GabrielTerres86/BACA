  UPDATE crawepr
     SET insitapr = 1,
         dtenvest = SYSDATE,
         hrenvest = TO_CHAR(SYSDATE,'SSSSS'),
         cdopeste = '1'
   WHERE cdcooper = 1
     AND nrdconta = 9931503
     AND nrctremp = 1574719;
	 
   
COMMIT;
/*

Viacredi
CNPJ: 03488271000126
Proposta 3531381
Conta: 9931503
Contrato: 1574719

INC0018643


Rollback
UPDATE crawepr
     SET insitapr = 2,
         dtenvest = NULL,
         hrenvest = 0,
         cdopeste = ' '
   WHERE cdcooper = 1
     AND nrdconta = 9931503
     AND nrctremp = 1574719;

*/




