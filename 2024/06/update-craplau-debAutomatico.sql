BEGIN
  
update cecred.craplau u
  set u.dtmvtopg = to_date('19/06/2024','DD/MM/YYYY')
where  u.cdcooper in (5,9,2)
  and  u.cdhistor in (4395, 667)
  and  u.insitlau = 1
  and  u.dtmvtopg > sysdate;
  
COMMIT;
END;
