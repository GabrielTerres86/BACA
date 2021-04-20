begin
  -- Caso A
  update tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = '[INC0085026] - ' || dscritica where IDSEQ_LANCAMENTO in (7336286, 7278499);
  
  -- Caso B
  update tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = '[INC0085026] - ' || dscritica where IDSEQ_LANCAMENTO in (5319838, 5769506, 5319872, 5319841);
  
  commit;
end;
