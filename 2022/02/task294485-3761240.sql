declare
  contaX clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>1</codigo>
                        </cooperativa>
                        <numeroContrato>11</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>100</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>26.82</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-01</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>48</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.86</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>24.75</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>996.49</tributoIOFValor>
                        <valor>32189.93</valor><valorBase>31186.00</valorBase><dataProposta>2022-02-21T16:49:30</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1988-08-04T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>6666295951</identificadorReceitaFederal>
                          <razaoSocialOuNome>GABRIELA DE ALMEIDA MELLO</razaoSocialOuNome>
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
                            <codigoConta>3761240</codigoConta>
                            <cooperativa>
                              <codigo>1</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>88317200</CEP>
                            <cidade>
                              <descricao>ITAJAI</descricao>
                            </cidade>
                            <nomeBairro>ESPINHEIROS</nomeBairro>
                            <numeroLogradouro>1284</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA FERMINO VIEIRA C</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>4898751</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>04247975737</identificador>
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
                        <identificadorRegistroFuncionario>3761240</identificadorRegistroFuncionario>
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
                        <valor>1064.34</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>4924.24</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>ITAJAI</naturalidade>
                         <dataCalculoLegado>2022-02-21T00:00:00</dataCalculoLegado>
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
    (1,
     3761240,
     4898751,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     contaX);
commit;
end;