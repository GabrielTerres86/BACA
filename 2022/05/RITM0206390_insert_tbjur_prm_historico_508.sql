BEGIN
  INSERT INTO cecred.tbjur_prm_quebra_sigilo (cdestsig, nmestsig) values (36, 'INTERNET - PAGAMENTO ON-LINE - HISTORICO 508');
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;  
END;
