BEGIN
  
  DELETE contacorrente.tbcc_controle_devolucoes t
   WHERE t.cdcooper = 2;
  
  COMMIT;
END;
