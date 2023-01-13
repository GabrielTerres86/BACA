begin
  
update cecred.crapage d 
  set d.cdagepac = 0
where d.cdcooper = 6
  and d.cdagenci= 8;
   
commit;
end;

