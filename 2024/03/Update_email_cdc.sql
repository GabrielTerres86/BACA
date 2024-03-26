BEGIN
  UPDATE cecred.tbsite_cooperado_cdc a
  SET a.dsemail = NULL
  WHERE a.cdcooper = 2
  AND a.idcooperado_cdc = 73795
  AND a.nrdconta = 18407528;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);  
END;
