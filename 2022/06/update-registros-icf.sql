begin
 
update cecred.crapicf f 
  set f.dtmvtolt = to_date('24/06/2022','DD/MM/YYYY') 
where  f.intipreq = 1 
  and  f.dtfimreq is null
  and  f.cdagereq in (206,246);

commit;
end;
