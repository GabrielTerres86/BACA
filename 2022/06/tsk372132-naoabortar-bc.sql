BEGIN
    DELETE cecred.craplcm lcm
     WHERE lcm.cdcooper = 10
       AND lcm.dtmvtolt = to_date('30/12/2021' , 'dd/mm/yyyy')
       AND lcm.cdhistor = 3018
       AND lcm.nrdconta = 194743
       AND lcm.nrparepr = 0;
       
   COMMIT;
   
EXCEPTION 
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
