DECLARE
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_count    INTEGER := 0;
  
  vr_contrato GENE0002.typ_split;
  vr_dadosctr GENE0002.typ_split;
  -- lista de contratos quebrados com pipe: conta ; contrato ; valor |
  vr_lstcontr VARCHAR(4000) := '511307;10007981;395672,77|520500;10008257;30102,59|518948;10008329;80252,83|508209;10008736;467409,68|508209;10009334;100396,66|517844;10012285;32421,38|521469;10012451;6185,80|508870;10012786;3133,52|509779;10013890;2371,91|514624;10014213;2262,84|528617;10014229;4601,26|524069;10014256;40435,73|528374;10014732;4864,87|528617;10015020;3870,17|528617;10015201;974,28|529249;13000007;6819,89|529230;13000417;4707,44|510041;13001003;49769,81|512346;13001008;2840,58|522244;13001098;8024,36|521272;14000366;4941,56|524930;14000505;7508,03|518468;14001210;40367,80|517186;14001392;21756,99|528544;14001433;9689,77|532207;14100030;2704,12|513644;15000120;7015,77|528765;15000192;6422,74|530107;15000256;1117,64|529044;15000273;4751,83|521132;15000295;41256,49|531316;15000479;11702,89|527041;15000488;6866,95|520012;15000569;8560,43|527548;15000670;6438,90|527432;15000824;11095,64|523127;15000881;17050,86|524131;15000882;47544,65|522252;15000980;6307,42|527769;15001025;68711,04|507610;15001042;124803,42|512753;15001049;35207,42|525065;15001084;31541,18|520497;15001121;27155,10|532266;15100015;5776,27|531979;15100050;20744,90|531472;16000013;56963,41|522120;16000164;5487,59|503339;16000275;3562,94|526711;16000303;6951,22|522120;16000453;4849,40|523747;16000466;3984,31|525367;16000471;56075,49|503380;16000580;18202,35|502499;16000582;34776,68|510815;16000589;857,48|530590;16000608;1098,48|503312;16000651;55983,41|528439;16000696;10035,53|521256;16000755;1312,15|513466;16000762;11288,54|520543;16000785;9301,31|520241;16000859;65152,13|500976;16001095;58797,27|531790;16100010;10218,78|532010;16100013;6911,28|503487;16100019;8850,53|525111;16100027;26399,53|532363;16100030;69001,68|531790;16100039;6658,54|532355;16100042;26949,58|500526;16200004;18372,87|527190;16200011;6170,11|';
  
  vr_nrdconta crapepr.nrdconta%TYPE;
  vr_nrctremp crapepr.nrctremp%TYPE;
  vr_vllanmto craplem.vllanmto%TYPE;
  
  vr_cdcooper crapcop.cdcooper%TYPE := 9;
  vr_cdhistor craphis.cdhistor%TYPE := 2409;
  
BEGIN
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  -- Quebra string para transformar numa tabela com os registros
  vr_contrato := GENE0002.fn_quebra_string(pr_string  => vr_lstcontr
                                          ,pr_delimit => '|');  
  
  -- Listagem de contratos 
  FOR vr_idx_lst IN 1..vr_contrato.COUNT - 1 LOOP
    
    vr_dadosctr := GENE0002.fn_quebra_string(pr_string  => vr_contrato(vr_idx_lst)
                                            ,pr_delimit => ';');  
      
    vr_nrdconta := vr_dadosctr(1);
    vr_nrctremp := vr_dadosctr(2);
    vr_vllanmto := to_number(vr_dadosctr(3));
    
    UPDATE crapepr
       SET vlsprjat = vlsdprej,
           vlsdprej = vlsdprej + vr_vllanmto,
           vljraprj = vljraprj + vr_vllanmto,
           vljrmprj = vr_vllanmto
     WHERE cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta
       AND nrctremp = vr_nrctremp;
    
    vr_count := vr_count + 1;
    
    dbms_output.put_line('Atualizacao na Conta: ' || vr_dadosctr(1) || ' Contrato: ' || vr_dadosctr(2) || ' Valor: ' || vr_dadosctr(3));
    
  END LOOP;
  
  dbms_output.put_line('Total de lançamentos feitos: ' || vr_count);
  
  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN 
    ROLLBACK;
    raise_application_error(-20500, vr_cdcritic || ': ' || vr_dscritic);
  WHEN OTHERS THEN 
    ROLLBACK;
    vr_dscritic := 'Erro ao fazer lançamentos :' || SQLERRM;
    raise_application_error(-20500, vr_dscritic);
END;
