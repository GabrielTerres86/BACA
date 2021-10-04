DECLARE
  v_data_acao_usuario varchar2(30) := to_char(sysdate,'yyyy')||'-'||to_char(sysdate,'mm')||'-'||to_char(sysdate,'dd')||'T'||to_char(sysdate,'hh24')||':'||to_char(sysdate,'mi')||':'||to_char(sysdate,'ss');
  conta_61646_10_07 CLOB := '<?xml version="1.0" encoding="ISO-8859-1" ?> <Root><convenioCredito><cooperativa><codigo>9</codigo></cooperativa><numeroContrato>21100066</numeroContrato></convenioCredito><propostaContratoCredito><emitente><contaCorrente><codigoContaSemDigito>524450</codigoContaSemDigito></contaCorrente></emitente></propostaContratoCredito><lote><tipoInteracao><codigo>INSTALLMENT_SETTLEMENT</codigo></tipoInteracao></lote><transacaoContaCorrente><tipoInteracao><codigo>DEBITO</codigo></tipoInteracao></transacaoContaCorrente><motivoEnvio>PADRAO</motivoEnvio><interacaoGrafica><dataAcaoUsuario>'||v_data_acao_usuario||'</dataAcaoUsuario></interacaoGrafica><parcela><dataEfetivacao>2021-09-10T11:10:16</dataEfetivacao><dataVencimento>2021-09-10</dataVencimento><identificador>362030</identificador><valor>53.90</valor></parcela></Root>';
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
    (9
    ,524450
    ,21100066
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
  