UPDATE  tbrisco_operacoes a
   SET a.inrisco_rating = 6,
       a.inrisco_rating_autom = 6
 WHERE a.cdcooper = 9
   AND a.nrdconta = 173053
   AND a.nrctremp = 6906;
commit;
   
