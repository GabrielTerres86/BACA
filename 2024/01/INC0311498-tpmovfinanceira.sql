BEGIN
  UPDATE credito.tbcred_pronampe_remessa a
     SET a.tpmovfinanceira = 3
   WHERE nvl(a.tpmovfinanceira, 0) = 0;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
