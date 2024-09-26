INSERT INTO tbgen_webservice_aciona
  (CDCOOPER
  ,CDAGENCI_ACIONAMENTO
  ,CDOPERAD
  ,CDORIGEM
  ,NRCTRPRP
  ,NRDCONTA
  ,TPACIONAMENTO
  ,DHACIONAMENTO
  ,DSOPERACAO
  ,DSURISERVICO
  ,DTMVTOLT
  ,CDSTATUS_HTTP
  ,DSCONTEUDO_REQUISICAO
  ,DSRESPOSTA_REQUISICAO
  ,DSPROTOCOLO
  ,TPPRODUTO
  ,CDCLIENTE
  ,DSMETODO
  ,FLGREENVIA
  ,NRREENVIO
  ,TPCONTEUDO)
VALUES
  (1
  ,1
  ,'MOTOR'
  ,9
  ,NULL
  ,19811829
  ,2
  ,'26/09/24 09:14:46,106323'
  ,'RETORNO ANALISE AUTOMATICA - REJEITADA AUTOM.'
  ,'0302appweb02.cecred.coop.br:8080'
  ,to_date('25-10-2022', 'dd-mm-yyyy')
  ,202
  ,'{"id":612570542,"createdDate":1666699672872,"regraProcessada":"PoliticaCartaoCreditoPF","proposta":"    2.227.413","protocolo":"PoliticaCartaoCreditoPF_612570542","resultadoAnaliseRegra":"REPROVAR"}'
  ,'<?xml version="1.0" encoding="WINDOWS-1252"?>
<Dados>
  <inf><status>202</status>
    <nrtransacao>00000000000051096858</nrtransacao>
    <cdcritic>0</cdcritic>
    <dscritic> </dscritic>
    <msg_detalhe>Parecer da proposta atualizado com sucesso.</msg_detalhe>
  </inf>
</Dados>
'
  ,'PoliticaCartaoCreditoPF_612570542'
  ,4
  ,1
  ,'POST'
  ,0
  ,0
  ,1);

commit;
