begin

update cecred.crapass set cdsitdct = 8
 where cdcooper = 6
   and nrdconta = 99827506;
   
commit;
end;
/