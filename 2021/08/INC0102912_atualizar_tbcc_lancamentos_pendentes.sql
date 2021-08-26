BEGIN
UPDATE tbcc_lancamentos_pendentes SET
        dscritica = 'INC0102912',
        idsituacao = 'M'
WHERE IDSEQ_LANCAMENTO = 26144528;
COMMIT;
END;