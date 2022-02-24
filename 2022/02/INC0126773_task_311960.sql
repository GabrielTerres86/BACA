DECLARE

	v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 14166313;
	v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 73261;
	v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 7;

	v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>7</codigo>
                        </cooperativa>
                        <numeroContrato>478</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>32</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>22.52</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-03-15</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>60</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>1229.21</tributoIOFValor>
                        <valor>41229.21</valor>
						<valorBase>40000.00</valorBase>
						<dataProposta>2022-02-24T17:35:11</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1986-04-11T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>11246176718</identificadorReceitaFederal>
                          <razaoSocialOuNome>JOSE CICERO TEIXEIRA JUNIOR</razaoSocialOuNome>
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
                            <codigoConta>14166313</codigoConta>
                            <cooperativa>
                              <codigo>7</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>06414000</CEP>
                            <cidade>
                              <descricao>BARUERI</descricao>
                            </cidade>
                            <nomeBairro>JARDIM TUPANCI</nomeBairro>
                            <numeroLogradouro>429</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA MARTE</tipoENomeLogradouro>
                            <UF>SP</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>73261</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>134192293</identificador>
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
                        <valor>1072.45</valor>
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
                        <naturalidade>RIO DE JANEIRO</naturalidade>
                         <dataCalculoLegado>2022-02-11T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

BEGIN

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

END;