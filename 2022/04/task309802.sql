declare

  conta_278963_39197 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>14</codigo>
    </cooperativa>
    <numeroContrato>11</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>43</diasCarencia>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>16.03</CETPercentAoAno>
    <dataPrimeiraParcela>2022-06-01</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>47</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.11</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>14.16</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>614.16</tributoIOFValor>
    <valor>20757.94</valor>
    <valorBase>20030.00</valorBase>
    <dataProposta>2022-04-19T16:16:16</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1995-05-14T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>9596412973</identificadorReceitaFederal>
      <razaoSocialOuNome>TATIANE CARDOSO</razaoSocialOuNome>
      <nacionalidade>
        <codigo>42</codigo>
      </nacionalidade>
      <tipo>
        <codigo>1</codigo>
      </tipo>
      <contaCorrente>
        <agencia>
          <codigo>113</codigo>
        </agencia>
        <banco>
          <codigo>85</codigo>
        </banco>
        <codigoConta>278963</codigoConta>
        <cooperativa>
          <codigo>14</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>85605410</CEP>
        <cidade>
          <descricao>FRANCISCO BELTRAO</descricao>
        </cidade>
        <nomeBairro>LUTHER KING</nomeBairro>
        <numeroLogradouro>1032</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA BOLIVIA</tipoENomeLogradouro>
        <UF>PR</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>39197</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>05918886740</identificador>
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
      <identificadorReceitaFederal>10311218000110</identificadorReceitaFederal>
      <razaoSocialOuNome>COOPERATIVA DE CREDITO EVOLUA</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>85601630</CEP>
        <cidade>
          <descricao>FRANCISCO BELTRAO</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>1819</numeroLogradouro>
        <tipoENomeLogradouro>RUA CURITIBA</tipoENomeLogradouro>
        <UF>PR</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>568.82</valor>
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
    <naturalidade>FRANCISCO BELTRAO</naturalidade>
    <dataCalculoLegado>2022-04-19T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

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
    (14,
     278963,
     39197,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_278963_39197);


  update crappep pep
     set pep.dtvencto = add_months(pep.dtvencto, 7)
   where pep.cdcooper = 14
     and pep.nrdconta = 278963
     and pep.nrctremp = 39197;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
