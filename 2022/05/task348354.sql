declare

  conta_11598123_5164197 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>1</codigo>
                        </cooperativa>
                        <numeroContrato>11</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>26</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>34.16</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-01</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>48</quantidadeParcelas>
                        <taxaJurosRemuneratorios>2.41</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>33.08</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>115.21</tributoIOFValor>
                        <valor>8465.21</valor><valorBase>8350.00</valorBase><dataProposta>2022-02-03T16:08:57</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1996-01-29T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>15580188757</identificadorReceitaFederal>
                          <razaoSocialOuNome>YAGO MELO DE SOUZA</razaoSocialOuNome>
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
                            <codigoConta>11598123</codigoConta>
                            <cooperativa>
                              <codigo>1</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89065030</CEP>
                            <cidade>
                              <descricao>BLUMENAU</descricao>
                            </cidade>
                            <nomeBairro>SALTO DO NORTE</nomeBairro>
                            <numeroLogradouro>345</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA CINCO DE OUTUBRO</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>5164197</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>256709718</identificador>
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
                          <identificadorReceitaFederal>82639451000138</identificadorReceitaFederal>
                          <razaoSocialOuNome>COOPERATIVA CREDITO VALE DO ITAJAI</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>89010600</CEP>
                            <cidade>
                              <descricao>BLUMENAU</descricao>
                            </cidade>
                            <nomeBairro>BOM RETIRO</nomeBairro>
                            <numeroLogradouro>1125</numeroLogradouro>
                            <tipoENomeLogradouro>RUA HERMANN HERING</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>298.55</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>4403.27</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>RIO DE JANEIRO</naturalidade>
                         <dataCalculoLegado>2022-05-12T00:00:00</dataCalculoLegado>
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
    (1,
     11598123,
     5164197,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_11598123_5164197);
     
     
     update crappep pep
     set pep.vlparepr = 298.55,
         pep.vlsdvpar = 298.55,
         pep.vlsdvsji = 298.55,
      pep.dtvencto = add_months(pep.dtvencto, 3)
   where pep.cdcooper = 1
     and pep.nrdconta = 11598123
     and pep.nrctremp = 5164197;
     
     update CRAWEPR w
     set w.vlpreemp = 298.55,
         w.vlpreori = 298.55,
         w.txminima = 2.41,
         w.txbaspre = 2.41,
         w.txmensal = 2.41,
         w.txorigin = 2.41
   where w.cdcooper = 1
     and w.nrdconta = 11598123
     and w.nrctremp = 5164197;
     
  update crapepr epr
     set epr.vlpreemp = 298.55,
         epr.txmensal = 2.41
   where epr.cdcooper = 1
     and epr.nrdconta = 11598123
     and epr.nrctremp = 5164197;
     
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
