begin
update cecred.gncontr 
   set dtmvtolt = to_date('20/09/2024','dd/mm/yyyy'),
       tpdcontr = 4
   where cdconven in (172,173) 
   and tpdcontr = 1
   and dtmvtolt = to_date('19/04/2024','dd/mm/yyyy');
commit; 
end;
