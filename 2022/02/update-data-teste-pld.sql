declare
begin  
update cecred.tbcalris_tanque tanque set tanque.cdstatus = 1 where tanque.nrcpfcgc in (72333938005, 12064245081, 37613080005);
commit;
end;
/