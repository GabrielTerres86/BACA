DECLARE 
 
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  --Variaveis para retorno de erro
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nrdconta      crapepr.nrdconta%TYPE;
  vr_nrctremp      crapepr.nrctremp%TYPE;
  vr_vllanmto      craplem.vllanmto%TYPE;
  
  vr_contrato      GENE0002.typ_split;
  vr_dadosctr      GENE0002.typ_split;

BEGIN
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => 9);
  FETCH btch0001.cr_crapdat  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  UPDATE crapprm SET dsvlrprm = '' WHERE cdacesso = 'PREJUIZO_EXCECAO' AND cdcooper = 9;
  
  -- excecao para prejuizo
  vr_contrato := GENE0002.fn_quebra_string(pr_string  => '502049;10014825;1762,05|518948;10008329;80252,83|508209;10008736;467409,68|508209;10009334;100396,66|517844;10012285;32421,38|521469;10012451;6185,80|509779;10013890;2371,91|514624;10014213;2262,84|528617;10014229;4601,26|524069;10014256;40435,73|528374;10014732;4864,87|528617;10015020;3870,17|528617;10015201;974,28|529249;13000007;6819,89|529230;13000417;4707,44|510041;13001003;49769,81|512346;13001008;2840,58|522244;13001098;8024,36|521272;14000366;4941,56|524930;14000505;7508,03|518468;14001210;40367,80|517186;14001392;21756,99|528544;14001433;9689,77|532207;14100030;2704,12|513644;15000120;7015,77|528765;15000192;6422,74|530107;15000256;1117,64|529044;15000273;4751,83|521132;15000295;41256,49|531316;15000479;11702,89|527041;15000488;6866,95|520012;15000569;8560,43|527548;15000670;6438,90|527432;15000824;11095,64|523127;15000881;17050,86|524131;15000882;47544,65|522252;15000980;6307,42|527769;15001025;68711,04|507610;15001042;124803,42|512753;15001049;35207,42|525065;15001084;31541,18|520497;15001121;27155,10|532266;15100015;5776,27|531979;15100050;20744,90|531472;16000013;56963,41|522120;16000164;5487,59|503339;16000275;3562,94|526711;16000303;6951,22|522120;16000453;4849,40|523747;16000466;3984,31|525367;16000471;56075,49|503380;16000580;18202,35|502499;16000582;34776,68|510815;16000589;857,48|530590;16000608;1098,48|503312;16000651;55983,41|528439;16000696;10035,53|521256;16000755;1312,15|513466;16000762;11288,54|520543;16000785;9301,31|520241;16000859;65152,13|500976;16001095;58797,27|531790;16100010;10218,78|503487;16100019;8850,53|525111;16100027;26399,53|532363;16100030;69001,68|531790;16100039;6658,54|532355;16100042;26949,58|500526;16200004;18372,87|527190;16200011;6170,11|'
                                          ,pr_delimit => '|');  
  IF vr_contrato.COUNT > 0 THEN
    -- Listagem de contratos selecionados
    FOR vr_idx_lst IN 1..vr_contrato.COUNT LOOP
      vr_dadosctr := GENE0002.fn_quebra_string(pr_string  => vr_contrato(vr_idx_lst)
                                              ,pr_delimit => ';');
      
      vr_nrdconta := vr_dadosctr(1);
      vr_nrctremp := vr_dadosctr(2);
      vr_vllanmto := to_number(vr_dadosctr(3));
      
      UPDATE crapepr e
         SET e.vlsdprej = e.vlsdprej - vr_vllanmto,
             e.vljraprj = (SELECT SUM(l.vllanmto) FROM craplem l WHERE l.cdcooper = e.cdcooper AND l.nrdconta = e.nrdconta AND l.nrctremp = e.nrctremp AND l.cdhistor = 2409)
       WHERE e.cdcooper = 9 
         AND e.nrdconta = vr_nrdconta
         AND e.nrctremp = vr_nrctremp;
      
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => 9
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => 1
                                     ,pr_cdbccxlt => 100
                                     ,pr_cdoperad => 1
                                     ,pr_cdpactra => 1
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => 600029
                                     ,pr_nrdconta => vr_nrdconta
                                     ,pr_cdhistor => 2392 -- abono
                                     ,pr_nrctremp => vr_nrctremp
                                     ,pr_vllanmto => vr_vllanmto
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => 0
                                     ,pr_vlpreemp => 0
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => TRUE 
                                     ,pr_flgcredi => FALSE  
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
           
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END LOOP;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20111, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20111, SQLERRM);
END;
