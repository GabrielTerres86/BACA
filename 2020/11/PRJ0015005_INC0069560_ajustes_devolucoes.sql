declare
  cursor cr_registros is
    select t.idtransacao
          ,t.VLTRANSACAO
          ,t.IDTRANSACAO_VINCULADA
      from tbpix_transacao t
     where t.IDTRANSACAO in(28242,34192,58786,73631,64445,66006,65041,116761,100929,125139,129457,142523,144871,159286,152468,87267,149033,109490);
begin
  -- Varrer registros processados manualmente
  for rw_reg in cr_registros loop
    -- Atualizar valor devolucao transacao original  
    update tbpix_transacao
       set vldevolucao = nvl(vldevolucao,0) + rw_reg.vltransacao
      where idtransacao = rw_reg.idtransacao_vinculada;  
    -- Atualizar a situação dessa transação para processada manualmente
    update tbpix_transacao
       set idsituacao = 'E'
          ,dscritica = 'Transação processada manualmente'
      where idtransacao = rw_reg.idtransacao;    
  end loop;
end;  
