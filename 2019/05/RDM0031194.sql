prompt RDM0031194

set feedback off
set define off


update crapepr e set e.dtdpagto = to_date('20/03/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3645681 and  nrctremp = 262726;
update crapepr e set e.dtdpagto = to_date('10/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 4036271 and  nrctremp = 899253;


commit;

prompt Done.
