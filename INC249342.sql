DECLARE

  dataAcaoUsuario VARCHAR(100) := to_char( sysdate, 'yyyy-mm-dd' ) || 'T' || to_char(SYSDATE, 'hh:mi:ss');
  
  v_nrdconta tbgen_evento_soa.NRDCONTA%type := 121720;
  v_cdcooper tbgen_evento_soa.CDCOOPER%type := 10;
  v_nrctrprp tbgen_evento_soa.NRCTRPRP%type := 17476;
  
  v_nrdconta_2 tbgen_evento_soa.NRDCONTA%type := 850721;
  v_cdcooper_2 tbgen_evento_soa.CDCOOPER%type := 2;
  v_nrctrprp_2 tbgen_evento_soa.NRCTRPRP%type := 267733;

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
                                      <codigoContaSemDigito>292770</codigoContaSemDigito>
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
							  
	conta_121720_10_19 CLOB := '<?xml version="1.0"?>
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
							  
	conta_850721_02_19 CLOB := '<?xml version="1.0"?>
                              <Root>
                                <convenioCredito>
                                  <cooperativa>
                                    <codigo>' ||to_char(v_cdcooper_2)|| '</codigo>
                                  </cooperativa>
                                  <numeroContrato>' ||to_char(v_nrctrprp_2)|| '</numeroContrato>
                                </convenioCredito>
                                <propostaContratoCredito>
                                  <emitente>
                                    <contaCorrente>
                                      <codigoContaSemDigito>' ||to_char(v_nrdconta_2)|| '</codigoContaSemDigito>
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
                                  <dataEfetivacao>2021-10-06T15:02:58</dataEfetivacao> 
                                  <dataVencimento>2022-03-10</dataVencimento>
                                  <identificador>725565</identificador>
                                  <valor>352.87</valor>
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
	  conta_292770_13_19
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
	  conta_121720_10_19
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
	  v_cdcooper_2,
	  v_nrdconta_2,
	  v_nrctrprp_2,
	  'PAGTO_PAGAR',
	  'CONSIGNADO',
	  'INSERT',
	  SYSDATE,
	  NULL,
	  NULL,
	  NULL,
	  NULL,
	  NULL,
	  conta_850721_02_19
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;