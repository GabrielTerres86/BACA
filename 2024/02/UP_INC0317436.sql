begin

UPDATE
  CECRED.TBCC_LANCAMENTOS_PENDENTES PEND
SET
  pend.IDSITUACAO = 'M',
  pend.DSCRITICA = 'Ajuste manual via RDM0056087'

WHERE
  IDSEQ_LANCAMENTO IN (394925512,394936920,394942145,394945605,394950768,394951540,394965006,394984292,394985333,394989475);

commit;
end;