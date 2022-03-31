begin
update  crapass a
set a.DTNASCTL = '30/03/2022'
where a.nrdconta = 80089534
and   a.cdcooper = 1;
commit;
end;
