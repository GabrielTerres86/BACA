BEGIN
  UPDATE craplot l 
     SET l.vlcompdb = 166300000.00
        ,l.vlinfodb = 166300000.00
        ,l.vlinfocr = 0
        ,l.vlcompcr = 0
        ,l.qtcompln = 6
        ,l.qtinfoln = 6 
   WHERE l.cdcooper = 3 
     AND l.dtmvtolt = to_date('19/08/2021','dd/mm/yyyy') 
     AND l.nrdolote = 4110;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
