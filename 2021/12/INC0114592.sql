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
to_date('01/11/2021','dd/mm/yyyy') dtmvtolt,
min(b.idsequencia) idsequencia
from crappep pep, tbepr_consignado_pagamento b
where (pep.nrdconta, pep.nrctremp, pep.cdcooper ) IN
(
(249505, 59898, 13)
,(13536290, 4571703, 1)
,(13217526, 4382622, 1)
)
and pep.nrdconta = b.nrdconta
and pep.nrctremp = b.nrctremp
and pep.nrparepr = b.nrparepr
and pep.cdcooper = b.cdcooper
and b.instatus <> 2
and pep.inliquid = 0
group by b.dtvencto,
b.vlpagpar,
b.nrdconta,
b.nrctremp,
b.cdcooper,
b.nrparepr,
b.dtmvtolt
order by b.cdcooper, b.nrdconta, b.nrctremp, b.nrparepr;
                
    rw_craplcm cr_craplcm%ROWTYPE;
	dataAcaoUsuario VARCHAR(100) := to_char( sysdate, 'yyyy-mm-dd' ) || 'T' || to_char(SYSDATE, 'hh:mi:ss');

	v_nrdconta tbgen_evento_soa.NRDCONTA%type := 525774;
	v_cdcooper tbgen_evento_soa.CDCOOPER%type := 9;
	v_nrctrprp tbgen_evento_soa.NRCTRPRP%type := 20100533;
	v_vlparpag VARCHAR2(10) := '60.11';
  
  						  
	conta_525774_09_21 CLOB := '<?xml version="1.0"?>
                              <Root>
                                <convenioCredito>
                                  <cooperativa>
                                    <codigo>' ||to_char(v_cdcooper)|| '</codigo>
                                  </cooperativa>
                                  <numeroContrato>' ||to_char(v_nrctrprp)|| '</numeroContrato>
                                </convenioCredito>
                                <propostaContratoCredito>
                                  <emitente>
                                    <contaCorrente>
                                      <codigoContaSemDigito>' ||to_char(v_nrdconta)|| '</codigoContaSemDigito>
                                    </contaCorrente>
                                  </emitente>
                                </propostaContratoCredito>
                                <lote>
                                  <tipoInteracao>
                                    <codigo>INSTALLMENT_SETTLEMENT</codigo>
                                  </tipoInteracao>
                                </lote>
                                <transacaoContaCorrente>
                                  <tipoInteracao>
                                    <codigo>DEBITO</codigo>
                                  </tipoInteracao>
                                </transacaoContaCorrente>
                                <parcela>
                                  <dataEfetivacao>2021-10-14T07:00:07</dataEfetivacao> 
                                  <dataVencimento>2021-09-10</dataVencimento>
                                  <identificador>727245</identificador>
                                  <valor>' ||to_char(v_vlparpag)|| '</valor>
                                </parcela>
                                <motivoEnvio>REENVIARPAGTO</motivoEnvio>
                                <interacaoGrafica>
                                  <dataAcaoUsuario>' || dataAcaoUsuario || '</dataAcaoUsuario>
                                </interacaoGrafica>
                              </Root>';	
	
BEGIN
  
    FOR rw_craplcm IN cr_craplcm LOOP
        vr_motenvio := 'REENVIARPAGTO';
        vr_tipo_pagto := ' <valor>'||trim(to_char(rw_craplcm.vlpagpar,'999999990.00'))||'</valor>' ;
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
	
	INSERT INTO tbgen_evento_soa
	(
		CDCOOPER,
		NRDCONTA,
		NRCTRPRP,
		TPEVENTO,
		TPRODUTO_EVENTO,
		TPOPERACAO,
		DHOPERACAO,
		DSPROCESSAMENTO,
		DSSTATUS,
		DHEVENTO,
		DSERRO,
		NRTENTATIVAS,
		DSCONTEUDO_REQUISICAO
	)
	VALUES
	(
		v_cdcooper,
		v_nrdconta,
		v_nrctrprp,
		'PAGTO_PAGAR',
		'CONSIGNADO',
		'INSERT',
		SYSDATE,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		conta_525774_09_21
	);
  
	UPDATE crappep
	   SET vlpagpar = 170.60,
		   inliquid = 1,
		   vlsdvpar = 0,
		   vlsdvatu = 0
	 WHERE cdcooper = v_cdcooper
	   AND nrdconta = v_nrdconta
	   AND nrctremp = v_nrctrprp
	   AND nrparepr = 1
	   AND inliquid = 0;
	                                
    COMMIT;
	
	
    UPDATE crapepr pr
       SET inliquid = 1, vlsdeved = 0
     WHERE pr.tpemprst = 1
      AND pr.tpdescto = 2
      AND pr.inliquid = 0
      AND NOT EXISTS (SELECT 1 FROM crappep p
                       WHERE p.cdcooper = pr.cdcooper
                         AND p.nrdconta = pr.nrdconta
                         AND p.nrctremp = pr.nrctremp
                         AND p.inliquid = 0);
    COMMIT;	

EXCEPTION
    WHEN OTHERS THEN
         ROLLBACK;
    
end;