declare
  vr_log_dstransa varchar2(1000);
  vr_nrdrowid     ROWID;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_cdcooper crapcop.cdcooper%TYPE := 13;
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR CR_CONTAS IS
    SELECT REGEXP_SUBSTR('419834,221546,388181,145998,80250,638315,548685,105295,186244,207497','[^,]+', 1, LEVEL) as nrdconta,
           REGEXP_SUBSTR('55980,135155,143312,145708,139169,151150,138828,109809,58233,51194','[^,]+', 1, LEVEL) as nrctremp,
           REGEXP_SUBSTR('24,6,5,4,5,3,5,10,24,27','[^,]+', 1, LEVEL) as nrparepr           
      FROM DUAL
   CONNECT BY REGEXP_SUBSTR('419834,221546,388181,145998,80250,638315,548685,105295,186244,207497','[^,]+', 1, LEVEL) IS NOT NULL;  
  
  CURSOR CR_LANCAMENTO(PR_CDCOOPER IN CRAPLEM.CDCOOPER%TYPE
                      ,PR_NRDCONTA IN CRAPLEM.NRDCONTA%TYPE
                      ,PR_NRCTREMP IN CRAPLEM.NRCTREMP%TYPE
                      ,PR_NRPAREPR IN CRAPLEM.NRPAREPR%TYPE) IS    
    SELECT SUM(VLLANMTO) VLLANMTO,
           DECODE(CDHISTOR,1037,1041,1044,1705,1047,1708,1077,1711,CDHISTOR) CDHISTOR,
           NRPAREPR 
      FROM CRAPLEM
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
      FROM CRAPPEP PEP
     WHERE CDCOOPER = PR_CDCOOPER
       AND NRDCONTA = PR_NRDCONTA
       AND NRCTREMP = PR_NRCTREMP
       AND NRPAREPR = PR_NRPAREPR 
     ORDER BY CDHISTOR;     
BEGIN
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  FOR rw_contas IN cr_contas LOOP
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => rw_contas.nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;  
  
    FOR rw_lancamento IN cr_lancamento(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => rw_contas.nrdconta
                                      ,pr_nrctremp => rw_contas.nrctremp
                                      ,pr_nrparepr => rw_contas.nrparepr) LOOP
      
      IF rw_lancamento.nrparepr = 0 THEN
         rw_lancamento.nrparepr := NULL;
      END IF;
      
      IF rw_lancamento.cdhistor IS NULL THEN    
        vr_log_dstransa := 'dtmvtolt = ' || rw_crapdat.dtmvtolt || ', ' || 'cdcooper = ' ||
                           vr_cdcooper || ', ' || 'nrdconta = ' ||
                           rw_contas.nrdconta || ', ' || 'nrctremp = ' ||
                           rw_contas.nrctremp || ', ' || 'nrparepr = ' ||
                           rw_lancamento.nrparepr || ', ' || 'cdhistor = ' ||
                           rw_lancamento.cdhistor || ', ' || 'vllanmto = ' ||
                           rw_lancamento.vllanmto;
      
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                             pr_cdoperad => '1',
                             pr_dscritic => 'N�o foi poss�vel determinar o c�digo do hist�rico para realizar o lan�amento.',
                             pr_dsorigem => 'PL/SQL SCRIPT',
                             pr_dstransa => vr_log_dstransa,
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 0,
                             pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                             pr_idseqttl => 1,
                             pr_nmdatela => NULL,
                             pr_nrdconta => rw_contas.nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
      
        CONTINUE;      
      END IF;     
                                       
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_cdagenci => rw_crapass.cdagenci,
                                      pr_cdbccxlt => 100,
                                      pr_cdoperad => 1,
                                      pr_cdpactra => rw_crapass.cdagenci,
                                      pr_tplotmov => 5,
                                      pr_nrdolote => 600031,
                                      pr_nrdconta => rw_contas.nrdconta,
                                      pr_cdhistor => TO_NUMBER(rw_lancamento.cdhistor),
                                      pr_nrctremp => rw_contas.nrctremp,
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