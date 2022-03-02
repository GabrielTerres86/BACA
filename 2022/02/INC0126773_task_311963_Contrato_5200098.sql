DECLARE

	v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 14235480;
	v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 5200098;
	v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 1;

	v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>1</codigo>
                        </cooperativa>
                        <numeroContrato>6502</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>43</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>11.08</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-04-01</dataPrimeiraParcela>
                        <produto> 
                          <codigo>162</codigo>
                        </produto>
                        <quantidadeParcelas>47</quantidadeParcelas>
                        <taxaJurosRemuneratorios>0.88</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>11.09</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>0.00</tributoIOFValor>
                        <valor>3218.27</valor>
						<valorBase>3218.27</valorBase>
						<dataProposta>2022-02-25T19:31:02</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1965-05-16T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>74476122949</identificadorReceitaFederal>
                          <razaoSocialOuNome>MARILUZ SOLANGE JASCHIK</razaoSocialOuNome>
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
                            <codigoConta>14235480</codigoConta>
                            <cooperativa>
                              <codigo>1</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>83405030</CEP>
                            <cidade>
                              <descricao>COLOMBO</descricao>
                            </cidade>
                            <nomeBairro>FATIMA</nomeBairro>
                            <numeroLogradouro>538</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA DORVAL CECCON</tipoENomeLogradouro>
                            <UF>PR</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>5200098</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>39769000</identificador>
                        <tipo>
                          <sigla>CI</sigla>
                        </tipo>
                      </pessoaDocumento>
                      <pessoaFisicaOcupacao>
                        <naturezaOcupacao>
                          <codigo>6</codigo>
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
                        <identificadorRegistroFuncionario>133096900</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>95423000000100</identificadorReceitaFederal>
                          <razaoSocialOuNome>MUNICIPIO DE PINHAIS</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>83323400</CEP>
                            <cidade>
                              <descricao>PINHAIS</descricao>
                            </cidade>
                            <nomeBairro>CENTRO</nomeBairro>
                            <numeroLogradouro>536</numeroLogradouro>
                            <tipoENomeLogradouro>RUA WANDA DOS SANTOS MALLMANN</tipoENomeLogradouro>
                            <UF>PR</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>84.22</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria>
					  <codigo>32</codigo>
					  </produtoCategoria>
					    <saldo>3218.27</saldo>
				      </posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>CURITIBA</naturalidade>
                         <dataCalculoLegado>2022-02-17T00:00:00</dataCalculoLegado>
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