begin

update cecred.crapatr set dtfimatr = to_date('24/11/2023','dd/mm/yyyy')
 where nrdconta in (82562210,82555737);
 
commit;

end;