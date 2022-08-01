BEGIN
  INSERT INTO cecred.tbjur_prm_quebra_sigilo (cdestsig, nmestsig) values (38, 'DEP. CUSTODIA. - HISTORICO 2662');
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;  
END;
