/* 22/01/2020 - ritm0050291 Altera��o de par�metro para considerar o limite de cr�dito na cooperativa CREVISC
para d�bito de cotas (Carlos) */
UPDATE crapprm SET crapprm.dsvlrprm = 'C' WHERE cdacesso = 'LIMITE_APLIC_PLANO_COTAS' AND cdcooper = 12;
COMMIT;
