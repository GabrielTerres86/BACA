BEGIN
  update CECRED.tbgen_notif_msg_cadastro n
   set n.inexibe_botao_acao_mobile = 1,
       n.dstexto_botao_acao_mobile = 'Transa��es Pendentes',
       n.cdmenu_acao_mobile        = 204,
       n.dslink_acao_mobile        = 'Servi�os > Transa��es Pendentes',
	   n.inenviar_push = 1,
       n.dshtml_mensagem = '<p>#nomecompleto</p>

<p>Voc� possui uma nova transa��o pendente de aprova��o</p>

<p>#dsdmensg</p>

<p>Esta transa��o estar� dispon�vel para aprova��o de todos os representantes at� as 23:00h de #datatransacao, caso n�o seja aprovada ser� cancelada. Acesse <b>Servi�os > Transa��es Pendentes</b></p>'
 where cdorigem_mensagem = 6
   and cdmensagem = 271;

COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK; 
END;