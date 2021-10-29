declare

    conta_8079625_4366220 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>69</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>45</diasCarencia>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>12.98</CETPercentAoAno>
    <dataPrimeiraParcela>2021-12-01</dataPrimeiraParcela>
    <produto>
      <codigo>162</codigo>
    </produto>
    <quantidadeParcelas>96</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.01</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>12.82</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>77.22</tributoIOFValor>
    <valor>15821.12</valor>
    <valorBase>15743.90</valorBase>
    <dataProposta>2021-10-28T16:16:16</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1997-02-21T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>9701846974</identificadorReceitaFederal>
      <razaoSocialOuNome>VANDIR DA SILVA</razaoSocialOuNome>
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
        <codigoConta>8079625</codigoConta>
        <cooperativa>
          <codigo>1</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>89135000</CEP>
        <cidade>
          <descricao>APIUNA</descricao>
        </cidade>
        <nomeBairro>RIBEIRAO CARVALHO</nomeBairro>
        <numeroLogradouro>4313</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA ESTRADA GERAL RI</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>4366220</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>6697806</identificador>
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
    <identificadorRegistroFuncionario>0</identificadorRegistroFuncionario>
  </pessoaFisicaRendimento>
  <remuneracaoColaborador>
    <empregador>
      <identificadorReceitaFederal>79373767000116</identificadorReceitaFederal>
      <razaoSocialOuNome>PREFEITURA MUNIPAL DE APIUNA</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>89135000</CEP>
        <cidade>
          <descricao>APIUNA</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>204</numeroLogradouro>
        <tipoENomeLogradouro>RUA QUINTINO BOCAIUVA</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>259.48</valor>
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
    <saldo>13361.60</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>RIO DO SUL</naturalidade>
    <dataCalculoLegado>2021-10-17T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

begin

    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (1, 8079625, 4366220, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_8079625_4366220);

	UPDATE crappep
	SET DTVENCTO = ADD_MONTHS(DTVENCTO, 2)
	WHERE NRDCONTA = 8079625  
	AND CDCOOPER = 1
	AND NRCTREMP = 4366220;    

    commit;
    
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;


end;    