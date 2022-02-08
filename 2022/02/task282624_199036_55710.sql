declare

  conta_199036_55710 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>5</codigo>
    </cooperativa>
    <numeroContrato>11</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>33</diasCarencia>
    <financiaIOF>false</financiaIOF>
    <financiaTarifa>false</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>29.04</CETPercentAoAno>
    <dataPrimeiraParcela>2022-03-01</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>54</quantidadeParcelas>
    <taxaJurosRemuneratorios>2.15</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>29.08</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>269.86</tributoIOFValor>
    <valor>9000.00</valor>
    <valorBase>9000.00</valorBase>
    <dataProposta>2022-02-10T13:20:33</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1988-01-08T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>5790922910</identificadorReceitaFederal>
      <razaoSocialOuNome>CLARICE PORFIRIO ANTONIO</razaoSocialOuNome>
      <nacionalidade>
        <codigo>42</codigo>
      </nacionalidade>
      <tipo>
        <codigo>1</codigo>
      </tipo>
      <contaCorrente>
        <agencia>
          <codigo>104</codigo>
        </agencia>
        <banco>
          <codigo>85</codigo>
        </banco>
        <codigoConta>199036</codigoConta>
        <cooperativa>
          <codigo>5</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>88860000</CEP>
        <cidade>
          <descricao>SIDEROPOLIS</descricao>
        </cidade>
        <nomeBairro>DONA SEBASTIANA</nomeBairro>
        <numeroLogradouro>0</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA ANTENOR DOS SANT</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>55710</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>05262054027</identificador>
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
      <identificadorReceitaFederal>3427097000101</identificadorReceitaFederal>
      <razaoSocialOuNome>COOP CRED DE LIVRE ADM DO SUL CATAR</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>88811700</CEP>
        <cidade>
          <descricao>CRICIUMA</descricao>
        </cidade>
        <nomeBairro>PROSPERA</nomeBairro>
        <numeroLogradouro>557</numeroLogradouro>
        <tipoENomeLogradouro>GENERAL OSVALDO PINTO DA VEIGA</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>283.93</valor>
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
    <naturalidade>CRICIUMA</naturalidade>
    <dataCalculoLegado>2022-01-27T00:00:00</dataCalculoLegado>
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
    (5,
     199036,
     55710,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_199036_55710);

  UPDATE crappep
     SET DTVENCTO = ADD_MONTHS(DTVENCTO, 3)
   WHERE NRDCONTA = 199036
     AND CDCOOPER = 5
     AND NRCTREMP = 55710;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
end;
