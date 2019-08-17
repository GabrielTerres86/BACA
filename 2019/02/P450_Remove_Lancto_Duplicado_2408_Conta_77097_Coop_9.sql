UPDATE tbcc_prejuizo
   SET vlsdprej = vlsdprej - 8.00
 WHERE cdcooper = 9
   AND nrdconta = 77097;
   
DELETE FROM tbcc_prejuizo_detalhe
 WHERE cdcooper = 9
   AND nrdconta = 77097
   AND cdhistor = 2408
   AND dtmvtolt = to_date('14/02/2019', 'DD/MM/YYYY')
   AND vllanmto = 8.00;
   
COMMIT;
 
