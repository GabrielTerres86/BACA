BEGIN
  UPDATE credito.tbcred_peac_contrato b
     SET b.cdsituacaohonra = 1
   WHERE b.idcontratoexterno = 2979852;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
