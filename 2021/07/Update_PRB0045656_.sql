Begin 
update tbseg_prestamista set   tpregist = 3 where cdcooper = 13 and
 nrctrseg  in  (71906,71908,104593,104595,72392,210125,134996,36349,92288,108031,50853,73209,132551); 

 update crapseg set cdsitseg = 1  where cdcooper = 13 and
 nrctrseg  in  (71906,71908,104593,104595,72392,210125,134996,36349,92288,108031,50853,73209,132551);

update crapass           set dtnasctl = to_date('01/06/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (383805);
update tbseg_prestamista set dtnasctl = to_date('01/06/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (383805);

update crapass           set dtnasctl = to_date('05/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (53007);
update tbseg_prestamista set dtnasctl = to_date('05/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (53007);

update crapass           set dtnasctl = to_date('01/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (174041);
update tbseg_prestamista set dtnasctl = to_date('01/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (174041);

update crapass           set dtnasctl = to_date('06/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (461750);
update tbseg_prestamista set dtnasctl = to_date('06/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (461750);

update crapass           set dtnasctl = to_date('06/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (340731);
update tbseg_prestamista set dtnasctl = to_date('06/07/1950','DD/MM/YYYY') where  cdcooper = 13 and nrdconta in (340731);

commit;
end;
/     