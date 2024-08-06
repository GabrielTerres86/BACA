BEGIN
  
  RISC0002.pc_import_arq_risco_cartao_job;
  
  COMMIT;
  
  UPDATE gestaoderisco.tbrisco_central_carga c
     SET c.cdstatus  = 4
   WHERE c.dtrefere  = to_date('31/07/2024','DD/MM/RRRR')
     AND c.tpproduto = 97;
     
  COMMIT;
  
END;
