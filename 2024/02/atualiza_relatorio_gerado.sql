BEGIN
  UPDATE crapslr l
     SET l.flgerado = 'S'
   WHERE l.flgerado = 'N'
     AND NOT l.nrseqsol = 43123621;
  COMMIT;
END;
