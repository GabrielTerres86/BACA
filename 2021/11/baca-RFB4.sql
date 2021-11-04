begin

update craplau set craplau.tpdvalor = 0 where craplau.cdcooper = 16  and craplau.nrdconta = 709131 AND   craplau.insitlau = 1 AND   craplau.dsorigem IN ('INTERNET','TAA', 'PORTABILIDAD','AIMARO');

commit;

end;