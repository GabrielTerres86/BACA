BEGIN
  
  UPDATE crapbdt t
     SET t.dtliqprj = to_date('07/04/2021','DD/MM/RRRR')
   WHERE t.inprejuz = 1
     AND t.dtliqprj IS NULL
     AND t.cdcooper = 1
     AND t.nrborder = 713249;
     
  COMMIT;   

END;
