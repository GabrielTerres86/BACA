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
8149419, 
'REGISTRO_GRAVAME', 
'CDC', 
'INSERT', 
SYSDATE, 
NULL, 
NULL, 
NULL, 
NULL, 
NULL, 
'<?xml version="1.0"?><Root><gravameB3><gravame iduriservico="/osb-soa/GarantiaVeiculoRestService/v2/EfetivarAlienacaoGravames" cdoperac="1" cdcooper="1" nrdconta="93622422" tpctrato="90" nrctremp="8149419" idseqbem="1" flaborta="N" flgobrig="S"><cooperativa><codigo>1</codigo></cooperativa><sistemaNacionalGravames><tipoInteracao><codigo>PLEDGE-IN</codigo></tipoInteracao><UFRegistro>SC</UFRegistro><tipoRegistro><codigo>03</codigo></tipoRegistro><dataInteracao>2024-05-09T00:00:00</dataInteracao></sistemaNacionalGravames><objetoContratoCredito><veiculoChassi>9BGKS48G0FG309874</veiculoChassi><veiculoChassiRemarcado>false</veiculoChassiRemarcado><veiculoPlacaUF> </veiculoPlacaUF><veiculoPlaca> </veiculoPlaca><veiculoRenavam>0</veiculoRenavam><anoFabricacao>2023</anoFabricacao><anoModelo>2023</anoModelo><tipo><descricao>ZERO KM</descricao></tipo></objetoContratoCredito><propostaContratoCredito><numeroContrato>8149419</numeroContrato><data>2024-05-10</data><quantidadeParcelas>36</quantidadeParcelas><multa>2</multa><valorJurosMoratorios>1,69</valorJurosMoratorios><tipoCalculoJuros><descricao>PREFIXADO</descricao></tipoCalculoJuros><valor>50000</valor><dataPrimeiraParcela>2024-06-10</dataPrimeiraParcela><dataUltimaParcela>2027-05-10</dataUltimaParcela><emitente><identificadorReceitaFederal>8847047935</identificadorReceitaFederal><razaoSocialOuNome>ANTONIO SANTOS</razaoSocialOuNome><pessoaContatoEndereco><tipoENomeLogradouro>ALAMEDA BENICIO SOUZA, 711</tipoENomeLogradouro><numeroLogradouro>186</numeroLogradouro><nomeBairro>ITOUPAVA CENTRAL</nomeBairro><UF>SC</UF><CEP>89062440</CEP></pessoaContatoEndereco><cidade><codigoMunicipioCETIP>8047</codigoMunicipioCETIP></cidade><pessoaContatoTelefone><DDD>47</DDD><numero>72862594</numero></pessoaContatoTelefone></emitente><credor><razaoSocialOuNome>VIACREDI</razaoSocialOuNome><contaCorrente><postoAtendimento><cidade><descricao>BLUMENAU</descricao></cidade><paisSubDivisao><sigla>SC</sigla></paisSubDivisao></postoAtendimento></contaCorrente><tipo><codigo>2</codigo></tipo><identificadorReceitaFederal>82639451000138</identificadorReceitaFederal><pessoaContatoEndereco><tipoENomeLogradouro>RUA HERMANN HERING</tipoENomeLogradouro><numeroLogradouro>1125</numeroLogradouro><nomeBairro>BOM RETIRO</nomeBairro><UF>SC</UF><CEP>89010971</CEP></pessoaContatoEndereco><cidade><codigoMunicipioCETIP>8047</codigoMunicipioCETIP></cidade><pessoaContatoTelefone><DDD>47</DDD><numero>33314655</numero></pessoaContatoTelefone></credor></propostaContratoCredito><representanteVendas><identificadorReceitaFederal></identificadorReceitaFederal></representanteVendas><estabelecimentoComercial><lojista><tipo><codigo>2</codigo></tipo><identificadorReceitaFederal>82639451000138</identificadorReceitaFederal></lojista></estabelecimentoComercial></gravame></gravameB3></Root>');

COMMIT;
END;