BEGIN
UPDATE CECRED.TBCC_LANCAMENTOS_PENDENTES P
SET IDSITUACAO = 'M'
WHERE P.IDSEQ_LANCAMENTO IN (439103028,439767663);
COMMIT;
END;