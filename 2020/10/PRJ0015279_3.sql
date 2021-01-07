-- Atualiza a URL e URI da esteira de crédito para apontar para o recurso internalizado.
UPDATE crapprm p
   SET p.dsvlrprm = 'https://wsesteiracredito.ailos.coop.br'
 WHERE p.cdacesso = 'HOSWEBSRVCE_ESTEIRA_IBRA';
 
UPDATE crapprm p
   SET p.dsvlrprm = 'autorizador/services/rest/v1/proposta'
 WHERE p.cdacesso = 'URIWEBSRVCE_RECURSO_IBRA';
 
COMMIT;
