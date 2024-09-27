begin
  
update cecred.craphis 
  set craphis.inautori = 1
WHERE craphis.cdcooper = 1 
  and craphis.dsexthst like '%POMER%';

commit;
end;
