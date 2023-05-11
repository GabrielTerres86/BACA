begin

update cecred.craplau l
   set l.dtmvtolt = to_date('11/11/2022','dd/mm/yyyy')
 where l.nrctremp in (100779,100787) 
   and cdcooper = 14;
   
commit;

end;
   