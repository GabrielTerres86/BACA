declare

  conta_xml clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>13</codigo>
                        </cooperativa>
                        <numeroContrato>140</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>41</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>19.32</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-10</dataPrimeiraParcela>
                        <produto> 
                          <codigo>162</codigo>
                        </produto>
                        <quantidadeParcelas>96</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.40</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>18.16</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>110.32</tributoIOFValor>
                        <valor>3560.32</valor><valorBase>3450.00</valorBase><dataProposta>2022-05-19T17:03:31</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1979-06-09T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>3842365969</identificadorReceitaFederal>
                          <razaoSocialOuNome>VALDEMIR FURTADO</razaoSocialOuNome>
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
                            <codigoConta>184993</codigoConta>
                            <cooperativa>
                              <codigo>13</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>84660000</CEP>
                            <cidade>
                              <descricao>GENERAL CARNEIRO</descricao>
                            </cidade>
                            <nomeBairro>GENERAL CARNEIRO</nomeBairro>
                            <numeroLogradouro>39</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA ANGELO OLIMPO GI</tipoENomeLogradouro>
                            <UF>PR</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>188624</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>02249791801</identificador>
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
                        <identificadorRegistroFuncionario>647</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>75687681000107</identificadorReceitaFederal>
                          <razaoSocialOuNome>PREFEITURA MUN DE GENERAL CARNEIRO</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>84660000</CEP>
                            <cidade>
                              <descricao>GENERAL CARNEIRO</descricao>
                            </cidade>
                            <nomeBairro>CENTRO</nomeBairro>
                            <numeroLogradouro>601</numeroLogradouro>
                            <tipoENomeLogradouro>AVENIDA GETULIO VARGAS</tipoENomeLogradouro>
                            <UF>PR</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>68.00</valor>
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
                        <naturalidade>GENERAL CARNEIRO</naturalidade>
                         <dataCalculoLegado>2022-04-30T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

begin

  insert into cecred.tbgen_evento_soa
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
  values
    (13,
     184993,
     188624,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_xml);
	 
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto, 1)
   where pep.cdcooper = 13
     and pep.nrdconta = 184993
     and pep.nrctremp = 188624;	 
     

  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;					  