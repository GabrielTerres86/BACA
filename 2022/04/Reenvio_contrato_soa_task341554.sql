DECLARE
v_cd_coopr tbgen_evento_soa.CDCOOPER%TYPE := 13;
v_nr_conta tbgen_evento_soa.NRDCONTA%TYPE := 298760;
v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 196024;

v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>13</codigo>
                        </cooperativa>
                        <numeroContrato>358</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>51</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>25.79</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-10</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>48</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.79</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>23.73</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>410.68</tributoIOFValor>
                        <valor>13897.49</valor><valorBase>13500.00</valorBase><dataProposta>2022-04-26T15:49:38</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1989-10-03T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>2593806010</identificadorReceitaFederal>
                          <razaoSocialOuNome>ELISIANI ADRIELI TOSSIN</razaoSocialOuNome>
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
                            <codigoConta>298760</codigoConta>
                            <cooperativa>
                              <codigo>13</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89278000</CEP>
                            <cidade>
                              <descricao>CORUPA</descricao>
                            </cidade>
                            <nomeBairro>ANO BOM</nomeBairro>
                            <numeroLogradouro>231</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA CARLOS EDUARDO W</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>196024</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>07114208802</identificador>
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
                        <identificadorRegistroFuncionario>0</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>10495274000152</identificadorReceitaFederal>
                          <razaoSocialOuNome>W E W CONFECCOES LTDA ME</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>89278000</CEP>
                            <cidade>
                              <descricao>CORUPA</descricao>
                            </cidade>
                            <nomeBairro>JOAO TOZINI</nomeBairro>
                            <numeroLogradouro>80</numeroLogradouro>
                            <tipoENomeLogradouro>RUA ALVINO PFUTZENREITER</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>439.78</valor>
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
                        <naturalidade>MIRAGUAI</naturalidade>
                         <dataCalculoLegado>2022-04-20T00:00:00</dataCalculoLegado>
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
    ROLLBACK;
END;
