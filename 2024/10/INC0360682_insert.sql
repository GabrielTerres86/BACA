BEGIN
  INSERT INTO cecred.tbtransf_erros_cnab (
         tperrocnab,
         dserrocnab
  ) VALUES (
    'YZ',
    'TED sem c�digo de finalidade'
  );
  
  COMMIT;

END;
