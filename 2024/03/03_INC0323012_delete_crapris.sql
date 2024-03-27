DECLARE

  vr_data_origen  DATE := to_date('09/02/2024', 'DD/MM/RRRR');

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
     ORDER BY c.cdcooper DESC;
      
BEGIN


  FOR rw_crapcop IN cr_crapcop LOOP 
    
    dbms_output.put_line('Limpando coop '||rw_crapcop.cdcooper);
    
    DELETE /*+parallel */ cecred.crapris r
     WHERE r.dtrefere = vr_data_origen
       AND r.cdcooper = rw_crapcop.cdcooper;

    DELETE /*+parallel */ cecred.crapvri r
     WHERE r.dtrefere = vr_data_origen
       AND r.cdcooper = rw_crapcop.cdcooper;
       
    COMMIT;       
  END LOOP;       

END;
