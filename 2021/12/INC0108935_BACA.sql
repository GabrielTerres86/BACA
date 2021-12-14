DECLARE

	dataAcaoUsuario VARCHAR(100) := to_char( sysdate, 'yyyy-mm-dd' ) || 'T' || to_char(SYSDATE, 'hh:mi:ss');

	v_nrdconta tbgen_evento_soa.NRDCONTA%type := 8840598;
	v_cdcooper tbgen_evento_soa.CDCOOPER%type := 1;
	v_nrctrprp tbgen_evento_soa.NRCTRPRP%type := 2955363;
	v_vlparpag VARCHAR2(10) := '262.54';
  	
	conta_8840598_p6 CLOB := '<?xml version="1.0"?>
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
                                  <dataEfetivacao>2021-08-19T08:52:12</dataEfetivacao> 
								  <dataVencimento>2021-03-10</dataVencimento>
								  <identificador>357946</identificador>
                                  <valor>' ||to_char(v_vlparpag)|| '</valor>
                                </parcela>
                                <motivoEnvio>REENVIARPAGTO</motivoEnvio>
                                <interacaoGrafica>
                                  <dataAcaoUsuario>' || dataAcaoUsuario || '</dataAcaoUsuario>
                                </interacaoGrafica>
                              </Root>';

	v_vlparpag_9 VARCHAR2(10) := '253.18';
	
	conta_8840598_p9 CLOB := '<?xml version="1.0"?>
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
                                  <dataEfetivacao>2021-08-19T08:52:12</dataEfetivacao> 
								  <dataVencimento>2021-06-10</dataVencimento>
								  <identificador>357949</identificador>
                                  <valor>' ||to_char(v_vlparpag_9)|| '</valor>
                                </parcela>
                                <motivoEnvio>REENVIARPAGTO</motivoEnvio>
                                <interacaoGrafica>
                                  <dataAcaoUsuario>' || dataAcaoUsuario || '</dataAcaoUsuario>
                                </interacaoGrafica>
                              </Root>';

BEGIN
  
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
		conta_8840598_p6
	);
	
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
		conta_8840598_p9
	);
  
	UPDATE crappep
	   SET vlpagpar = 262.54,
		   inliquid = 1,
		   vlsdvpar = 0,
		   vlsdvatu = 0
	 WHERE cdcooper = v_cdcooper
	   AND nrdconta = v_nrdconta
	   AND nrctremp = v_nrctrprp
	   AND nrparepr = 6
	   AND inliquid = 0;
	   
	UPDATE crappep
	   SET vlpagpar = 253.18,
		   inliquid = 1,
		   vlsdvpar = 0,
		   vlsdvatu = 0
	 WHERE cdcooper = v_cdcooper
	   AND nrdconta = v_nrdconta
	   AND nrctremp = v_nrctrprp
	   AND nrparepr = 9
	   AND inliquid = 0;
	 
	COMMIT;
  
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;