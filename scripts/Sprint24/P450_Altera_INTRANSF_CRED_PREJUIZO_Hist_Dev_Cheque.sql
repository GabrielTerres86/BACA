-- Desativa transferência dos históricos de crédito 
-- de devolução ode cheques para a conta transitória
UPDATE craphis his
   SET his.intransf_cred_prejuizo = 0
 WHERE cdhistor IN (47,191,338,573);
 
COMMIT;
