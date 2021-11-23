declare

  CURSOR cr_crapdat is
    SELECT c.dtmvtolt FROM crapdat c WHERE c.cdcooper = 1;
  rw_crapdat cr_crapdat%ROWTYPE;

  vr_cdcritic number;
  vr_dscritic varchar2(4000);
  vr_cdcooper number;
  vr_vljuros  number(25, 2);
  vr_nrdconta number;
  vr_nrctremp number;

begin
  -- RITM0175984 - Atualização de valor de contrato consolidado (reversão) RITM0166722
  -- c/c : 2385651, viacredi, contrato : 242195
  -- lançar R$ 161266.45 de juros remuneratorios la craplem, hist (2409)
 
  vr_cdcooper := 1;
  vr_vljuros  := 161266.45;
  vr_nrdconta := 2385651;
  vr_nrctremp := 242195;

  OPEN cr_crapdat;
  FETCH cr_crapdat
    INTO rw_crapdat;

  --inserir lancamento na craplem    
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                         pr_dtmvtolt => to_date(rw_crapdat.Dtmvtolt,
                                                                'dd/mm/rrrr'),
                                         pr_cdagenci => 1,
                                         pr_cdbccxlt => 100,
                                         pr_cdoperad => 1,
                                         pr_cdpactra => 1,
                                         pr_tplotmov => 3,
                                         pr_nrdolote => 8361,
                                         pr_nrdconta => vr_nrdconta,
                                         pr_cdhistor => 2409,
                                         pr_nrctremp => vr_nrctremp,
                                         pr_vllanmto => vr_vljuros,
                                         pr_dtpagemp => to_date(rw_crapdat.Dtmvtolt,
                                                                'dd/mm/rrrr'),
                                         pr_txjurepr => 0.0006000,
                                         pr_vlpreemp => 1113.75,
                                         pr_nrsequni => 0,
                                         pr_nrparepr => 0,
                                         pr_flgincre => true,
                                         pr_flgcredi => true,
                                         pr_nrseqava => 0,
                                         pr_cdorigem => 0,
                                         pr_cdcritic => vr_cdcritic,
                                         pr_dscritic => vr_dscritic);

  IF vr_dscritic IS NULL OR vr_cdcritic IS NULL THEN
    --atualizar saldo nas informacoes do contrato
    UPDATE CECRED.CRAPEPR
       SET VLSPRJAT = VLSDPREJ,
           VLSDPREJ = VLSDPREJ + vr_vljuros,
           VLJRAPRJ = VLJRAPRJ + vr_vljuros,
           VLJRMPRJ = vr_vljuros
     WHERE CRAPEPR.CDCOOPER = vr_cdcooper
       AND CRAPEPR.NRDCONTA = vr_nrdconta
       AND CRAPEPR.NRCTREMP = vr_nrctremp;
  
  END IF;

  CLOSE cr_crapdat;

  commit;
exception
  when others then
    rollback;
    dbms_output.put_line(vr_dscritic);
    cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' ||
                                                vr_dscritic);
end;
