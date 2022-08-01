begin

update cecred.craphec c
  set c.dtultexc = null
where  c.dsprogra  like 'ICF';
commit;


update cecred.crapenl crapenl
  set crapenl.dtmvtolt = to_date('23/05/2022','DD/MM/YYYY') 
where  crapenl.cdcooper = 5
  AND crapenl.dtmvtolt = to_date('25/04/2022','DD/MM/YYYY') 
  and crapenl.cdagetfn = 10     
  AND crapenl.nrterfin = 11 
  and crapenl.vlchqinf > 20000
  and  crapenl.cdsitenv = 0;

commit;
end;
