begin

update cecred.craplau
  set insitlau = 3, dtdebito = TRUNC(SYSDATE)
WHERE craplau.cdcooper = 1
  and craplau.cdtiptra IN (4, 22)
  and craplau.dtmvtopg = TRUNC(SYSDATE)
  and craplau.insitlau = 1
  and cdhistor = 555;

commit;

end;
