declare 
  vr_cdcooper crapepr.cdcooper%type;
  vr_nrdconta crapepr.nrdconta%type;
  vr_nrctremp crapepr.nrctremp%type;
  vr_vlrpar   crappep.vlparepr%type;
begin
  vr_cdcooper := 1;
  vr_nrdconta := 3555909;
  vr_nrctremp := 5980967;
  vr_vlrpar   := 804.99;
  
  update crapepr epr
     set epr.vlpreemp = vr_vlrpar
   where epr.cdcooper = vr_cdcooper
     and epr.nrdconta = vr_nrdconta
     and epr.nrctremp = vr_nrctremp; 
   
  update crappep pep
     set pep.vlparepr = vr_vlrpar,
         pep.vlsdvpar = vr_vlrpar, 
         pep.vlsdvsji = vr_vlrpar
   where pep.cdcooper = vr_cdcooper
     and pep.nrdconta = vr_nrdconta
     and pep.nrctremp = vr_nrctremp;
  
  commit;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20500,SQLERRM);
END;
