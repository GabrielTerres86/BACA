BEGIN
  
UPDATE
CECRED.TBCC_LANCAMENTOS_PENDENTES P
SET
IDSITUACAO = 'M'
WHERE
P.IDSEQ_LANCAMENTO IN
(
416526539
);
COMMIT;

END;