DECLARE
    conta_26654_108177_1 CLOB := '<?xml version="1.0"?> <Root>   <convenioCredito>     <cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>108177</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente>       <contaCorrente>         <codigoContaSemDigito>26654</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>2022-10-13T08:00:00</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2022-09-26T08:00:00</dataEfetivacao>     <dataVencimento>2022-01-10</dataVencimento>     <identificador>1680729</identificador>     <valor>182.58</valor>   </parcela> </Root> ';
    conta_26654_108177_2 CLOB := '<?xml version="1.0"?> <Root>   <convenioCredito>     <cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>108177</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente>       <contaCorrente>         <codigoContaSemDigito>26654</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>2022-10-13T08:00:00</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2022-09-26T08:00:00</dataEfetivacao>     <dataVencimento>2022-02-10</dataVencimento>     <identificador>1680730</identificador>     <valor>180.41</valor>   </parcela> </Root> ';
    conta_26654_108177_3 CLOB := '<?xml version="1.0"?> <Root>   <convenioCredito>     <cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>108177</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente>       <contaCorrente>         <codigoContaSemDigito>26654</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>2022-10-13T08:00:00</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2022-09-26T08:00:00</dataEfetivacao>     <dataVencimento>2022-03-10</dataVencimento>     <identificador>1680731</identificador>     <valor>178.46</valor>   </parcela> </Root> ';
    conta_26654_108177_4 CLOB := '<?xml version="1.0"?> <Root>   <convenioCredito>     <cooperativa>       <codigo>13</codigo>     </cooperativa>     <numeroContrato>108177</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente>       <contaCorrente>         <codigoContaSemDigito>26654</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PREJUIZO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>2022-10-13T08:00:00</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2022-09-26T08:00:00</dataEfetivacao>     <dataVencimento>2022-04-10</dataVencimento>     <identificador>1680732</identificador>     <valor>176.53</valor>   </parcela> </Root> ';
    conta_6683045_3919366 CLOB := '<?xml version="1.0"?> <Root>   <convenioCredito>     <cooperativa>       <codigo>1</codigo>     </cooperativa>     <numeroContrato>3919366</numeroContrato>   </convenioCredito>   <propostaContratoCredito>     <emitente>       <contaCorrente>         <codigoContaSemDigito>6683045</codigoContaSemDigito>       </contaCorrente>     </emitente>   </propostaContratoCredito>   <lote>     <tipoInteracao>       <codigo>INSTALLMENT_SETTLEMENT</codigo>     </tipoInteracao>   </lote>   <transacaoContaCorrente>     <tipoInteracao>       <codigo>DEBITO</codigo>     </tipoInteracao>   </transacaoContaCorrente>   <motivoEnvio>PADRAO</motivoEnvio>   <interacaoGrafica>     <dataAcaoUsuario>2022-10-13T08:00:00</dataAcaoUsuario>   </interacaoGrafica>   <parcela>     <dataEfetivacao>2022-09-22T08:00:00</dataEfetivacao>     <dataVencimento>2025-03-10</dataVencimento>     <identificador>1680275</identificador>     <valor>269.85</valor>   </parcela> </Root> ';
BEGIN
    INSERT INTO tbgen_evento_soa
                (cdcooper,
                 nrdconta,
                 nrctrprp,
                 tpevento,
                 tproduto_evento,
                 tpoperacao,
                 dhoperacao,
                 dsprocessamento,
                 dsstatus,
                 dhevento,
                 dserro,
                 nrtentativas,
                 dsconteudo_requisicao)
    VALUES      (13,
                 26654,
                 108177,
                 'PAGTO_PAGAR',
                 'CONSIGNADO',
                 'INSERT',
                 SYSDATE,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 conta_26654_108177_1);
                 
    INSERT INTO tbgen_evento_soa
                (cdcooper,
                 nrdconta,
                 nrctrprp,
                 tpevento,
                 tproduto_evento,
                 tpoperacao,
                 dhoperacao,
                 dsprocessamento,
                 dsstatus,
                 dhevento,
                 dserro,
                 nrtentativas,
                 dsconteudo_requisicao)
    VALUES      (13,
                 26654,
                 108177,
                 'PAGTO_PAGAR',
                 'CONSIGNADO',
                 'INSERT',
                 SYSDATE,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 conta_26654_108177_2);
                 
    INSERT INTO tbgen_evento_soa
                (cdcooper,
                 nrdconta,
                 nrctrprp,
                 tpevento,
                 tproduto_evento,
                 tpoperacao,
                 dhoperacao,
                 dsprocessamento,
                 dsstatus,
                 dhevento,
                 dserro,
                 nrtentativas,
                 dsconteudo_requisicao)
    VALUES      (13,
                 26654,
                 108177,
                 'PAGTO_PAGAR',
                 'CONSIGNADO',
                 'INSERT',
                 SYSDATE,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 conta_26654_108177_3);
      
    INSERT INTO tbgen_evento_soa
                (cdcooper,
                 nrdconta,
                 nrctrprp,
                 tpevento,
                 tproduto_evento,
                 tpoperacao,
                 dhoperacao,
                 dsprocessamento,
                 dsstatus,
                 dhevento,
                 dserro,
                 nrtentativas,
                 dsconteudo_requisicao)
    VALUES      (13,
                 26654,
                 108177,
                 'PAGTO_PAGAR',
                 'CONSIGNADO',
                 'INSERT',
                 SYSDATE,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 conta_26654_108177_4);
                 
     INSERT INTO tbgen_evento_soa
                (cdcooper,
                 nrdconta,
                 nrctrprp,
                 tpevento,
                 tproduto_evento,
                 tpoperacao,
                 dhoperacao,
                 dsprocessamento,
                 dsstatus,
                 dhevento,
                 dserro,
                 nrtentativas,
                 dsconteudo_requisicao)
    VALUES      (1,
                 6683045,
                 3919366,
                 'PAGTO_PAGAR',
                 'CONSIGNADO',
                 'INSERT',
                 SYSDATE,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 conta_6683045_3919366);

    COMMIT;
    
    EXCEPTION
      
      WHEN OTHERS THEN
        RAISE_application_error(-20500, SQLERRM);
        ROLLBACK;
  
END; 
