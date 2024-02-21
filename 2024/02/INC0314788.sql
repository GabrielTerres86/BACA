begin

update cecred.crawcrd set
DDDEBITO = 22
where cdcooper = 16
and nrdconta = 1112 
and DDDEBITO = 32;

update cecred.crapcrd set
DDDEBITO = 22
where cdcooper = 16
and nrdconta = 1112 
and DDDEBITO = 32;

commit;
end;
