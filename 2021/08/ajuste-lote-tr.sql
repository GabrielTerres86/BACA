BEGIN
  UPDATE craplot l 
     SET l.vlcompdb = l.vlinfodb
        ,l.qtcompln = l.qtinfoln
   WHERE l.cdcooper = 3 
     AND l.dtmvtolt = to_date('19/08/2021','dd/mm/yyyy') 
     AND l.nrdolote = 4110;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
