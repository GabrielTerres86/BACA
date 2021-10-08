DECLARE
  v_data_acao_usuario varchar2(30) := to_char(sysdate,'yyyy')||'-'||to_char(sysdate,'mm')||'-'||to_char(sysdate,'dd')||'T'||to_char(sysdate,'hh24')||':'||to_char(sysdate,'mi')||':'||to_char(sysdate,'ss');
  conta CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
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
                  </transacaoContaCorrente> <parcela>
                           <dataEfetivacao>2021-07-21T08:18:32</dataEfetivacao> 
                           <dataVencimento>2021-06-10</dataVencimento>
                           <identificador>44257</identificador> <valor>382.42</valor></parcela><motivoEnvio>REENVIARPAGTO</motivoEnvio><interacaoGrafica>
                    <dataAcaoUsuario>'||v_data_acao_usuario||'</dataAcaoUsuario>
                  </interacaoGrafica></Root>';        
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
    (13
    ,292770
    ,51071
    ,'PAGTO_PAGAR'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,conta);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
  