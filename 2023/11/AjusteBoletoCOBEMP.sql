BEGIN
  DELETE FROM cecred.tbgen_batch_paralelo a
   WHERE a.cdcooper = 14
     AND a.cdprogra = 'CRPS001'
     AND a.situacao = 1;
  COMMIT;
END;
