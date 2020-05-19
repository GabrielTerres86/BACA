begin 
  /*
    INC0038825 - Atualizar a data de movimento corretamente para que as informa��es do relatorio de movimento de cobran�a exibam as informa��es corretas dos boletos.
  */    
  update craprtc t
  set dtmvtolt = trunc(dtmvtolt)
  where trunc(dtmvtolt) <> dtmvtolt;
  
  commit;
  
end;
/

  
