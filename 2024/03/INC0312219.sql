BEGIN
  update cecred.craplau set
  dtdebito = '22/10/2019'
  where cdcooper = 1  
  and nrdconta = 9151133
  and dtmvtolt = '21/10/2019'
  and  substr(cdseqtel, 1, 21) in ('201910210000094325587' , '201910210000094325588');
  
  commit;
END;
