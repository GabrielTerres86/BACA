DECLARE
  V_CODIGO                 TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  V_CODIGO_MOTIVO_MENSAGEM TBGEN_NOTIF_AUTOMATICA_PRM.Cdmotivo_Mensagem%TYPE;
BEGIN
  SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
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
    ((V_CODIGO + 1),
     6,
     'Transação pendente de aprovação',
     'Transações pendentes: Você possui uma nova transação pendente de aprovação. Clique e saiba mais.',
     '<p>#nomecompleto</p>

<p>Você possui uma nova transação pendente de aprovação:</p>

<p>#dsdmensg</p>

<p>Esta transação estará disponível para aprovação de todos os representantes até as 23:00h de #datatransacao, caso não seja aprovada será cancelada. Acesse <b>Serviços > Transações Pendentes</b></p>',
     2,
     0,
     null,
     1,
     'Transações Pendentes',
     204,
     'Serviços > Transações Pendentes',
     null,
     null,
     1);

  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGO_MOTIVO_MENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM
    WHERE CDORIGEM_MENSAGEM = 6;
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
    (6,
     (V_CODIGO_MOTIVO_MENSAGEM + 1),
     'PENDENTES - Transação pendente',
     (V_CODIGO + 1),
     '<br/>#dsdmensg - Mensagem de pendência
<br;>#datatransacao - data e hora da transacao',
     1,
     0,
     null,
     null,
     null,
     null,
     null,
     null,
     null);
	 
  update CECRED.tbgen_notif_msg_cadastro n
   set n.inexibe_botao_acao_mobile = 0,
       n.dstexto_botao_acao_mobile = '',
       n.cdmenu_acao_mobile        = 0,
       n.dslink_acao_mobile        = '',
     n.inenviar_push = 0,
       n.dshtml_mensagem = '<p>#nomecompleto</p>

<p>Você possui uma nova transação pendente de aprovação</p>

<p>#dsdmensg</p>

<p>Acesse "Transações Pendentes > Transações > Pendências" e confira.</p>'
 where cdorigem_mensagem = 6
   and cdmensagem = 271;
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: ' || SQLERRM);
END;

