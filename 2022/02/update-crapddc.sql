begin

update crapddc ddc
  set ddc.flgpcctl = 0
     WHERE ddc.cdcooper = 1
       AND ddc.dtmvtolt = to_date('21/01/2022','DD/MM/YYYY')
       AND ddc.flgdevol = 1  
       AND ddc.flgpcctl = 1;
       
commit;
end; 
