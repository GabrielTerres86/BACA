begin

update crapdat t
  set t.inproces = 1 
where t.cdcooper = 16;

commit;

end;
