declare

  conta_1080946_377942 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>2</codigo>
                        </cooperativa>
                        <numeroContrato>11</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>22</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>26.30</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-01</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>36</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.79</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>23.73</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>299.06</tributoIOFValor>
                        <valor>10810.43</valor><valorBase>10500.00</valorBase><dataProposta>2022-05-12T14:36:28</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1988-10-29T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>7480859988</identificadorReceitaFederal>
                          <razaoSocialOuNome>DIEGO LUIS DA SILVA</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>42</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>1</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>102</codigo>
                            </agencia>
                            <banco>
                              <codigo>85</codigo>
                            </banco>
                            <codigoConta>1080946</codigoConta>
                            <cooperativa>
                              <codigo>2</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89226040</CEP>
                            <cidade>
                              <descricao>JOINVILLE</descricao>
                            </cidade>
                            <nomeBairro>AVENTUREIRO</nomeBairro>
                            <numeroLogradouro>163</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA PICAPAU</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>377942</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>04227359282</identificador>
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
                          <identificadorReceitaFederal>3461243000115</identificadorReceitaFederal>
                          <razaoSocialOuNome>ACREDICOOP</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>89201260</CEP>
                            <cidade>
                              <descricao>JOINVILLE</descricao>
                            </cidade>
                            <nomeBairro>CENTRO</nomeBairro>
                            <numeroLogradouro>277</numeroLogradouro>
                            <tipoENomeLogradouro>RUA ALEXANDRE DOHLER</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>407.59</valor>
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
                        <naturalidade>JOINVILLE</naturalidade>
                         <dataCalculoLegado>2022-05-10T00:00:00</dataCalculoLegado>
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
    (2,
     1080946,
     377942,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_1080946_377942);
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
