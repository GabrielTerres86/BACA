begin 

 update tbcc_lancamentos_pendentes l
    set l.idsituacao = 'I'
  where l.idseq_lancamento = 92645;    
  
  update tbcc_lancamentos_pendentes l
    set l.idsituacao = 'A'
  where l.idsituacao = 'E'
    and l.idseq_lancamento <> 92645;
	
  commit;   
end;   