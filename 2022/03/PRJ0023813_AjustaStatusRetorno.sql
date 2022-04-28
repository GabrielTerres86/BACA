BEGIN
  UPDATE credito.tbcred_peac_operacao a
     SET a.cdstatus = 'PROCESSANDO'
   WHERE a.cdstatus = 'PENDENTE';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
