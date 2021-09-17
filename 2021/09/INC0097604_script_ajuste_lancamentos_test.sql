BEGIN

update cecred.craplcm
set cdcoptfn = 16
where dtmvtolt = to_date('14/06/2021','DD/MM/YYYY')
  and cdcoptfn = 7
  and vllanmto = 900
  and nrdconta = 243361
  and cdcooper = 16;


update cecred.craplcm
set cdcoptfn = 16
where dtmvtolt = to_date('15/06/2021','DD/MM/YYYY')
  and cdcoptfn = 7
  and vllanmto = 40
  and nrdconta = 243361
  and cdcooper = 16;


delete from cecred.craplgi
where nmdcampo = 'craplcm.cdcoptfn'
  and idseqttl = 1
  and nrsequen = 1
  and hrtransa = 447647000
  and dttransa = '06/09/2021'
  and progress_recid = 40
  and cdcooper  = 16
  and nrdconta  = 243361;

  
delete from cecred.craplgi
where nmdcampo = 'craplcm.cdcoptfn'
  and idseqttl = 1
  and nrsequen = 1
  and hrtransa = 531225000
  and dttransa = '06/09/2021'
  and progress_recid = 900
  and cdcooper  = 16
  and nrdconta  = 243361;


COMMIT;

EXCEPTION
 WHEN OTHERS THEN
   BEGIN
   
     ROLLBACK;

     RAISE_APPLICATION_ERROR(-20000, 'Erro na execução do script '|| SQLCODE || ' - '|| SQLERRM);

   END;
   
END;
/