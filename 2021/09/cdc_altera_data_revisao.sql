begin
   update crapalt
      set dtaltera = dtaltera - 80
      WHERE cdcooper = 1
        AND   nrdconta = 10780424
        AND   tpaltera = 1;
   commit;
exception
  WHEN others THEN
    begin
    raise_application_error(-20501, SQLERRM);
    rollback;
    end;
end;  
/