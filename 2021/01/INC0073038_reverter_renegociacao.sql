UPDATE tbepr_renegociacao
   SET dtlibera = null
 WHERE cdcooper = 1
   AND nrdconta = 6863833
   AND nrctremp = 3339219;

UPDATE tbepr_renegociacao_contrato
   SET cdfinemp_origem = 77     
 WHERE cdcooper = 1 
   AND nrdconta = 6863833     
   AND nrctremp = 3339219
   AND nrctrepr = 1708418;
     
UPDATE crapepr
   SET cdfinemp = 77    
 WHERE cdcooper = 1 
   AND nrdconta = 6863833     
   AND nrctremp = 1708418;    
   