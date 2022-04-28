DECLARE
v_cd_coopr tbgen_evento_soa.CDCOOPER%TYPE := 13;
v_nr_conta tbgen_evento_soa.NRDCONTA%TYPE := 26395;
v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 196905;

v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>13</codigo>
                        </cooperativa>
                        <numeroContrato>6</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>46</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>25.43</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-10</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>12</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>38.14</tributoIOFValor>
                        <valor>1837.38</valor><valorBase>1800.00</valorBase><dataProposta>2022-04-28T14:59:14</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1971-01-12T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>72973404991</identificadorReceitaFederal>
                          <razaoSocialOuNome>MARA MARIA DE SOUZA CARDOSO</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>42</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>1</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>112</codigo>
                            </agencia>
                            <banco>
                              <codigo>85</codigo>
                            </banco>
                            <codigoConta>26395</codigoConta>
                            <cooperativa>
                              <codigo>13</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89295000</CEP>
                            <cidade>
                              <descricao>RIO NEGRINHO</descricao>
                            </cidade>
                            <nomeBairro>SERRINHA</nomeBairro>
                            <numeroLogradouro>118</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA RANTONIO BREY</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>196905</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>27717160</identificador>
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
                          <codigo>2</codigo>
                        </sexo> 
                      </pessoaFisicaDetalhamento>
                      <pessoaFisicaRendimento>
                        <identificadorRegistroFuncionario>26395</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>433450000178</identificadorReceitaFederal>
                          <razaoSocialOuNome>CAHDAM VOLTA GRANDE SA</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>89295000</CEP>
                            <cidade>
                              <descricao>RIO NEGRINHO</descricao>
                            </cidade>
                            <nomeBairro>INDL NORTE</nomeBairro>
                            <numeroLogradouro>1232</numeroLogradouro>
                            <tipoENomeLogradouro>RUA ADOLFO TRENTINI</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>170.90</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>RIO NEGRO</naturalidade>
                         <dataCalculoLegado>2022-04-25T00:00:00</dataCalculoLegado>
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
