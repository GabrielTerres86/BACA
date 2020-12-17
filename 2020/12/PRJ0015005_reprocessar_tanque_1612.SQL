begin 
  
  -- Ajustar numero da conta do estorno + Reprocessar
  update tbcc_lancamentos_pendentes l
     set l.idsituacao = 'A' /* Aguardando processamento */
	    ,l.nrdconta   = 9316876
   where l.idseq_lancamento = 231815;
   
  -- Mandar reprocessar alguns registros 
  update tbcc_lancamentos_pendentes l
     set l.idsituacao = 'A'
   where l.idsituacao = 'E'
     and l.idseq_lancamento in(436585,436586,436587,434655);
	 
	commit;   
end;   