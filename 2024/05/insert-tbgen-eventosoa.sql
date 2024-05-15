BEGIN

INSERT INTO CECRED.TBGEN_EVENTO_SOA(CDCOOPER, 
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
VALUES(1, 
93622422, 
8145606, 
'REGISTRO_GRAVAME', 
'CDC', 
'INSERT', 
SYSDATE, 
NULL, 
NULL, 
NULL, 
NULL, 
NULL, 
'<?xml version="1.0"?><Root><gravameB3><gravame iduriservico="/osb-soa/GarantiaVeiculoRestService/v2/EfetivarAlienacaoGravames" cdoperac="1" cdcooper="1" nrdconta="6377513" tpctrato="90" nrctremp="8145606" idseqbem="1" flaborta="N" flgobrig="S"><cooperativa><codigo>1</codigo></cooperativa><sistemaNacionalGravames><tipoInteracao><codigo>PLEDGE-IN</codigo></tipoInteracao><UFRegistro>SC</UFRegistro><tipoRegistro><codigo>03</codigo></tipoRegistro><dataInteracao>2024-04-25T00:00:00</dataInteracao></sistemaNacionalGravames><objetoContratoCredito><veiculoChassi>93YBSR6RHBJ728047</veiculoChassi><veiculoChassiRemarcado>false</veiculoChassiRemarcado><veiculoPlacaUF>SC</veiculoPlacaUF><veiculoPlaca>NNY5242</veiculoPlaca><veiculoRenavam>307475018</veiculoRenavam><anoFabricacao>2011</anoFabricacao><anoModelo>2011</anoModelo><tipo><descricao>USADO</descricao></tipo></objetoContratoCredito><propostaContratoCredito><numeroContrato>8145606</numeroContrato><data>2024-04-24</data><quantidadeParcelas>48</quantidadeParcelas><multa>2</multa><valorJurosMoratorios>2,59</valorJurosMoratorios><tipoCalculoJuros><descricao>PREFIXADO</descricao></tipoCalculoJuros><valor>13900</valor><dataPrimeiraParcela>2024-07-22</dataPrimeiraParcela><dataUltimaParcela>2028-06-22</dataUltimaParcela><emitente><identificadorReceitaFederal>8847047935</identificadorReceitaFederal><razaoSocialOuNome>EUDENISE MAIARA DE SOUZA</razaoSocialOuNome><pessoaContatoEndereco><tipoENomeLogradouro>RUA HENRIQUE SETTER</tipoENomeLogradouro><numeroLogradouro>217</numeroLogradouro><nomeBairro>ITOUPAVA CENTRAL</nomeBairro><UF>SC</UF><CEP>89062440</CEP></pessoaContatoEndereco><cidade><codigoMunicipioCETIP>8047</codigoMunicipioCETIP></cidade><pessoaContatoTelefone><DDD>47</DDD><numero>991182451</numero></pessoaContatoTelefone></emitente><credor><razaoSocialOuNome>VIACREDI</razaoSocialOuNome><contaCorrente><postoAtendimento><cidade><descricao>BLUMENAU</descricao></cidade><paisSubDivisao><sigla>SC</sigla></paisSubDivisao></postoAtendimento></contaCorrente><tipo><codigo>2</codigo></tipo><identificadorReceitaFederal>82639451000138</identificadorReceitaFederal><pessoaContatoEndereco><tipoENomeLogradouro>RUA HERMANN HERING</tipoENomeLogradouro><numeroLogradouro>1125</numeroLogradouro><nomeBairro>BOM RETIRO</nomeBairro><UF>SC</UF><CEP>89010971</CEP></pessoaContatoEndereco><cidade><codigoMunicipioCETIP>8047</codigoMunicipioCETIP></cidade><pessoaContatoTelefone><DDD>47</DDD><numero>33314655</numero></pessoaContatoTelefone></credor></propostaContratoCredito><representanteVendas><identificadorReceitaFederal>39450868000129</identificadorReceitaFederal></representanteVendas><estabelecimentoComercial><lojista><tipo><codigo>2</codigo></tipo><identificadorReceitaFederal>82639451000138</identificadorReceitaFederal></lojista></estabelecimentoComercial></gravame></gravameB3></Root>');

COMMIT;
END;