/*
Squad Renegociação e Cadastro Positivo
Analista: Diógenes Lazzarini
Desenvolvedor: Diógenes Lazzarini

INC0054694
Novas linhas de crédito foram criadas (covid) e não devem gerar pendência no 
*/

UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',31000,41000') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 1 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';                 
				 
UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',460') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 5 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';
				 
UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',89,98') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 6 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',222,223') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 7 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';
				 
UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',310,320,2900,2910') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 10 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',52') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 11 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',2451,2461') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 12 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',570') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 13 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',25') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 14 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';
				 
COMMIT;