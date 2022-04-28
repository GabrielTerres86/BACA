DECLARE
v_cd_coopr tbgen_evento_soa.CDCOOPER%TYPE := 7;
v_nr_conta tbgen_evento_soa.NRDCONTA%TYPE := 14132842;
v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 78411;

v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>7</codigo>
                        </cooperativa>
                        <numeroContrato>478</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>49</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>20.84</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-15</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>51</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>0.00</tributoIOFValor>
                        <valor>4467.19</valor><valorBase>4467.19</valorBase><dataProposta>2022-04-28T19:31:49</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1985-04-27T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>5519897930</identificadorReceitaFederal>
                          <razaoSocialOuNome>CAMILA GUIMARAES CARVALHO</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>42</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>1</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>106</codigo>
                            </agencia>
                            <banco>
                              <codigo>85</codigo>
                            </banco>
                            <codigoConta>14132842</codigoConta>
                            <cooperativa>
                              <codigo>7</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88113350</CEP>
                            <cidade>
                              <descricao>SAO JOSE</descricao>
                            </cidade>
                            <nomeBairro>SAO JOSESC</nomeBairro>
                            <numeroLogradouro>95</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA BRASIL PINHO</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>78411</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>04183699834</identificador>
                        <tipo>
                          <sigla>CI</sigla>
                        </tipo>
                      </pessoaDocumento>
                      <pessoaFisicaOcupacao>
                        <naturezaOcupacao>
                          <codigo>14</codigo>
                        </naturezaOcupacao>
                      </pessoaFisicaOcupacao>
                      <pessoaFisicaDetalhamento>
                        <estadoCivil>
                          <codigo>4</codigo>  </estadoCivil>
                        <sexo>
                          <codigo>2</codigo>
                        </sexo> 
                      </pessoaFisicaDetalhamento>
                      <pessoaFisicaRendimento>
                        <identificadorRegistroFuncionario>0</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>82901000000127</identificadorReceitaFederal>
                          <razaoSocialOuNome>INTELBRAS S A INDUSTRIA DE TELECOMU</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>88104800</CEP>
                            <cidade>
                              <descricao>SAO JOSE</descricao>
                            </cidade>
                            <nomeBairro>DISTRITO INDUST</nomeBairro>
                            <numeroLogradouro>0</numeroLogradouro>
                            <tipoENomeLogradouro>RODOVIA BR101</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>129.80</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>4467.19</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>FLORIANOPOLIS</naturalidade>
                         <dataCalculoLegado>2022-04-27T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

BEGIN
  INSERT 
    INTO tbgen_evento_soa(CDCOOPER
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
                  VALUES(v_cd_coopr
                        ,v_nr_conta
                        ,v_nr_contrato
                        ,'EFETIVA_PROPOSTA'
                        ,'CONSIGNADO'
                        ,'INSERT'
                        ,SYSDATE
                        ,NULL
                        ,NULL
                        ,NULL
                        ,NULL
                        ,NULL
                        ,v_xml_envio_contrato);
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_application_error(-20500, SQLERRM);
  ROLLBACK;
END;
