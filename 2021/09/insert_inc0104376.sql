DECLARE
  v_data_acao_usuario varchar2(30) := to_char(sysdate,'yyyy')||'-'||to_char(sysdate,'mm')||'-'||to_char(sysdate,'dd')||'T'||to_char(sysdate,'hh24')||':'||to_char(sysdate,'mi')||':'||to_char(sysdate,'ss');
  conta_61646_10_07 CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
<cooperativa>
<codigo>5</codigo>
</cooperativa>
<numeroContrato>21945</numeroContrato>
</convenioCredito>
<propostaContratoCredito>
<emitente>
<contaCorrente>
<codigoContaSemDigito>87521</codigoContaSemDigito>
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
</transacaoContaCorrente> <parcela>
<dataEfetivacao>2021-07-30T07:00:08</dataEfetivacao>
<dataVencimento>2021-05-10</dataVencimento>
<identificador>48781</identificador> <valor>238.40</valor></parcela><motivoEnvio>REENVIARPAGTO</motivoEnvio><interacaoGrafica>
<dataAcaoUsuario>'||v_data_acao_usuario||'</dataAcaoUsuario></interacaoGrafica></Root>';
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
    (5
    ,87521
    ,21945
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta_61646_10_07);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
