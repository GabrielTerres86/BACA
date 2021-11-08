DECLARE

  dataAcaoUsuario VARCHAR(100) := to_char( sysdate, 'yyyy-mm-dd' ) || 'T' || to_char(SYSDATE, 'hh:mi:ss');

  conta_121720_10_19 CLOB := '<?xml version="1.0"?>
                              <Root>
                                <convenioCredito>
                                  <cooperativa>
                                    <codigo>10</codigo>
                                  </cooperativa>
                                  <numeroContrato>17476</numeroContrato>
                                </convenioCredito>
                                <propostaContratoCredito>
                                  <emitente>
                                    <contaCorrente>
                                      <codigoContaSemDigito>121720</codigoContaSemDigito>
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
                                  <dataEfetivacao>2021-08-31T15:02:58</dataEfetivacao> 
                                  <dataVencimento>2021-08-10</dataVencimento>
                                  <identificador>361004</identificador>
                                  <valor>162.97</valor>
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
	  10,
	  121720,
	  17476,
	  'PAGTO_PAGAR',
	  'CONSIGNADO',
	  'INSERT',
	  SYSDATE,
	  NULL,
	  NULL,
	  NULL,
	  NULL,
	  NULL,
	  conta_121720_10_19
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;