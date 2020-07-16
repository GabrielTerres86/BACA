/*
Squad Renegociação e Cadastro Positivo
Analista: Diógenes Lazzarini
Desenvolvedor: Diógenes Lazzarini

INC0054694
Novas linhas de crédito foram criadas (covid) e não devem gerar pendência no digidoc. Esse script retorna os valores originais.
*/

UPDATE crapprm SET DSVLRPRM = '30000,40000' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 1 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';                 
				 
UPDATE crapprm SET DSVLRPRM = '46' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 5 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';
				 
UPDATE crapprm SET DSVLRPRM = '87' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 6 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = '220,221' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 7 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';
				 
UPDATE crapprm SET DSVLRPRM = '31,32,290,291' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 10 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = '51' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 11 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = '245,246' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 12 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = '57' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 13 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';

UPDATE crapprm SET DSVLRPRM = '20,30' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 14 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';
				 
UPDATE crapprm SET DSVLRPRM = '9033,8033' WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 16 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';					 
				 
COMMIT;