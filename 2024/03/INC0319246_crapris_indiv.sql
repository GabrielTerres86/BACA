DECLARE 

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;

BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    
    UPDATE crapris ris
       SET ris.flgindiv = 0
     WHERE ris.cdcooper = rw_crapcop.cdcooper
       AND ris.FLGINDIV = 1
       AND ris.dtrefere = to_date('29/02/2024', 'DD/MM/RRRR');
       
    dbms_output.put_line('Coop:'||rw_crapcop.cdcooper||' qtd Reg:'||sql%rowcount);
    
    COMMIT;

    DELETE crapris ris
     WHERE ris.cdcooper = rw_crapcop.cdcooper
       AND ris.Inddocto = 2
       AND ris.dtrefere = to_date('29/02/2024', 'DD/MM/RRRR');
       
    dbms_output.put_line('Coop:'||rw_crapcop.cdcooper||' Del Saidas qtd Reg:'||sql%rowcount);   
    
    COMMIT;
    
    
  END LOOP;
  
END;
