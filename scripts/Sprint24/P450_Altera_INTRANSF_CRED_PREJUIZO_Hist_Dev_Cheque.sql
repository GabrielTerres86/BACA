-- Desativa transfer�ncia dos hist�ricos de cr�dito 
-- de devolu��o ode cheques para a conta transit�ria
UPDATE craphis his
   SET his.intransf_cred_prejuizo = 0
 WHERE cdhistor IN (47,191,338,573);
 
COMMIT;
