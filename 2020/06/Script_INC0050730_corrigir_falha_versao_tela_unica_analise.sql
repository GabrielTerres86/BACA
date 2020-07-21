BEGIN
  BEGIN
    UPDATE tbgen_analise_credito t
       SET t.nrversao_analise = 1
     WHERE t.idanalise_contrato = 1068668;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Falha update 1 '||SQLERRM);
  END; 
  --
  BEGIN
    UPDATE tbgen_analise_credito t
       SET t.nrversao_analise = 2
     WHERE t.idanalise_contrato = 1068466; 
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Falha update 2 '||SQLERRM);
  END; 
  COMMIT;
END;    
