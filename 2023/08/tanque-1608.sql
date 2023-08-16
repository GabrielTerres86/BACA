begin
UPDATE 
  CECRED.tbcc_lancamentos_pendentes p
SET
  p.idsituacao = 'M',
  p.dscritica = 'Ajustado pela RDM0051064 em alinhamento com Aline Galdino'
WHERE
  IDSEQ_LANCAMENTO = 293886843;
commit;
end;