declare
conta_3761240_4898751 clob := '<?xml version="1.0" encoding="WINDOWS-1252"?>
                              <Root>
                                <convenioCredito>
                                  <cooperativa>
                                    <codigo>1</codigo>
                                  </cooperativa>
                                  <numeroContrato>11</numeroContrato>
                                </convenioCredito>
                                <configuracaoCredito>
                                  <financiaIOF>true</financiaIOF>
                                  <financiaTarifa>true</financiaTarifa>
                                  <diasCarencia>64</diasCarencia>
                                </configuracaoCredito>
                                <propostaContratoCredito>
                                  <CETPercentAoAno>28.45</CETPercentAoAno>
                                  <dataPrimeiraParcela>2022-07-01</dataPrimeiraParcela>
                                  <produto>
                                    <codigo>161</codigo>
                                  </produto>
                                  <quantidadeParcelas>48</quantidadeParcelas>
                                  <taxaJurosRemuneratorios>1.99</taxaJurosRemuneratorios>
                                  <taxaJurosRemuneratoriosAnual>26.68</taxaJurosRemuneratoriosAnual>
                                  <tipoLiberacao>
                                    <codigo>6</codigo>
                                  </tipoLiberacao>
                                  <tipoLiquidacao>
                                    <codigo>4</codigo>
                                  </tipoLiquidacao>
                                  <tributoIOFValor>804.46</tributoIOFValor>
                                  <valor>31990.46</valor>
                                  <valorBase>31186.00</valorBase>
                                  <dataProposta>2022-05-05T16:32:01</dataProposta>
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
                                    <codigo>4</codigo>
                                  </estadoCivil>
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
                                <beneficio/>
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
                                  <valor>1064.33</valor>
                                </parcela>
                                <tarifa>
                                  <valor>0.0</valor>
                                </tarifa>
                                <inadimplencia>
                                  <despesasCartorarias>0.0</despesasCartorarias>
                                </inadimplencia>
                                <usuarioDominioCecred>
                                  <codigo/>
                                </usuarioDominioCecred>
                                <parametroConsignado>
                                  <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                                  <indicadorContaPrincipal>true</indicadorContaPrincipal>
                                  <naturalidade>ITAJAI</naturalidade>
                                  <dataCalculoLegado>2021-04-28T00:00:00</dataCalculoLegado>
                                </parametroConsignado>
                              </Root>';
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
     conta_3761240_4898751);
     
     update crappep pep
     set pep.vlparepr = 1064.33,
         pep.vlsdvpar = 1064.33,
         pep.vlsdvsji = 1064.33,
         pep.dtvencto = add_months(pep.dtvencto, 3)
   where pep.cdcooper = 1
     and pep.nrdconta = 3761240
     and pep.nrctremp = 4898751;
     
     update CRAWEPR w
     set w.vlpreemp = 1064.33,
         w.vlpreori = 1064.33,
         w.txminima = 1.99,
         w.txbaspre = 1.99,
         w.txmensal = 1.99,
         w.txorigin = 1.99
   where w.cdcooper = 1
     and w.nrdconta = 3761240
     and w.nrctremp = 4898751;
     
  update crapepr epr
     set epr.vlpreemp = 1064.33,
         epr.txmensal = 1.99
   where epr.cdcooper = 1
     and epr.nrdconta = 3761240
     and epr.nrctremp = 4898751;
  commit;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
