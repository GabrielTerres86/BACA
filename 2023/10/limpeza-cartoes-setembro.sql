DECLARE
  CURSOR cr_coop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1;
  rw_coop cr_coop%ROWTYPE;
BEGIN
  
  FOR rw_coop IN cr_coop LOOP
    BEGIN
      DELETE FROM gestaoderisco.tbrisco_crapvri 
       WHERE cdcooper = rw_coop.cdcooper
         AND dtrefere = to_date('30/09/2023', 'dd/mm/rrrr') 
         AND nrseqctr = 97;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao limpar tbrisco_crapvri - Coop: ' || rw_coop.cdcooper || ' - ' || SQLERRM);
    END;
    
    BEGIN
      DELETE FROM gestaoderisco.tbrisco_crapris 
       WHERE cdcooper = rw_coop.cdcooper
         AND dtrefere = to_date('30/09/2023', 'dd/mm/rrrr') 
         AND nrseqctr = 97;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao limpar tbrisco_crapris - Coop: ' || rw_coop.cdcooper || ' - ' || SQLERRM);
    END;
    
    BEGIN
      DELETE FROM gestaoderisco.htrisco_central_retorno 
       WHERE cdcooper = rw_coop.cdcooper
         AND dtreferencia = to_date('30/09/2023', 'dd/mm/rrrr') 
         AND cdproduto = 97;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao limpar htrisco_central_retorno - Coop: ' || rw_coop.cdcooper || ' - ' || SQLERRM);
    END;
    
    COMMIT;
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
