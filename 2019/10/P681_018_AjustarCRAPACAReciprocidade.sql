BEGIN
  UPDATE CRAPACA T 
     SET t.lstparam = 'pr_nrconven,pr_cdcatego,pr_inpessoa,pr_nrdconta'
   WHERE t.nmdeacao = 'BUSCA_TARIFAS';
   
  COMMIT;
END;
