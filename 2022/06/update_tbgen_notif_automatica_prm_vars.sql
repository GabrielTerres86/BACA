BEGIN

  UPDATE tbgen_notif_automatica_prm SET dsvariaveis_mensagem = null
    where cdorigem_mensagem = 11 ;
    
  commit;
end;
