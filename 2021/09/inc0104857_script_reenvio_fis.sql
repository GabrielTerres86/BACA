DECLARE

  conta_2515938_01_07 CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>3969605</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>2515938</codigoContaSemDigito>
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
    <dataEfetivacao>2021-08-02T12:31:34</dataEfetivacao> 
    <dataVencimento>2021-07-01</dataVencimento>
    <identificador>49225</identificador>
    <valor>1394.13</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-09-23T00:00:00</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

BEGIN

  INSERT INTO TBGEN_EVENTO_SOA
    (CDCOOPER
    ,NRDCONTA
    ,NRCTRPRP
    ,TPEVENTO
    ,TPRODUTO_EVENTO
    ,TPOPERACAO
    ,DHOPERACAO
    ,DSPROCESSAMENTO
    ,DSSTATUS
    ,DHEVENTO
    ,DSERRO
    ,NRTENTATIVAS
    ,DSCONTEUDO_REQUISICAO)
  VALUES
    (1
    ,2515938
    ,3969605
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_2515938_01_07);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
