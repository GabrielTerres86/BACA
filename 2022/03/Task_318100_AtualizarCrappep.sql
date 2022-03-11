declare
  v_vlsdvpar crappep.vlsdvpar%type := 0;
  v_vlsdvatu crappep.vlsdvatu%type := 0;
  v_inliquid crappep.inliquid%type := 1;
  v_vlpagpar crappep.vlpagpar%type := 181.67;
  
  v_cdcooper crappep.cdcooper%type := 1;
  v_nrdconta crappep.nrdconta%type := 11618191;
  v_nrctremp crappep.nrctremp%type := 4244536;
  v_nrparepr crappep.nrparepr%type := 6;
begin

  update crappep
     set vlsdvpar = v_vlsdvpar,
         vlsdvatu = v_vlsdvatu,
         inliquid = v_inliquid,
         vlpagpar = v_vlpagpar
   where cdcooper = v_cdcooper
     and nrdconta = v_nrdconta
     and nrctremp = v_nrctremp
     and nrparepr = v_nrparepr;

  commit;
exception
  when others then
    raise_application_error(-20500, sqlerrm);
    rollback;
end;