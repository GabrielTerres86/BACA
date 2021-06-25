BEGIN
  
  UPDATE craplcm x
     SET x.dtmvtolt = to_date('25/06/2021','DD/MM/RRRR')
  WHERE x.cdcooper = 12
  AND x.dtmvtolt = to_date('24/06/2021','DD/MM/RRRR')
  AND TRUNC(x.dttrans) >= to_date('24/06/2021','DD/MM/RRRR');

  UPDATE craplem x
     SET x.dtmvtolt = to_date('25/06/2021','DD/MM/RRRR')
  WHERE x.cdcooper = 12
  AND x.dtmvtolt = to_date('24/06/2021','DD/MM/RRRR')
  AND x.dthrtran >= to_date('24/06/2021','DD/MM/RRRR');

  UPDATE tbdsct_lancamento_bordero x
     SET x.dtmvtolt = to_date('25/06/2021','DD/MM/RRRR')
  WHERE x.cdcooper = 12
  AND x.dtmvtolt = to_date('24/06/2021','DD/MM/RRRR')
  AND x.dtrefatu >= to_date('24/06/2021','DD/MM/RRRR');


  COMMIT;

END;
