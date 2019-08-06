
set feedback off
set define off

--- Apaga tabelas
--DELETE tbgen_notificacao t  WHERE cdmensagem IN (SELECT cdmensagem  FROM cecred.tbgen_notif_msg_cadastro t   WHERE cdorigem_mensagem = 11);
--COMMIT;
--DELETE cecred.tbgen_notif_msg_origem t WHERE cdorigem_mensagem = 11;
--COMMIT;
--DELETE tbgen_notif_automatica_prm t WHERE cdorigem_mensagem = 11;
--COMMIT;
--DELETE cecred.tbgen_notif_msg_cadastro t WHERE cdorigem_mensagem = 11;
--COMMIT;
 
 
declare
vr_max_cdmensagem number;
begin

-- Insere na tabela principal
INSERT INTO cecred.tbgen_notif_msg_origem
  (cdorigem_mensagem,
   dsorigem_mensagem,
   cdtipo_mensagem,
   hrinicio_push,
   hrfim_push,
   hrtempo_validade_push)
VALUES
  (11, 'Aprovação carta credito por canais', 2, 0, 0, 0);

SELECT MAX(c.cdmensagem) + 1
  INTO vr_max_cdmensagem
  FROM tbgen_notif_msg_cadastro c;

INSERT INTO cecred.tbgen_notif_msg_cadastro
  (cdmensagem,
   cdorigem_mensagem,
   dstitulo_mensagem,
   dstexto_mensagem,
   dshtml_mensagem,
   cdicone,
   inexibir_banner,
   nmimagem_banner,
   inexibe_botao_acao_mobile,
   dstexto_botao_acao_mobile,
   cdmenu_acao_mobile,
   dslink_acao_mobile,
   dsmensagem_acao_mobile,
   dsparam_acao_mobile,
   inenviar_push)
VALUES
  (vr_max_cdmensagem,
   11,
   'Solicitação de Cartão',
   'Solicitação cartão - Sem assinatura ',
   '<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos</p><p>Voc&ecirc; possui uma proposta de cart&atilde;o pendente para aprova&ccedil;&atilde;o.</p><p>Acesse o menu Cart&otilde;es &gt; Autoriza&ccedil;&atilde;o de solicita&ccedil;&atilde;o do Cart&atilde;o, verifique as informa&ccedil;&otilde;es e proceda com a aprova&ccedil;&atilde;o.</p><p>.</p>',
   3,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   1);

INSERT INTO tbgen_notif_automatica_prm
  (cdorigem_mensagem,
   cdmotivo_mensagem,
   dsmotivo_mensagem,
   cdmensagem,
   dsvariaveis_mensagem,
   inmensagem_ativa,
   intipo_repeticao,
   nrdias_semana,
   nrsemanas_repeticao,
   nrdias_mes,
   nrmeses_repeticao,
   hrenvio_mensagem,
   nmfuncao_contas,
   dhultima_execucao)
VALUES
  (11,
   1,
   'CARTÃO DE CREDITO - Solicitação de Cartão - sem assinatura conjunta',
   vr_max_cdmensagem,
   '<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos</p>',
   1,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL);
COMMIT;
SELECT MAX(c.cdmensagem) + 1
  INTO vr_max_cdmensagem
  FROM tbgen_notif_msg_cadastro c;

INSERT INTO cecred.tbgen_notif_msg_cadastro
  (cdmensagem,
   cdorigem_mensagem,
   dstitulo_mensagem,
   dstexto_mensagem,
   dshtml_mensagem,
   cdicone,
   inexibir_banner,
   nmimagem_banner,
   inexibe_botao_acao_mobile,
   dstexto_botao_acao_mobile,
   cdmenu_acao_mobile,
   dslink_acao_mobile,
   dsmensagem_acao_mobile,
   dsparam_acao_mobile,
   inenviar_push)
VALUES
  (vr_max_cdmensagem,
   11,
   'Solicitação de Cartão',
   -- 'Solicitação cartão - Com assinatura  conjunta',
    ' ',

   '<p>Voc&ecirc; possui uma proposta de cart&atilde;o pendente para aprova&ccedil;&atilde;o.</p><p>Acesse o menu Cart&otilde;es &gt; Autoriza&ccedil;&atilde;o de solicita&ccedil;&atilde;o do Cart&atilde;o e/ou Transa&ccedil;&otilde;es Pendentes, verifique as informa&ccedil;&otilde;es e proceda com a aprova&ccedil;&atilde;o</p>',
   3,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   1);

