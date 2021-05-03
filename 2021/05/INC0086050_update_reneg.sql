/* INC0086050 - Preenche o número da proposta nos registros de renegociação */

BEGIN
  UPDATE tbepr_renegociacao 
  SET    nrctremp = 108480
  WHERE  cdcooper = 13
  AND    nrdconta = 479373;
  --
  UPDATE tbepr_renegociacao_contrato 
  SET    nrctremp  = 108480
  WHERE  cdcooper  = 13
  AND    nrdconta  = 479373
  AND    nrctrepr in (92584,111039);
  --
  UPDATE tbepr_renegociacao 
  SET    nrctremp = 22441
  WHERE  cdcooper = 10
  AND    nrdconta = 85154;
  --
  UPDATE tbepr_renegociacao_contrato 
  SET    nrctremp  = 22441
  WHERE  cdcooper  = 10
  AND    nrdconta  = 85154
  AND    nrctrepr in (4653,85154);
  --
  COMMIT;  
  --
END;  
