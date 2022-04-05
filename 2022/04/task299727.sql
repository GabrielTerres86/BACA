DECLARE

  v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 1;
  v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 9501096;
  v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 4531209;

  v_xml_envio_contrato CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>2461</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
    <diasCarencia>82</diasCarencia>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>16.35</CETPercentAoAno>
    <dataPrimeiraParcela>2022-06-10</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>48</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.25</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>16.08</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>222.84</tributoIOFValor>
    <valor>49422.84</valor>
    <valorBase>49200.00</valorBase>
    <dataProposta>2022-04-07T16:16:16</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1976-01-02T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>93684177920</identificadorReceitaFederal>
      <razaoSocialOuNome>CRISTIANE DO ROCIO GONCALVES</razaoSocialOuNome>
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
        <codigoConta>9501096</codigoConta>
        <cooperativa>
          <codigo>1</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>89107000</CEP>
        <cidade>
          <descricao>POMERODE</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>211</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA RUDOLFO SCHIPPMA</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>4531209</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>34334483</identificador>
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
    <identificadorRegistroFuncionario>9077</identificadorRegistroFuncionario>
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
    <valor>1405.41</valor>
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
    <saldo>43317.91</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>PARANAGUA</naturalidade>
    <dataCalculoLegado>2022-03-20T00:00:00</dataCalculoLegado>
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
     SET pep.dtvencto = add_months(pep.dtvencto, 7)
   WHERE (pep.cdcooper, pep.nrdconta, pep.nrctremp) IN ((v_cd_coopr, v_nr_conta, v_nr_contrato));

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    raise_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
