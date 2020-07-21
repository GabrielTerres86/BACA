/*
Squad Renegociação e Cadastro Positivo
Analista: Diógenes Lazzarini
Desenvolvedor: Diógenes Lazzarini

INC0054694
Novas linhas de crédito foram criadas (covid) e não devem gerar pendência no digidoc.
*/

UPDATE crapprm SET DSVLRPRM = CONCAT(DSVLRPRM, ',35') WHERE crapprm.nmsistem = 'CRED' AND
                 crapprm.cdcooper = 14 AND
                 crapprm.cdacesso = 'LCRED_NAO_GERA_PENDENCIA';		 
				 
COMMIT;