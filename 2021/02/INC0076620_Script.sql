/* INC0076620 - Atualizar o retorno da CIP para o boleto*/

BEGIN

  UPDATE crapcob cob
  SET cob.nratutit = 1595446513280000722
     ,cob.ininscip = 2
  WHERE cob.cdcooper = 16
  AND cob.nrdconta = 587419
  AND cob.nrdocmto = 412
  AND cob.nrcnvcob = 115004;
  
  COMMIT;
END;  
