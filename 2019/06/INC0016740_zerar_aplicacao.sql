BEGIN
  
  UPDATE craprda a SET a.vlslfmea = 0,
                       a.vlsltxmx = 0,
                       a.vlsltxmm = 0,
                       a.vlsdextr = 0,
                       a.vlslfmes = 0,
                       a.dtsaqtot = TRUNC(SYSDATE),
                       a.insaqtot = 0,
                       a.vlsdrdca = 0 
   WHERE a.cdcooper = 12
   AND   a.nrdconta = 74195
   AND   a.nraplica = 38;  
   
  COMMIT;

END;   
