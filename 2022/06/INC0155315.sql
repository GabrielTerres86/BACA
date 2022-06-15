DELETE FROM cecred.TBGEN_NOTIF_PUSH WHERE  CDNOTIFICACAO IN (select CDNOTIFICACAO from TBGEN_NOTIFICACAO WHERE cdmensagem  = 9310); 
DELETE FROM cecred.tbgen_notificacao where  cdmensagem  = 9310; 
DELETE FROM cecred.tbgen_notif_manual_prm where cdmensagem = 9310; 
DELETE FROM cecred.tbgen_notif_msg_cadastro where cdmensagem = 9310; 
COMMIT; 