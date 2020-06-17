/* 22/01/2020 - ritm0050291 Alteração de parâmetro para considerar o limite de crédito na cooperativa CREVISC
para débito de cotas (Carlos) */
UPDATE crapprm SET crapprm.dsvlrprm = 'C' WHERE cdacesso = 'LIMITE_APLIC_PLANO_COTAS' AND cdcooper = 12;
COMMIT;
