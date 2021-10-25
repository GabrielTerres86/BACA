--qtd de grupos para o crps445
INSERT INTO CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
VALUES ('CRED', 1, 'QTD_GRUPOS_CRPS445', 'Quantidade de grupos no paralelismo do CRPS445', '300');

UPDATE tbgen_batch_param SET qtparalelo = 50 WHERE cdprograma = 'CRPS445' AND cdcooper = 1;

COMMIT;
