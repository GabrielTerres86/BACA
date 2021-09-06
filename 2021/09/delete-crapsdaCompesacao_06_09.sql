begin
  delete crapsda
  where  cdcooper = 8
    and  dtmvtolt between '08/08/2021' and '31/08/2021';
commit;
end;
