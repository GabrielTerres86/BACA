declare
conta_493341_193908 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>13</codigo>
                        </cooperativa>
                        <numeroContrato>11</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>23</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>21.66</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-01</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>36</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.58</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.7</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>368.5</tributoIOFValor>
                        <valor>33368.5</valor><valorBase>33000.00</valorBase><dataProposta>2022-05-10T17:16:01</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1980-10-04T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>28206915877</identificadorReceitaFederal>
                          <razaoSocialOuNome>ALEXANDRE TAVARES DA SILVA</razaoSocialOuNome>
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
                            <codigoConta>493341</codigoConta>
                            <cooperativa>
                              <codigo>13</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89290207</CEP>
                            <cidade>
                              <descricao>SAO BENTO DO SUL</descricao>
                            </cidade>
                            <nomeBairro>25 DE JULHO</nomeBairro>
                            <numeroLogradouro>2467</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA ESTEVAO BUSCHLE</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>193908</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>29840204</identificador>
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
                          <identificadorReceitaFederal>10218474000168</identificadorReceitaFederal>
                          <razaoSocialOuNome>COOP CRED DA REGIAO DO CONTESTADO</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>89280355</CEP>
                            <cidade>
                              <descricao>SAO BENTO DO SUL</descricao>
                            </cidade>
                            <nomeBairro>RIO NEGRO</nomeBairro>
                            <numeroLogradouro>127</numeroLogradouro>
                            <tipoENomeLogradouro>R JOAO STOEBERL</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>1218.02</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>20152.09</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>SAO PAULO</naturalidade>
                         <dataCalculoLegado>2022-05-09T00:00:00</dataCalculoLegado>
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
    (13,
     493341,
     193908,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_493341_193908);
     
     update crappep pep
     set pep.vlparepr = 1218.02,
         pep.vlsdvpar = 1218.02,
         pep.vlsdvsji = 1218.02
   where pep.cdcooper = 13
     and pep.nrdconta = 493341
     and pep.nrctremp = 193908;
     
     update CRAWEPR w
     set w.vlpreemp = 1218.02,
         w.vlpreori = 1218.02,
         w.txminima = 1.58,
         w.txbaspre = 1.58,
         w.txmensal = 1.58,
         w.txorigin = 1.58
   where w.cdcooper = 13
     and w.nrdconta = 493341
     and w.nrctremp = 193908;
     
  update crapepr epr
     set epr.vlpreemp = 1218.02,
         epr.txmensal = 1.58
   where epr.cdcooper = 13
     and epr.nrdconta = 493341
     and epr.nrctremp = 193908;
  commit;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
