DECLARE

  v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 1;
  v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 8304440;
  v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 4879513;

  v_xml_envio_contrato CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>11</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>34</diasCarencia>
    <financiaIOF>false</financiaIOF>
    <financiaTarifa>false</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>20.95</CETPercentAoAno>
    <dataPrimeiraParcela>2022-05-01</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>48</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.60</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>20.98</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>0.00</tributoIOFValor>
    <valor>30338.00</valor>
    <valorBase>30338.00</valorBase>
    <dataProposta>2022-04-05T17:05:41</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1979-01-25T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>2050310994</identificadorReceitaFederal>
      <razaoSocialOuNome>MITSA DIORGEA WESTARB</razaoSocialOuNome>
      <nacionalidade>
        <codigo>42</codigo>
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
        <codigoConta>8304440</codigoConta>
        <cooperativa>
          <codigo>1</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>88340482</CEP>
        <cidade>
          <descricao>CAMBORIU</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>20</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA JOAO LAZARO DO N</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>94879513</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>03033083210</identificador>
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
      <identificadorReceitaFederal>82639451000138</identificadorReceitaFederal>
      <razaoSocialOuNome>COOPERATIVA CREDITO VALE DO ITAJAI</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>89010600</CEP>
        <cidade>
          <descricao>BLUMENAU</descricao>
        </cidade>
        <nomeBairro>BOM RETIRO</nomeBairro>
        <numeroLogradouro>1125</numeroLogradouro>
        <tipoENomeLogradouro>RUA HERMANN HERING</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>912.24</valor>
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
    <saldo>30337.10</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>LAGES</naturalidade>
    <dataCalculoLegado>2022-03-28T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

BEGIN

  INSERT INTO tbgen_evento_soa
    (CDCOOPER
    ,NRDCONTA
    ,NRCTRPRP
    ,TPEVENTO
    ,TPRODUTO_EVENTO
    ,TPOPERACAO
    ,DHOPERACAO
    ,DSPROCESSAMENTO
    ,DSSTATUS
    ,DHEVENTO
    ,DSERRO
    ,NRTENTATIVAS
    ,DSCONTEUDO_REQUISICAO)
  VALUES
    (v_cd_coopr
    ,v_nr_conta
    ,v_nr_contrato
    ,'EFETIVA_PROPOSTA'
    ,'CONSIGNADO'
    ,'INSERT'
    ,SYSDATE
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,v_xml_envio_contrato);

  UPDATE crappep pep
     SET pep.dtvencto = add_months(pep.dtvencto, 2)
   WHERE (pep.cdcooper, pep.nrdconta, pep.nrctremp) IN ((v_cd_coopr, v_nr_conta, v_nr_contrato));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    raise_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
