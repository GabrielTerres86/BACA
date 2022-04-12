DECLARE

  vr_xml_parcela VARCHAR2(1000);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_exc_saida exception;

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
      from crappep pep
     inner join tbepr_consignado_pagamento cp
        on cp.cdcooper = pep.cdcooper
       and cp.nrdconta = pep.nrdconta
       and cp.nrctremp = pep.nrctremp
       and cp.nrparepr = pep.nrparepr
     where (pep.cdcooper, pep.nrdconta, pep.nrctremp, pep.nrparepr) in ((9, 503207, 21300042, 6))
     order by cp.cdcooper
             ,cp.nrdconta
             ,cp.nrctremp
             ,cp.nrparepr;

  rw_craplcm cr_craplcm%ROWTYPE;

BEGIN

  FOR rw_craplcm IN cr_craplcm LOOP
  
    vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>' ||
                      to_char(rw_craplcm.dtmvtolt, 'yyyy-mm-dd') || 'T' ||
                      to_char(sysdate, 'hh24:mi:ss') || '</dataEfetivacao> 
                       <dataVencimento>' ||
                      to_char(rw_craplcm.dtvencto, 'yyyy-mm-dd') ||
                      '</dataVencimento>
                       <identificador>' || rw_craplcm.idintegracao ||
                      '</identificador> 
                       <valor>' ||
                      trim(to_char(rw_craplcm.vlpagpar, '999999990.00')) || '</valor>' ||
                      '</parcela>';
  
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

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
