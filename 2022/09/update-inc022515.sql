begin

update cecred.craplcm m 
  set m.dsidenti = 748806320180129865
where  m.cdcooper = 9
   and m.nrdconta in (99747227, 252719)
   and m.dtmvtolt = to_date('11/08/2022','DD/MM/YYYY')
   and m.nrdocmto = 55670016;
   
commit;
end;