INSERT INTO tbgen_notif_automatica_prm
  (cdorigem_mensagem,
   cdmotivo_mensagem,
   dsmotivo_mensagem,
   cdmensagem,
   dsvariaveis_mensagem,
   inmensagem_ativa,
   intipo_repeticao,
   nrdias_semana,
   nrsemanas_repeticao,
   nrdias_mes,
   nrmeses_repeticao,
   hrenvio_mensagem,
   nmfuncao_contas,
   dhultima_execucao)
VALUES
  (11,
   11,
   'CARTÃO DE CREDITO - Solicitação de Cartão - com assinatura conjunta',
   vr_max_cdmensagem,
   '<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos</p>',
   1,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL);

COMMIT;
SELECT MAX(c.cdmensagem) + 1
  INTO vr_max_cdmensagem
  FROM tbgen_notif_msg_cadastro c;

INSERT INTO cecred.tbgen_notif_msg_cadastro
  (cdmensagem,
   cdorigem_mensagem,
   dstitulo_mensagem,
   dstexto_mensagem,
   dshtml_mensagem,
   cdicone,
   inexibir_banner,
   nmimagem_banner,
   inexibe_botao_acao_mobile,
   dstexto_botao_acao_mobile,
   cdmenu_acao_mobile,
   dslink_acao_mobile,
   dsmensagem_acao_mobile,
   dsparam_acao_mobile,
   inenviar_push)
VALUES
  (vr_max_cdmensagem,
   11,
   'Upgrade/Downgrade',
  -- 'Upgrade/Daowngrade',
    'Solicitação cartão ',
   '<p>Voc&ecirc; possui uma proposta de cart&atilde;o pendente para aprova&ccedil;&atilde;o.</p>
<p>Acesse o menu Cart&otilde;es &gt; Autoriza&ccedil;&atilde;o de solicita&ccedil;&atilde;o do Cart&atilde;o, verifique as informa&ccedil;&otilde;es e proceda com a aprova&ccedil;&atilde;o.</p><p>&nbsp;</p> ',
   3,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   1);

INSERT INTO tbgen_notif_automatica_prm
  (cdorigem_mensagem,
   cdmotivo_mensagem,
   dsmotivo_mensagem,
   cdmensagem,
   dsvariaveis_mensagem,
   inmensagem_ativa,
   intipo_repeticao,
   nrdias_semana,
   nrsemanas_repeticao,
   nrdias_mes,
   nrmeses_repeticao,
   hrenvio_mensagem,
   nmfuncao_contas,
   dhultima_execucao)
VALUES
  (11,
   2,
   'CARTÃO DE CREDITO - Upgrade/downgrade ',
   vr_max_cdmensagem,
   '<p>Solicita&ccedil;&atilde;o de Cart&atilde;o Ailos</p>',
   1,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL);

COMMIT;

SELECT MAX(c.cdmensagem) + 1
  INTO vr_max_cdmensagem
  FROM tbgen_notif_msg_cadastro c;

INSERT INTO cecred.tbgen_notif_msg_cadastro
  (cdmensagem,
   cdorigem_mensagem,
   dstitulo_mensagem,
   dstexto_mensagem,
   dshtml_mensagem,
   cdicone,
   inexibir_banner,
   nmimagem_banner,
   inexibe_botao_acao_mobile,
   dstexto_botao_acao_mobile,
   cdmenu_acao_mobile,
   dslink_acao_mobile,
   dsmensagem_acao_mobile,
   dsparam_acao_mobile,
   inenviar_push)
VALUES
  (vr_max_cdmensagem,
   11,
   'Limite de Crédito',
   'Alteração de Limite de Crédito',
   '<p>Informamos que o limite do seu cart&atilde;o Ailos foi alterado. Para visualizar seu novo limite acesse o APP Ailos Cart&otilde;es ou entre em contato com sua Cooperativa.</p>',
   3,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   1);

