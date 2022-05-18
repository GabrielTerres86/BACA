DECLARE
  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    cecred.tbgen_evento_soa.idevento%TYPE;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida EXCEPTION;

  CURSOR cr_craplcm IS
    SELECT b.dtvencto
      ,b.vlpagpar
      ,b.nrdconta
      ,b.nrctremp
      ,b.cdcooper
      ,b.nrparepr
      ,to_date('13/04/2022','dd/mm/yyyy') dtmvtolt
      ,MIN(b.idsequencia) idsequencia
    FROM cecred.tbepr_consignado_pagamento b
      ,(SELECT cdcooper
          ,nrdconta
          ,nrctremp
          ,nrparepr
        FROM cecred.crappep
       WHERE (cdcooper, nrdconta, nrctremp, nrparepr) IN
           ((1 , 10682333, 3189310, 17 ),
            (1, 10682333, 3088171, 17))
         AND inliquid = 0) pep
   WHERE pep.nrdconta = b.nrdconta
     AND pep.nrctremp = b.nrctremp
     AND pep.cdcooper = b.cdcooper
     AND pep.nrparepr = b.nrparepr
GROUP BY b.dtvencto
       ,b.vlpagpar
       ,b.nrdconta
       ,b.nrctremp
       ,b.cdcooper
       ,b.nrparepr
       ,b.dtmvtolt
   ORDER BY b.cdcooper
       ,b.nrdconta
       ,b.nrctremp
       ,b.nrparepr;
     
  rw_craplcm         cr_craplcm%ROWTYPE;
BEGIN

  FOR rw_craplcm IN cr_craplcm LOOP
    vr_motenvio    := 'REENVIARPAGTO';
    vr_tipo_pagto  := ' <valor>' || TRIM(to_char(rw_craplcm.vlpagpar, '999999990.00')) || '</valor>';
    vr_xml_parcela := ' <parcela>
              <dataEfetivacao>' || to_char(rw_craplcm.dtmvtolt,'yyyy-mm-dd') || 'T' || to_char(SYSDATE, 'hh24:mi:ss') || '</dataEfetivacao>
              <dataVencimento>' || to_char(rw_craplcm.dtvencto, 'yyyy-mm-dd') || '</dataVencimento>
              <identificador>' || rw_craplcm.idsequencia || '</identificador>' || vr_tipo_pagto || 
            '</parcela>';
  
    CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_craplcm.cdcooper, 
                                                 pr_nrdconta     => rw_craplcm.nrdconta, 
                                                 pr_nrctremp     => rw_craplcm.nrctremp, 
                                                 pr_xml_parcelas => vr_xml_parcela, 
                                                 pr_tpenvio      => 1, 
                                                 pr_tptransa     => 'DEBITO', 
                                                 pr_motenvio     => vr_motenvio, 
                                                 pr_dsxmlali     => vr_dsxmlali, 
                                                 pr_dscritic     => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    cecred.soap0003.pc_gerar_evento_soa(pr_cdcooper              => rw_craplcm.cdcooper,
                                 pr_nrdconta              => rw_craplcm.nrdconta,
                                 pr_nrctrprp              => rw_craplcm.nrctremp,
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
  raise_application_error(-20500, SQLERRM);
  ROLLBACK;
END;
