DECLARE

  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida exception;

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
          ,to_date('25/02/2022', 'dd/mm/yyyy') as dataefetivacao
      from crappep                    pep
          ,tbepr_consignado_pagamento cp
     where pep.nrdconta = cp.nrdconta
       and pep.nrctremp = cp.nrctremp
       and pep.nrparepr = cp.nrparepr
       and pep.cdcooper = cp.cdcooper
       and (pep.cdcooper, pep.nrdconta, pep.nrctremp, pep.nrparepr) in ((1, 12390917, 5060921, 1))
     order by cp.cdcooper
             ,cp.nrdconta
             ,cp.nrctremp
             ,cp.nrparepr;

  rw_crappep cr_crappep%rowtype;

BEGIN

  FOR rw_crappep IN cr_crappep LOOP
    vr_motenvio    := 'REENVIARPAGTO';
    vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_crappep.vlpagpar, '999999990.00')) ||
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
  END LOOP;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
