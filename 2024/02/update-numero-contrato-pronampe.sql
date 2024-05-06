declare
  vr_exc_saida     EXCEPTION;
  
  i integer;
 
  vr_cdcooper      crapcop.cdcooper%TYPE;
  vr_nrdconta      crapass.nrdconta%TYPE;
  vr_nrctrempa     craplem.nrctremp%TYPE;
  vr_nrctrempd     craplem.nrctremp%TYPE;
 
  TYPE cooperativa_info IS RECORD (
    cooperativa crapcop.cdcooper%TYPE,
    conta crapass.nrdconta%TYPE,
    contratoant craplem.nrctremp%TYPE,
	contratodep craplem.nrctremp%TYPE
  );
  
  TYPE cooperativa_list IS TABLE OF cooperativa_info;
  vr_coop_list cooperativa_list := cooperativa_list(
    cooperativa_info(2, 98961942, 481381, 3074669),
    cooperativa_info(2, 99195240, 491950, 3075571),
    cooperativa_info(2, 99206846, 489054, 3076639)
  );
  
BEGIN
  FOR i IN vr_coop_list.FIRST..vr_coop_list.LAST LOOP 
  
    vr_cdcooper := vr_coop_list(i).cooperativa;
    vr_nrdconta := vr_coop_list(i).conta;
    vr_nrctrempa := vr_coop_list(i).contratoant;
    vr_nrctrempd := vr_coop_list(i).contratodep;
  
    update cecred.crapavl t 
      set t.nrctravd = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrctaavd = vr_nrdconta 
      and t.nrctravd = vr_nrctrempa;
       
    update cecred.crapavt t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa 
      and tpctrato in (1,4);
         
    update cecred.crawcrd t 
      set t.nrctrcrd = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctrcrd = vr_nrctrempa;
         
    update cecred.crapprp t 
      set t.nrctrato = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctrato = vr_nrctrempa 
      and t.tpctrato = 90;
         
    update cecred.crapbpr t 
      set t.nrctrpro = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctrpro = vr_nrctrempa 
      and t.tpctrpro = 90;
        
    update cecred.craprpr t 
      set t.nrctrato = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctrato = vr_nrctrempa 
      and t.tpctrato = 90;
        
    update cecred.crappep t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa;
        
    update cecred.tbrating_historicos t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa 
      and t.tpctrato = 90;
        
    update cecred.tbrisco_operacoes t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa 
      and t.tpctrato = 90;
       
    update cecred.crawepr t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa;
       
    update cecred.crapepr t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa;
       
    update cecred.craplem t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa;
       
    update cecred.tbepr_portabilidade t 
      set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper 
      and t.nrdconta = vr_nrdconta 
      and t.nrctremp = vr_nrctrempa;
    
    update cecred.tbgar_cobertura_operacao t 
      set t.nrcontrato = vr_nrctrempd
    where t.idcobertura = (select x.idcobope from cecred.crawepr x where x.cdcooper = vr_cdcooper and x.nrdconta = vr_nrdconta and x.nrctremp = vr_nrctrempa);
    
    update cecred.tbepr_consignado t
    set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper
    and t.nrdconta = vr_nrdconta
    and t.nrctremp = vr_nrctrempa;
    
    update cecred.tbepr_calculo_cet t
    set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper
    and t.nrdconta = vr_nrdconta
    and t.nrctremp = vr_nrctrempa;
    
    update cecred.tbgen_iof_lancamento t
    set t.nrcontrato = vr_nrctrempd
    where t.cdcooper = vr_cdcooper
    and t.nrdconta = vr_nrdconta
    and t.nrcontrato = vr_nrctrempa;
    
    update cecred.crapris t
    set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper
    and t.nrdconta = vr_nrdconta
    and t.nrctremp = vr_nrctrempa;
    
    update cecred.crapvri t
    set t.nrctremp = vr_nrctrempd
    where t.cdcooper = vr_cdcooper
    and t.nrdconta = vr_nrdconta
    and t.nrctremp = vr_nrctrempa;
                 
    commit;
  END LOOP;
exception 
  when others then
    rollback;
    raise_application_error(-20500, SQLERRM);
end;