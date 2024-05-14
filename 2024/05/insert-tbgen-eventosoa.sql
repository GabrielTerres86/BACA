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
VALUES(
1, 
12175870, 
8159273, 
'REGISTRO_GRAVAME', 
'CDC', 
'INSERT', 
SYSDATE, 
NULL, 
NULL, 
NULL, 
NULL, 
NULL, 
'<?xml version="1.0"?><Root><gravameB3><gravame iduriservico="/osb-soa/GarantiaVeiculoRestService/v2/EfetivarAlienacaoGravames" cdoperac="1" cdcooper="1" nrdconta="12175870" tpctrato="90" nrctremp="8159273" idseqbem="1" flaborta="N" flgobrig="S"><cooperativa><codigo>1</codigo></cooperativa><sistemaNacionalGravames><tipoInteracao><codigo>PLEDGE-IN</codigo></tipoInteracao><UFRegistro>SC</UFRegistro><tipoRegistro><codigo>03</codigo></tipoRegistro><dataInteracao>2024-04-29T00:00:00</dataInteracao></sistemaNacionalGravames><objetoContratoCredito><veiculoChassi>9C2KC2200RR017638</veiculoChassi><veiculoChassiRemarcado>false</veiculoChassiRemarcado><veiculoPlacaUF/><veiculoPlaca/><veiculoRenavam>0</veiculoRenavam><anoFabricacao>2024</anoFabricacao><anoModelo>2024</anoModelo><tipo><descricao>ZERO KM</descricao></tipo></objetoContratoCredito><propostaContratoCredito><numeroContrato>8159273</numeroContrato><data>2024-05-13</data><quantidadeParcelas>48</quantidadeParcelas><multa>2</multa><valorJurosMoratorios>2,29</valorJurosMoratorios><tipoCalculoJuros><descricao>PREFIXADO</descricao></tipoCalculoJuros><valor>20476,5</valor><dataPrimeiraParcela>2024-06-15</dataPrimeiraParcela><dataUltimaParcela>2028-05-15</dataUltimaParcela><emitente><identificadorReceitaFederal>4890285946</identificadorReceitaFederal><razaoSocialOuNome>MISAEL SILVA DA COSTA</razaoSocialOuNome><pessoaContatoEndereco><tipoENomeLogradouro>RUA GERAL BOA VISTA</tipoENomeLogradouro><numeroLogradouro>160</numeroLogradouro><nomeBairro>BOA VISTA</nomeBairro><UF>SC</UF><CEP>89121000</CEP></pessoaContatoEndereco><cidade><codigoMunicipioCETIP>8289</codigoMunicipioCETIP></cidade><pessoaContatoTelefone><DDD>47</DDD><numero>996807711</numero></pessoaContatoTelefone></emitente><credor><razaoSocialOuNome>VIACREDI</razaoSocialOuNome><contaCorrente><postoAtendimento><cidade><descricao>RIO DOS CEDROS</descricao></cidade><paisSubDivisao><sigla>SC</sigla></paisSubDivisao></postoAtendimento></contaCorrente><tipo><codigo>2</codigo></tipo><identificadorReceitaFederal>82639451000138</identificadorReceitaFederal><pessoaContatoEndereco><tipoENomeLogradouro>RUA HERMANN HERING</tipoENomeLogradouro><numeroLogradouro>1125</numeroLogradouro><nomeBairro>BOM RETIRO</nomeBairro><UF>SC</UF><CEP>89010971</CEP></pessoaContatoEndereco><cidade><codigoMunicipioCETIP>8047</codigoMunicipioCETIP></cidade><pessoaContatoTelefone><DDD>47</DDD><numero>33314655</numero></pessoaContatoTelefone></credor></propostaContratoCredito><representanteVendas><identificadorReceitaFederal>5149370924</identificadorReceitaFederal></representanteVendas><estabelecimentoComercial><lojista><tipo><codigo>2</codigo></tipo><identificadorReceitaFederal>82639451000138</identificadorReceitaFederal></lojista></estabelecimentoComercial></gravame></gravameB3></Root>');

COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;
