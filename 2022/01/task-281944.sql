DECLARE
vr_xml_parcela VARCHAR2(1000);
vr_motenvio    VARCHAR2(50);
vr_dsxmlali    XMLType;
vr_dscritic    VARCHAR2(4000);
vr_idevento    tbgen_evento_soa.idevento%type;
vr_tipo_pagto  VARCHAR2(500);
vr_exc_saida   exception;

CURSOR cr_craplcm IS  
SELECT b.dtvencto,
       b.vlpagpar,
       b.nrdconta,
       b.nrctremp,
       b.cdcooper,
       b.nrparepr,
       b.dtmvtolt,
       min(b.idsequencia) idsequencia
    FROM tbepr_consignado_pagamento b,
       (SELECT cdcooper, nrdconta, nrctremp, nrparepr
        FROM crappep
       WHERE (cdcooper, nrdconta, nrctremp, nrparepr) in ((2, 880019, 302476, 35))
       and inliquid = 0)pep
   WHERE pep.nrdconta = b.nrdconta
     AND pep.nrctremp = b.nrctremp
     AND pep.cdcooper = b.cdcooper
     AND pep.nrparepr = b.nrparepr
     AND b.instatus <> 2
  GROUP BY b.dtvencto,
       b.vlpagpar,
       b.nrdconta,
       b.nrctremp,
       b.cdcooper,
       b.nrparepr,
       b.dtmvtolt
  ORDER BY b.cdcooper, b.nrdconta, b.nrctremp, b.nrparepr;
   rw_craplcm cr_craplcm%ROWTYPE;
BEGIN
  
    FOR rw_craplcm IN cr_craplcm LOOP
        vr_motenvio := 'REENVIARPAGTO';
        vr_tipo_pagto := ' <valor>'||trim(to_char(rw_craplcm.vlpagpar,'999999990.00'))||'</valor>' ;
        vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>'||('2021-10-29')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
                            <dataVencimento>'||to_char(rw_craplcm.dtvencto,'yyyy-mm-dd')||'</dataVencimento>
                            <identificador>'||rw_craplcm.idsequencia||'</identificador>'||
                            vr_tipo_pagto|| 
                        '</parcela>';
        CECRED.EMPR0020.pc_gera_xml_pagamento_consig(pr_cdcooper    => rw_craplcm.cdcooper, -- código da cooperativa
                                    pr_nrdconta     => rw_craplcm.nrdconta, -- Número da conta
                                    pr_nrctremp     => rw_craplcm.nrctremp, -- Número do contrato de emprestimo
                                    pr_xml_parcelas => vr_xml_parcela, -- xml da parcela
                                    pr_tpenvio      => 1,           -- Tipo de envio (1-INSTALLMENT_SETTLEMENT, 2-REVERSAL_SETTLEMENT,3-CONTRACT_SETTLEMENT, 4-DEFAULTING_INSTALLMENT_SETTLEMENT)
                                    pr_tptransa     =>'DEBITO',     -- tipo transação (DEBITO, ESTORNO DEBITO)
                                    pr_motenvio     => vr_motenvio, -- Motivo de envio à FIS
                                    pr_dsxmlali     => vr_dsxmlali, -- XML de saida do pagamento
                                    pr_dscritic     => vr_dscritic); 
        IF vr_dscritic IS NOT NULL  THEN
            RAISE vr_exc_saida;
        END IF;
                                    
        soap0003.pc_gerar_evento_soa(pr_cdcooper               => rw_craplcm.cdcooper
                                    ,pr_nrdconta               => rw_craplcm.nrdconta
                                    ,pr_nrctrprp               => rw_craplcm.nrctremp
                                    ,pr_tpevento               => 'PAGTO_PAGAR'
                                    ,pr_tproduto_evento        => 'CONSIGNADO'
                                    ,pr_tpoperacao             => 'INSERT'
                                    ,pr_dsconteudo_requisicao  => vr_dsxmlali.getClobVal()
                                    ,pr_idevento               => vr_idevento
                                    ,pr_dscritic               => vr_dscritic);
    END LOOP;    
                                
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
         ROLLBACK;
    
end;
