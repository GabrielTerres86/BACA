begin
UPDATE
pix.tbcc_lancamentos_pendentes t
SET
t.IDSITUACAO = 'M'
WHERE
T.IDSEQ_LANCAMENTO = 399868863
COMMIT;

end;