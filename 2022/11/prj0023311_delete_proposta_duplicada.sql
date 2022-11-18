BEGIN

 DELETE credito.tbepr_contrato_bem_imobiliario a
  WHERE a.cdcooper = 1
  AND a.nrdconta = 946907
  AND a.nrctremp = 5656358;
  
  DELETE credito.tbepr_contrato_imobiliario a
  WHERE a.cdcooper = 1
  AND a.nrdconta = 946907
  AND a.nrctremp = 5656358;

  DELETE credito.tbepr_imob_imp_arq_risco a
  WHERE a.cdcooper = 1
  AND a.nrdconta = 946907
  AND a.contrt = 5656358;
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
