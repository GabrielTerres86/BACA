DECLARE
BEGIN
    update tbgen_notif_msg_cadastro set dshtml_mensagem = 'O Pix Saque que você realizou às #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvido <b>#parcialtotalmente.</br></br> O valor está novamente disponível em sua conta corrente.</b></br></br>Acesse o comprovante para mais detalhes da devolução.' where cdmensagem = 7892;
    update tbgen_notif_msg_cadastro set dshtml_mensagem = 'A parcela #parcelacompratroco do Pix Troco que você realizou às #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvida <b>#parcialtotalmente.</br></br> O valor está novamente disponível em sua conta corrente.</b></br></br>Acesse o comprovante para mais detalhes da devolução.' where cdmensagem = 7893;
    COMMIT;
END;
