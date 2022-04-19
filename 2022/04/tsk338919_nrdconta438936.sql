DECLARE

  v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 7;
  v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 438936;
  v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 75964;

  v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>7</codigo>
                        </cooperativa>
                        <numeroContrato>478</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>58</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>23.66</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-05-15</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>29</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>260.20</tributoIOFValor>
                        <valor>9260.20</valor><valorBase>9000.00</valorBase><dataProposta>2022-04-19T14:49:59</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1988-11-13T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>6528359962</identificadorReceitaFederal>
                          <razaoSocialOuNome>CLECI APARECIDA PALHANO FLORES</razaoSocialOuNome>
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
                            <codigoConta>438936</codigoConta>
                            <cooperativa>
                              <codigo>7</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88136097</CEP>
                            <cidade>
                              <descricao>PALHOCA</descricao>
                            </cidade>
                            <nomeBairro>SAO SEBASTIAO</nomeBairro>
                            <numeroLogradouro>10</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA FRANCISCO BRAZ</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>75964</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>06543429416</identificador>
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
                        <valor>407.01</valor>
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
                        <naturalidade>CHAPECO</naturalidade>
                         <dataCalculoLegado>2022-03-18T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

BEGIN

  INSERT INTO tbgen_evento_soa
    (CDCOOPER,
     NRDCONTA,
     NRCTRPRP,
     TPEVENTO,
     TPRODUTO_EVENTO,
     TPOPERACAO,
     DHOPERACAO,
     DSPROCESSAMENTO,
     DSSTATUS,
     DHEVENTO,
     DSERRO,
     NRTENTATIVAS,
     DSCONTEUDO_REQUISICAO)
  VALUES
    (v_cd_coopr,
     v_nr_conta,
     v_nr_contrato,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     SYSDATE,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     v_xml_envio_contrato);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN 
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;  
END;
