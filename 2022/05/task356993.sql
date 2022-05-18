declare

  conta_478512_185911 clob := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>13</codigo>
                        </cooperativa>
                        <numeroContrato>6</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>44</diasCarencia>
                        <financiaIOF>true</financiaIOF>
                        <financiaTarifa>true</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>34.01</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-06-10</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>12</quantidadeParcelas>
                        <taxaJurosRemuneratorios>2.15</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>29.08</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>35.87</tributoIOFValor>
                        <valor>1755.87</valor><valorBase>1720.00</valorBase><dataProposta>2022-05-17T12:36:27</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1999-05-19T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>10063453967</identificadorReceitaFederal>
                          <razaoSocialOuNome>LUIZ HENRIQUE VONECHO</razaoSocialOuNome>
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
                            <codigoConta>478512</codigoConta>
                            <cooperativa>
                              <codigo>13</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>89295000</CEP>
                            <cidade>
                              <descricao>RIO NEGRINHO</descricao>
                            </cidade>
                            <nomeBairro>VOLTA GRANDE</nomeBairro>
                            <numeroLogradouro>42</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>RUA PEDRO BAIL</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>185911</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>6800769</identificador>
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
                          <identificadorReceitaFederal>433450000178</identificadorReceitaFederal>
                          <razaoSocialOuNome>CAHDAM VOLTA GRANDE SA</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>89295000</CEP>
                            <cidade>
                              <descricao>RIO NEGRINHO</descricao>
                            </cidade>
                            <nomeBairro>INDL NORTE</nomeBairro>
                            <numeroLogradouro>1232</numeroLogradouro>
                            <tipoENomeLogradouro>RUA ADOLFO TRENTINI</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>169.24</valor>
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
                        <naturalidade>RIO NEGRINHO</naturalidade>
                         <dataCalculoLegado>2022-04-27T00:00:00</dataCalculoLegado>
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
    (13,
     478512,
     185911,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_478512_185911);
     
     
     update cecred.crappep pep
     set pep.vlparepr = 169.24,
         pep.vlsdvpar = 169.24,
         pep.vlsdvsji = 169.24,
      pep.dtvencto = add_months(pep.dtvencto, 2)
   where pep.cdcooper = 13
     and pep.nrdconta = 136050
     and pep.nrctremp = 168149;
     
     update cecred.CRAWEPR w
     set w.vlpreemp = 169.24,
         w.vlpreori = 169.24,
         w.txminima = 169.24,
         w.txbaspre = 2.15,
         w.txmensal = 2.15,
         w.txorigin = 2.15
   where w.cdcooper = 13
     and w.nrdconta = 478512
     and w.nrctremp = 185911;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 169.24,
         epr.txmensal = 2.15
   where epr.cdcooper = 13
     and epr.nrdconta = 478512
     and epr.nrctremp = 185911;
     
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
