DECLARE

	v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 14204118;
	v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 72423;
	v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 7;

	v_envio_contrato_t311939 CLOB := '<?xml version="1.0" encoding="UTF-8"?>
					<Root>
					  <convenioCredito>
						<cooperativa>
						  <codigo>7</codigo>
						</cooperativa>
						<numeroContrato>478</numeroContrato>
					  </convenioCredito>
					  <configuracaoCredito>
						<diasCarencia>46</diasCarencia>
						<financiaIOF>true</financiaIOF>
						<financiaTarifa>true</financiaTarifa>
					  </configuracaoCredito>
					  <propostaContratoCredito>
						<CETPercentAoAno>24.67</CETPercentAoAno>
						<dataPrimeiraParcela>2022-03-15</dataPrimeiraParcela>
						<produto> 
						  <codigo>161</codigo>
						</produto>
						<quantidadeParcelas>18</quantidadeParcelas>
						<taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
						<taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
						<tipoLiberacao>
						  <codigo>6</codigo>
						</tipoLiberacao>
						<tipoLiquidacao>
						  <codigo>4</codigo>
						</tipoLiquidacao> 
						<tributoIOFValor>76.04</tributoIOFValor>
						<valor>3076.04</valor>
						<valorBase>3000.00</valorBase>
						<dataProposta>2022-02-22T15:08:42</dataProposta>
						<emitente> 
						  <dataNascOuConstituicao>1986-01-14T00:00:00</dataNascOuConstituicao>
						  <identificadorReceitaFederal>35918436871</identificadorReceitaFederal>
						  <razaoSocialOuNome>MARIO DE ANDRADE NETO</razaoSocialOuNome>
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
							<codigoConta>14204118</codigoConta>
							<cooperativa>
							  <codigo>7</codigo>
							</cooperativa>
						  </contaCorrente>
						  <numeroTitularidade>1</numeroTitularidade>
						  <pessoaContatoEndereco>
							<CEP>09843740</CEP>
							<cidade>
							  <descricao>SAO BERNARDO DO CAMP</descricao>
							</cidade>
							<nomeBairro>BATISTINI</nomeBairro>
							<numeroLogradouro>270</numeroLogradouro>
							<tipoEndereco>
							  <codigo>13</codigo> 
							</tipoEndereco>
							<tipoENomeLogradouro>RUA MATO GROSSO</tipoENomeLogradouro>
							<UF>SP</UF>
						  </pessoaContatoEndereco>
						</emitente>
						<identificadorProposta>72423</identificadorProposta>
						<statusProposta>
						  <codigo>26</codigo>
						</statusProposta>
					  </propostaContratoCredito>
					  <pessoaDocumento>
						<identificador>03396885526</identificador>
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
						  <identificadorReceitaFederal>82901000000127</identificadorReceitaFederal>
						  <razaoSocialOuNome>INTELBRAS S A INDUSTRIA DE TELECOMU</razaoSocialOuNome>
						</empregador>
					  </remuneracaoColaborador>
					<beneficio/>
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
					  <valor>199.53</valor>
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
					  <naturalidade>SAO BERNARDO DO CAMP</naturalidade>
					   <dataCalculoLegado>2022-01-28T00:00:00</dataCalculoLegado>
					  </parametroConsignado>
					</Root>';

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
       v_envio_contrato_t311939);
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20500, SQLERRM);
      ROLLBACK;
  END;

END;