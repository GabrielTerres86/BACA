BEGIN
  update tbgen_notif_msg_cadastro n
   set n.inexibe_botao_acao_mobile = 1,
       n.dstexto_botao_acao_mobile = 'Transações Pendentes',
       n.cdmenu_acao_mobile        = 204,
       n.dslink_acao_mobile        = 'Serviços > Transações Pendentes'
 where cdorigem_mensagem = 6
   and cdmensagem = 271;
COMMIT;
exception
  when others then
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
/
