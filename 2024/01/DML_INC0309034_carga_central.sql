BEGIN
  
  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.CDSTATUS = 4
   WHERE c.DTREFERE = to_date('31/12/2023','DD/MM/RRRR')
     AND c.TPPRODUTO IN (97)
     AND c.IDCENTRAL_CARGA NOT IN (SELECT MAX(x.IDCENTRAL_CARGA)
                                     FROM gestaoderisco.tbrisco_central_carga x
                                    WHERE x.DTREFERE = to_date('31/12/2023','DD/MM/RRRR')
                                      AND x.TPPRODUTO IN (97)
                                    GROUP BY cdcooper);
  COMMIT; 
              
END;                     
