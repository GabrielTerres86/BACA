DECLARE
  vr_dttransa                     cecred.craplgm.dttransa%type;
  vr_hrtransa                     cecred.craplgm.hrtransa%type;
  vr_nrdconta                     cecred.crapass.nrdconta%type;
  vr_cdcooper                     cecred.crapcop.cdcooper%type;
  vr_cdoperad                     cecred.craplgm.cdoperad%TYPE;
  vr_nrdrowid                     ROWID;
  vr_cdcritic                     cecred.crapcri.cdcritic%type;  
  vr_dscritic                     cecred.crapcri.dscritic%type;  
  vr_globalname                   varchar2(100);
  
  vc_dstransaStatusCC             CONSTANT VARCHAR2(4000) := 'Alteracao da Data de Demissao via script - PRB0047805';
  vc_bdprod                       CONSTANT VARCHAR2(100) := 'AYLLOSP';
  
  CURSOR cr_crapass(pr_globalname varchar2) is
    SELECT t.cdcooper
          ,t.nrdconta
          ,t.dtdemiss as dtdemiss_old
          ,a.dtdemiss as dtdemiss_new
          ,t.cdmotdem as cdmotdem_old
          ,a.cdmotdem as cdmotdem_new
      FROM CECRED.CRAPASS t
         ,(select 1 as cdcooper, decode(pr_globalname, vc_bdprod, 11828510,88171426) as nrdconta, to_date('13/07/2021','dd/mm/yyyy') as dtdemiss, 11 as  cdmotdem from dual union all
           select 1 as cdcooper, decode(pr_globalname, vc_bdprod, 8288445,91711495) as nrdconta, to_date('23/02/2021','dd/mm/yyyy') as dtdemiss, 11 as  cdmotdem from dual union all
           select 1 as cdcooper, decode(pr_globalname, vc_bdprod, 6132618,93867328) as nrdconta, to_date('14/05/2021','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 1 as cdcooper, decode(pr_globalname, vc_bdprod, 12354651,87645289) as nrdconta, to_date('14/05/2021','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 2 as cdcooper, decode(pr_globalname, vc_bdprod, 950165,99049775) as nrdconta, to_date('23/06/2022','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 2 as cdcooper, decode(pr_globalname, vc_bdprod, 1019600,98980335) as nrdconta, to_date('30/07/2021','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 2 as cdcooper, decode(pr_globalname, vc_bdprod, 986658,99013282) as nrdconta, to_date('28/07/2021','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 5 as cdcooper, decode(pr_globalname, vc_bdprod, 303380,99696550) as nrdconta, to_date('08/11/2021','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 9 as cdcooper, decode(pr_globalname, vc_bdprod, 333964,99665972) as nrdconta, to_date('15/06/2020','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 10 as cdcooper, decode(pr_globalname, vc_bdprod, 180602,99819333) as nrdconta, to_date('01/09/2021','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 11 as cdcooper, decode(pr_globalname, vc_bdprod, 628417,99371529) as nrdconta, to_date('02/10/2020','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 11 as cdcooper, decode(pr_globalname, vc_bdprod, 876194,99123746) as nrdconta, to_date('30/01/2021','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual union all
           select 11 as cdcooper, decode(pr_globalname, vc_bdprod, 655244,99344696) as nrdconta, to_date('06/10/2020','dd/mm/yyyy')  as dtdemiss, 11 as  cdmotdem from dual
           ) a
     WHERE 1=1
       AND t.cdcooper = a.cdcooper
       AND t.nrdconta = a.nrdconta
     order by a.cdcooper, a.nrdconta;
     
  rg_crapass                      cr_crapass%rowtype;
     
BEGIN
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
  
  SELECT GLOBAL_NAME
    INTO vr_globalname
    FROM GLOBAL_NAME;  
  
  FOR rg_crapass IN cr_crapass(vr_globalname) LOOP
    
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;
              
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscritic => vr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaStatusCC,
                                pr_dttransa => vr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => vr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => rg_crapass.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
                         
    IF (rg_crapass.dtdemiss_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtdemiss',
                                       pr_dsdadant => rg_crapass.dtdemiss_old,
                                       pr_dsdadatu => rg_crapass.dtdemiss_new);
    END IF;
                              
    IF (rg_crapass.cdmotdem_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.cdmotdem',
                                       pr_dsdadant => rg_crapass.cdmotdem_old,
                                       pr_dsdadatu => rg_crapass.cdmotdem_new); 
    END IF;
                                                             
    update cecred.crapass a
       set a.dtdemiss = nvl(rg_crapass.dtdemiss_new, a.dtdemiss)
          ,a.cdmotdem = nvl(rg_crapass.cdmotdem_new, a.cdmotdem)
          ,a.dtelimin = nvl(rg_crapass.dtdemiss_new, a.dtdemiss)
     where a.cdcooper = rg_crapass.cdcooper
       and a.nrdconta = rg_crapass.nrdconta;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20003,
                            'Erro geral script -> cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
