declare
 CURSOR cr_crapcop is
  select cdcooper
   from crapcop p;
 rw_crapcop cr_crapcop%rowtype;
 
 vr_nmsistem     crapprm.nmsistem%type := 'CRED';
 vr_cdacesso_pf  crapprm.cdacesso%type := 'REGRA_ANL_MOTOR_PF_RENG';
 vr_cdacesso_pf2 crapprm.cdacesso%type := 'REGRA_ANL_IBRA_RENEG_PF';
 vr_dstexprm_pf  crapprm.dstexprm%type := 'Nome da politica de credito a ser executada no Motor de Credito IBRATAN quando for renegociacao';
 vr_dsvlrprm_pf  crapprm.dsvlrprm%type := 'PoliticaRenegociacaoFacilitadaPF';
 
 --REGRA_ANL_MOTOR_PJ_RENG
 --REGRA_ANL_IBRA_RENEG_PJ
 vr_cdacesso_pj  crapprm.cdacesso%type := 'REGRA_ANL_MOTOR_PJ_RENG';
 vr_cdacesso_pj2 crapprm.cdacesso%type := 'REGRA_ANL_IBRA_RENEG_PJ';
 --PoliticaRenegociacaoFacilitadaPJ
 vr_dsvlrprm_pj  crapprm.dsvlrprm%type := 'PoliticaRenegociacaoFacilitadaPJ';
 
 
 

begin
  
  OPEN cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;
  CLOSE cr_crapcop;
  
  -- PF
  insert into crapprm p
  (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) 
  values 
  (vr_nmsistem, rw_crapcop.cdcooper, vr_cdacesso_pf , vr_dstexprm_pf, vr_dsvlrprm_pf);

  -- PF
  insert into crapprm p
  (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) 
  values 
  (vr_nmsistem, rw_crapcop.cdcooper, vr_cdacesso_pf2 , vr_dstexprm_pf, vr_dsvlrprm_pf);
  
  
  -- PJ
  insert into crapprm p
  (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) 
  values 
  (vr_nmsistem, rw_crapcop.cdcooper, vr_cdacesso_pj , vr_dstexprm_pf, vr_dsvlrprm_pj);

  -- PJ
  insert into crapprm p
  (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm) 
  values 
  (vr_nmsistem, rw_crapcop.cdcooper, vr_cdacesso_pj2 , vr_dstexprm_pf, vr_dsvlrprm_pj);
  
  commit;

end;
