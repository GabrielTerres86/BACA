begin

update cecred.crappco set dsconteu = 'S'
 where cdpartar = 262
   and cdcooper = 11;
   

 commit;
 
end;