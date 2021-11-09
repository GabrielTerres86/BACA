declare

    conta_479276_135085 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>13</codigo>
                        </cooperativa>
                        <numeroContrato>167</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>37</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>16.72</CETPercentAoAno>
                        <dataPrimeiraParcela>2021-12-10</dataPrimeiraParcela>
                        <produto> 
                          <codigo>162</codigo>
                        </produto>
                        <quantidadeParcelas>24</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.29</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>16.63</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>1.27</tributoIOFValor>
                        <valor>3245.27</valor><valorBase>3244.00</valorBase><dataProposta>2021-11-09T12:44:35</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1961-11-14T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>56377223900</identificadorReceitaFederal>
                          <razaoSocialOuNome>SILVIO GONCALVES RIBEIRO</razaoSocialOuNome>
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
                            <codigoConta>479276</codigoConta>
                            <cooperativa>
                              <codigo>13</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>83860000</CEP>
                            <cidade>
                              <descricao>PIEN</descricao>
                            </cidade>
                            <nomeBairro>BOA VISTA</nomeBairro>
                            <numeroLogradouro>0</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA GREGORIO EMIDIO </tipoENomeLogradouro>
                            <UF>PR</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>135085</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>00943281042</identificador>
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
                        <identificadorRegistroFuncionario>8331</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>76002666000140</identificadorReceitaFederal>
                          <razaoSocialOuNome>PREFEITURA MUNICIPAL DE PIEN</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>83860000</CEP>
                            <cidade>
                              <descricao>PIEN</descricao>
                            </cidade>
                            <nomeBairro>CENTRO</nomeBairro>
                            <numeroLogradouro>373</numeroLogradouro>
                            <tipoENomeLogradouro>RUA AMAZONAS</tipoENomeLogradouro>
                            <UF>PR</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>158.57</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>3196.95</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>PIEN</naturalidade>
                         <dataCalculoLegado>2021-11-03T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>
';

begin
 
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (1, 479276, 135085, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_479276_135085);

  UPDATE crappep
  SET DTVENCTO = ADD_MONTHS(DTVENCTO, 3)
  WHERE NRDCONTA = 479276  
  AND CDCOOPER = 13
  AND NRCTREMP = 135085;    

    commit;
    
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;


end;    
