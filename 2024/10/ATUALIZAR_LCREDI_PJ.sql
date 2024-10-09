DECLARE 
  CURSOR cr_ativar_contributario IS
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 1 AND l.cdlcremp IN (900,2700)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 2 AND l.cdlcremp IN (4604,4605,4606,4625)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 5 AND l.cdlcremp IN (142,814,815,816,817)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 6 AND l.cdlcremp IN (128,129)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 7 AND l.cdlcremp IN (300,301,26014)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 8 AND l.cdlcremp IN (148,470)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 9 AND l.cdlcremp IN (4626,9619,671,2180)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 10 AND l.cdlcremp IN (401,402,410,411,437,438,662)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 11 AND l.cdlcremp IN (219,865,1000)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 12 AND l.cdlcremp IN (313,314,2602,2601)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 13 AND l.cdlcremp IN (423)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 14 AND l.cdlcremp IN (3089,3090,8109,8132,3143,3325,3327,3328,3329,3330);
 
  CURSOR cr_desativar_prestamista IS
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 1 AND l.cdlcremp IN (10000,10006,10007,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 4 AND l.cdlcremp IN (100,800,900,48,6901);

  CURSOR cr_desativar_contributario IS
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 2 AND l.cdlcremp IN (10000,10006,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 5 AND l.cdlcremp IN (10000,10006,10007,16900,16901,16902)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 5 AND l.cdlcremp IN (10000,10006,10007,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 6 AND l.cdlcremp IN (10000,10006,10007,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 7 AND l.cdlcremp IN (8888,10000,10006,10007,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 8 AND l.cdlcremp IN (10000,10006,10007,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 9 AND l.cdlcremp IN (10000,10006,10007,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 10  AND l.cdlcremp IN (10000,10006,10007,11000,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 11  AND l.cdlcremp IN (10000,10006,10007,11000,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 12  AND l.cdlcremp IN (10000,10006,10007,11000,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 13  AND l.cdlcremp IN (10000,10006,10007,11000,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 14  AND l.cdlcremp IN (10000,10006,10007,11000,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 15  AND l.cdlcremp IN (900)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 16  AND l.cdlcremp IN (10000,10006,10007,11000,16900,16901,16902,20006)
    UNION ALL
    SELECT l.cdcooper, l.cdlcremp, l.tpcuspr, l.flgsegpr, l.dslcremp FROM cecred.craplcr l WHERE l.cdcooper = 17  AND l.cdlcremp IN (6901,6902,6903,6904,6905);

BEGIN
  
  FOR rw_ativar_contributario IN cr_ativar_contributario LOOP
    
    UPDATE cecred.craplcr l
       SET l.tpcuspr = 0,
           l.flgsegpr = 1
     WHERE l.cdcooper = rw_ativar_contributario.cdcooper
       AND l.cdlcremp = rw_ativar_contributario.cdlcremp;  
  END LOOP;
  COMMIT;
  
  FOR rw_desativar_prestamista  IN cr_desativar_prestamista LOOP
    UPDATE cecred.craplcr l
       SET l.flgsegpr = 0
     WHERE l.cdcooper = rw_desativar_prestamista.cdcooper
       AND l.cdlcremp = rw_desativar_prestamista.cdlcremp;  
  END LOOP;
  COMMIT;
  
  FOR rw_desativar_contributario IN cr_desativar_contributario LOOP
    
    UPDATE cecred.craplcr l
       SET l.tpcuspr = 1,
           l.flgsegpr = 0
     WHERE l.cdcooper = rw_desativar_contributario.cdcooper
       AND l.cdlcremp = rw_desativar_contributario.cdlcremp;
  END LOOP;
  COMMIT;
  
END;
