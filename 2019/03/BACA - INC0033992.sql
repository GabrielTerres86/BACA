BEGIN
  INSERT INTO tbchq_param_conta
    (cdcooper, nrdconta, flgdevolu_autom)
  VALUES
    (2, 565466, 1);
    COMMIT;  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;     
END;    
