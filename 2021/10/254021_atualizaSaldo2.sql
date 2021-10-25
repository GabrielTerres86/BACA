begin
   update crapsda set vlsddisp = 2000000.74 where nrdconta = 3048020 and cdcooper = 1 and dtmvtolt = to_date('14/10/2021', 'dd/mm/yyyy');
commit;
exception
WHEN others THEN
rollback;
raise_application_error(-20501, SQLERRM);
 end;
/
