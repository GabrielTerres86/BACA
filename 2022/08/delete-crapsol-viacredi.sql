begin
  
delete cecred.crapsol s where s.cdcooper = 1 and s.dtrefere = to_date('27/07/2022','DD/MM/YYYY');

commit;
end;
