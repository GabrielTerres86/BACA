declare
begin  
update cecred.crapass set dtabtcct = trunc(SYSDATE) - 1 where nrdconta = 434000 and cdcooper = 7;
commit;
end;
/