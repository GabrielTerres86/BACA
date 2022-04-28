BEGIN
  
insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (9, 525820, 21100180, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', SYSDATE, null, null, null, null, null, '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                    <cooperativa>
                      <codigo>9</codigo>
                    </cooperativa>
                    <numeroContrato>21100180</numeroContrato>
                  </convenioCredito>
                  <propostaContratoCredito>
                    <emitente>
                      <contaCorrente>
                        <codigoContaSemDigito>525820</codigoContaSemDigito>
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
                            <dataEfetivacao>2021-10-06T10:57:33</dataEfetivacao> 
                            <dataVencimento>2021-08-10</dataVencimento>
                            <identificador>725617</identificador> <valor>26.19</valor></parcela><motivoEnvio>REENVIARPAGTO</motivoEnvio><interacaoGrafica>
                    <dataAcaoUsuario>2021-12-07T10:57:33</dataAcaoUsuario>
                  </interacaoGrafica></Root>');

insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (9, 517984, 21100236, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', SYSDATE, null, null, null, null, null, '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                    <cooperativa>
                      <codigo>9</codigo>
                    </cooperativa>
                    <numeroContrato>21100236</numeroContrato>
                  </convenioCredito>
                  <propostaContratoCredito>
                    <emitente>
                      <contaCorrente>
                        <codigoContaSemDigito>517984</codigoContaSemDigito>
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
                            <dataEfetivacao>2021-11-05T10:57:33</dataEfetivacao> 
                            <dataVencimento>2021-09-10</dataVencimento>
                            <identificador>1069259</identificador> <valor>87.53</valor></parcela><motivoEnvio>REENVIARPAGTO</motivoEnvio><interacaoGrafica>
                    <dataAcaoUsuario>2021-12-07T10:57:33</dataAcaoUsuario>
                  </interacaoGrafica></Root>');

insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (1, 12127426, 3319430, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', SYSDATE, null, null, null, null, null, '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                    <cooperativa>
                      <codigo>1</codigo>
                    </cooperativa>
                    <numeroContrato>3319430</numeroContrato>
                  </convenioCredito>
                  <propostaContratoCredito>
                    <emitente>
                      <contaCorrente>
                        <codigoContaSemDigito>12127426</codigoContaSemDigito>
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
                            <dataEfetivacao>2021-11-03T10:57:33</dataEfetivacao> 
                            <dataVencimento>2021-11-01</dataVencimento>
                            <identificador>1068656</identificador> <valor>390.85</valor></parcela><motivoEnvio>REENVIARPAGTO</motivoEnvio><interacaoGrafica>
                    <dataAcaoUsuario>2021-12-07T10:57:33</dataAcaoUsuario>
                  </interacaoGrafica></Root>');

COMMIT;

END;
