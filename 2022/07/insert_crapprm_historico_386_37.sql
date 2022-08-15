BEGIN
  INSERT INTO cecred.tbjur_prm_quebra_sigilo (cdestsig, nmestsig) values (37, 'DEP.CHQ.COOP. - HISTORICO 386');
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;  
END;
