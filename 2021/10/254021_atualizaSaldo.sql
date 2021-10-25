begin
  update crapsda set vlsddisp = 2000000 where nrdconta = 3048020 and cdcooper = 1 and dtmvtolt = '14/10/2021';
  commit;
exception
  WHEN others THEN
    rollback;
    raise_application_error(-20501, SQLERRM);
end;
/
