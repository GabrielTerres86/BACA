/* INC0086050 - Preenche o n�mero da proposta nos registros de renegocia��o */

BEGIN

  UPDATE tbepr_renegociacao 
  SET    nrctremp = 108480
  WHERE  cdcooper = 13
  AND    nrdconta = 479373;

  UPDATE tbepr_renegociacao_contrato 
  SET    nrctremp  = 108480
  WHERE  cdcooper  = 13
  AND    nrdconta  = 479373
  AND    nrctrepr in (92584,111039);
  
  COMMIT;  
  
END;  
