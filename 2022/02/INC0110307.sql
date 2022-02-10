declare
  envio_contrato_t302669 clob := '<?xml version="1.0" encoding="WINDOWS-1252"?>
									<Root>
									  <convenioCredito>
										<cooperativa>
										  <codigo>16</codigo>
										</cooperativa>
										<numeroContrato>1111</numeroContrato>
									  </convenioCredito>
									  <configuracaoCredito>
										<financiaIOF>true</financiaIOF>
										<financiaTarifa>true</financiaTarifa>
										<diasCarencia>79</diasCarencia>
									  </configuracaoCredito>
									  <propostaContratoCredito>
										<CETPercentAoAno>20.92</CETPercentAoAno>
										<dataPrimeiraParcela>2022-04-10</dataPrimeiraParcela>
										<produto>
										  <codigo>161</codigo>
										</produto>
										<quantidadeParcelas>12</quantidadeParcelas>
										<taxaJurosRemuneratorios>1.75</taxaJurosRemuneratorios>
										<taxaJurosRemuneratoriosAnual>23.14</taxaJurosRemuneratoriosAnual>
										<tipoLiberacao>
										  <codigo>6</codigo>
										</tipoLiberacao>
										<tipoLiquidacao>
										  <codigo>4</codigo>
										</tipoLiquidacao>
										<tributoIOFValor>218.55</tributoIOFValor>
										<valor>8267.29</valor>
										<valorBase>8048.00</valorBase>
										<dataProposta>2022-02-10T08:26:11</dataProposta>
										<emitente>
										  <dataNascOuConstituicao>1980-11-22T00:00:00</dataNascOuConstituicao>
										  <identificadorReceitaFederal>3342515910</identificadorReceitaFederal>
										  <razaoSocialOuNome>MARCELO NICOLAU CUCH</razaoSocialOuNome>
										  <nacionalidade>
											<codigo>42</codigo>
										  </nacionalidade>
										  <tipo>
											<codigo>1</codigo>
										  </tipo>
										  <contaCorrente>
											<agencia>
											  <codigo>115</codigo>
											</agencia>
											<banco>
											  <codigo>85</codigo>
											</banco>
											<codigoConta>369403</codigoConta>
											<cooperativa>
											  <codigo>16</codigo>
											</cooperativa>
										  </contaCorrente>
										  <numeroTitularidade>1</numeroTitularidade>
										  <pessoaContatoEndereco>
											<CEP>89140000</CEP>
											<cidade>
											  <descricao>IBIRAMA</descricao>
											</cidade>
											<nomeBairro>BELA VISTA</nomeBairro>
											<numeroLogradouro>90</numeroLogradouro>
											<tipoEndereco>
											  <codigo>13</codigo>
											</tipoEndereco>
											<tipoENomeLogradouro>RUA WALTER IDEKER</tipoENomeLogradouro>
											<UF>SC</UF>
										  </pessoaContatoEndereco>
										</emitente>
										<identificadorProposta>358297100</identificadorProposta>
										<statusProposta>
										  <codigo>26</codigo>
										</statusProposta>
									  </propostaContratoCredito>
									  <pessoaDocumento>
										<identificador>79358827</identificador>
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
										  <codigo>4</codigo>
										</estadoCivil>
										<sexo>
										  <codigo>1</codigo>
										</sexo>
									  </pessoaFisicaDetalhamento>
									  <pessoaFisicaRendimento>
										<identificadorRegistroFuncionario>0</identificadorRegistroFuncionario>
									  </pessoaFisicaRendimento>
									  <remuneracaoColaborador>
										<empregador>
										  <identificadorReceitaFederal>84148436000112</identificadorReceitaFederal>
										  <razaoSocialOuNome>MANOEL MARCHETTI IND E COM LTDA</razaoSocialOuNome>
										</empregador>
									  </remuneracaoColaborador>
									  <beneficio/>
									  <listaPessoasEndereco>
										<pessoaEndereco>
										  <parametroConsignado>
											<tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
										  </parametroConsignado>
										  <pessoaContatoEndereco>
											<CEP>89140000</CEP>
											<cidade>
											  <descricao>IBIRAMA</descricao>
											</cidade>
											<nomeBairro>CENTRO</nomeBairro>
											<numeroLogradouro>61</numeroLogradouro>
											<tipoENomeLogradouro>RUA 3 DE MAIO</tipoENomeLogradouro>
											<UF>SC</UF>
										  </pessoaContatoEndereco>
										</pessoaEndereco>
									  </listaPessoasEndereco>
									  <parcela>
										<valor>761.42</valor>
									  </parcela>
									  <tarifa>
										<valor>0.0</valor>
									  </tarifa>
									  <inadimplencia>
										<despesasCartorarias>0.0</despesasCartorarias>
									  </inadimplencia>
									  <usuarioDominioCecred>
										<codigo/>
									  </usuarioDominioCecred>
									  <parametroConsignado>
										<codigoFisTabelaJuros>1</codigoFisTabelaJuros>
										<indicadorContaPrincipal>true</indicadorContaPrincipal>
										<naturalidade>UNIAO DA VITORIA</naturalidade>
										<dataCalculoLegado>2022-01-21T00:00:00</dataCalculoLegado>
									  </parametroConsignado>
									</Root>';
 
BEGIN
  
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (16, 369403, 358297100, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, envio_contrato_t302669);
    
	UPDATE crappep
    SET DTVENCTO = ADD_MONTHS(DTVENCTO, 3)
    WHERE (CDCOOPER, NRDCONTA, NRCTREMP) IN ((16, 369403, 358297));
	
	COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
		RAISE_application_error(-20500, SQLERRM);
		ROLLBACK;
end; 