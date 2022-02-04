begin
  
delete crapsol 
where dtrefere = to_date('24/01/2022','DD/MM/YYYY') 
  and cdcooper = 8;
  
commit;
end;  
