BEGIN  
  UPDATE squad_juridico.tbjur_prm_quebra_sigilo a 
     set a.nmestsig = 'FOLHA PAGAMENTO (DEBITO)' 
   where a.cdestsig = 14; 
   
  INSERT INTO squad_juridico.tbjur_prm_quebra_sigilo (CDESTSIG, NMESTSIG)
  VALUES (38, 'FOLHA PAGAMENTO (CREDITO)');

  COMMIT; 
END;