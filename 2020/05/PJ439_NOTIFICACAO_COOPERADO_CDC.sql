DECLARE

begin

insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
values (1382, 8, 'PROPOSTA AGUARDANDO ASSINATURA DIGITAL', 'Proposta está disponível para sua conferência, contrate digitando a sua senha.', 'Cooperado,</br></br>Proposta está disponível para sua conferência, contrate digitando a sua senha.  </br></br>', 7, 0, null, 0, null, 0, null, null, null, 1);

insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
values (1383, 8, 'PROPOSTA PENDENTE', 'Existe alguma pendência que precisa ser ajustada para concluir o processo. Verifique com a loja ou com seu Posto de Atendimento.', 'Cooperado,</br></br>Existe alguma pendência que precisa ser ajustada para concluir o processo. Verifique com a loja ou com seu Posto de Atendimento. </br></br>', 7, 0, null, 0, null, 0, null, null, null, 1);

insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
values (1384, 8, 'CONTRATO IMPRESSO', 'Falta Pouco! Vá até a loja para assinar o contrato.', 'Cooperado,</br></br>Falta Pouco! Vá até a loja para assinar o contrato. </br></br>', 7, 0, null, 0, null, 0, null, null, null, 1);


insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
values (8, 22, 'PROPOSTA AGUARDANDO ASSINATURA DIGITAL', 1382, 'Notificação de Proposta Aguardando assinatura digital', 1, 0, null, null, null, null, null, null, null);

insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
values (8, 23, 'PROPOSTA PENDENTE', 1383, 'Notificação de Proposta Pendente', 1, 0, null, null, null, null, null, null, null);

insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
values (8, 24, 'CONTRATO IMPRESSO', 1384, 'Notificação de Proposta Contrato impresso', 1, 0, null, null, null, null, null, null, null);


commit;
dbms_output.put_line('Sucesso');

exception
  when others then
    rollback;
    dbms_output.put_line('Erro: ' || SQLERRM);
    

end;
