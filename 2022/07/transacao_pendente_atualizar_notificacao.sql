BEGIN
  update CECRED.tbgen_notif_msg_cadastro n
   set n.inexibe_botao_acao_mobile = 1,
       n.dstexto_botao_acao_mobile = 'Transações Pendentes',
       n.cdmenu_acao_mobile        = 204,
       n.dslink_acao_mobile        = 'Serviços > Transações Pendentes',
	   n.inenviar_push = 1,
       n.dshtml_mensagem = '<p>#nomecompleto</p>

<p>Você possui uma nova transação pendente de aprovação</p>

<p>#dsdmensg</p>

<p>Esta transação estará disponível para aprovação de todos os representantes até as 23:00h de #datatransacao, caso não seja aprovada será cancelada. Acesse <b>Serviços > Transações Pendentes</b></p>'
 where cdorigem_mensagem = 6
   and cdmensagem = 271;

COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK; 
END;