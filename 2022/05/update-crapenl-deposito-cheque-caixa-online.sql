begin
  
update cecred.crapenl crapenl
  set crapenl.vlchqinf = 30000
where  crapenl.cdcooper = 5
  AND crapenl.dtmvtolt = to_date('25/04/2022','DD/MM/YYYY')
  and crapenl.cdagetfn = 10     
  AND crapenl.nrterfin = 11;
  
commit;
end;
