begin

insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (10, 134090, 16316, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', SYSDATE, null, null, null, null, null, '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                    <cooperativa>
                      <codigo>10</codigo>
                    </cooperativa>
                    <numeroContrato>16316</numeroContrato>
                  </convenioCredito>
                  <propostaContratoCredito>
                    <emitente>
                      <contaCorrente>
                        <codigoContaSemDigito>134090</codigoContaSemDigito>
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
                            <dataEfetivacao>2021-10-22T16:21:25</dataEfetivacao>
                            <dataVencimento>2024-01-10</dataVencimento>
                            <identificador>829106</identificador> <valor>280.29</valor></parcela><motivoEnvio>REENVIARPAGTO</motivoEnvio><interacaoGrafica>
                    <dataAcaoUsuario>2021-11-18T16:21:25</dataAcaoUsuario>
                  </interacaoGrafica></Root>');

insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (10, 134090, 16316, 'PAGTO_PAGAR', 'CONSIGNADO', 'INSERT', SYSDATE, null, null, null, null, null, '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                    <cooperativa>
                      <codigo>10</codigo>
                    </cooperativa>
                    <numeroContrato>16316</numeroContrato>
                  </convenioCredito>
                  <propostaContratoCredito>
                    <emitente>
                      <contaCorrente>
                        <codigoContaSemDigito>134090</codigoContaSemDigito>
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
                            <dataEfetivacao>2021-10-22T16:21:25</dataEfetivacao>
                            <dataVencimento>2024-02-10</dataVencimento>
                            <identificador>829107</identificador> <valor>272.91</valor></parcela><motivoEnvio>REENVIARPAGTO</motivoEnvio><interacaoGrafica>
                    <dataAcaoUsuario>2021-11-18T16:21:25</dataAcaoUsuario>
                  </interacaoGrafica></Root>');
				  
commit;

end;