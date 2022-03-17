declare

  conta_14376920_74431 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>7</codigo>
    </cooperativa>
    <numeroContrato>478</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>51</diasCarencia>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>22.53</CETPercentAoAno>
    <dataPrimeiraParcela>2022-04-15</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>60</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>389.36</tributoIOFValor>
    <valor>12889.36</valor>
    <valorBase>12500.00</valorBase>
    <dataProposta>2022-03-17T15:24:55</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1993-08-27T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>39463569820</identificadorReceitaFederal>
      <razaoSocialOuNome>MARIANA CARVALHO BRAZ DA SILVA</razaoSocialOuNome>
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
        <codigoConta>14376920</codigoConta>
        <cooperativa>
          <codigo>7</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>08253360</CEP>
        <cidade>
          <descricao>SAO PAULO</descricao>
        </cidade>
        <nomeBairro>CONJUNTO RESIDENCIAL</nomeBairro>
        <numeroLogradouro>60</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA ANDRE FILIPINI</tipoENomeLogradouro>
        <UF>SP</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>74431</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>06163190160</identificador>
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
    <valor>338.64</valor>
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
    <naturalidade>PALHOCA</naturalidade>
    <dataCalculoLegado>2022-02-23T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
'; 

BEGIN
  
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (7, 14376920, 74431, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_14376920_74431);

  COMMIT;
  
END;  