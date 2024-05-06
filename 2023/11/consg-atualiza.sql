BEGIN
  
  update tbepr_consig_parcelas_tmp SET nrdconta = 99286734 where cdcooper = 1 and nrctremp = 267257;
  update tbepr_consig_contrato_tmp SET nrdconta = 99286734 where cdcooper = 1 and nrctremp = 267257;
  update tbepr_consig_movimento_tmp SET nrdconta = 99286734 where cdcooper = 1 and nrctremp = 267257;

 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
