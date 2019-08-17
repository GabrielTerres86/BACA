BEGIN
   
 UPDATE tbgen_notif_automatica_prm ntf
   SET ntf.hrenvio_mensagem = 72000
 WHERE cdorigem_mensagem =2
  AND cdmotivo_mensagem =1;            
                   
  commit;
end;
