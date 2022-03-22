begin
update craplft set craplft.nrrefere = 123456 where craplft.cdcooper = 8 and craplft.dtmvtolt >= '11/03/2022' and craplft.cdhistor = 3465 and craplft.vllanmto = 10;
commit;

end;