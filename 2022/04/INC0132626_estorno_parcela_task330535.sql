DECLARE
  vr_xml_parcela VARCHAR2(1000);
  vr_motenvio    VARCHAR2(50);
  vr_dsxmlali    XMLType;
  vr_dscritic    VARCHAR2(4000);
  vr_idevento    tbgen_evento_soa.idevento%type;
  vr_tipo_pagto  VARCHAR2(500);
  vr_exc_saida exception;
  CURSOR cr_crappep is
    SELECT x.*
          ,REGEXP_SUBSTR('2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30','[^,]+', 1, LEVEL) as idsequencia
     FROM(SELECT b.dtvencto
                ,b.vlpagpar
                ,b.nrdconta
                ,b.nrctremp
                ,b.cdcooper
                ,b.nrparepr
                ,to_date('03/03/2022','DD/MM/RRRR') dtmvtolt          
            from crappep                    pep
                ,tbepr_consignado_pagamento b
           where pep.cdcooper = 7 
             and pep.nrdconta = 294284  
             and pep.nrctremp = 60161 
             and pep.nrparepr = 7
             and pep.nrdconta = b.nrdconta
             and pep.nrctremp = b.nrctremp
             and pep.nrparepr = b.nrparepr
             and pep.cdcooper = b.cdcooper
             and b.instatus = 1
           group by b.dtvencto
                   ,b.vlpagpar
                   ,b.nrdconta
                   ,b.nrctremp
                   ,b.cdcooper
                   ,b.nrparepr
                   ,b.dtmvtolt
           order by b.cdcooper
                   ,b.nrdconta
                   ,b.nrctremp
                   ,b.nrparepr) x  
      CONNECT BY REGEXP_SUBSTR('2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30','[^,]+', 1, LEVEL) IS NOT NULL;
  rw_crappep cr_crappep%rowtype;
BEGIN  
  FOR rw_crappep IN cr_crappep LOOP
    vr_motenvio    := 'REENVIARPAGTO';
    vr_tipo_pagto  := ' <valor>' || trim(to_char(rw_crappep.vlpagpar, '999999990.00')) ||
                      '</valor>';
    vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>' ||
                      to_char(rw_crappep.dtmvtolt, 'yyyy-mm-dd') || 'T' ||
                      to_char(sysdate, 'hh24:mi:ss') ||
                      '</dataEfetivacao> 
                            <dataVencimento>' ||
                      to_char(rw_crappep.dtvencto, 'yyyy-mm-dd') ||
                      '</dataVencimento>
                            <identificador>' || rw_crappep.idsequencia ||
                      '</identificador>' || vr_tipo_pagto || '</parcela>';
    CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper    => rw_crappep.cdcooper, 
                                    pr_nrdconta     => rw_crappep.nrdconta, 
                                    pr_nrctremp     => rw_crappep.nrctremp, 
                                    pr_xml_parcelas => vr_xml_parcela, 
                                    pr_tpenvio      => 2,           
                                    pr_tptransa     =>'ESTORNO DEBITO',     
                                    pr_motenvio     => '', 
                                    pr_dsxmlali     => vr_dsxmlali, 
                                    pr_dscritic     => vr_dscritic); 
        IF vr_dscritic IS NOT NULL  THEN
            RAISE vr_exc_saida;
        END IF;
                                    
        soap0003.pc_gerar_evento_soa(pr_cdcooper               => rw_crappep.cdcooper
                                    ,pr_nrdconta               => rw_crappep.nrdconta
                                    ,pr_nrctrprp               => rw_crappep.nrctremp
                                    ,pr_tpevento               => 'ESTORNO_ESTORN'
                                    ,pr_tproduto_evento        => 'CONSIGNADO'
                                    ,pr_tpoperacao             => 'INSERT'
                                    ,pr_dsconteudo_requisicao  => vr_dsxmlali.getClobVal()
                                    ,pr_idevento               => vr_idevento
                                    ,pr_dscritic               => vr_dscritic);
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;