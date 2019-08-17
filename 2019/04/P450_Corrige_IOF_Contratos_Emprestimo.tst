PL/SQL Developer Test script 3.0
353
-- Created on 21/03/2019 by T0031667 
declare
  CURSOR cr_crapprm IS
  
    SELECT prm.dsvlrprm
    
      FROM crapprm prm
    
     WHERE prm.nmsistem = 'CRED'
       AND prm.cdcooper = 0
       AND prm.cdacesso = 'IN_ATIVA_REGRAS_PREJU';

  CURSOR cr_nrdocmto(pr_cdcooper NUMBER,
                     pr_dtmvtolt DATE,
                     pr_cdagenci NUMBER,
                     pr_cdbccxlt NUMBER,
                     pr_nrdolote NUMBER,
                     pr_nrdconta NUMBER) IS
    SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
      FROM craplcm
     WHERE cdcooper = pr_cdcooper
       AND dtmvtolt = pr_dtmvtolt
       AND cdagenci = pr_cdagenci
       AND cdbccxlt = pr_cdbccxlt
       AND nrdconta = pr_nrdconta;

  CURSOR cr_craplcm(pr_cdcooper NUMBER,
                    pr_dtmvtolt DATE,
                    pr_cdhistor NUMBER,
                    pr_nrdolote NUMBER,
                    pr_cdagenci NUMBER,
                    pr_cdbccxlt NUMBER,
                    pr_nrdconta NUMBER,
                    pr_vllanmto NUMBER) IS
  
    SELECT 1
      FROM CRAPLCM L
     WHERE L.CDCOOPER = pr_cdcooper
       AND L.DTMVTOLT = pr_dtmvtolt
       AND L.CDHISTOR = pr_cdhistor
       AND L.NRDOLOTE = pr_nrdolote
       AND L.NRDCONTA = pr_nrdconta
       AND L.VLLANMTO = pr_vllanmto
       AND l.cdbccxlt = pr_cdbccxlt
       AND L.Cdagenci = pr_cdagenci;

  CURSOR cr_crapdat(pr_cdcooper NUMBER) IS
    SELECT d.dtmvtolt FROM crapdat d WHERE d.cdcooper = pr_cdcooper;

  CURSOR cr_crapepr IS
  
    SELECT l.cdcooper, --"Cooperativa",
           c.nmrescop, --"Nm. Cooperativa",
           l.nrdconta, --"Conta",
           l.nrctremp, --"Contrato",
           --DECODE(l.tpemprst, 0, 'TR', 1, 'PP', 2, 'POS', '') "Produto",
           --l.qtpreemp "Qt. Parcelas",
           --l.inliquid "Liquidado",
           --l.inprejuz "Prejuizo",
           l.vlsdprej, --"Saldo Prejuizo",
           l.vlttmupr - l.vlpgmupr "SDMULTAPAGO",
           l.vlttjmpr - l.vlpgjmpr "SDMORAPAGO",
           l.vltiofpr - l.vlpiofpr "SDIOFPAGO",
           l.vlttmupr, -- "TT. Multa",
           l.vlpgmupr, -- "PG. Multa",
           l.vlttjmpr, -- "TT. Juros Mora",
           l.vlpgjmpr, --"PG. Juros Mora",
           l.vltiofpr, --"TT. IOF",
           l.vlpiofpr --"PG. IOF",
    /*
    (select s.nracordo
       from tbrecup_acordo s, tbrecup_acordo_contrato c
     
      where (s.cdcooper = l.cdcooper and s.nrdconta = l.nrdconta and
            s.cdsituacao = 2)
        and (c.nracordo = s.nracordo and c.nrctremp = l.nrctremp and
            c.nrgrupo = 1 and c.cdorigem = b.cdorigem)) "Nr. Acordo",
    
    (select s.dtliquid
       from tbrecup_acordo s, tbrecup_acordo_contrato c
     
      where (s.cdcooper = l.cdcooper and s.nrdconta = l.nrdconta and
            s.cdsituacao = 2)
        and (c.nracordo = s.nracordo and c.nrctremp = l.nrctremp and
            c.nrgrupo = 1 and c.cdorigem = b.cdorigem)) "DT. Liquida Acordo",
    
    (select crapcyc.flgehvip
       from crapcyc
      where crapcyc.cdcooper = b.cdcooper
        and crapcyc.nrdconta = b.nrdconta
        and crapcyc.nrctremp = b.nrctremp
        and crapcyc.cdorigem = b.cdorigem) "Eh VIP"*/
    
      FROM crapepr l
    
      JOIN crapcyb b
        on b.cdcooper = l.cdcooper
       and b.cdorigem IN (3, 2)
       and b.nrdconta = l.nrdconta
       and b.nrctremp = l.nrctremp
    
      JOIN crapcop c
        on c.cdcooper = l.cdcooper
    
     WHERE 1 = 1
       and (l.inprejuz = 1)
       --and (l.vlsdprej = 0)
       and ((l.vlpgjmpr > l.vlttjmpr) OR (l.vltiofpr - l.vlpiofpr > 0))
       and (l.dtprejuz > '01/01/2018')
          
       and EXISTS
     (select 1
              from tbrecup_acordo s, tbrecup_acordo_contrato c
            
             where (s.cdcooper = l.cdcooper and s.nrdconta = l.nrdconta and
                   s.cdsituacao = 2)
               and (c.nracordo = s.nracordo and c.nrctremp = l.nrctremp and
                   c.nrgrupo = 1 and c.cdorigem = b.cdorigem))
          
       and ((l.cdcooper = 13 and l.nrdconta = 90689 and l.nrctremp = 20185) OR
           (l.cdcooper = 13 and l.nrdconta = 108480 and l.nrctremp = 18782) OR
           (l.cdcooper = 7 and l.nrdconta = 281530 and l.nrctremp = 17718) OR
           (l.cdcooper = 7 and l.nrdconta = 42013 and l.nrctremp = 19394) OR
           (l.cdcooper = 7 and l.nrdconta = 53210 and l.nrctremp = 17367) OR
           (l.cdcooper = 11 and l.nrdconta = 59722 and l.nrctremp = 34759) OR
           (l.cdcooper = 11 and l.nrdconta = 146390 and l.nrctremp = 22216) OR
           (l.cdcooper = 1 and l.nrdconta = 3533131 and
           l.nrctremp = 228702) OR
           (l.cdcooper = 1 and l.nrdconta = 3954994 and
           l.nrctremp = 988288) OR
           (l.cdcooper = 1 and l.nrdconta = 6248110 and
           l.nrctremp = 869995) OR
           (l.cdcooper = 1 and l.nrdconta = 6321089 and
           l.nrctremp = 1136199) OR
           (l.cdcooper = 1 and l.nrdconta = 6904440 and
           l.nrctremp = 1158193) OR
           (l.cdcooper = 1 and l.nrdconta = 7433336 and
           l.nrctremp = 1214648) OR
           (l.cdcooper = 1 and l.nrdconta = 7453086 and
           l.nrctremp = 1072710) OR
           (l.cdcooper = 1 and l.nrdconta = 7485093 and
           l.nrctremp = 944884) OR
           (l.cdcooper = 1 and l.nrdconta = 7565380 and
           l.nrctremp = 965946) OR
           (l.cdcooper = 1 and l.nrdconta = 8102422 and
           l.nrctremp = 1158178) OR
           (l.cdcooper = 1 and l.nrdconta = 8564019 and
           l.nrctremp = 995035) OR
           (l.cdcooper = 1 and l.nrdconta = 8564019 and
           l.nrctremp = 995052) OR
           (l.cdcooper = 1 and l.nrdconta = 8578222 and
           l.nrctremp = 1157911) OR
           (l.cdcooper = 1 and l.nrdconta = 8796173 and
           l.nrctremp = 190073) OR
           (l.cdcooper = 1 and l.nrdconta = 9064745 and
           l.nrctremp = 872500) OR
           (l.cdcooper = 1 and l.nrdconta = 9088695 and
           l.nrctremp = 1130901) OR
           (l.cdcooper = 1 and l.nrdconta = 9293264 and
           l.nrctremp = 1113195) OR
           (l.cdcooper = 1 and l.nrdconta = 9293264 and
           l.nrctremp = 1113315) OR
           (l.cdcooper = 1 and l.nrdconta = 9293264 and
           l.nrctremp = 1117316) OR
           (l.cdcooper = 1 and l.nrdconta = 9293264 and
           l.nrctremp = 1185257) OR
           (l.cdcooper = 1 and l.nrdconta = 8578222 and
           l.nrctremp = 1157911) OR
           (l.cdcooper = 2 and l.nrdconta = 591050 and l.nrctremp = 238872) OR
           (l.cdcooper = 1 and l.nrdconta = 9267115 and
           l.nrctremp = 934462));

  vr_nrdocmto    NUMBER;
  vr_incrineg    INTEGER;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  rw_crapdat     cr_crapdat%ROWTYPE;
  vr_exc_erro EXCEPTION;
  vr_prejuizo VARCHAR2(1);
  vr_existlan NUMBER;

