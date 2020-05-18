UPDATE crapseg s
   SET s.dtcancel = TRUNC(SYSDATE)  
     , s.cdsitseg = 2 
 WHERE s.progress_recid IN (795057, 795058, 795059, 795060);
 
COMMIT;
