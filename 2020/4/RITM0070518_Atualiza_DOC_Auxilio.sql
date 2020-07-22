BEGIN
  -- Deve atualizar 1802 registros
  UPDATE gncpdoc t
     SET t.dsinform = 'CEFAUXILIO2'
   WHERE t.dtmvtolt = to_date('20/04/2020','dd/mm/yyyy')
     AND (TRIM(t.nmpesemi) = 'AUXILIO EMERGENCIAL COVID19' OR t.nrcctrcb = 109476200);
  
  COMMIT;
  
END;
