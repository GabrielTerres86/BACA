BEGIN
  
  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.CDSTATUS = 7
   WHERE c.DTREFERE < to_date('30/09/2023','DD/MM/RRRR') 
     AND c.CDSTATUS <> 7
     AND c.TPPRODUTO IN(97,98);

  COMMIT;     
END;     
