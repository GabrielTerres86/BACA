--Incluir o Histórico 1030 - SAQUE CARTAO para não Incrementar Saldo do Prejuizo 
UPDATE crapprm prm 
SET    prm.dsvlrprm = prm.dsvlrprm||';1030'
WHERE  prm.nmsistem = 'CRED'
AND    prm.cdcooper = 0
AND    prm.cdacesso = 'HISTOR_PREJ_N_SALDO';
 
--Salva 
COMMIT;
