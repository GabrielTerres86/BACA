declare

conta_13897500_4934686 clob := '<?xml version="1.0" encoding="WINDOWS-1252"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>6502</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <financiaIOF>false</financiaIOF>
    <financiaTarifa>false</financiaTarifa>
    <diasCarencia>49</diasCarencia>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>12.54</CETPercentAoAno>
    <dataPrimeiraParcela>2022-05-01</dataPrimeiraParcela>
    <produto>
      <codigo>162</codigo>
    </produto>
    <quantidadeParcelas>34</quantidadeParcelas>
    <taxaJurosRemuneratorios>0.99</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>12.55</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>0.0</tributoIOFValor>
    <valor>2530.10</valor>
    <valorBase>2530.10</valorBase>
    <dataProposta>2022-03-24T16:56:50</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1963-06-11T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>68020155953</identificadorReceitaFederal>
      <razaoSocialOuNome>PEDRO GIOVANI SCHLIZINSKI</razaoSocialOuNome>
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
        <codigoConta>13897500</codigoConta>
        <cooperativa>
          <codigo>1</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>83303000</CEP>
        <cidade>
          <descricao>PIRAQUARA</descricao>
        </cidade>
        <nomeBairro>VILA VICENTE MACEDO</nomeBairro>
        <numeroLogradouro>190</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA MACEIO</tipoENomeLogradouro>
        <UF>PR</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>4934686</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>04725377992</identificador>
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
      <codigo>1</codigo>
    </sexo>
  </pessoaFisicaDetalhamento>
  <pessoaFisicaRendimento>
    <identificadorRegistroFuncionario>119602200</identificadorRegistroFuncionario>
  </pessoaFisicaRendimento>
  <remuneracaoColaborador>
    <empregador>
      <identificadorReceitaFederal>95423000000100</identificadorReceitaFederal>
      <razaoSocialOuNome>MUNICIPIO DE PINHAIS</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>83323400</CEP>
        <cidade>
          <descricao>PINHAIS</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>536</numeroLogradouro>
        <tipoENomeLogradouro>RUA WANDA DOS SANTOS MALLMANN</tipoENomeLogradouro>
        <UF>PR</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>88.56</valor>
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
    <saldo>2530.10</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>CURITIBA</naturalidade>
    <dataCalculoLegado>2022-03-13T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

begin

insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (1, 13897500, 4934686, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_13897500_4934686);

UPDATE crappep
     SET DTVENCTO = ADD_MONTHS(DTVENCTO, 3)
   WHERE NRDCONTA = 13897500
     AND CDCOOPER = 1
     AND NRCTREMP = 4934686;
commit;
EXCEPTION
  WHEN OTHERS THEN
     raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
