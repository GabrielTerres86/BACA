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
  vc_dstransaStatusCC             CONSTANT VARCHAR2(4000) := 'Alteracao da situacao de conta por script - INC0317285';
  vc_dstransaDevCotas             CONSTANT VARCHAR2(4000) := 'Alteracao da situacao de conta por script - INC0317285';
  vc_dstransaDevDepVista          CONSTANT VARCHAR2(4000) := 'Alteracao da situacao de conta por script - INC0317285';
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
         ,(select 1  as cdcooper, decode(vr_globalname, vc_bdprod,2354217   ,97645729) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1  as cdcooper, decode(vr_globalname, vc_bdprod,8153906   ,91846030) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1  as cdcooper, decode(vr_globalname, vc_bdprod,10989153  ,89010787) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1 as cdcooper, decode(vr_globalname, vc_bdprod,12480878   ,87519062) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1  as cdcooper, decode(vr_globalname, vc_bdprod,12629464  ,87370476) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1  as cdcooper, decode(vr_globalname, vc_bdprod,12780235  ,87219700) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1 as cdcooper, decode(vr_globalname, vc_bdprod,13343149   ,86656791) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1 as cdcooper, decode(vr_globalname, vc_bdprod,13569066   ,86430874) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union
		   select 1  as cdcooper, decode(vr_globalname, vc_bdprod,3686930 , 96313005 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1  as cdcooper, decode(vr_globalname, vc_bdprod,3754618 , 96245328 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1  as cdcooper, decode(vr_globalname, vc_bdprod,6551173 , 93448767 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1  as cdcooper, decode(vr_globalname, vc_bdprod,12237736, 87762200 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11 as cdcooper, decode(vr_globalname, vc_bdprod,3344    , 99996596 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11 as cdcooper, decode(vr_globalname, vc_bdprod,528161  , 99471779 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11 as cdcooper, decode(vr_globalname, vc_bdprod,883239  , 99116707 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 13 as cdcooper, decode(vr_globalname, vc_bdprod,682837  , 99317109 ) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
		   union	   
		   select 11  as cdcooper,decode(vr_globalname, vc_bdprod,601861    ,0000000) as nrdconta, vc_cdsitdctProcesDemis as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
		   select 11 as cdcooper,decode(vr_globalname, vc_bdprod,537233    ,99462702) as nrdconta, vc_cdsitdctProcesDemis as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
		   select 11 as cdcooper,decode(vr_globalname, vc_bdprod,520462    ,99479478) as nrdconta, vc_cdsitdctProcesDemis as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
		   select 1 as cdcooper,decode(vr_globalname, vc_bdprod,12021857    ,87978083) as nrdconta, vc_cdsitdctProcesDemis as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
		   select 1 as cdcooper,decode(vr_globalname, vc_bdprod,10651764    ,89348176) as nrdconta, vc_cdsitdctProcesDemis as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
          ) a
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

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 16);
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
                                       pr_dsdadant => rg_crapass.cdsitdct_old,
                                       pr_dsdadatu => rg_crapass.cdsitdct_new);
    END IF;

    IF (rg_crapass.dtdemiss_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtdemiss',
                                       pr_dsdadant => rg_crapass.dtdemiss_old,
                                       pr_dsdadatu => rg_crapass.dtdemiss_new);
    END IF;
                              
    IF (rg_crapass.dtelimin_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtelimin',
                                       pr_dsdadant => rg_crapass.dtelimin_old,
                                       pr_dsdadatu => rg_crapass.dtelimin_new);  
    END IF;
                                                            
    IF (rg_crapass.cdmotdem_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.cdmotdem',
                                       pr_dsdadant => rg_crapass.cdmotdem_old,
                                       pr_dsdadatu => rg_crapass.cdmotdem_new); 
    END IF;
                                                             
    IF (rg_crapass.dtasitct_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtasitct',
                                       pr_dsdadant => rg_crapass.dtasitct_old,
                                       pr_dsdadatu => rg_crapass.dtasitct_new);                                
    END IF;

    if rg_crapass.cdsitdct_new = 4 then
       update cecred.crapass a set a.cdsitdct = nvl(rg_crapass.cdsitdct_new, a.cdsitdct)
                                  ,a.dtdemiss = nvl(a.dtdemiss,vr_dtmvtolt)
                                  ,a.dtelimin = nvl(a.dtelimin,vr_dtmvtolt)
                                  ,a.cdmotdem = nvl(11, a.cdmotdem)
                                  ,a.dtasitct = nvl(vr_dtmvtolt, a.dtasitct)
       where a.cdcooper = rg_crapass.cdcooper
         and a.nrdconta = rg_crapass.nrdconta;
	else
	   update cecred.crapass a set a.cdsitdct = nvl(rg_crapass.cdsitdct_new, a.cdsitdct)
                                  ,a.dtasitct = nvl(vr_dtmvtolt, a.dtasitct)
       where a.cdcooper = rg_crapass.cdcooper
         and a.nrdconta = rg_crapass.nrdconta;
	end if;
    
    
    vr_vldcotas_crapcot := 0;
    
    BEGIN
      SELECT nvl(vldcotas,0)
        INTO vr_vldcotas_crapcot
        FROM CECRED.crapcot
       WHERE nrdconta = rg_crapass.nrdconta
         AND cdcooper = rg_crapass.cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        dbms_output.put_line(chr(10) ||
                             'Não encontrado registro em crapcot para conta ' ||
                             rg_crapass.nrdconta);
        vr_vldcotas_crapcot := 0;
      
    END;
    
    IF vr_vldcotas_crapcot > 0 THEN
      
      
      vr_busca := TRIM(to_char(rg_crapass.cdcooper)) || ';' ||
                          TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                          TRIM(to_char(rg_crapass.cdagenci)) || ';' ||
                          '100;' || 
                          vc_nrdolote_cota;
                          
      vr_nrdocmto := cecred.fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);
                                 
      vr_nrseqdig := cecred.fn_sequence('CRAPLOT','NRSEQDIG',''||rg_crapass.cdcooper||';'||
                                                                  TRIM(to_char(vr_dtmvtolt, 'DD/MM/RRRR'))||';'||
                                                                  rg_crapass.cdagenci||
                                                                  ';100;'|| 
                                                                  vc_nrdolote_cota);
    
      case rg_crapass.inpessoa
        when vc_inpessoaPF then
          vr_cdhistor := vc_cdhistCotasPF;
        when vc_inpessoaPJ then
          vr_cdhistor := vc_cdhistCotasPJ;
        else
          raise vr_inpessoa_invalido;
      end case;
      
      INSERT INTO CECRED.craplct
        (cdcooper,
         cdagenci,
         cdbccxlt,
         nrdolote,
         dtmvtolt,
         cdhistor,
         nrctrpla,
         nrdconta,
         nrdocmto,
         nrseqdig,
         vllanmto,
         CDOPEORI,
         DTINSORI)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.cdagenci,
         100,
         vc_nrdolote_cota,
         vr_dtmvtolt,
         vr_cdhistor,
         0,
         rg_crapass.nrdconta,
         vr_nrdocmto,
         vr_nrseqdig,
         vr_vldcotas_crapcot,
         1,
         sysdate);
      
      vr_nrdrowid := null;
      
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                  pr_cdoperad => vr_cdoperad,
                                  pr_dscritic => vr_dscritic,
                                  pr_dsorigem => 'AIMARO',
                                  pr_dstransa => vc_dstransaDevCotas,
                                  pr_dttransa => vr_dttransa,
                                  pr_flgtrans => 1,
                                  pr_hrtransa => vr_hrtransa,
                                  pr_idseqttl => 0,
                                  pr_nmdatela => NULL,
                                  pr_nrdconta => rg_crapass.nrdconta,
                                  pr_nrdrowid => vr_nrdrowid);
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplct.dtmvtolt',
                                       pr_dsdadant => null,
                                       pr_dsdadatu => vr_dtmvtolt);
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplct.vllanmto',
                                       pr_dsdadant => null,
                                       pr_dsdadatu => vr_vldcotas_crapcot);
    
      UPDATE CECRED.crapcot
         SET vldcotas = 0
       WHERE cdcooper = rg_crapass.cdcooper
         AND nrdconta = rg_crapass.nrdconta;
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapcot.vldcotas',
                                       pr_dsdadant => vr_vldcotas_crapcot,
                                       pr_dsdadatu => 0);
                                
       MERGE INTO CECRED.TBCOTAS_DEVOLUCAO a
       USING (SELECT rg_crapass.cdcooper as cdcooper, rg_crapass.nrdconta as nrdconta, vc_tpdevCotas as tpdevolucao 
                FROM DUAL) b
         ON (a.cdcooper = b.cdcooper AND a.nrdconta = b.nrdconta AND a.tpdevolucao = b.tpdevolucao)
       WHEN MATCHED THEN UPDATE SET a.vlcapital =(a.vlcapital + vr_vldcotas_crapcot)
       WHEN NOT MATCHED THEN INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
                             VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vldcotas_crapcot);
    
    END IF;
    
    
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
