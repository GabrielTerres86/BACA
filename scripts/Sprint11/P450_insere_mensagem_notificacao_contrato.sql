declare
  VR_CDMENSAGEM INTEGER;
begin
  select max(CDMENSAGEM) into VR_CDMENSAGEM from TBGEN_NOTIF_MSG_CADASTRO;
  
    insert into TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM,
     CDORIGEM_MENSAGEM,
     DSTITULO_MENSAGEM,
     DSTEXTO_MENSAGEM,
     DSHTML_MENSAGEM,
     CDICONE,
     INEXIBIR_BANNER,
     NMIMAGEM_BANNER,
     INEXIBE_BOTAO_ACAO_MOBILE,
     DSTEXTO_BOTAO_ACAO_MOBILE,
     CDMENU_ACAO_MOBILE,
     DSLINK_ACAO_MOBILE,
     DSMENSAGEM_ACAO_MOBILE,
     DSPARAM_ACAO_MOBILE,
     INENVIAR_PUSH)
  values
    (VR_CDMENSAGEM + 1,
     8,
     'Aviso sobre seu seguro',
     'Seguro: Aviso sobre seu seguro. Clique e saiba mais.',
     '<p>Cooperado, seu seguro #descseguro foi cancelado por falta de pagamento.</p>
<p>Duvidas consulte seu posto de atendimento.</p>',
     2,
     0,
     null,
     0,
     null,
     0,
     null,
     null,
     null,
     1);
         
 insert into TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM,
     CDMOTIVO_MENSAGEM,
     DSMOTIVO_MENSAGEM,
     CDMENSAGEM,
     DSVARIAVEIS_MENSAGEM,
     INMENSAGEM_ATIVA,
     INTIPO_REPETICAO,
     NRDIAS_SEMANA,
     NRSEMANAS_REPETICAO,
     NRDIAS_MES,
     NRMESES_REPETICAO,
     HRENVIO_MENSAGEM,
     NMFUNCAO_CONTAS,
     DHULTIMA_EXECUCAO)
  values
    (8,
     7,
     'SEGURO - Cancelamento Serviço',
     VR_CDMENSAGEM + 1,
     '<br/>#descseguro - Descrição do seguro cancelado ',
     1,
     0,
     null,
     null,
     null,
     null,
     null,
     null,
     null);
     
     commit;     
end;
