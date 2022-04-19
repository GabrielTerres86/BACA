DECLARE

  v_cd_coopr    tbgen_evento_soa.CDCOOPER%TYPE := 7;
  v_nr_conta    tbgen_evento_soa.NRDCONTA%TYPE := 14555859;
  v_nr_contrato tbgen_evento_soa.NRCTRPRP%TYPE := 76944;

  v_xml_envio_contrato CLOB := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>7</codigo>
    </cooperativa>
    <numeroContrato>478</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>46</diasCarencia>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>22.58</CETPercentAoAno>
    <dataPrimeiraParcela>2022-05-15</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>57</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.59</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>20.84</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>92.76</tributoIOFValor>
    <valor>3092.76</valor>
    <valorBase>3000.00</valorBase>
    <dataProposta>2022-04-19T13:34:33</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1996-08-16T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>10488991951</identificadorReceitaFederal>
      <razaoSocialOuNome>FRANCIELE ANTUNES</razaoSocialOuNome>
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
        <codigoConta>14555859</codigoConta>
        <cooperativa>
          <codigo>7</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>88130615</CEP>
        <cidade>
          <descricao>PALHOCA</descricao>
        </cidade>
        <nomeBairro>PONTE DO IMARUIM</nomeBairro>
        <numeroLogradouro>437</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA HERCALIO LUZ</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>76944</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>06863107526</identificador>
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
    <valor>83.61</valor>
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
    <dataCalculoLegado>2022-03-30T00:00:00</dataCalculoLegado>
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

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    raise_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
