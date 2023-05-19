DECLARE
BEGIN
INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
    (13, 58, 'Alteração de limites Pix para Empresas', 12421, 1, 0, '#NomeCooperado, <br><br>O ajuste de limite Pix para Empresas, que você solicitou foi realizado com sucesso. <br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.');
commit;
END;
