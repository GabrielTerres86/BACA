begin
  update cecred.CRAWEPR w
     set w.vlpreemp = 958.95,
         w.vlpreori = 958.95
   where w.cdcooper = 1
     and w.nrdconta = 80145264
     and w.nrctremp = 5206569;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 958.95
   where epr.cdcooper = 1
     and epr.nrdconta = 80145264
     and epr.nrctremp = 5206569;
     
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;