BEGIN
   update CECRED.crapemp p
   set p.nmextemp = 'TESTETESTETESTETESTETESTETESTETESTETESTETESTETESTE'
   where p.nmextemp like '%HUMANO LTDA%' and
         p.cdcooper = 1 and
         p.cdempres = 81;
         
   COMMIT;
EXCEPTION
WHEN OTHERS THEN
  raise_application_error(-20010, SQLERRM);
END;