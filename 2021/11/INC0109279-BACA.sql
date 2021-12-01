DECLARE

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
  
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;