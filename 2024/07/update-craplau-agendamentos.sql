begin
  
update cecred.craplau lau
  set  lau.dtmvtopg = to_date('23/07/2024','dd/mm/yyyy')
WHERE  lau.cdcooper = 11 
   AND lau.dsorigem IN ('INTERNET', 'TAA')
   AND lau.insitlau = 1 
   AND lau.dtmvtopg = to_date('24/07/2024','dd/mm/yyyy')
   AND lau.cdtiptra <> 4
   and lau.cdhistor = 508
   and substr(dscodbar,1,1) = '8'
   and lau.nrdconta = 81333820;

commit;
end;
