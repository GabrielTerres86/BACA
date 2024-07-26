BEGIN

  DELETE cecred.tbcc_hist_param_pessoa_prod t
   WHERE t.cdproduto = 25
     AND t.idmotivo = 66;
     
  UPDATE cecred.tbgen_motivo m
    SET m.cdproduto = 25
  WHERE m.idmotivo = 32; 

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20010, SQLERRM);
END;

