DECLARE
  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida   exception;
  vr_cdcooper    NUMBER := 1;
  vr_nrdconta    NUMBER := 12166103;
  vr_nrctremp    NUMBER := 3369926; 
    
  CURSOR cr_crappep (pr_cdcooper IN NUMBER
                    ,pr_nrdconta IN NUMBER
                    ,pr_nrctrato IN NUMBER)is
    SELECT b.dtvencto
          ,b.vlpagpar
          ,b.nrdconta
          ,b.nrctremp
          ,b.cdcooper
          ,b.nrparepr
          ,'28/04/2022' dtmvtolt
          ,min(b.idsequencia) idsequencia
      from crappep                    pep
          ,tbepr_consignado_pagamento b
     where pep.cdcooper = pr_cdcooper 
       and pep.nrdconta = pr_nrdconta  
       and pep.nrctremp = pr_nrctrato 
       and pep.nrparepr not in (1,2,8)
       and pep.nrdconta = b.nrdconta
       and pep.nrctremp = b.nrctremp
       and pep.nrparepr = b.nrparepr
       and pep.cdcooper = b.cdcooper
     group by b.dtvencto
             ,b.vlpagpar
             ,b.nrdconta
             ,b.nrctremp
             ,b.cdcooper
             ,b.nrparepr
     order by b.cdcooper
             ,b.nrdconta
             ,b.nrctremp
             ,b.nrparepr;
  rw_crappep cr_crappep%rowtype;
BEGIN  
  FOR rw_crappep IN cr_crappep(pr_cdcooper => TO_NUMBER(vr_cdcooper)
                              ,pr_nrdconta => TO_NUMBER(vr_nrdconta)
                              ,pr_nrctrato => TO_NUMBER(vr_nrctremp)) LOOP
    vr_motenvio    := 'REENVIARPAGTO';
    vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_crappep.vlpagpar, '999999990.00')) ||
                      '</valor>';
    vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>' ||
                      to_char(to_date(rw_crappep.dtmvtolt,'DD/MM/RRRR'), 'yyyy-mm-dd') || 'T' ||
                      to_char(sysdate, 'hh24:mi:ss') ||
                      '</dataEfetivacao> 
                            <dataVencimento>' ||
                      to_char(to_date(rw_crappep.dtvencto,'DD/MM/RRRR'), 'yyyy-mm-dd') ||
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
