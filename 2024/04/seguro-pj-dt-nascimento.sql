begin

update cecred.crapass s 
set s.dtnasctl = to_date('21/03/1991','dd/mm/yyyy')
where s.cdcooper = 14 and nrdconta = 82302103;

commit;
end;