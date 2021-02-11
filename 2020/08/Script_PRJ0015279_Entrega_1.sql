INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'URL_TAXA_WSO2',
   'URL utilizada para buscar valores de taxa no WSO2',
   'https://apiendpoint.ailos.coop.br/ailos-osb/ibratan/api/v1/TransacaoCreditoRestService/v1/ObterCondicoesProposta');

INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'AUTHORIZATION_TAXA_SOA',
   'Authorization para busca de taxa no SOA',
   'Basic cG9ydGFsY2RjOlBhJCRwMHJ0NEwuMjAxOA==');
   
INSERT INTO crapprm
  (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES
  ('CRED',
   0,
   'URL_CLOUD_MOTOR_DEVOLUC',
   'URL de retorno da abalise da Cloud Ibratan - Motor de Credito.',
   'https://app.capacitor.digital/api/commands-raw/WorkflowForwardReplyTo?toUrl=');
   
-- URI de retorno da analise do Web Service Ibratan - Motor de Credito.
UPDATE crapprm p
   SET p.dsvlrprm = REPLACE(p.dsvlrprm
                           ,'https://wsayllos.cecred.coop.br/'
                           ,'https://apiendpoint.ailos.coop.br/ailos/ibratan/api/v1/')
 WHERE p.cdacesso = 'URI_WEBSRV_MOTOR_DEVOLUC'
   AND p.cdcooper = 0
   AND p.dsvlrprm LIKE 'https://wsayllos.cecred.coop.br/motorcredito%';

-- URI de retorno da analise do Web Service Ibratan - Motor de Credito.
UPDATE crapprm p
   SET p.dsvlrprm = REPLACE(p.dsvlrprm
                           ,'https://wsayllos.cecred.coop.br/'
                           ,'https://apiendpoint.ailos.coop.br/ailos/ibratan/api/v1/')
 WHERE p.cdacesso = 'URI_WEBSRV_MOTOR_DEV_CRD'
   AND p.cdcooper = 0
   AND p.dsvlrprm LIKE 'https://wsayllos.cecred.coop.br/motorcartao%';

-- URI de retorno do Motor Simulação do Web Service Ibratan.   
UPDATE crapprm p
   SET p.dsvlrprm = REPLACE(p.dsvlrprm
                           ,'https://wsayllos.cecred.coop.br/'
                           ,'https://apiendpoint.ailos.coop.br/ailos/ibratan/api/v1/')
 WHERE p.cdacesso = 'URI_WEBSRV_RET_MOTOR_SIM'
   AND p.cdcooper = 0
   AND p.dsvlrprm LIKE 'https://wsayllos.cecred.coop.br/taxa%';

COMMIT;