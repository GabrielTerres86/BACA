DECLARE
  vr_dttransa                     cecred.craplgm.dttransa%type;
  vr_hrtransa                     cecred.craplgm.hrtransa%type;
  vr_nrdconta                     cecred.crapass.nrdconta%type;
  vr_cdcooper                     cecred.crapcop.cdcooper%type;
  vr_cdoperad                     cecred.craplgm.cdoperad%TYPE;
  vr_cdcritic                     cecred.crapcri.cdcritic%type;
  vr_dscritic                     cecred.crapcri.dscritic%TYPE;
  vr_nrdrowid                     ROWID;
  vr_des_reto                     VARCHAR2(3);
  
  vr_dtmvtolt                     DATE;
  vr_busca                        VARCHAR2(100);
  vr_nrdocmto                     INTEGER;
  vr_nrseqdig                     INTEGER;
  vr_vldcotas                     NUMBER;
  vr_vldcotas_crapcot             NUMBER;
  vr_vlsddisp                     cecred.crapsda.vlsddisp%type;
  vr_incrineg                     NUMBER;
  vr_index                        NUMBER;
  vr_cdhistor                     cecred.craphis.cdhistor%type;
  vr_globalname                   varchar2(100);
 
  
  vc_nrdolote_cota                CONSTANT cecred.craplct.nrdolote%type := 600040;
  vc_tpdevCotas                   CONSTANT NUMBER := 3;
  vc_tpdevDepVista                CONSTANT NUMBER := 4;
  vc_cdhistDepVistaPF             CONSTANT NUMBER := 2079;
  vc_cdhistDepVistaPJ             CONSTANT NUMBER := 2080;
  vc_cdhistCotasPF                CONSTANT NUMBER := 2079;
  vc_cdhistCotasPJ                CONSTANT NUMBER := 2080;  
  vc_dstransaStatusCC             CONSTANT VARCHAR2(4000) := 'Reativacao conta (INC0356059)';
  vc_dstransaDevCotas             CONSTANT VARCHAR2(4000) := 'Reativacao conta (INC0356059)';
  vc_dstransaDevDepVista          CONSTANT VARCHAR2(4000) := 'Reativacao conta (INC0356059)';
  vc_inpessoaPF                   CONSTANT NUMBER := 1;
  vc_inpessoaPJ                   CONSTANT NUMBER := 2; 
  vc_nrdolote_lanc                CONSTANT NUMBER := 37000;
  vc_cdbccxlt                     CONSTANT NUMBER := 1;
  vc_cdsitdctProcesDemis          CONSTANT NUMBER := 8;
  vc_cdsitdctEncerrada            CONSTANT NUMBER := 4;
  vc_bdprod                       CONSTANT VARCHAR2(100) := 'AYLLOSP';
  
  CURSOR cr_crapass is
    SELECT t.cdagenci
          ,t.cdcooper
          ,t.nrdconta
          ,t.inpessoa
          ,t.vllimcre
          ,t.cdsitdct as cdsitdct_old
          ,a.cdsitdct as cdsitdct_new
          ,t.dtdemiss as dtdemiss_old
          ,a.dtdemiss as dtdemiss_new
          ,t.dtelimin as dtelimin_old
          ,a.dtelimin as dtelimin_new
          ,t.dtasitct as dtasitct_old
          ,a.dtasitct as dtasitct_new
          ,t.cdmotdem as cdmotdem_old
          ,a.cdmotdem as cdmotdem_new    
      FROM CECRED.CRAPASS t
         ,(select 6   as cdcooper, decode(vr_globalname, vc_bdprod,  172430  ,99827506) as nrdconta, vc_cdsitdctProcesDemis as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual) a
     WHERE 1=1
       AND t.cdcooper = a.cdcooper
       AND t.nrdconta = a.nrdconta
     order by a.cdsitdct desc;
     
  rg_crapass                      cr_crapass%rowtype;
   
  rw_crapdat                      CECRED.BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_sald                     CECRED.EXTR0001.typ_tab_saldos;
  vr_tab_erro                     CECRED.GENE0001.typ_tab_erro;
  vr_tab_retorno                  cecred.LANC0001.typ_reg_retorno;
  vr_exc_sem_data_cooperativa     EXCEPTION;
  vr_exc_saldo                    EXCEPTION;
  vr_exc_lanc_conta               EXCEPTION;
  vr_inpessoa_invalido            EXCEPTION;
  
BEGIN
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;

  SELECT GLOBAL_NAME
  INTO vr_globalname
  FROM GLOBAL_NAME;

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 9);
  FETCH cecred.btch0001.cr_crapdat INTO rw_crapdat;
  
  IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE cecred.btch0001.cr_crapdat;
    raise vr_exc_sem_data_cooperativa;
  ELSE
    CLOSE cecred.btch0001.cr_crapdat;
  END IF;
  vr_dtmvtolt := rw_crapdat.dtmvtolt;
  
  
  FOR rg_crapass IN cr_crapass LOOP
    
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
                         
    IF (rg_crapass.cdsitdct_new IS NOT NULL) THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.cdsitdct',
                                       pr_dsdadant => 8,
                                       pr_dsdadatu => 1);
    END IF;

    
    update cecred.crapass a
       set a.cdsitdct = 1
     where a.cdcooper = rg_crapass.cdcooper
       and a.nrdconta = rg_crapass.nrdconta;
    
    
	
   
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_sem_data_cooperativa THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao buscar data da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ');
  WHEN vr_exc_saldo THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001,
                            'Erro ao buscar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' - ' ||
                            'vr_dscritic: ' || vr_dscritic);
    
  WHEN vr_exc_lanc_conta THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001,
                            'Erro ao realizar lançamento na cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' - ' ||
                            'vr_dscritic: ' || vr_dscritic);
  
  WHEN vr_inpessoa_invalido THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002,
                            'Erro tipo de pessoa inválido da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ');
    
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20003,
                            'Erro geral script -> cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
/
