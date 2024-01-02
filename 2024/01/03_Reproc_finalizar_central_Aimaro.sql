DECLARE


  pr_dscritic VARCHAR2(1000) := NULL;

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper IN (3)
     ORDER BY c.cdcooper DESC;
     
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
    
    DELETE gestaoderisco.tbrisco_crapris x
     WHERE x.DTREFERE = to_date('31/12/2023','DD/MM/RRRR')
       AND x.cdcooper = rw_crapcop.cdcooper;

    DELETE gestaoderisco.tbrisco_crapvri x
     WHERE x.DTREFERE = to_date('31/12/2023','DD/MM/RRRR')
       AND x.cdcooper = rw_crapcop.cdcooper; 
     
    COMMIT; 
      
    gestaoderisco.finalizarCentralRisco(pr_cdcooper => rw_crapcop.cdcooper,
                                        pr_tpCalculo => 1,
                                        pr_dscritic => pr_dscritic);
    
    IF TRIM(pr_dscritic) IS NOT NULL THEN
      raise_application_error(-20500,'Coop: '||rw_crapcop.cdcooper||' Erro:'||pr_dscritic);
    END IF;
    
    COMMIT;
                                          
  END LOOP;                   
                     
END;
