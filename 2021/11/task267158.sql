declare 

 conta_11195541_4604839 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>1</codigo>
                        </cooperativa>
                        <numeroContrato>8387</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>44</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>11.09</CETPercentAoAno>
                        <dataPrimeiraParcela>2021-12-05</dataPrimeiraParcela>
                        <produto> 
                          <codigo>162</codigo>
                        </produto>
                        <quantidadeParcelas>117</quantidadeParcelas>
                        <taxaJurosRemuneratorios>0.88</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>11.09</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>0.0</tributoIOFValor>
                        <valor>57456.61</valor><valorBase>57456.61</valorBase><dataProposta>2021-11-16T09:30:56</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1994-07-11T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>8508951973</identificadorReceitaFederal>
                          <razaoSocialOuNome>JEFFERSON DOUGLAS EBERT</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>42</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>1</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>101</codigo>
                            </agencia>
                            <banco>
                              <codigo>85</codigo>
                            </banco>
                            <codigoConta>11195541</codigoConta>
                            <cooperativa>
                              <codigo>1</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89120000</CEP>
                            <cidade>
                              <descricao>TIMBO</descricao>
                            </cidade>
                            <nomeBairro>TIROLESES</nomeBairro>
                            <numeroLogradouro>0</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA RODOVIA MUNICIPA</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>4604839</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>05633135061</identificador>
                        <tipo>
                          <sigla>CI</sigla>
                        </tipo>
                      </pessoaDocumento>
                      <pessoaFisicaOcupacao>
                        <naturezaOcupacao>
                          <codigo>1</codigo>
                        </naturezaOcupacao>
                      </pessoaFisicaOcupacao>
                      <pessoaFisicaDetalhamento>
                        <estadoCivil>
                          <codigo>4</codigo>  </estadoCivil>
                        <sexo>
                          <codigo>1</codigo>
                        </sexo> 
                      </pessoaFisicaDetalhamento>
                      <pessoaFisicaRendimento>
                        <identificadorRegistroFuncionario>0</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>5278562000115</identificadorReceitaFederal>
                          <razaoSocialOuNome>SERVICO AUTONOMO MUN ICIPAL DE AGUA</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>89120000</CEP>
                            <cidade>
                              <descricao>TIMBO</descricao>
                            </cidade>
                            <nomeBairro>CENTRO</nomeBairro>
                            <numeroLogradouro>56</numeroLogradouro>
                            <tipoENomeLogradouro>R DUQUE DE CAXIAS</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>791.73</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>57456.61</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>TIMBO</naturalidade>
                         <dataCalculoLegado>2021-10-22T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

begin
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (1, 11195541, 4604839, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_11195541_4604839);

    commit;
end;