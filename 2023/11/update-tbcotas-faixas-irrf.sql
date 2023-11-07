BEGIN
  UPDATE cecred.tbcotas_faixas_irrf
     SET VLFAIXA_FINAL = 2112
   WHERE CDFAIXA = 1 
     AND INPESSOA = 1;
  
  UPDATE cecred.tbcotas_faixas_irrf
     SET VLFAIXA_INICIAL = 2112.01,
         VLDEDUCAO = 158.4
   WHERE CDFAIXA = 2 
     AND INPESSOA = 1;
     
   UPDATE cecred.tbcotas_faixas_irrf
     SET VLDEDUCAO = 370.4
   WHERE CDFAIXA = 3 
     AND INPESSOA = 1;
     
  UPDATE cecred.tbcotas_faixas_irrf
     SET VLDEDUCAO = 651.73
   WHERE CDFAIXA = 4 
     AND INPESSOA = 1;
  
  UPDATE cecred.tbcotas_faixas_irrf
     SET VLFAIXA_INICIAL = 4664.68,
         VLDEDUCAO = 884.96
   WHERE CDFAIXA = 5
     AND INPESSOA = 1;
     
  COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'RITM0311488'); 
      ROLLBACK;
END;
         
