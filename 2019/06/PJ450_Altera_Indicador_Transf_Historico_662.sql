--Altera o indicador de historico de credito deve ser transferido para a conta transitoria caso a conta esteja em prejuizo 
UPDATE craphis 
SET    intransf_cred_prejuizo = 0 --(0 = nao, 1 = sim)
WHERE  cdhistor = 662; 
 
--Salva 
COMMIT;
