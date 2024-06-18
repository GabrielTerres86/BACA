BEGIN
  
update cecred.craplau u
  set u.dtmvtopg = '18/06/2024'
where  u.cdcooper = 2
  and  u.cdhistor = 3826
  and  u.insitlau = 1
  and  u.dtmvtopg > sysdate;
  
COMMIT;
END;
