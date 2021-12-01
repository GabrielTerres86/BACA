DECLARE

	v_gravar_prop CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>9</codigo>
                        </cooperativa>
                        <numeroContrato>530</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>23</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>0.12</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-01-10</dataPrimeiraParcela>
                        <produto> 
                          <codigo>162</codigo>
                        </produto>
                        <quantidadeParcelas>11</quantidadeParcelas>
                        <taxaJurosRemuneratorios>0.01</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>0.12</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>0.00</tributoIOFValor>
                        <valor>1345.85</valor><valorBase>1345.85</valorBase><dataProposta>2021-12-07T11:31:29</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1967-10-26T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>42414032049</identificadorReceitaFederal>
                          <razaoSocialOuNome>MAURICIO DE OLIVEIRA</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>42</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>1</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>108</codigo>
                            </agencia>
                            <banco>
                              <codigo>85</codigo>
                            </banco>
                            <codigoConta>502464</codigoConta>
                            <cooperativa>
                              <codigo>9</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>94197030</CEP>
                            <cidade>
                              <descricao>GRAVATAI</descricao>
                            </cidade>
                            <nomeBairro>JARDIM DO CEDRO</nomeBairro>
                            <numeroLogradouro>28</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA ILHA MAUA</tipoENomeLogradouro>
                            <UF>RS</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>21200155</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>04208501860    </identificador>
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
                          <codigo>1</codigo>
                        </sexo> 
                      </pessoaFisicaDetalhamento>
                      <pessoaFisicaRendimento>
                        <identificadorRegistroFuncionario>86869922</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>34028316000103</identificadorReceitaFederal>
                          <razaoSocialOuNome>EMPRESA BRASILEIRA DE CORREIOS E TE</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>70297400</CEP>
                            <cidade>
                              <descricao>BRASLIA</descricao>
                            </cidade>
                            <nomeBairro>SEPN SHCN</nomeBairro>
                            <numeroLogradouro>1</numeroLogradouro>
                            <tipoENomeLogradouro>SBN QUADRA 1</tipoENomeLogradouro>
                            <UF>DF</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>122.42</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia>
					  <posicao>
					    <produtoCategoria>
						  <codigo>32</codigo>
						</produtoCategoria>
					    <saldo>1345.85</saldo>
					  </posicao>
					  <usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>IJUI</naturalidade>
                         <dataCalculoLegado>2021-12-18T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

BEGIN

	INSERT INTO tbgen_evento_soa
	(cdcooper,
	 nrdconta,
	 nrctrprp,
	 tpevento,
	 tproduto_evento,
	 tpoperacao,
	 dhoperacao,
	 dsprocessamento,
	 dsconteudo_requisicao)
	VALUES
	(9,
	 502464,
	 21200155,
	 'EFETIVA_PROPOSTA',
	 'CONSIGNADO',
	 'INSERT',
	 SYSDATE,
	 'P',
	 v_gravar_prop);
	 
	commit;
  
---EXCEPTION
---	WHEN OTHERS THEN
		---ROLLBACK;
END;