begin
    UPDATE crappep
       SET vljura60 = (vlsdvatu - 23779.66 )
     WHERE cdcooper = 9
       AND nrdconta = 32611
       AND nrctremp = 17837
       AND nrparepr = 1;
    COMMIT;
exception
  when others then
    rollback;
end;