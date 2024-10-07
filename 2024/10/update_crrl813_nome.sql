BEGIN
  UPDATE cecred.craprel c
     SET c.nmrelato = 'ARQ PREVIA SEG PREST CONTRIBUTARIO SEMANAL PF'
   WHERE c.cdrelato = 813;
   
  COMMIT;
END;
