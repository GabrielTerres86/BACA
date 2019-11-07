BEGIN

-- Menu para o mobile abrir ao clicar no CADASTRAR
INSERT INTO menumobile(menumobileid,menupaiid,nome,sequencia,habilitado,autorizacao,versaominimaapp,versaomaximaapp)
VALUES (1006,900,'Cart�es',1,1,1,'2.7.0.0',NULL);
--


-- Inicio Limite pre-aprovado disponivel

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
  (1064,
   8,
   'Oferta de cart�o pr�-aprovado',
   'Tem um cart�o Ailos esperando por voc�',
   '<p>Voc&ecirc; possui um cart&atilde;o de cr&eacute;dito com limite pr&eacute;-aprovado. Conheça os benef&iacute;cios e solicite agora.</p>',
   3,
   0,
   NULL,
   1,
   'CONTRATAR',
   1006,
   NULL,
   NULL,
   NULL,
   1);
  
-- Inserir na tbgen_notif_automatica_prm
 
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
  (8,
   12,
   'Oferta de cart�o pr�-aprovado',
   1064,
   '<p>Voc� possui um cart�o de cr�dito com limite pr�-aprovado. Conhe�a os benef�cios e solicite agora.</p>',
   1,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL);
   
-- Fim Limite pre-aprovado disponivel

-- Inicio solicitacao sem assinatura
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
  (1065,
   8,
   'Solicita��o de Cart�o',
   'Solicita��o cart�o - Sem assinatura',
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
  (8,
   13,
   'CART�O DE CREDITO - Solicita��o de Cart�o - sem assinatura conjunta',
   1065,
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
-- Fim solicitacao sem assinatura


-- Inicio solicitacao com assinatura
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
  (1066,
   8,
   'Solicita��o de Cart�o',
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
  (8,
   14,
   'CART�O DE CREDITO - Solicita��o de Cart�o - com assinatura conjunta',
   1066,
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
-- Fim solicitacao com assinatura   

-- Inicio Upgrade/Downgrade
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
  (1067,
   8,
   'Upgrade/Downgrade',
   'Solicita��o cart�o ',
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
  (8,
   15,
   'CART�O DE CREDITO - Upgrade/downgrade ',
   1067,
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

-- Fim Upgrade/Downgrade

-- Inicio Alteracao de limite
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
  (1068,
   8,
   'Limite de Cr�dito',
   'Altera��o de Limite de Cr�dito',
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
  (8,
   16,
   'ALTERA��O LIMITE',
   1068,
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
   
-- Fim Alteracao Limite

-- Inicio Erros NOTURNO

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
  (1069,
   8,
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
  (8,
   17,
   'ERRO NOTURNO - Erros noturnos processos Bancob',
   1069,
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
-- Fim Noturno   

-- Inicio Recusa Esteira
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
  (1070,
   8,
   'Recusa Esteira',
   'N�o aprova��o/Recusa Esteira',
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
  (8,
   18,
   'ERRO ESTEIRA -  N�o aprova��o/rejei��o da Esteira',
   1070,
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
-- Fim Recusa Esteira

END;