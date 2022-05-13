declare
  vr_log_dstransa varchar2(1000);
  vr_nrdrowid     ROWID;
  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro cecred.GENE0001.typ_tab_erro;
  vr_cdcooper cecred.crapcop.cdcooper%TYPE := 13;
  vr_nrdconta cecred.crapass.nrdconta%TYPE := 93378;
  vr_nrctremp cecred.craplem.nrctremp%type := 84031;
  vr_nrparepr cecred.craplem.nrparepr%type := 16;  
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
   
  CURSOR CR_LANCAMENTO(PR_CDCOOPER IN CRAPLEM.CDCOOPER%TYPE
                      ,PR_NRDCONTA IN CRAPLEM.NRDCONTA%TYPE
                      ,PR_NRCTREMP IN CRAPLEM.NRCTREMP%TYPE
                      ,PR_NRPAREPR IN CRAPLEM.NRPAREPR%TYPE) IS    
    SELECT SUM(VLLANMTO) VLLANMTO,
           DECODE(CDHISTOR,1037,1041,1044,1705,1047,1708,1077,1711,CDHISTOR) CDHISTOR,
           NRPAREPR 
      FROM cecred.CRAPLEM
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND NRCTREMP = PR_NRCTREMP
       AND DTMVTOLT = TO_DATE('11/02/2022','DD/MM/RRRR')
       AND CDHISTOR <> 2311
     GROUP BY CDHISTOR,
              NRPAREPR 
    UNION ALL
    SELECT PEP.VLPAREPR AS VLLANMTO,
           (SELECT DECODE(INDAUTREPASSECC, 1, 3026, 3027)
              FROM TBCADAST_EMPRESA_CONSIG
             WHERE CDCOOPER = PR_CDCOOPER
               AND CDEMPRES = (SELECT CDEMPRES
                                 FROM CRAPEPR
                                WHERE CDCOOPER = PR_CDCOOPER
                                  AND NRDCONTA = PR_NRDCONTA
                                  AND NRCTREMP = PR_NRCTREMP)) CDHISTOR,
           PEP.NRPAREPR                                  
      FROM cecred.CRAPPEP PEP
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND NRCTREMP = PR_NRCTREMP
       AND NRPAREPR = PR_NRPAREPR 
     ORDER BY CDHISTOR;     
BEGIN
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH cecred.btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;  
  
  FOR rw_lancamento IN cr_lancamento(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => vr_nrdconta
                                    ,pr_nrctremp => vr_nrctremp
                                    ,pr_nrparepr => vr_nrparepr) LOOP
      
    IF rw_lancamento.nrparepr = 0 THEN
       rw_lancamento.nrparepr := NULL;
    END IF;
      
    IF rw_lancamento.cdhistor IS NULL THEN    
      vr_log_dstransa := 'dtmvtolt = ' || rw_crapdat.dtmvtolt || ', ' || 'cdcooper = ' ||
                         vr_cdcooper || ', ' || 'nrdconta = ' ||
                         vr_nrdconta || ', ' || 'nrctremp = ' ||
                         vr_nrctremp || ', ' || 'nrparepr = ' ||
                         rw_lancamento.nrparepr || ', ' || 'cdhistor = ' ||
                         rw_lancamento.cdhistor || ', ' || 'vllanmto = ' ||
                         rw_lancamento.vllanmto;
      
      cecred.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => '1',
                           pr_dscritic => 'Não foi possível determinar o código do histórico para realizar o lançamento.',
                           pr_dsorigem => 'PL/SQL SCRIPT',
                           pr_dstransa => vr_log_dstransa,
                           pr_dttransa => TRUNC(SYSDATE),
                           pr_flgtrans => 0,
                           pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                           pr_idseqttl => 1,
                           pr_nmdatela => NULL,
                           pr_nrdconta => vr_nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
      
      CONTINUE;      
    END IF;     
                                       
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                    pr_cdagenci => rw_crapass.cdagenci,
                                    pr_cdbccxlt => 100,
                                    pr_cdoperad => 1,
                                    pr_cdpactra => rw_crapass.cdagenci,
                                    pr_tplotmov => 5,
                                    pr_nrdolote => 600031,
                                    pr_nrdconta => vr_nrdconta,
                                    pr_cdhistor => TO_NUMBER(rw_lancamento.cdhistor),
                                    pr_nrctremp => vr_nrctremp,
                                    pr_vllanmto => TO_NUMBER(REPLACE(rw_lancamento.vllanmto,',','.'),'9999.99'),
                                    pr_dtpagemp => rw_crapdat.dtmvtolt,
                                    pr_txjurepr => 0,
                                    pr_vlpreemp => 0,
                                    pr_nrsequni => 0,
                                    pr_nrparepr => rw_lancamento.nrparepr,
                                    pr_flgincre => FALSE,
                                    pr_flgcredi => FALSE,
                                    pr_nrseqava => 0,
                                    pr_cdorigem => 5,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
