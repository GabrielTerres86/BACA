BEGIN

  DELETE FROM tbgen_notificacao WHERE cdmensagem = 7887;
  DELETE FROM tbgen_notif_manual_prm WHERE cdmensagem = 7887;
  DELETE FROM tbgen_notif_msg_cadastro WHERE cdmensagem = 7887;
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    
END;
