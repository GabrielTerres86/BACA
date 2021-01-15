begin
    UPDATE crapsld
       SET vlsmnmes = 0 --> -0.03
          ,vljuresp = 0 --> 0.91
    WHERE cdcooper = 1
      AND nrdconta = 10274600;
    COMMIT;
exception
  when others then
    rollback;
end;