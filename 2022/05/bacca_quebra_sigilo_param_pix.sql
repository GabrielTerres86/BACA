BEGIN
  insert into cecred.tbjur_prm_quebra_sigilo (cdestsig, nmestsig) values (35, 'PIX');
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;  
END;