DECLARE

  dataAcaoUsuario VARCHAR(100) := to_char(SYSDATE, 'DD/MM/YYYY hh24:mi:ss');

  conta_292770_13_19 CLOB := '<?xml version="1.0"?>
                              <Root>
                                <convenioCredito>
                                  <cooperativa>
                                    <codigo>13</codigo>
                                  </cooperativa>
                                  <numeroContrato>51071</numeroContrato>
                                </convenioCredito>
                                <propostaContratoCredito>
                                  <emitente>
                                    <contaCorrente>
                                      <codigoContaSemDigito>29277</codigoContaSemDigito>
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
                                  <dataEfetivacao>2021-07-15T15:02:58</dataEfetivacao> 
                                  <dataVencimento>2021-06-10</dataVencimento>
                                  <identificador>39695</identificador>
                                  <valor>382.42</valor>
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
	  13,
	  292770,
	  51071,
	  'PAGTO_PAGAR',
	  'CONSIGNADO',
	  'INSERT',
	  SYSDATE,
	  NULL,
	  NULL,
	  NULL,
	  NULL,
	  NULL,
	  NULL
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;