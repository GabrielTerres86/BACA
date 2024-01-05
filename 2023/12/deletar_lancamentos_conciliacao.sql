begin
    update craplcm a set a.dtmvtolt = to_date('03/01/2024', 'dd/mm/yyyy'), a.nrseqdig = a.nrseqdig +100
    where a.dtmvtolt = to_date('02/01/2024', 'dd/mm/yyyy')
    and a.cdcooper = 8 
    and a.cdhistor in (2936,2937,2938,3239,3241);
   commit;
 end;