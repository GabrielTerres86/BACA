declare

conta_214370_184950 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>13</codigo>
    </cooperativa>
    <numeroContrato>126</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>57</diasCarencia>
    <financiaIOF>false</financiaIOF>
    <financiaTarifa>false</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>14.02</CETPercentAoAno>
    <dataPrimeiraParcela>2022-05-10</dataPrimeiraParcela>
    <produto>
      <codigo>162</codigo>
    </produto>
    <quantidadeParcelas>112</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.10</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>14.03</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>0.0</tributoIOFValor>
    <valor>21541.12</valor>
    <valorBase>21541.12</valorBase>
    <dataProposta>2022-04-05T19:33:00</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1978-08-01T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>2306623902</identificadorReceitaFederal>
      <razaoSocialOuNome>SOLANGE APARECIDA MINCH DE LIM</razaoSocialOuNome>
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
        <codigoConta>214370</codigoConta>
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
        <nomeBairro>JARDIM HANTSCHEL</nomeBairro>
        <numeroLogradouro>61</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA ALFREDO BAIL</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>184950</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>2928805</identificador>
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
    <identificadorRegistroFuncionario>902702</identificadorRegistroFuncionario>
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
    <valor>338.79</valor>
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
    <saldo>21541.12</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>RIO NEGRINHO</naturalidade>
    <dataCalculoLegado>2022-03-14T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

begin

insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (13, 214370, 184950, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_214370_184950);

commit;

EXCEPTION
  WHEN OTHERS THEN
     raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
