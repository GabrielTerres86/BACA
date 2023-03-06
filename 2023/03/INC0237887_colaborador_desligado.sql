BEGIN
  
  UPDATE owsiv.econ_cpempregador 
     SET flag_desligado='S', 
         data_desligado='01/02/2023' 
   WHERE cod_contrato_inter=7522;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;
