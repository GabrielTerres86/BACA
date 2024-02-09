begin
delete cecred.craplcm
 where cdcooper = 1
   and dtmvtolt = to_date('17/10/2023')
   and nrdolote = 10117;

delete cecred.crapsol where nrsolici = 78;

commit;
end;
