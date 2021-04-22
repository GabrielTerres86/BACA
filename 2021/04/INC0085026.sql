begin
  -- Caso A
  update tbcc_lancamentos_pendentes
     set idsituacao = 'M',
         dscritica  = '[INC0085026] - Registro alterado via script'
   where IDSEQ_LANCAMENTO = 7336286;
  
  update tbcc_lancamentos_pendentes
     set idsituacao = 'M',
         dscritica  = '[INC0085026] - Registro alterado via script'
   where IDSEQ_LANCAMENTO = 7278499;
  
  -- Caso B
  update tbcc_lancamentos_pendentes
     set idsituacao = 'M',
         dscritica  = '[INC0085026] - Registro alterado via script'
   where IDSEQ_LANCAMENTO = 5319838;
   
  update tbcc_lancamentos_pendentes
     set idsituacao = 'M',
         dscritica  = '[INC0085026] - Registro alterado via script'
   where IDSEQ_LANCAMENTO = 5769506;
   
  update tbcc_lancamentos_pendentes
     set idsituacao = 'M',
         dscritica  = '[INC0085026] - Registro alterado via script'
   where IDSEQ_LANCAMENTO = 5319872;
   
  update tbcc_lancamentos_pendentes
     set idsituacao = 'M',
         dscritica  = '[INC0085026] - Registro alterado via script'
   where IDSEQ_LANCAMENTO = 5319841;
   
  commit;
end;