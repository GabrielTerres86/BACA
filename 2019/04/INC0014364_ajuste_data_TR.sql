/*
INC0014364 - Ana - 30/04/2019
Ajustar datas contratos TR
select e.dtdpagto, nrdconta, e.nrctremp from crapepr e where cdcooper = 1 and nrdconta =2117266 and  nrctremp in (473510, 473526);
select e.dtdpagto, nrdconta, e.nrctremp from crapepr e where cdcooper = 1 and nrdconta =1830830 and  nrctremp = 236552;
select e.dtdpagto, nrdconta, e.nrctremp from crapepr e where cdcooper = 1 and nrdconta =646849 and  nrctremp = 786138;
*/



update crapepr e set e.dtdpagto = to_date('22/02/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta =2117266 and  nrctremp = 473510;

update crapepr e set e.dtdpagto = to_date('22/02/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta =2117266 and  nrctremp = 473526;

update crapepr e set e.dtdpagto = to_date('25/02/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta =1830830 and  nrctremp = 236552;

update crapepr e set e.dtdpagto = to_date('16/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta =646849 and  nrctremp = 786138;

COMMIT;
