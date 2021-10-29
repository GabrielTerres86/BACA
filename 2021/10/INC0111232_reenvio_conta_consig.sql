declare

    conta_10115218_4275578 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>1</codigo>
    </cooperativa>
    <numeroContrato>2461</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>42</diasCarencia>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>24.77</CETPercentAoAno>
    <dataPrimeiraParcela>2021-12-10</dataPrimeiraParcela>
    <produto>
      <codigo>161</codigo>
    </produto>
    <quantidadeParcelas>36</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.82</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>24.16</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>29.52</tributoIOFValor>
    <valor>4556.52</valor>
    <valorBase>4527.00</valorBase>
    <dataProposta>2021-10-29T16:16:16</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1985-04-25T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>4872210956</identificadorReceitaFederal>
      <razaoSocialOuNome>MARCELO DOS SANTOS LEAL</razaoSocialOuNome>
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
        <codigoConta>10115218</codigoConta>
        <cooperativa>
          <codigo>1</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>89080553</CEP>
        <cidade>
          <descricao>INDAIAL</descricao>
        </cidade>
        <nomeBairro>RIBEIRAO DAS PEDRAS</nomeBairro>
        <numeroLogradouro>233</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA CRISTAL</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>4275578</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>53250206</identificador>
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
    <identificadorRegistroFuncionario>7279</identificadorRegistroFuncionario>
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
    <valor>174.90</valor>
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
    <saldo>3512.72</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>ASSIS CHATEAUBRIAND</naturalidade>
    <dataCalculoLegado>2021-10-29T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

begin
 
    insert into tbgen_evento_soa (CDCOOPER, NRDCONTA, NRCTRPRP, TPEVENTO, TPRODUTO_EVENTO, TPOPERACAO, DHOPERACAO, DSPROCESSAMENTO, DSSTATUS, DHEVENTO, DSERRO, NRTENTATIVAS, DSCONTEUDO_REQUISICAO)
    values (1, 10115218, 4275578, 'EFETIVA_PROPOSTA', 'CONSIGNADO', 'INSERT', sysdate, null, null, null, null, null, conta_10115218_4275578);

	UPDATE crappep
	SET DTVENCTO = ADD_MONTHS(DTVENCTO, 3)
	WHERE NRDCONTA = 10115218  
	AND CDCOOPER = 1
	AND NRCTREMP = 4275578;    

    commit;
    
/*EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
*/

end;    