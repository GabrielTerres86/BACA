begin
update  crapass a
set a.DTNASCTL = to_date('30/03/2022','dd/mm/yyyy')
where a.nrdconta = 80089534
and   a.cdcooper = 1;
commit;
end;
