DELETE FROM TBGEN_NOTIF_PUSH WHERE  CDNOTIFICACAO IN (select CDNOTIFICACAO from TBGEN_NOTIFICACAO WHERE cdmensagem  = 5843); 
DELETE FROM tbgen_notificacao where  cdmensagem  = 5843;
DELETE FROM tbgen_notif_manual_prm where cdmensagem = 5843;
DELETE FROM tbgen_notif_msg_cadastro where cdmensagem = 5843;
COMMIT;