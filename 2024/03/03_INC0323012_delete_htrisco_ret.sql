DECLARE

  vr_data_origen  DATE := to_date('26/03/2024', 'DD/MM/RRRR');

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
     ORDER BY c.cdcooper DESC;
      
BEGIN


  FOR rw_crapcop IN cr_crapcop LOOP 
    
    dbms_output.put_line('Limpando coop '||rw_crapcop.cdcooper);
    
    DELETE /*+parallel */ gestaoderisco.htrisco_central_retorno r
     WHERE r.dtreferencia = vr_data_origen
       AND r.cdcooper = rw_crapcop.cdcooper;
       
    COMMIT;       
  END LOOP;       

END;
