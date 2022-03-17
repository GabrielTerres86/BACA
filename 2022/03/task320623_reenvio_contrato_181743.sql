declare

  conta_148164_181743 clob := '<?xml version="1.0" encoding="WINDOWS-1252"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>13</codigo>
    </cooperativa>
    <numeroContrato>126</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
    <diasCarencia>44</diasCarencia>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>18.15</CETPercentAoAno>
    <dataPrimeiraParcela>2022-04-10</dataPrimeiraParcela>
    <produto>
      <codigo>162</codigo>
    </produto>
    <quantidadeParcelas>120</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.40</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>18.16</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>0.00</tributoIOFValor>
    <valor>17510.00</valor>
    <valorBase>17510.00</valorBase>
    <dataProposta>2022-03-17T17:02:41</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1986-09-26T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>724314903</identificadorReceitaFederal>
      <razaoSocialOuNome>ROSANGELA SIMONE REIS</razaoSocialOuNome>
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
        <codigoConta>148164</codigoConta>
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
        <nomeBairro>VISTA ALEGRE</nomeBairro>
        <numeroLogradouro>263</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA JOSE BERNARDINO </tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>181743</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>4546182</identificador>
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
      <codigo>4</codigo>
    </estadoCivil>
    <sexo>
      <codigo>2</codigo>
    </sexo>
  </pessoaFisicaDetalhamento>
  <pessoaFisicaRendimento>
    <identificadorRegistroFuncionario>7091</identificadorRegistroFuncionario>
  </pessoaFisicaRendimento>
  <remuneracaoColaborador>
    <empregador>
      <identificadorReceitaFederal>83102756000179</identificadorReceitaFederal>
      <razaoSocialOuNome>PREFEITURA MUNICIPAL RIO NEGRINHO</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
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
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>200</numeroLogradouro>
        <tipoENomeLogradouro>AV RICHARD S DE ALBUQUERQUE</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>304.07</valor>
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
    <naturalidade>RIO NEGRINHO</naturalidade>
    <dataCalculoLegado>2022-02-25T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
'; 

BEGIN
  
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (13, 148164, 181743, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_148164_181743);

  COMMIT;
  
END;  