--deve deletar apenas 1 registro
DELETE 
  FROM crawseg cc 
 WHERE cc.cdcooper = 1
   AND cc.nrdconta = 6913172
   AND cc.nrctrato = 1501817
   AND cc.tpseguro = 4;

COMMIT;
