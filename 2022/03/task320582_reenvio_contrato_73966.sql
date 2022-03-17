declare

  conta_14227517_73966 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>7</codigo>
    </cooperativa>
    <numeroContrato>478</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>56</diasCarencia>
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
    <tributoIOFValor>71.43</tributoIOFValor>
    <valor>2355.25</valor>
    <valorBase>2283.82</valorBase>
    <dataProposta>2022-03-17T09:09:59</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1986-01-07T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>5605287958</identificadorReceitaFederal>
      <razaoSocialOuNome>SAMANTA TRUPPEL</razaoSocialOuNome>
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
        <codigoConta>14227517</codigoConta>
        <cooperativa>
          <codigo>7</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>88140000</CEP>
        <cidade>
          <descricao>SANTO AMARO DA IMPER</descricao>
        </cidade>
        <nomeBairro>SANTO AMARO DA IMPER</nomeBairro>
        <numeroLogradouro>250</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA NOSSA SENHORA DE</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>73966</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>5172328</identificador>
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
    <valor>62.04</valor>
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
    <naturalidade>FLORIANOPOLIS</naturalidade>
    <dataCalculoLegado>2022-02-18T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
'; 

BEGIN
  
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (7, 14227517, 73966, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_14227517_73966);

  COMMIT;
  
END;  