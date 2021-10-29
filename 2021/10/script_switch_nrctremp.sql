declare
 vr_exc_saida     EXCEPTION;
 
  vr_cdcooper      crapcop.cdcooper%TYPE := 2;
  vr_nrdconta      crapass.nrdconta%TYPE := 918016;
  vr_nrctrempa     craplem.nrctremp%TYPE := 334799;
  vr_nrctrempd     craplem.nrctremp%TYPE := 297944;
  
BEGIN
   update crapavl t 
      set t.nrctravd = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrctaavd = vr_nrdconta 
      and t.nrctravd = vr_nrctrempa;
     
    update crapavt t 
       set t.nrctremp = vr_nrctrempd
     where t.cdcooper = vr_cdcooper 
       and t.nrdconta = vr_nrdconta 
       and t.nrctremp = vr_nrctrempa 
       and tpctrato in (1,4);
       
    update crawcrd t 
       set t.nrctrcrd = vr_nrctrempd
     where t.cdcooper = vr_cdcooper 
       and t.nrdconta = vr_nrdconta 
       and t.nrctrcrd = vr_nrctrempa;

    update crapprp t 
       set t.nrctrato = vr_nrctrempd
     where t.cdcooper = vr_cdcooper 
       and t.nrdconta = vr_nrdconta 
       and t.nrctrato = vr_nrctrempa 
       and t.tpctrato = 90;
       
    update crapbpr t 
       set t.nrctrpro = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctrpro = vr_nrctrempa 
      and t.tpctrpro = 90;
      
   update craprpr t 
      set t.nrctrato = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctrato = vr_nrctrempa 
      and t.tpctrato = 90;
      
   update crappep t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa;
      
   update tbrating_historicos t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa 
      and t.tpctrato = 90;
      
  update tbrisco_operacoes t 
     set t.nrctremp = vr_nrctrempd
   where t.cdcooper = vr_cdcooper 
     and t.nrdconta = vr_nrdconta 
     and t.nrctremp = vr_nrctrempa 
     and t.tpctrato = 90;
     
  update crawepr t 
    set t.nrctremp = vr_nrctrempd
  where t.cdcooper = vr_cdcooper 
    and t.nrdconta = vr_nrdconta 
    and t.nrctremp = vr_nrctrempa;
               
  commit;
exception 
  when others then
    rollback;
end;
