declare 
  
begin

  UPDATE craplcr
     SET craplcr.vlperidx = 100
   WHERE craplcr.tpprodut = 2;

  UPDATE crawepr
     SET crawepr.vlperidx = 100
   WHERE crawepr.tpemprst = 2;

  commit;  
end;