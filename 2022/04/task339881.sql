declare

  conta_311537_190709 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>11</codigo>
                        </cooperativa>
                        <numeroContrato>11</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>62</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>20.45</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-01</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>50</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.43</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>18.58</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>785.52</tributoIOFValor>
                        <valor>26060.52</valor><valorBase>25275.00</valorBase><dataProposta>2022-04-26T15:22:10</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1985-05-27T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>4358164978</identificadorReceitaFederal>
                          <razaoSocialOuNome>FERNANDA CLAUDIANO MEIRELES</razaoSocialOuNome>
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
                            <codigoConta>311537</codigoConta>
                            <cooperativa>
                              <codigo>11</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88312120</CEP>
                            <cidade>
                              <descricao>ITAJAI</descricao>
                            </cidade>
                            <nomeBairro>SAO VICENTE</nomeBairro>
                            <numeroLogradouro>215</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA GERVASIO FRANCIS</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>190709</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>03789787782</identificador>
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
                          <identificadorReceitaFederal>9512539000102</identificadorReceitaFederal>
                          <razaoSocialOuNome>COOP CRED  FOZ RIO ITAJAI</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>88307326</CEP>
                            <cidade>
                              <descricao>ITAJAI</descricao>
                            </cidade>
                            <nomeBairro>RESSACADA</nomeBairro>
                            <numeroLogradouro>143</numeroLogradouro>
                            <tipoENomeLogradouro>RUA NIVALDO DETOIE</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>744.31</valor>
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
                        <naturalidade>ITAJAI</naturalidade>
                         <dataCalculoLegado>2022-03-31T00:00:00</dataCalculoLegado>
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
     311537,
     190709,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_311537_190709);


  update crappep pep
     set pep.vlparepr = 744.31,
         pep.vlsdvpar = 744.31,
         pep.vlsdvsji = 744.31,
      pep.dtvencto = add_months(pep.dtvencto, 4)
   where pep.cdcooper = 11
     and pep.nrdconta = 311537
     and pep.nrctremp = 190709;
     
     update CRAWEPR w
     set w.vlpreemp = 744.31,
         w.vlpreori = 744.31,
         w.txminima = 1.43,
         w.txbaspre = 1.43,
         w.txmensal = 1.43,
         w.txorigin = 1.43
   where w.cdcooper = 11
     and w.nrdconta = 311537
     and w.nrctremp = 190709;

  update crapepr epr
     set epr.vlpreemp = 744.31,
         epr.txmensal = 1.43
   where epr.cdcooper = 11
     and epr.nrdconta = 311537
     and epr.nrctremp = 190709;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
