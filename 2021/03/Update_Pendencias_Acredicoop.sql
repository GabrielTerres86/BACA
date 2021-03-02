update crapdoc
  set flgdigit = 1, dtbxapen = trunc(SYSDATE)
where  cdcooper = 2
  and  flgdigit = 0
  and  dtbxapen is null
  and  tpdocmto = 84
  and  dtmvtolt <= '30/11/2020';
commit;    
