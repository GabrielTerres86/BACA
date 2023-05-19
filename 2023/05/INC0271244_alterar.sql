begin
update cedred.craplau aa set aa.insitlau = 3, aa.dtdebito= (select a.dtmvtolt from cedred.crapdat a where a.cdcooper = 13) where aa.nrdconta = 47260 and aa.cdcooper = 13 and aa.cdhistor = 3651 and aa.cdseqtel = '202304955207' ;
update cedred.craplau aa set aa.insitlau = 3, aa.dtdebito= (select a.dtmvtolt from cedred.crapdat a where a.cdcooper = 5)  where aa.nrdconta = 116327 and aa.cdcooper = 5 and aa.cdhistor = 3651 and aa.cdseqtel = '202302056152' ;
commit;
end;
