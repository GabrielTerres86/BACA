begin
  
update cecred.crapddc ddc 
  set ddc.flgpcctl = 0 
WHERE ddc.cdcooper = 3 
   AND ddc.dtmvtolt = to_date('08/07/2022','DD/MM/YYYY')
   AND ddc.flgdevol = 1 
   AND ddc.flgpcctl = 1;
   
commit;
end;
