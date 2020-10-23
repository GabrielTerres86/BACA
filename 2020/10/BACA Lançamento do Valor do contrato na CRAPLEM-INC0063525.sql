DECLARE
    CURSOR c_craplem (prc_cdcooper craplem.cdcooper%TYPE
                     ,prc_dtmvtolt  craplem.dtmvtolt%TYPE
                     ,prc_cdagenci craplem.cdagenci%TYPE
                     ,prc_cdbccxlt craplem.cdbccxlt%TYPE
                     ,prc_nrdolote craplem.nrdolote%TYPE
                     ,prc_nrdocmto craplem.nrdocmto%type
                     ,prc_nrseqdig craplem.nrseqdig%TYPE) IS
         select lem.dtmvtolt,
                lem.cdhistor,
                lem.cdcooper,
                lem.nrdconta,
                lem.nrctremp,
                lem.vllanmto,
                lem.cdagenci,
                lem.nrdocmto,
                lem.rowid,
                lem.nrdolote,
                lem.cdbccxlt,
                lem.dtpagemp,
                lem.cdorigem,
                lem.nrseqava,
                lem.txjurepr
           from craplem lem
          where lem.cdcooper = prc_cdcooper
            and lem.cdagenci = prc_cdagenci
            and lem.cdbccxlt = prc_cdbccxlt
            and lem.nrdolote = prc_nrdolote
            and lem.nrdocmto = prc_nrdocmto
            and lem.nrseqdig = prc_nrseqdig
            and lem.dtmvtolt = prc_dtmvtolt;
            r_craplem c_craplem%ROWTYPE;

  vr_cdcritic             NUMBER(3);
  vr_dscritic             VARCHAR2(1000);
  vr_erro                 EXCEPTION;
  
  BEGIN

    OPEN c_craplem(10, '06/10/2020', 1, 100, 600005, 2, 2); 
    FETCH c_craplem INTO r_craplem;
      IF c_craplem%FOUND THEN
        
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => r_craplem.cdcooper
                                   ,pr_dtmvtolt => r_craplem.dtmvtolt
                                   ,pr_cdagenci => r_craplem.cdagenci
                                   ,pr_cdbccxlt => r_craplem.cdbccxlt
                                   ,pr_cdoperad => '1'
                                   ,pr_cdpactra => r_craplem.cdagenci
                                   ,pr_tplotmov => 4
                                   ,pr_nrdolote => r_craplem.nrdolote
                                   ,pr_nrdconta => r_craplem.nrdconta
                                   ,pr_cdhistor => '1036'
                                   ,pr_nrctremp => r_craplem.nrctremp
                                   ,pr_vllanmto => 302
                                   ,pr_dtpagemp => r_craplem.dtpagemp
                                   ,pr_txjurepr => r_craplem.txjurepr
                                   ,pr_vlpreemp => 0
                                   ,pr_nrsequni => 0
                                   ,pr_nrparepr => r_craplem.nrdocmto
                                   ,pr_flgincre => true
                                   ,pr_flgcredi => true
                                   ,pr_nrseqava => r_craplem.nrseqava
                                   ,pr_cdorigem => r_craplem.cdorigem
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

         CLOSE c_craplem;                                   

         IF vr_dscritic is not null THEN
            RAISE vr_erro;
         END IF;
         
         COMMIT;         
       END IF;

    EXCEPTION WHEN OTHERS THEN
      ROLLBACK;       
END; 