INSERT INTO tbgen_notif_automatica_prm
  (cdorigem_mensagem,
   cdmotivo_mensagem,
   dsmotivo_mensagem,
   cdmensagem,
   dsvariaveis_mensagem,
   inmensagem_ativa,
   intipo_repeticao,
   nrdias_semana,
   nrsemanas_repeticao,
   nrdias_mes,
   nrmeses_repeticao,
   hrenvio_mensagem,
   nmfuncao_contas,
   dhultima_execucao)
VALUES
  (11,
   3,
   'ALTERAÇÃO LIMITE',
   vr_max_cdmensagem,
   '<p>Altera&ccedil;&atilde;o de Limite de Cr&eacute;dito</p>',
   1,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL);
COMMIT;

SELECT MAX(c.cdmensagem) + 1
  INTO vr_max_cdmensagem
  FROM tbgen_notif_msg_cadastro c;

INSERT INTO cecred.tbgen_notif_msg_cadastro
  (cdmensagem,
   cdorigem_mensagem,
   dstitulo_mensagem,
   dstexto_mensagem,
   dshtml_mensagem,
   cdicone,
   inexibir_banner,
   nmimagem_banner,
   inexibe_botao_acao_mobile,
   dstexto_botao_acao_mobile,
   cdmenu_acao_mobile,
   dslink_acao_mobile,
   dsmensagem_acao_mobile,
   dsparam_acao_mobile,
   inenviar_push)
VALUES
  (vr_max_cdmensagem,
   11,
   'Processos Noturnos',
   'Erros noturnos processos Bancob',
   '<p>Comunicamos que ocorreu uma inconsist&ecirc;ncia na solicita&ccedil;&atilde;o do seu cart&atilde;o Ailos. Favor entre em contato com sua Cooperativa.</p>',
   3,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   1);

INSERT INTO tbgen_notif_automatica_prm
  (cdorigem_mensagem,
   cdmotivo_mensagem,
   dsmotivo_mensagem,
   cdmensagem,
   dsvariaveis_mensagem,
   inmensagem_ativa,
   intipo_repeticao,
   nrdias_semana,
   nrsemanas_repeticao,
   nrdias_mes,
   nrmeses_repeticao,
   hrenvio_mensagem,
   nmfuncao_contas,
   dhultima_execucao)
VALUES
  (11,
   4,
   'ERRO NOTURNO - Erros noturnos processos Bancob',
   vr_max_cdmensagem,
   '<p>Inconsist&ecirc;ncia na aprova&ccedil;&atilde;o da proposta do cart&atilde;o</p>',
   1,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL);

COMMIT;
SELECT MAX(c.cdmensagem) + 1
  INTO vr_max_cdmensagem
  FROM tbgen_notif_msg_cadastro c;

INSERT INTO cecred.tbgen_notif_msg_cadastro
  (cdmensagem,
   cdorigem_mensagem,
   dstitulo_mensagem,
   dstexto_mensagem,
   dshtml_mensagem,
   cdicone,
   inexibir_banner,
   nmimagem_banner,
   inexibe_botao_acao_mobile,
   dstexto_botao_acao_mobile,
   cdmenu_acao_mobile,
   dslink_acao_mobile,
   dsmensagem_acao_mobile,
   dsparam_acao_mobile,
   inenviar_push)
VALUES
  (vr_max_cdmensagem,
   11,
   'Recusa Esteira',
   'Não aprovação/Recusa Esteira',
   '<p>Comunicamos que ocorreu uma inconsist&ecirc;ncia na solicita&ccedil;&atilde;o do seu cart&atilde;o Ailos. Favor entre em contato com sua Cooperativa.</p>',
   3,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   1);

INSERT INTO tbgen_notif_automatica_prm
  (cdorigem_mensagem,
   cdmotivo_mensagem,
   dsmotivo_mensagem,
   cdmensagem,
   dsvariaveis_mensagem,
   inmensagem_ativa,
   intipo_repeticao,
   nrdias_semana,
   nrsemanas_repeticao,
   nrdias_mes,
   nrmeses_repeticao,
   hrenvio_mensagem,
   nmfuncao_contas,
   dhultima_execucao)
VALUES
  (11,
   5,
   'ERRO ESTEIRA -  Não aprovação/rejeição da Esteira',
   vr_max_cdmensagem,
   '<p>Inconsist&ecirc;ncia na aprova&ccedil;&atilde;o da proposta do cart&atilde;o</p>',
   1,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL);

END;
/
COMMIT;
prompt Done.
