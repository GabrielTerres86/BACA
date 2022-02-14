declare 

 vr_dsxmlali clob := '<?xml version="1.0" encoding="ISO-8859-1" ?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>9193537</numeroContrato>
  </convenioCredito>
  <propostaContratoCredito>
    <emitente>
      <contaCorrente>
        <codigoContaSemDigito>2956223</codigoContaSemDigito>
      </contaCorrente>
    </emitente>
  </propostaContratoCredito>
  <lote>
    <tipoInteracao>
      <codigo>REVERSAL_SETTLEMENT</codigo>
    </tipoInteracao>
  </lote>
  <transacaoContaCorrente>
    <tipoInteracao>
      <codigo>ESTORNO DEBITO</codigo>
    </tipoInteracao>
  </transacaoContaCorrente>
  <interacaoGrafica>
    <dataAcaoUsuario>2022-02-14T14:09:52</dataAcaoUsuario>
  </interacaoGrafica>
  <parcela>
    <dataEfetivacao>2022-02-14T14:09:52</dataEfetivacao>
    <dataVencimento>2021-10-10</dataVencimento>
    <identificador>1</identificador>
    <valor>712.84</valor>
  </parcela>
  <motivoEnvio>PADRAO</motivoEnvio>
</Root>';

begin
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (1, 2956223, 9193537, 'ESTORNO_ESTORN', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, vr_dsxmlali);
 commit;    
end;
