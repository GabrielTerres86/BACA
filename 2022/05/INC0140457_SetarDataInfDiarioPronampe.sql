BEGIN
  UPDATE credito.tbcred_pronampe_remessa a
     SET a.dtenviolcm = to_date('05/05/2022', 'DD/MM/RRRR')
   WHERE a.nrremessa = 101
     AND a.dtenviolcm IS NULL;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
