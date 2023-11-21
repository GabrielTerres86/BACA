BEGIN
UPDATE
cecred.tbcc_lancamentos_pendentes pend
SET
pend.IDSITUACAO = 'M'
where
pend.IDSEQ_LANCAMENTO = 341877155;
COMMIT;
END;