begin
update cecred.gncontr 
   set dtmvtolt = to_date('20/09/2024','dd/mm/yyyy')
   where cdconven in (172,173) 
   and tpdcontr in (1,4) 
   and cdcooper = 7 
   and dtmvtolt = to_date('19/04/2024','dd/mm/yyyy');
commit; 
end;
