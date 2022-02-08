declare

  conta_8768390_4808214 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>2461</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>49</diasCarencia>
    <financiaIOF>false</financiaIOF>
    <financiaTarifa>false</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>17.44</CETPercentAoAno>
    <dataPrimeiraParcela>2022-03-10</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>48</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.35</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>17.46</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>460.39</tributoIOFValor>
    <valor>14990.00</valor>
    <valorBase>14990.00</valorBase>
    <dataProposta>2022-02-17T16:01:12</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1985-05-20T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>1405327901</identificadorReceitaFederal>
      <razaoSocialOuNome>JUNOL SIDNEY</razaoSocialOuNome>
      <nacionalidade>
        <codigo>2</codigo>
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
        <codigoConta>8768390</codigoConta>
        <cooperativa>
          <codigo>1</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>89070720</CEP>
        <cidade>
          <descricao>BLUMENAU</descricao>
        </cidade>
        <nomeBairro>BADENFURT</nomeBairro>
        <numeroLogradouro>324</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA MATHILDE WAGNER</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>4808214</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>0325229</identificador>
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
      <identificadorReceitaFederal>78855830000198</identificadorReceitaFederal>
      <razaoSocialOuNome>KYLY INDUSTRIA TEXTIL LTDA</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>89107000</CEP>
        <cidade>
          <descricao>POMERODE</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>3155</numeroLogradouro>
        <tipoENomeLogradouro>RODOVIA SC 418</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>429.99</valor>
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
    <naturalidade>REPUBLICA DO HAITI</naturalidade>
    <dataCalculoLegado>2022-01-20T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

BEGIN

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
     8768390,
     4808214,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_8768390_4808214);

  UPDATE crappep
     SET DTVENCTO = ADD_MONTHS(DTVENCTO, 2)
   WHERE NRDCONTA = 8768390
     AND CDCOOPER = 1
     AND NRCTREMP = 4808214;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
end;
