BEGIN
  UPDATE cecred.tbsite_cooperado_cdc a
  SET a.dsemail = NULL
  WHERE a.cdcooper = 1
  AND a.idcooperado_cdc = 66815
  AND a.nrdconta = 17709784;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);  
END;
