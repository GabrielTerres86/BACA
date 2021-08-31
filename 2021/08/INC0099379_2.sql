declare

conta_12412902_08_01 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>3613511</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>12412902</codigoContaSemDigito>
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
    <dataEfetivacao>2021-07-23T11:14:52</dataEfetivacao>
    <dataVencimento>2021-08-01</dataVencimento>
    <identificador>46740</identificador>
    <valor>410.06</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-07-28T14:28:04</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

conta_12412902_09_01 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>3613511</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>12412902</codigoContaSemDigito>
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
    <dataEfetivacao>2021-07-23T11:14:52</dataEfetivacao>
    <dataVencimento>2021-09-01</dataVencimento>
    <identificador>46741</identificador>
    <valor>406.75</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-07-28T14:28:05</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

conta_12412902_11_01 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>3613511</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>12412902</codigoContaSemDigito>
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
    <dataEfetivacao>2021-07-23T11:14:52</dataEfetivacao>
    <dataVencimento>2021-11-01</dataVencimento>
    <identificador>46743</identificador>
    <valor>400.30</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-07-28T14:28:05</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

conta_12412902_02_01 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>3613511</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>12412902</codigoContaSemDigito>
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
    <dataEfetivacao>2021-07-23T11:14:52</dataEfetivacao>
    <dataVencimento>2022-02-01</dataVencimento>
    <identificador>46746</identificador>
    <valor>390.77</valor>
  </parcela>
  <motivoEnvio>REENVIARPAGTO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-07-28T14:28:05</dataAcaoUsuario>
  </interacaoGrafica>
</Root>';

begin

    insert into TBGEN_EVENTO_SOA ( CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values ( 1, 12412902, 3613511, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_12412902_08_01);

    insert into TBGEN_EVENTO_SOA ( CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values ( 1, 12412902, 3613511, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_12412902_09_01);

    insert into TBGEN_EVENTO_SOA ( CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values ( 1, 12412902, 3613511, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_12412902_11_01);

    insert into TBGEN_EVENTO_SOA ( CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values ( 1, 12412902, 3613511, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_12412902_02_01);

    commit;

EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;

end;