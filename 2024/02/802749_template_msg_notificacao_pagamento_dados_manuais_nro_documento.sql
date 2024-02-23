DECLARE
    codigoMensagem CECRED.tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN
    SELECT (max(cdmensagem) + 1) into codigoMensagem FROM CECRED.tbgen_notif_msg_cadastro;  
    insert into CECRED.TBGEN_NOTIF_MSG_CADASTRO (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
    values (codigoMensagem, 13, 'Confirmação de pagamento agendado Pix', 'Seu pagamento Pix agendado no valor de #valorpix foi realizado com sucesso', '#nomeresumido,<br><br> Seu pagamento Pix que estava agendado para hoje foi realizado com sucesso.<br><br> Beneficiário: #beneficiario<br> CPF/CNPJ : #documentorecebedor<br> Valor: #valorpix <br><br>Para consultar mais informações acesse a opção ver comprovante.', 16, 0, null, 1, 'Ver comprovante', 400, null, 'Ver comprovante', null, 1);

    insert into CECRED.tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
    values (13, 63, 'PIX - Confirmação de pagamento agendado Pix', codigoMensagem, '#nomeresumido,<br><br> Seu pagamento Pix que estava agendado para hoje foi realizado com sucesso.<br><br> Beneficiário: #beneficiario<br> CPF/CNPJ : #documentorecebedor<br> Valor: #valorpix <br><br>Para consultar mais informações acesse a opção ver comprovante.', 1, 0, null, null, null, null, null, null, null);
    commit;
END;
