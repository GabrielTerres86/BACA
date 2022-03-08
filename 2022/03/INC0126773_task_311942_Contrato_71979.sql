DECLARE

	v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 14173905;
	v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 71979;
	v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 7;

	v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>7</codigo>
                        </cooperativa>
                        <numeroContrato>478</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>34</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>20.80</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-03-15</dataPrimeiraParcela>
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
                        <valor>868.74</valor><valorBase>868.74</valorBase><dataProposta>2022-03-08T08:37:37</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1963-03-19T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>83479112900</identificadorReceitaFederal>
                          <razaoSocialOuNome>LINA LEIA AVELAR</razaoSocialOuNome>
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
                            <codigoConta>14173905</codigoConta>
                            <cooperativa>
                              <codigo>7</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88090060</CEP>
                            <cidade>
                              <descricao>FLORIANOPOLIS</descricao>
                            </cidade>
                            <nomeBairro>CAPOEIRAS</nomeBairro>
                            <numeroLogradouro>1100</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA JOAQUIM NABUCO</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>71979</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>3052661</identificador>
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
                        <valor>23.86</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>868.74</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>ASTORGA</naturalidade>
                         <dataCalculoLegado>2022-02-09T00:00:00</dataCalculoLegado>
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