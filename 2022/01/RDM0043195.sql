BEGIN
    DELETE FROM TBGEN_NOTIF_PUSH WHERE  CDNOTIFICACAO IN (select CDNOTIFICACAO from TBGEN_NOTIFICACAO WHERE cdmensagem  = 7870); 
    DELETE FROM tbgen_notificacao where  cdmensagem  = 7870;
    DELETE FROM tbgen_notif_manual_prm where cdmensagem = 7870;
    DELETE FROM tbgen_notif_msg_cadastro where cdmensagem = 7870;
    COMMIT;
END;

BEGIN
    DELETE FROM TBGEN_NOTIF_PUSH WHERE  CDNOTIFICACAO IN (select CDNOTIFICACAO from TBGEN_NOTIFICACAO WHERE cdmensagem  = 7858); 
    DELETE FROM tbgen_notificacao where  cdmensagem  = 7858;
    DELETE FROM tbgen_notif_manual_prm where cdmensagem = 7858;
    DELETE FROM tbgen_notif_msg_cadastro where cdmensagem = 7858;
    COMMIT;
END;