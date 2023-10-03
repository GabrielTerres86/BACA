BEGIN
  
  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.DTREFERE = to_date('30/09/2023','DD/MM/RRRR') 
   WHERE c.DTREFERE >= to_date('30/09/2023','DD/MM/RRRR') 
     AND c.TPPRODUTO IN (97,98);
     
  COMMIT;     
END;     
