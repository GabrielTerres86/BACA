BEGIN
  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.DTREFERE = to_date('31/10/2023','DD/MM/RRRR') 
   WHERE c.DTREFERE = to_date('30/09/2023','DD/MM/RRRR')
     AND TRUNC(c.DHINICAR_AIMARO) = to_date('03/11/2023')
     AND c.TPPRODUTO = 98;
     
  COMMIT;

  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.DTREFERE = to_date('31/10/2023','DD/MM/RRRR') 
   WHERE c.DTREFERE = to_date('30/09/2023','DD/MM/RRRR')
     AND TRUNC(c.DHINICAR_AIMARO) = to_date('02/11/2023')
     AND c.TPPRODUTO = 97;
     
  COMMIT;

  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.DTREFERE = to_date('31/10/2023','DD/MM/RRRR') 
        ,c.CDSTATUS = 4
   WHERE c.DTREFERE = to_date('30/09/2023','DD/MM/RRRR')
     AND TRUNC(c.DHINICAR_AIMARO) = to_date('01/11/2023')
     AND c.TPPRODUTO = 98;
     
  COMMIT;

END;     
