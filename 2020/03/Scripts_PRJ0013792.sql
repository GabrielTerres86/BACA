-- Scripts DML Projetos: PRJ0013792 - Inclusão do cheque especial na esteira de crédito

-- armazenar tela para interface web
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('LIMI0003', sysdate);
COMMIT;

--------------------- Crapaca ---------------------
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('VERIFICA_CONTING_LIMCHEQ','LIMI0003','pc_conting_limcheq_web','pr_cdcooper',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

COMMIT;

