BEGIN 
  update tbgrv_registro_contrato set dtregistro_contrato = (dtregistro_contrato + INTERVAL '60' SECOND) where cdcooper = 1 and nrdconta = 10277145 and nrctrpro = 3732845 and cdsituacao_contrato = 2;
  update tbgrv_registro_contrato set dtregistro_contrato = (dtregistro_contrato + INTERVAL '60' SECOND) where cdcooper = 1 and nrdconta = 8763216  and nrctrpro = 3725389 and cdsituacao_contrato = 2;
  COMMIT;
END;