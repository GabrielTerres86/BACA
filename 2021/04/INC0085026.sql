begin
  -- Caso A
  update tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = '[INC0085026] - ' || dscritica where IDSEQ_LANCAMENTO in (7336286, 7278499);
  
  -- Caso B
  update tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = '[INC0085026] - ' || dscritica where IDSEQ_LANCAMENTO in (5319838, 5769506, 5319872, 5319841);
  
  -- Caso C
  update tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = '[INC0085026] - ' || dscritica where IDSEQ_LANCAMENTO in (5546516,5546446,5546561,5546512,5546450,5546560,5546552,5546517,5546509,5546559,5546505,5546511,5546447,5546514,5546558,5546518, 5546551);
  update tbcc_lancamentos_pendentes set idsituacao = 'M', dscritica = '[INC0085026] - ' || dscritica where IDSEQ_LANCAMENTO in (5546555,5546557,5546556,5546449,5546506,5546507,5546508,5546553,5546510,5546554,5546513);
  
  -- Caso D
  update tbcc_lancamentos_pendentes set idsituacao = 'A', qtexecucoes = 0, dscritica = null where idseq_lancamento in (7713009,7713003,7713001,7713000,7712999,7712997,7712994,7712995,7712992,7712991,7712989,7712987,7712860,7712838,7712825,7712823,7712820,7712799,7712789,7712784,7712782,7712781);
  
  commit;
end;
