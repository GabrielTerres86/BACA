BEGIN
  UPDATE credito.tbcred_peac_operacao a
     SET a.cdstatus = 'PROCESSANDO'
   WHERE a.idpeac_operacao IN (167, 168, 169);
  COMMIT;
END;
