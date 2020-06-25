begin

  update craplcm c
     set c.cdhistor = 1015
   where c.cdcooper = 1
     and c.nrdconta = 313149
     and c.dtmvtolt = '25/06/2020'
     and c.progress_recid = 893908561
  ;

  commit;

end;