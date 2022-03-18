declare

  conta_14192020_73524 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>7</codigo>
    </cooperativa>
    <numeroContrato>478</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>53</diasCarencia>
    <financiaIOF>false</financiaIOF>
    <financiaTarifa>false</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>20.87</CETPercentAoAno>
    <dataPrimeiraParcela>2022-04-15</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>16</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>0.00</tributoIOFValor>
    <valor>7659.14</valor>
    <valorBase>7659.14</valorBase>
    <dataProposta>2022-03-17T19:31:52</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1980-11-17T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>28615629862</identificadorReceitaFederal>
      <razaoSocialOuNome>KLEBER FERREIRA SOARES</razaoSocialOuNome>
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
        <codigoConta>14192020</codigoConta>
        <cooperativa>
          <codigo>7</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>08060330</CEP>
        <cidade>
          <descricao>SAO PAULO</descricao>
        </cidade>
        <nomeBairro>VILA JACUI</nomeBairro>
        <numeroLogradouro>107</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA DOMINGOS ANTONIO</tipoENomeLogradouro>
        <UF>SP</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>73524</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>00663382349</identificador>
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
  <beneficio/>
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
    <valor>552.58</valor>
  </parcela>
  <tarifa>
    <valor>0.0</valor>
  </tarifa>
  <inadimplencia>
    <despesasCartorarias>0.0</despesasCartorarias>
  </inadimplencia>
  <posicao>
    <produtoCategoria>
      <codigo>32</codigo>
    </produtoCategoria>
    <saldo>7659.14</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>SAO PAULO</naturalidade>
    <dataCalculoLegado>2022-02-21T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
'; 

BEGIN
  
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (7, 14192020, 73524, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_14192020_73524);

  COMMIT;
  
END;  