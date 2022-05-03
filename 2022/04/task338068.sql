declare

conta_700347_209166 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
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
                        <CETPercentAoAno>19.77</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-07-01</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>48</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.38</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>17.88</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>310.13</tributoIOFValor>
                        <valor>10310.13</valor><valorBase>10000.00</valorBase><dataProposta>2022-05-05T17:11:28</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>2000-09-01T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>70943683483</identificadorReceitaFederal>
                          <razaoSocialOuNome>BRUNA BEATRIZ DA SILVA NUNES</razaoSocialOuNome>
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
                            <codigoConta>700347</codigoConta>
                            <cooperativa>
                              <codigo>11</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88309601</CEP>
                            <cidade>
                              <descricao>ITAJAI</descricao>
                            </cidade>
                            <nomeBairro>SAO VICENTE</nomeBairro>
                            <numeroLogradouro>1420</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA PROFESSORA EROTI</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>209166</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>070943683483</identificador>
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
                        <valor>299.50</valor>
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
                        <naturalidade>MOSSORO</naturalidade>
                         <dataCalculoLegado>2022-04-30T00:00:00</dataCalculoLegado>
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
     700347,
     209166,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_700347_209166);
     
     update crappep pep
     set pep.vlparepr = 299.5,
         pep.vlsdvpar = 299.5,
         pep.vlsdvsji = 299.5,
      pep.dtvencto = add_months(pep.dtvencto, 3)
   where pep.cdcooper = 11
     and pep.nrdconta = 700347
     and pep.nrctremp = 209166;
     
     update CRAWEPR w
     set w.vlpreemp = 299.5,
         w.vlpreori = 299.5,
         w.txminima = 1.38,
         w.txbaspre = 1.38,
         w.txmensal = 1.38,
         w.txorigin = 1.38
   where w.cdcooper = 11
     and w.nrdconta = 700347
     and w.nrctremp = 209166;
     
  update crapepr epr
     set epr.vlpreemp = 299.5,
         epr.txmensal = 1.38
   where epr.cdcooper = 11
     and epr.nrdconta = 700347
     and epr.nrctremp = 209166;
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