BEGIN
  :RESULT     := 'Erro';
  vr_prejuizo := NULL;

  OPEN cr_crapprm;
  FETCH cr_crapprm
    INTO vr_prejuizo;
  CLOSE cr_crapprm;

  IF vr_prejuizo IS NULL THEN
    raise vr_exc_erro;
  END IF;

  UPDATE crapprm p
     SET p.dsvlrprm = 'N'
   WHERE p.nmsistem = 'CRED'
     AND p.cdcooper = 0
     AND p.cdacesso = 'IN_ATIVA_REGRAS_PREJU';

  FOR rw_crapepr IN cr_crapepr LOOP
  
    OPEN cr_crapdat(rw_crapepr.cdcooper);
    FETCH cr_crapdat
      INTO rw_crapdat;
    CLOSE cr_crapdat;
  
    /*******************************************
    * Pagar e ajustar o valor pago do IOF      *
    *******************************************/
  
    IF (rw_crapepr.sdiofpago > 0) THEN
    
      --l.vlttmupr - l.vlpgmupr "SDMULTAPAGO",
      --l.vlttjmpr - l.vlpgjmpr "SDMORAPAGO",
      --l.vltiofpr - l.vlpiofpr "SDIOFPAGO",
    
      vr_existlan := NULL;
      OPEN cr_craplcm(pr_cdcooper => rw_crapepr.cdcooper,
                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                      pr_cdhistor => 362,
                      pr_nrdolote => 2228,
                      pr_cdagenci => 1,
                      pr_cdbccxlt => 100,
                      pr_nrdconta => rw_crapepr.nrdconta,
                      pr_vllanmto => rw_crapepr.vltiofpr);
      FETCH cr_craplcm
        INTO vr_existlan;
      CLOSE cr_craplcm;
    
      IF vr_existlan IS NULL THEN
      
        OPEN cr_nrdocmto(pr_cdcooper => rw_crapepr.cdcooper,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                         pr_cdagenci => 1,
                         pr_cdbccxlt => 100,
                         pr_nrdolote => 2228,
                         pr_nrdconta => rw_crapepr.nrdconta);
        FETCH cr_nrdocmto
          INTO vr_nrdocmto;
        CLOSE cr_nrdocmto;
      
        lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                           pr_cdagenci    => 1,
                                           pr_cdbccxlt    => 100,
                                           pr_nrdolote    => 2228,
                                           pr_nrdconta    => rw_crapepr.nrdconta,
                                           pr_nrdocmto    => vr_nrdocmto,
                                           pr_cdhistor    => 362,
                                           pr_nrseqdig    => 1,
                                           pr_vllanmto    => rw_crapepr.vltiofpr,
                                           pr_nrdctabb    => rw_crapepr.nrdconta,
                                           pr_cdcooper    => rw_crapepr.cdcooper,
                                           pr_cdoperad    => '1',
                                           pr_incrineg    => vr_incrineg,
                                           pr_tplotmov    => 1,
                                           pr_inprolot    => 1,
                                           pr_tab_retorno => vr_tab_retorno,
                                           pr_cdcritic    => :pr_cdcritic,
                                           pr_dscritic    => :pr_dscritic);
      
        IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    
      vr_existlan := NULL;
      OPEN cr_craplcm(pr_cdcooper => rw_crapepr.cdcooper,
                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                      pr_cdhistor => 2317,
                      pr_nrdolote => 8457,
                      pr_cdagenci => 1,
                      pr_cdbccxlt => 100,
                      pr_nrdconta => rw_crapepr.nrdconta,
                      pr_vllanmto => rw_crapepr.vltiofpr);
      FETCH cr_craplcm
        INTO vr_existlan;
      CLOSE cr_craplcm;
    
      IF vr_existlan IS NULL THEN
      
        OPEN cr_nrdocmto(pr_cdcooper => rw_crapepr.cdcooper,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                         pr_cdagenci => 1,
                         pr_cdbccxlt => 100,
                         pr_nrdolote => 8457,
                         pr_nrdconta => rw_crapepr.nrdconta);
        FETCH cr_nrdocmto
          INTO vr_nrdocmto;
        CLOSE cr_nrdocmto;
      
        lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                           pr_cdagenci    => 1,
                                           pr_cdbccxlt    => 100,
                                           pr_nrdolote    => 8457,
                                           pr_nrdconta    => rw_crapepr.nrdconta,
                                           pr_nrdocmto    => vr_nrdocmto,
                                           pr_cdhistor    => 2317,
                                           pr_nrseqdig    => 1,
                                           pr_vllanmto    => rw_crapepr.vltiofpr,
                                           pr_nrdctabb    => rw_crapepr.nrdconta,
                                           pr_cdpesqbb    => rw_crapepr.nrctremp,
                                           pr_cdcooper    => rw_crapepr.cdcooper,
                                           pr_cdoperad    => '1',
                                           pr_incrineg    => vr_incrineg,
                                           pr_tplotmov    => 1,
                                           pr_inprolot    => 1,
                                           pr_tab_retorno => vr_tab_retorno,
                                           pr_cdcritic    => :pr_cdcritic,
                                           pr_dscritic    => :pr_dscritic);
      
        IF TRIM(:pr_dscritic) IS NOT NULL OR nvl(:pr_cdcritic, 0) > 0 THEN
          RAISE vr_exc_erro;
        END IF;
      
        UPDATE crapepr epr
           SET epr.vlpiofpr = rw_crapepr.vltiofpr
         WHERE cdcooper = rw_crapepr.cdcooper
           AND nrdconta = rw_crapepr.nrdconta
           AND nrctremp = rw_crapepr.nrctremp;
      END IF;
    END IF;
    /*********************************************
    * VIACREDI - Conta 6904440 - Contrato 981991 *
    *********************************************/
    --l.vlttmupr - l.vlpgmupr "SDMULTAPAGO",
    --l.vlttjmpr - l.vlpgjmpr "SDMORAPAGO",
    --l.vltiofpr - l.vlpiofpr "SDIOFPAGO",
  
    IF (rw_crapepr.sdmorapago < 0) THEN
      UPDATE crapepr epr
         SET epr.vlpgjmpr = epr.vlttjmpr
       WHERE cdcooper = rw_crapepr.cdcooper
         AND nrdconta = rw_crapepr.nrdconta
         AND nrctremp = rw_crapepr.nrctremp;
    END IF;
  
  END LOOP;

  UPDATE crapprm p
     SET p.dsvlrprm = vr_prejuizo
   WHERE p.nmsistem = 'CRED'
     AND p.cdcooper = 0
     AND p.cdacesso = 'IN_ATIVA_REGRAS_PREJU';

  COMMIT;

  :RESULT := 'Sucesso';

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    :RESULT := 'ERRO';
END;
3
pr_cdcritic
0
5
pr_dscritic
0
5
RESULT
1
Sucesso
5
1
vr_prejuizo
