BEGIN
  
update cecred.craplau u
  set u.dtmvtopg = to_date('18/06/2024','DD/MM/YYYY')
where  u.cdcooper in (5,9)
  and  u.cdhistor = 3826
  and  u.insitlau = 1
  and  u.dtmvtopg > sysdate;
  
COMMIT;
END;
