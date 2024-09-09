Begin
INSERT INTO CECRED.CRAPREL (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf, dsdemail, cdfilrel, nrseqpri) 
SELECT 1007, 
       nrviadef, 
       nrviamax, 
       'ARQ PREVIA SEG PREST CONTRIBUTARIO SEMANAL PJ', 
       nrmodulo, 
       nmdestin, 
       nmformul, 
       indaudit, 
       cdcooper, 
       periodic, 
       tprelato, 
       inimprel, 
       ingerpdf, 
       dsdemail, 
       cdfilrel, 
       nrseqpri
  FROM craprel  
WHERE cdrelato = 813; 
COMMIT;
END;
