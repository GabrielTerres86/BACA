declare

  conta_13988492_192396 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>11</codigo>
                        </cooperativa>
                        <numeroContrato>1341</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>75</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>15.69</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-15</dataPrimeiraParcela>
                        <produto> 
                          <codigo>162</codigo>
                        </produto>
                        <quantidadeParcelas>48</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.09</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>13.89</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>795.91</tributoIOFValor>
                        <valor>26070.91</valor><valorBase>25275.00</valorBase><dataProposta>2022-04-26T17:34:22</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1962-03-18T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>47995327900</identificadorReceitaFederal>
                          <razaoSocialOuNome>JOSE OLAVIO PEIXER</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>42</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>1</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>109</codigo>
                            </agencia>
                            <banco>
                              <codigo>85</codigo>
                            </banco>
                            <codigoConta>13988492</codigoConta>
                            <cooperativa>
                              <codigo>11</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88240000</CEP>
                            <cidade>
                              <descricao>SAO JOAO BATISTA</descricao>
                            </cidade>
                            <nomeBairro>SAO JOAO BATISTASC</nomeBairro>
                            <numeroLogradouro>66</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA AUGUSTO JOSE TAM</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>192396</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>02799329130</identificador>
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
                          <identificadorReceitaFederal>82951229000176</identificadorReceitaFederal>
                          <razaoSocialOuNome>ESTADO DE SANTA CATARINA</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>88032000</CEP>
                            <cidade>
                              <descricao>FLORIANOPOLIS</descricao>
                            </cidade>
                            <nomeBairro>SACO GRANDE II</nomeBairro>
                            <numeroLogradouro>4600</numeroLogradouro>
                            <tipoENomeLogradouro>ROD SC 401</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>711.94</valor>
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
                        <naturalidade>SAO JOAO BATISTA</naturalidade>
                         <dataCalculoLegado>2022-04-01T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

begin

  insert into tbgen_evento_soa
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
    (11,
     13988492,
     192396,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_13988492_192396);


  update crappep pep
     set pep.vlparepr = 711.94,
         pep.vlsdvpar = 711.94,
         pep.vlsdvsji = 711.94,
      pep.dtvencto = add_months(pep.dtvencto, 4)
   where pep.cdcooper = 11
     and pep.nrdconta = 13988492
     and pep.nrctremp = 192396;
     
     update CRAWEPR w
     set w.vlpreemp = 711.94,
         w.vlpreori = 711.94,
         w.txminima = 1.09,
         w.txbaspre = 1.09,
         w.txmensal = 1.09,
         w.txorigin = 1.09
   where w.cdcooper = 11
     and w.nrdconta = 13988492
     and w.nrctremp = 192396;

  update crapepr epr
     set epr.vlpreemp = 711.94,
         epr.txmensal = 1.09
   where epr.cdcooper = 11
     and epr.nrdconta = 13988492
     and epr.nrctremp = 192396;
	 
  update crappep pep
     set pep.vlparepr = 1030.94,
         pep.vlsdvpar = 1030.94,
         pep.vlsdvsji = 1030.94
   where pep.cdcooper = 14
     and pep.nrdconta = 195189
     and pep.nrctremp = 57208;
     
  update CRAWEPR w
     set w.vlpreemp = 1030.94,
         w.vlpreori = 1030.94
   where w.cdcooper = 14
     and w.nrdconta = 195189
     and w.nrctremp = 57208;

  update crapepr epr
     set epr.vlpreemp = 1030.94
   where epr.cdcooper = 14
     and epr.nrdconta = 195189
     and epr.nrctremp = 57208;	 
	 

  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
