declare

conta_662569_160854 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>13</codigo>
    </cooperativa>
    <numeroContrato>539</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>65</diasCarencia>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>24.90</CETPercentAoAno>
    <dataPrimeiraParcela>2022-05-10</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>24</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.65</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>21.70</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>74.23</tributoIOFValor>
    <valor>2708.23</valor>
    <valorBase>2634.00</valorBase>
    <dataProposta>2022-03-24T17:39:13</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1987-06-07T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>6203326976</identificadorReceitaFederal>
      <razaoSocialOuNome>VALDEVINO BATISTA</razaoSocialOuNome>
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
        <codigoConta>662569</codigoConta>
        <cooperativa>
          <codigo>13</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>84500004</CEP>
        <cidade>
          <descricao>IRATI</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>1000</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA JOAO CANDIDO FER</tipoENomeLogradouro>
        <UF>PR</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>160854</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>05735763630</identificador>
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
      <identificadorReceitaFederal>13103895000131</identificadorReceitaFederal>
      <razaoSocialOuNome>LUAR COMERCIO DE ARTIGOS DE COLCHOA</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>84500069</CEP>
        <cidade>
          <descricao>IRATI</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>436</numeroLogradouro>
        <tipoENomeLogradouro>RUA XV DE NOVEMBRO</tipoENomeLogradouro>
        <UF>PR</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>140.22</valor>
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
    <naturalidade>IRATI</naturalidade>
    <dataCalculoLegado>2022-03-06T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

begin

insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
values (13, 662569, 160854, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_662569_160854);

UPDATE crappep
     SET dtvencto = ADD_MONTHS(dtvencto, 4)
   WHERE nrdconta = 662569
     AND cdcooper = 13
     AND nrctremp = 160854;
commit;
EXCEPTION
  WHEN OTHERS THEN
     raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
