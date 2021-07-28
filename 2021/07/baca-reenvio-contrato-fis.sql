begin

insert into tbgen_evento_soa ( CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values ( 10, 105090, 17740, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', null, null, null, null, null, null, '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>10</codigo>
    </cooperativa>
    <numeroContrato>17740</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>105090</codigoContaSemDigito>
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
    <dataEfetivacao>2021-06-29T12:30:23</dataEfetivacao>
    <dataVencimento>2021-06-10</dataVencimento>
    <identificador>39695</identificador>
    <valor>192.25</valor>
  </parcela>
  <motivoEnvio>PADRAO</motivoEnvio>
  <interacaoGrafica>
    <dataAcaoUsuario>2021-07-28T12:30:23</dataAcaoUsuario>
  </interacaoGrafica>
</Root>
');

commit;

end;