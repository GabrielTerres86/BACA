begin 
  /*
    INC0038825 - Atualizar a data de movimento corretamente para que as informações do relatorio de movimento de cobrança exibam as informações corretas dos boletos.
  */    
  update craprtc t
  set dtmvtolt = trunc(dtmvtolt)
  where trunc(dtmvtolt) <> dtmvtolt;
  
  commit;
  
end;
/

  
