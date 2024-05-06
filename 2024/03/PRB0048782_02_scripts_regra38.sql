BEGIN  
  UPDATE tbjur_prm_quebra_sigilo a 
     set a.nmestsig = 'FOLHA PAGAMENTO (DEBITO)' 
   where a.cdestsig = 14; 
   
  INSERT INTO tbjur_prm_quebra_sigilo (CDESTSIG, NMESTSIG)
  VALUES (38, 'FOLHA PAGAMENTO (CREDITO)');

  COMMIT; 
END;