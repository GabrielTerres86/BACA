begin
  update craplcm t
     set t.vllanmto = 6400
   where t.NRDCONTA = 16615000
     and t.CDCOOPER = 2
     and t.CDHISTOR = 3813
     and t.nrdocmto = 1
     and t.dtmvtolt = to_date('27/10/2023', 'DD/MM/RRRR');
  commit;
end;
