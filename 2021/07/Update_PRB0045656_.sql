Begin 
update tbseg_prestamista set   tpregist = 3 where cdcooper = 1 and
 nrctrseg  in(711648,561133,313526,417386,417390,553543,312905,312893,417377 
              ,585429,714972,714971,174228,174228  
              ,707628,707628,707628,711288,760635,405061,409986,698570,644791,653291,664288);  
              
 update crapseg set cdsitseg = 1  where cdcooper = 1 and
 nrctrseg  in(711648,561133,313526,417386,417390,553543,312905,312893,417377 
              ,585429,714972,714971,174228,174228
              ,707628,707628,707628,711288,760635,405061,409986,698570,644791,653291,664288);

update crapass set dtnasctl = to_date('01/06/1950','DD/MM/YYYY') where  cdcooper = 1 and nrdconta = 2552787;
update tbseg_prestamista set dtnasctl = to_date('01/06/1950','DD/MM/YYYY') where  cdcooper = 1 and nrdconta = 2552787;

update crapass set dtnasctl = to_date('01/07/1950','DD/MM/YYYY') where  cdcooper = 1 and nrdconta = 8380279;
update tbseg_prestamista set dtnasctl = to_date('01/07/1950','DD/MM/YYYY') where  cdcooper = 1 and nrdconta = 8380279;

commit;
end;
/