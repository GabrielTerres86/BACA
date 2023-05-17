begin
update cecred.craplau aa set aa.insitlau = 1, aa.dtdebito = null where   aa.nrdconta = 99952670 and aa.cdcooper=13 and aa.cdhistor = 3651 and aa.cdseqtel = '202304955207';
update cecred.craplau aa set aa.insitlau = 1, aa.dtdebito = null where   aa.nrdconta = 99883619 and aa.cdcooper=5 and aa.cdhistor = 3651 and aa.cdseqtel = '202302056152';
commit;
end;
