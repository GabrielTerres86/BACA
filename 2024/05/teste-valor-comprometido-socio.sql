begin

update seguro.tbseg_contrato_socio_pj s
set s.vlcobertura = 100000
where cdcooper = 5
and nrdconta = 99966140
and nrctrseg = 147245;

update seguro.tbseg_contrato_socio_pj s
set s.vlcobertura = 600000
where cdcooper = 5
and nrdconta = 99966140
and nrctrseg = 147249;

insert into crapseg(nrdconta,nrctrseg,dtinivig,dtfimvig,dtmvtolt,cdsitseg,tpseguro,cdcooper)
values (99966140,147245,to_date('24/04/2024','dd/mm/yyyy'),to_date('10/05/2024','dd/mm/yyyy'),to_date('24/04/2024','dd/mm/yyyy'),1,4,5);
insert into crapseg(nrdconta,nrctrseg,dtinivig,dtfimvig,dtmvtolt,cdsitseg,tpseguro,cdcooper)
values (99966140,147249,to_date('24/04/2024','dd/mm/yyyy'),to_date('10/05/2024','dd/mm/yyyy'),to_date('24/04/2024','dd/mm/yyyy'),1,4,5);

commit;
end;