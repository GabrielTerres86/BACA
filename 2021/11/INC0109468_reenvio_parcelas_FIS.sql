DECLARE
 
vr_xml_parcela VARCHAR2(1000);
vr_motenvio    VARCHAR2(50);
vr_dsxmlali XMLType;
vr_dscritic VARCHAR2(4000);
vr_idevento   tbgen_evento_soa.idevento%type;
vr_tipo_pagto  VARCHAR2(500);
vr_exc_saida exception;

CURSOR cr_craplcm (pr_cdcooper IN crapepr.cdcooper%TYPE,
                   pr_nrdconta IN crapepr.nrdconta%TYPE,
                   pr_nrctremp IN crapepr.nrctremp%TYPE) IS       
        select pep.dtvencto,
               lcm.vllanmto,
               a.vlsaldoparc,
               lcm.nrdconta,
               pep.nrctremp,
               lcm.cdcooper,
               lcm.nrparepr,
               lcm.dtmvtolt,
               b.idsequencia
          from crappep pep, craplcm lcm, tbepr_consig_parcelas_tmp a, tbepr_consignado_pagamento b
         where lcm.nrparepr > 0
           and lcm.nrdconta = pr_nrdconta
           and lcm.cdcooper = pr_cdcooper
           and pep.nrctremp = pr_nrctremp
           and pep.nrdconta = lcm.nrdconta
           and pep.nrctremp = to_number(replace(lcm.cdpesqbb, '.', '') DEFAULT 0 ON CONVERSION ERROR)
           and pep.nrparepr = lcm.nrparepr
           and pep.cdcooper = lcm.cdcooper
           and a.cdcooper = pep.cdcooper
           and a.nrctremp = pep.nrctremp
           and a.nrdconta = pep.nrdconta
           and a.nrparcela = pep.nrparepr
           and a.vlsaldoparc = lcm.vllanmto
           and pep.inliquid = 0 -- Parcelas que não foram liquidadas mesmo com o pagamento
           and b.nrdconta = a.nrdconta
           and b.nrctremp = a.nrctremp
           and b.cdcooper = a.cdcooper
           and b.nrparepr = a.nrparcela;
                
    rw_craplcm cr_craplcm%ROWTYPE;

begin

    FOR rw_craplcm IN cr_craplcm(pr_cdcooper => 13,
                     pr_nrdconta => 180556,
                     pr_nrctremp => 54036) LOOP

        vr_motenvio := 'REENVIARPAGTO';
        vr_tipo_pagto := ' <valor>'||trim(to_char(rw_craplcm.vllanmto,'999999990.00'))||'</valor>' ;

        vr_xml_parcela := ' <parcela>
                            <dataEfetivacao>'||to_char(rw_craplcm.dtmvtolt,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
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

    commit;

EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    
end;