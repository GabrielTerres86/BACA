Begin 
update crapass set dtnasctl = to_date('01/07/1950','DD/MM/YYYY') where  cdcooper = 1 and nrdconta in (2200368 , 2780844, 907472);
update tbseg_prestamista set dtnasctl = to_date('01/07/1950','DD/MM/YYYY') where  cdcooper = 1 and nrdconta in (2200368 , 2780844, 907472);

commit;
end;
/     