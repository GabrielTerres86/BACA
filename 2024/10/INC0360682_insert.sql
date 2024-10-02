BEGIN
  INSERT INTO cecred.tbtransf_erros_cnab (
         tperrocnab,
         dserrocnab
  ) VALUES (
    'YZ',
    'TED sem código de finalidade'
  );
  
  COMMIT;

END;
