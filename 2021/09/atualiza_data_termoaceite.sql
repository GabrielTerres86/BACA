begin
   update crapcdr
    set dtacectr = null
    where nrdconta = '2529033'
    and cdcooper =  1;
    commit;
exception
  WHEN others THEN
    begin
    raise_application_error(-20501, SQLERRM);
    rollback;
    end;
end;  
/