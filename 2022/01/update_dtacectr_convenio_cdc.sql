begin
    update crapcdr
    set dtacectr = null
    where nrdconta = 2492083 and cdcooper = 1 and progress_recid = 2879;
    commit;
    exception
      when OTHERS then
        rollback;
end;