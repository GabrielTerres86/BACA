BEGIN

  DELETE FROM gestaoderisco.tbrisco_crapvri 
   WHERE cdcooper IN (1, 8)
     AND dtrefere = to_date('30/09/2023', 'dd/mm/rrrr') 
     AND nrseqctr = 97;
  
  DELETE FROM gestaoderisco.tbrisco_crapris 
   WHERE cdcooper IN (1, 8)
     AND dtrefere = to_date('30/09/2023', 'dd/mm/rrrr') 
     AND nrseqctr = 97;
     
  DELETE FROM gestaoderisco.htrisco_central_retorno 
   WHERE cdcooper IN (1, 8)
     AND dtreferencia = to_date('30/09/2023', 'dd/mm/rrrr') 
     AND cdproduto = 97;

  COMMIT;
END;
