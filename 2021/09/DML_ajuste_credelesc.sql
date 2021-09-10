BEGIN
  UPDATE craplem s
     SET s.dtmvtolt = to_date('10/08/2021', 'DD/MM/RRRR')
   WHERE s.cdcooper = 8
     AND s.dtmvtolt = to_date('25/08/2021', 'DD/MM/RRRR');

  UPDATE craplcm s
     SET s.dtmvtolt = to_date('10/08/2021', 'DD/MM/RRRR') ,
         s.nrseqdig = nrseqdig + 10
   WHERE s.cdcooper = 8
     AND s.dtmvtolt = to_date('25/08/2021', 'DD/MM/RRRR');

  DELETE crapris s
   WHERE s.cdcooper = 8
     AND s.dtrefere > to_date('09/08/2021', 'DD/MM/RRRR');

  DELETE crapsda s
   WHERE s.cdcooper = 8
     AND s.dtmvtolt > to_date('09/08/2021', 'DD/MM/RRRR');   
  
  COMMIT;
     
END;  
