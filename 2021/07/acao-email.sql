DECLARE

BEGIN
  
 UPDATE CRAPACA 
    SET lstparam = 'pr_nrdconta, pr_nrcontrato'
  WHERE nmdeacao = 'VALIDA_EMAIL' 
    AND nmproced = 'CREDITO.validaEmailContasWeb' 
    AND nrseqrdr = 1045;
    
COMMIT;
END;
