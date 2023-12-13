begin
update CECRED.GNCONTR CTR set CTR.DTMVTOLT = to_date('08/08/2022','dd/mm/yyyy')
where  CTR.CDCONVEN = 58 and  CTR.DTMVTOLT = to_date('18/10/2023','dd/mm/yyyy'); 

commit;
end;

