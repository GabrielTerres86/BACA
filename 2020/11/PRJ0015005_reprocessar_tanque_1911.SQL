begin 
  update tbcc_lancamentos_pendentes l
     set l.idsituacao = 'A'
   where l.idsituacao = 'E';
  commit;   
end;   