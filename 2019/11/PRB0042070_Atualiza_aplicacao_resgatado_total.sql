BEGIN
  UPDATE craprda rda
     SET rda.insaqtot = 1
        ,rda.dtsaqtot = to_date('05/11/2019','DD/MM/RRRR')
   WHERE rda.vlsdrdca <= 0
     AND rda.insaqtot = 0
     AND rda.dtfimper BETWEEN to_date('01/01/2019','DD/MM/RRRR') AND to_date('05/11/2019','DD/MM/RRRR')
     AND rda.tpaplica IN (7,8);
     
  COMMIT;
END;
