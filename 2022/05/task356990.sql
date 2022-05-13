declare

  conta_conta_136050_168149 clob := '<?xml version="1.0"?>
<Root>
  <convenioCredito>
    <cooperativa>
      <codigo>13</codigo>
    </cooperativa>
    <numeroContrato>129</numeroContrato>
  </convenioCredito>
  <configuracaoCredito>
    <diasCarencia>44</diasCarencia>
    <financiaIOF>true</financiaIOF>
    <financiaTarifa>true</financiaTarifa>
  </configuracaoCredito>
  <propostaContratoCredito>
    <CETPercentAoAno>17.44</CETPercentAoAno>
    <dataPrimeiraParcela>2022-06-10</dataPrimeiraParcela>
    <produto>
      <codigo>162</codigo>
    </produto>
    <quantidadeParcelas>120</quantidadeParcelas>
    <taxaJurosRemuneratorios>1.30</taxaJurosRemuneratorios>
    <taxaJurosRemuneratoriosAnual>16.77</taxaJurosRemuneratoriosAnual>
    <tipoLiberacao>
      <codigo>6</codigo>
    </tipoLiberacao>
    <tipoLiquidacao>
      <codigo>4</codigo>
    </tipoLiquidacao>
    <tributoIOFValor>140.82</tributoIOFValor>
    <valor>6402.82</valor>
    <valorBase>6262.00</valorBase>
    <dataProposta>2022-05-17T10:35:18</dataProposta>
    <emitente>
      <dataNascOuConstituicao>1978-02-21T00:00:00</dataNascOuConstituicao>
      <identificadorReceitaFederal>96988207953</identificadorReceitaFederal>
      <razaoSocialOuNome>MARIA HELENE BECKER FERREIRA D</razaoSocialOuNome>
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
        <codigoConta>136050</codigoConta>
        <cooperativa>
          <codigo>13</codigo>
        </cooperativa>
      </contaCorrente>
      <numeroTitularidade>1</numeroTitularidade>
      <pessoaContatoEndereco>
        <CEP>89282265</CEP>
        <cidade>
          <descricao>SAO BENTO DO SUL</descricao>
        </cidade>
        <nomeBairro>BRASILIA</nomeBairro>
        <numeroLogradouro>314</numeroLogradouro>
        <tipoEndereco>
          <codigo>13</codigo>
        </tipoEndereco>
        <tipoENomeLogradouro>RUA JOAO OSNI PSCHEI</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </emitente>
    <identificadorProposta>168149</identificadorProposta>
    <statusProposta>
      <codigo>26</codigo>
    </statusProposta>
  </propostaContratoCredito>
  <pessoaDocumento>
    <identificador>05176560706</identificador>
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
    <identificadorRegistroFuncionario>3436901</identificadorRegistroFuncionario>
  </pessoaFisicaRendimento>
  <remuneracaoColaborador>
    <empregador>
      <identificadorReceitaFederal>86051398000100</identificadorReceitaFederal>
      <razaoSocialOuNome>PREFEITURA MUNIC SAO BENTO DO SUL</razaoSocialOuNome>
    </empregador>
  </remuneracaoColaborador>
  <beneficio/>
  <listaPessoasEndereco>
    <pessoaEndereco>
      <parametroConsignado>
        <tipoPessoaEndereco>EMPREGADOR</tipoPessoaEndereco>
      </parametroConsignado>
      <pessoaContatoEndereco>
        <CEP>89280902</CEP>
        <cidade>
          <descricao>SAO BENTO DO SUL</descricao>
        </cidade>
        <nomeBairro>CENTRO</nomeBairro>
        <numeroLogradouro>75</numeroLogradouro>
        <tipoENomeLogradouro>RUA JORGE LACERDA</tipoENomeLogradouro>
        <UF>SC</UF>
      </pessoaContatoEndereco>
    </pessoaEndereco>
  </listaPessoasEndereco>
  <parcela>
    <valor>106.30</valor>
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
    <saldo>1915.12</saldo>
  </posicao>
  <usuarioDominioCecred>
    <codigo/>
  </usuarioDominioCecred>
  <parametroConsignado>
    <codigoFisTabelaJuros>1</codigoFisTabelaJuros>
    <indicadorContaPrincipal>true</indicadorContaPrincipal>
    <naturalidade>SAO BENTO DO SUL</naturalidade>
    <dataCalculoLegado>2022-04-27T00:00:00</dataCalculoLegado>
  </parametroConsignado>
</Root>
';

begin

  insert into cecred.tbgen_evento_soa
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
    (13,
     136050,
     168149,
     'EFETIVA_PROPOSTA',
     'CONSIGNADO',
     'INSERT',
     sysdate,
     null,
     null,
     null,
     null,
     null,
     conta_136050_168149);
     
     
     update cecred.crappep pep
     set pep.vlparepr = 106.30,
         pep.vlsdvpar = 106.30,
         pep.vlsdvsji = 106.30,
      pep.dtvencto = add_months(pep.dtvencto, 4)
   where pep.cdcooper = 13
     and pep.nrdconta = 136050
     and pep.nrctremp = 168149;
     
     update cecred.CRAWEPR w
     set w.vlpreemp = 106.30,
         w.vlpreori = 106.30,
         w.txminima = 1.30,
         w.txbaspre = 1.30,
         w.txmensal = 1.30,
         w.txorigin = 1.30
   where w.cdcooper = 13
     and w.nrdconta = 136050
     and w.nrctremp = 168149;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 106.30,
         epr.txmensal = 1.30
   where epr.cdcooper = 13
     and epr.nrdconta = 136050
     and epr.nrctremp = 168149;
     
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
