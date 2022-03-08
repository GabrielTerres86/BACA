DECLARE

	v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 14165759;
	v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 72351;
	v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 7;

	v_xml_envio_contrato CLOB := '<?xml version="1.0" encoding="UTF-8"?><Root><convenioCredito>
                        <cooperativa>
                          <codigo>7</codigo>
                        </cooperativa>
                        <numeroContrato>478</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>59</diasCarencia>
                        <financiaIOF>false</financiaIOF>
                        <financiaTarifa>false</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>19.01</CETPercentAoAno>
                        <dataPrimeiraParcela>2022-04-15</dataPrimeiraParcela>
                        <produto> 
                          <codigo>161</codigo>
                        </produto>
                        <quantidadeParcelas>22</quantidadeParcelas>
                        <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo></tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>0.00</tributoIOFValor>
                        <valor>16392.25</valor>
						<valorBase>16392.25</valorBase>
						<dataProposta>2022-02-24T16:25:00</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>1984-08-06T00:00:00</dataNascOuConstituicao>
                          <identificadorReceitaFederal>32094992845</identificadorReceitaFederal>
                          <razaoSocialOuNome>RODRIGO SANVITTO</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>42</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>1</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>106</codigo>
                            </agencia>
                            <banco>
                              <codigo>85</codigo>
                            </banco>
                            <codigoConta>14165759</codigoConta>
                            <cooperativa>
                              <codigo>7</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>1</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>03422000</CEP>
                            <cidade>
                              <descricao>SAO PAULO</descricao>
                            </cidade>
                            <nomeBairro>VILA CARRAO</nomeBairro>
                            <numeroLogradouro>928</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>13</codigo> 
                            </tipoEndereco>
                            <tipoENomeLogradouro>AVENIDA GUILHERME GI</tipoENomeLogradouro>
                            <UF>SP</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>72351</identificadorProposta>
                        <statusProposta>
                          <codigo>26</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>436109268</identificador>
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
                          <identificadorReceitaFederal>82901000000127</identificadorReceitaFederal>
                          <razaoSocialOuNome>INTELBRAS S A INDUSTRIA DE TELECOMU</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>88104800</CEP>
                            <cidade>
                              <descricao>SAO JOSE</descricao>
                            </cidade>
                            <nomeBairro>DISTRITO INDUST</nomeBairro>
                            <numeroLogradouro>0</numeroLogradouro>
                            <tipoENomeLogradouro>RODOVIA BR101</tipoENomeLogradouro>
                            <UF>SC</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>888.85</valor>
                      </parcela>
                      <tarifa>
                        <valor>0.0</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia><posicao><produtoCategoria> <codigo>32</codigo></produtoCategoria><saldo>16392.25</saldo></posicao><usuarioDominioCecred>
                        <codigo></codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>true</indicadorContaPrincipal> 
                        <naturalidade>SAO PAULO</naturalidade>
                         <dataCalculoLegado>2022-02-15T00:00:00</dataCalculoLegado>
                      </parametroConsignado> </Root>';

BEGIN

  BEGIN
    INSERT INTO tbgen_evento_soa
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
    VALUES
      (v_cd_coopr,
       v_nr_conta,
       v_nr_contrato,
       'EFETIVA_PROPOSTA',
       'CONSIGNADO',
       'INSERT',
       SYSDATE,
       NULL,
       NULL,
       NULL,
       NULL,
       NULL,
       v_xml_envio_contrato);
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20500, SQLERRM);
      ROLLBACK;
  END;

END;