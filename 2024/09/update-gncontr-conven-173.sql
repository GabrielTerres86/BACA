begin
  
update cecred.gncontr ctr
  set ctr.dtmvtolt = TO_DATE('20/09/2024','dd/mm/yyyy') 
WHERE CTR.TPDCONTR = 4
  AND CTR.DTMVTOLT = TO_DATE('19/09/2024','dd/mm/yyyy') 
  AND CTR.CDCONVEN = 173;


commit;
end;
