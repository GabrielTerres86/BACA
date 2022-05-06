DECLARE

v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 7;
v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 441350;
v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 78547;
v_xml_envio_contrato CLOB;

BEGIN

v_xml_envio_contrato := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>7</codigo>
                        </cooperativa>
                        <numeroContrato>478</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>42</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>20.83</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-15</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>55</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>0.00</tributoIOFValor>
                        <valor>23644.21</valor><valorBase>23644.21</valorBase><dataProposta>2022-05-10T19:31:14</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1982-05-05T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>889680906</identificadorReceitaFederal>
                          <razaoSocialOuNome>HUDSON MARCOS DA SILVA VIEIRA</razaoSocialOuNome>
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
                            <codigoConta>441350</codigoConta>
                            <cooperativa>
                              <codigo>7</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88160308</CEP>
                            <cidade>
                              <descricao>BIGUACU</descricao>
                            </cidade>
                            <nomeBairro>PRAIA JOAO ROSA</nomeBairro>
                            <numeroLogradouro>731</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA DOMINGOS COELHO</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>78547</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>01364630523</identificador>
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
                        <valor>652.22</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>23644.21</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>SAO JOSE</naturalidade>
                         <dataCalculoLegado>2022-05-04T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';


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
                        
v_nr_contrato := 78548;

v_xml_envio_contrato := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>7</codigo>
                        </cooperativa>
                        <numeroContrato>478</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>42</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>20.83</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-15</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>46</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>0.00</tributoIOFValor>
                        <valor>5343.21</valor><valorBase>5343.21</valorBase><dataProposta>2022-05-10T19:31:19</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1982-05-05T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>889680906</identificadorReceitaFederal>
                          <razaoSocialOuNome>HUDSON MARCOS DA SILVA VIEIRA</razaoSocialOuNome>
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
                            <codigoConta>441350</codigoConta>
                            <cooperativa>
                              <codigo>7</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88160308</CEP>
                            <cidade>
                              <descricao>BIGUACU</descricao>
                            </cidade>
                            <nomeBairro>PRAIA JOAO ROSA</nomeBairro>
                            <numeroLogradouro>731</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA DOMINGOS COELHO</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>78548</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>01364630523</identificador>
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
                        <valor>165.69</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>5343.21</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>SAO JOSE</naturalidade>
                         <dataCalculoLegado>2022-05-04T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';


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
