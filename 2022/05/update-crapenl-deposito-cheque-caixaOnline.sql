begin
 
update crapenl crapenl
  set crapenl.vlchqinf = '25000' 
where  crapenl.cdcooper = 5
  AND crapenl.dtmvtolt = to_date('25/04/2022','DD/MM/YYYY') 
  and crapenl.cdagetfn = 15     
  AND crapenl.nrterfin = 10;
  
commit;
end;
