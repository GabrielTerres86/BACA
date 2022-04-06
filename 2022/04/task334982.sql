DECLARE

  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida exception;
  vr_cdcritic crapcri.cdcritic%TYPE;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  CURSOR cr_craplcm IS
    SELECT cp.cdcooper
          ,cp.nrdconta
          ,cp.nrctremp
          ,cp.nrparepr
          ,cp.dtvencto
          ,cp.dtmvtolt
          ,cp.vlpagpar
          ,cp.idintegracao
          ,cp.idsequencia
      from crappep                    pep
          ,tbepr_consignado_pagamento cp
     where pep.nrdconta = cp.nrdconta
       and pep.nrctremp = cp.nrctremp
       and pep.nrparepr = cp.nrparepr
       and pep.cdcooper = cp.cdcooper
       and (pep.cdcooper, pep.nrdconta, pep.nrctremp, pep.nrparepr) in ((1, 12543004, 3869309, 10))
       and trunc(cp.dtmvtolt) = trunc(to_date('06/04/2022', 'dd/mm/yyyy'))
       and cp.vlpagpar = 263.44
       and cp.idintegracao = 1
     order by cp.cdcooper
             ,cp.nrdconta
             ,cp.nrctremp
             ,cp.nrparepr;

  rw_craplcm cr_craplcm%ROWTYPE;

  CURSOR cr_crappep is
    SELECT cp.cdcooper
          ,cp.nrdconta
          ,cp.nrctremp
          ,cp.nrparepr
          ,cp.dtvencto
          ,cp.dtmvtolt
          ,cp.vlpagpar
          ,cp.idintegracao
          ,cp.idsequencia
          ,to_date('24/02/2022') as dataefetivacao
          ,733.76 as valorapagar
          ,cp.cdagenci
      from crappep                    pep
          ,tbepr_consignado_pagamento cp
     where pep.nrdconta = cp.nrdconta
       and pep.nrctremp = cp.nrctremp
       and pep.nrparepr = cp.nrparepr
       and pep.cdcooper = cp.cdcooper
       and (pep.cdcooper, pep.nrdconta, pep.nrctremp, pep.nrparepr) in ((1, 12543004, 3869309, 10))
       and trunc(cp.dtmvtolt) = trunc(to_date('06/04/2022', 'dd/mm/yyyy'))
       and cp.vlpagpar = 263.44
       and cp.idintegracao = 1
     order by cp.cdcooper
             ,cp.nrdconta
             ,cp.nrctremp
             ,cp.nrparepr;

  rw_crappep cr_crappep%rowtype;
BEGIN

  FOR rw_craplcm IN cr_craplcm LOOP
  
    vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_craplcm.vlpagpar, '999999990.00')) ||
                      '</valor>';
    vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>' ||
                      to_char(rw_craplcm.dtmvtolt, 'yyyy-mm-dd') || 'T' ||
                      to_char(sysdate, 'hh24:mi:ss') ||
                      '</dataEfetivacao> 
                            <dataVencimento>' ||
                      to_char(rw_craplcm.dtvencto, 'yyyy-mm-dd') ||
                      '</dataVencimento>
                            <identificador>' || rw_craplcm.idintegracao ||
                      '</identificador>' || vr_tipo_pagto || '</parcela>';
  
    CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_craplcm.cdcooper,
                                                 pr_nrdconta     => rw_craplcm.nrdconta,
                                                 pr_nrctremp     => rw_craplcm.nrctremp,
                                                 pr_xml_parcelas => vr_xml_parcela,
                                                 pr_tpenvio      => 2,
                                                 pr_tptransa     => 'ESTORNO DEBITO',
                                                 pr_motenvio     => '',
                                                 pr_dsxmlali     => vr_dsxmlali,
                                                 pr_dscritic     => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
    
      RAISE vr_exc_saida;
    
    END IF;
  
    soap0003.pc_gerar_evento_soa(pr_cdcooper              => rw_craplcm.cdcooper,
                                 pr_nrdconta              => rw_craplcm.nrdconta,
                                 pr_nrctrprp              => rw_craplcm.nrctremp,
                                 pr_tpevento              => 'ESTORNO_ESTORN',
                                 pr_tproduto_evento       => 'CONSIGNADO',
                                 pr_tpoperacao            => 'INSERT',
                                 pr_dsconteudo_requisicao => vr_dsxmlali.getClobVal(),
                                 pr_idevento              => vr_idevento,
                                 pr_dscritic              => vr_dscritic);
  
  END LOOP;

  COMMIT;

  FOR rw_crappep IN cr_crappep LOOP
  
    vr_motenvio    := 'REENVIARPAGTO';
    vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_crappep.valorapagar, '999999990.00')) ||
                      '</valor>';
    vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>' ||
                      to_char(rw_crappep.dataefetivacao, 'yyyy-mm-dd') || 'T' ||
                      to_char(sysdate, 'hh24:mi:ss') ||
                      '</dataEfetivacao> 
                            <dataVencimento>' ||
                      to_char(rw_crappep.dtvencto, 'yyyy-mm-dd') ||
                      '</dataVencimento>
                            <identificador>' || rw_crappep.idsequencia ||
                      '</identificador>' || vr_tipo_pagto || '</parcela>';
  
    CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_crappep.cdcooper,
                                                 pr_nrdconta     => rw_crappep.nrdconta,
                                                 pr_nrctremp     => rw_crappep.nrctremp,
                                                 pr_xml_parcelas => vr_xml_parcela,
                                                 pr_tpenvio      => 1,
                                                 pr_tptransa     => 'DEBITO',
                                                 pr_motenvio     => vr_motenvio,
                                                 pr_dsxmlali     => vr_dsxmlali,
                                                 pr_dscritic     => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
    
      RAISE vr_exc_saida;
    
    END IF;
  
    soap0003.pc_gerar_evento_soa(pr_cdcooper              => rw_crappep.cdcooper,
                                 pr_nrdconta              => rw_crappep.nrdconta,
                                 pr_nrctrprp              => rw_crappep.nrctremp,
                                 pr_tpevento              => 'PAGTO_PAGAR',
                                 pr_tproduto_evento       => 'CONSIGNADO',
                                 pr_tpoperacao            => 'INSERT',
                                 pr_dsconteudo_requisicao => vr_dsxmlali.getClobVal(),
                                 pr_idevento              => vr_idevento,
                                 pr_dscritic              => vr_dscritic);
  
    COMMIT;
  
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crappep.cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => rw_crappep.cdcooper,
                                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                    pr_cdagenci => rw_crappep.cdagenci,
                                    pr_cdbccxlt => 100,
                                    pr_cdoperad => 1,
                                    pr_cdpactra => rw_crappep.cdagenci,
                                    pr_tplotmov => 5,
                                    pr_nrdolote => 600031,
                                    pr_nrdconta => rw_crappep.nrdconta,
                                    pr_cdhistor => 3027,
                                    pr_nrctremp => rw_crappep.nrctremp,
                                    pr_vllanmto => 0.96,
                                    pr_dtpagemp => rw_crapdat.dtmvtolt,
                                    pr_txjurepr => 0,
                                    pr_vlpreemp => 0,
                                    pr_nrsequni => 0,
                                    pr_nrparepr => rw_crappep.nrparepr,
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

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
