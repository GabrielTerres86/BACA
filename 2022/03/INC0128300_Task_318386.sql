declare 
  v_vlsdvpar crappep.vlsdvpar%type := 0;
  v_vlsdvatu crappep.vlsdvatu%type := 0;
  v_inliquid crappep.inliquid%type := 1;
  
  v_cdcooper crappep.cdcooper%type := 13;
  v_nrdconta crappep.nrdconta%type := 156680;
  v_nrctremp crappep.nrctremp%type := 125327;
  
  cursor crapperp_cur IS
    select nrparepr,
           vlparepr
      from crappep
     where cdcooper = v_cdcooper
       and nrdconta = v_nrdconta
       and nrctremp = v_nrctremp
       and inliquid = 0
    order by nrparepr;
    
  type crapperp_t is table of crapperp_cur%rowtype index by pls_integer;
  
  v_crappep crapperp_t;
  
begin
  open crapperp_cur;
  
  loop
    fetch crapperp_cur bulk collect into v_crappep;
    exit when crapperp_cur%NOTFOUND;
  end loop;
  
  forall idx in v_crappep.first .. v_crappep.last
    
    update crappep
       set vlsdvpar = v_vlsdvpar,
           vlsdvatu = v_vlsdvatu,
           inliquid = v_inliquid,
           vlpagpar = v_crappep(idx).vlparepr
     where cdcooper = v_cdcooper
       and nrdconta = v_nrdconta
       and nrctremp = v_nrctremp
       and nrparepr = v_crappep(idx).nrparepr;
    
  close crapperp_cur;

  commit;
  
exception
    when others then
		  raise_application_error(-20500, sqlerrm);
		  rollback;
end;