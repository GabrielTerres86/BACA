begin

update cecred.crapseg s
set s.cdsitseg = 2
where cdcooper = 5
and nrdconta = 99966140
and nrctrseg = 147245;

commit;
end;