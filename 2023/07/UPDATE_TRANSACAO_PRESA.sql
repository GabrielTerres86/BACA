begin
UPDATE 
  tbcc_lancamentos_pendentes p
SET
  p.idsituacao = 'M',
  p.dscritica = 'Ajustado pela RDM0051064 em alinhamento com Juliana Carla'
WHERE
  IDSEQ_LANCAMENTO = 279376883;
commit;
end;