-- Ativar a mensagem automatica e alterado para rodar no dia 24 de cada mês
UPDATE tbgen_notif_automatica_prm
SET INMENSAGEM_ATIVA = 1, NRDIAS_MES = 26
WHERE cdmensagem = 840;
COMMIT;