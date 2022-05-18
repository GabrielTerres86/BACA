declare

conta_893870_430933 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>16</codigo>
                        </cooperativa>
                        <numeroContrato>1111</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>48</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>40.94</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-10</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>48</quantidadeParcelas>
                        <taxaJurosRemuneratorios>2.90</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>40.92</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>2.32</tributoIOFValor>
                        <valor>13802.32</valor><valorBase>13800.00</valorBase><dataProposta>2022-05-05T15:25:36</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1983-02-01T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>3781147940</identificadorReceitaFederal>
                          <razaoSocialOuNome>MARCONDES RENATO LUNELLI</razaoSocialOuNome>
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
                            <codigoConta>893870</codigoConta>
                            <cooperativa>
                              <codigo>16</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89140000</CEP>
                            <cidade>
                              <descricao>PRESIDENTE GETULIO</descricao>
                            </cidade>
                            <nomeBairro>CENTRO</nomeBairro>
                            <numeroLogradouro>2148</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA CURT HERING</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>430933</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>03179324348</identificador>
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
                        <identificadorRegistroFuncionario>20256</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>84148436000112</identificadorReceitaFederal>
                          <razaoSocialOuNome>MANOEL MARCHETTI IND E COM LTDA</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
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
                        <valor>545.50</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>13721.40</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>WITMARSUM</naturalidade>
                         <dataCalculoLegado>2022-04-23T00:00:00</dataCalculoLegado>
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
    (16,
     893870,
     430933,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_893870_430933);
     
     update crappep pep
     set pep.vlparepr = 545.50,
         pep.vlsdvpar = 545.50,
         pep.vlsdvsji = 545.50,
      pep.dtvencto = add_months(pep.dtvencto, 2)
   where pep.cdcooper = 16
     and pep.nrdconta = 893870
     and pep.nrctremp = 430933;
     
     update CRAWEPR w
     set w.vlpreemp = 545.50,
         w.vlpreori = 545.50,
         w.txminima = 2.90,
         w.txbaspre = 2.90,
         w.txmensal = 2.90,
         w.txorigin = 2.90
   where w.cdcooper = 16
     and w.nrdconta = 893870
     and w.nrctremp = 430933;
     
  update crapepr epr
     set epr.vlpreemp = 545.50,
         epr.txmensal = 2.90
   where epr.cdcooper = 16
     and epr.nrdconta = 893870
     and epr.nrctremp = 430933;
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
