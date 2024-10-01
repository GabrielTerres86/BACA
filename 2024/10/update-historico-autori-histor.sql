begin
  
update cecred.craphis 
  set craphis.inautori = 0
WHERE craphis.cdcooper = 1 
  and craphis.dsexthst like '%POMER%'
  and craphis.cdhistor in (620,663,618,664,2026,4419,4420,4422)
  and craphis.inautori = 1;

commit;
end;
