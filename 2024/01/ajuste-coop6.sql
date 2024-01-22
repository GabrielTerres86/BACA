begin
delete from crapsda a
where a.cdcooper = 6
and   a.dtmvtolt >= to_date('20/01/2024','dd/mm/yyyy');
commit;
end;
