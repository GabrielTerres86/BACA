UPDATE craphis
   SET intransf_cred_prejuizo = 1
 WHERE cdhistor = 662;
 
DELETE FROM tbcc_prejuizo_detalhe
 WHERE cdcooper = 2
   AND nrdconta = 384763
   AND idlancto IN (9679, 8510, 7918);
   
UPDATE tbcc_prejuizo
   SET vlsdprej = vlsdprej - (9.90 * 3)
 WHERE cdcooper = 2
   AND nrdconta = 384763
   AND dtliquidacao IS NULL;

DELETE FROM tbcc_prejuizo_detalhe
 WHERE cdcooper = 7
   AND nrdconta = 330337
   AND idlancto IN (9680, 8511, 7917);
   
UPDATE tbcc_prejuizo
   SET vlsdprej = vlsdprej - (9.90 * 3)
 WHERE cdcooper = 7
   AND nrdconta = 330337
   AND dtliquidacao IS NULL;
   
COMMIT;
