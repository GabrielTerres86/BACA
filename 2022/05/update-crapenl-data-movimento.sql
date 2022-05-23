begin
 
update cecred.crapenl crapenl
  set crapenl.dtmvtolt = to_date('23/05/2022','DD/MM/YYYY') 
where  crapenl.cdcooper = 5
  AND crapenl.dtmvtolt = '25/04/2022' 
  and crapenl.cdagetfn = 10     
  AND crapenl.nrterfin = 11 
  and crapenl.vlchqinf > 20000
  and  crapenl.cdsitenv = 0;

commit;
end;
