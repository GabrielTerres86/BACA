BEGIN
UPDATE CECRED.TBCC_LANCAMENTOS_PENDENTES P
SET IDSITUACAO = 'M'
WHERE P.IDSEQ_LANCAMENTO IN (444337550,445196156,446445849,446445854,446455449);
COMMIT;
END;