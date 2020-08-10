-- INSERT PARA O VINICUS DO MOBILE
INSERT INTO menumobile
  (menumobileid,
   menupaiid,
   nome,
   sequencia,
   habilitado,
   autorizacao,
   versaominimaapp,
   versaomaximaapp)
VALUES
  (1008, 30, 'Consórcios', 1, 1, 1, '2.10.0.0', NULL);
  
-- FIM MOBILE

INSERT ALL
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('001', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('002', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('ADV', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('AMG', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('DES', ' ', 0)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('ENT', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('EXC', ' ', 0)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('EXJ', ' ', 0)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('EXP', ' ', 0)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('JUR', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('NOR', ' ', 1)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('NOT', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('OBT', ' ', 5)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('PCC', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('PCN', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('PEN', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('QSE', ' ', 5)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('QUI', 'Quitado', 3)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('SCC', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('SCN', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('SCS', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('SER', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('SQG', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('TCC', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('TCD', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('TCN', ' ', 2)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('TRA', 'Transferido', 4)
  INTO cecred.tbconsor_situacao (cdsituacao, nmsituacao, cdclassificacao) VALUES ('SQI', ' ', 2)
SELECT * FROM dual;

---------------------------
--        ENTREGA 3
---------------------------

----------- Parametros 
INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES ('CRED', 0, 'QTD_DIA_NOTIFICA_ASSEMBL', 'Quantidade de dias para notificar a próxima assembléia', 10);

INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES ('CRED', 0, 'HR_ENVIO_MSG_AGEND_DEBIT', 'Horário do envio da notificação de parcela de consórcio programada. (Segundos)', 30000);

INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
VALUES ('CRED', 0, 'HR_ENVIO_MSG_INADIMPLENT', 'Horário do envio da notificação para associados com consórcio inadimplente. (Segundos)', 30000);

----------- Notificações


-- Assembleia de consorcio
INSERT INTO tbgen_notif_msg_cadastro
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
  (5180,
   8,
   'Assembleia de consórcio',
   'A sua assembleia de consórcio está chegando!',
   '<p>Olá <b>#nmprimtl</b>!</p>

<p>A sua assembleia de consórcio está chegando. Que tal você ofertar um lance? Desta forma, suas chances de contemplação aumentam :). Basta acessar o canal do consorciado ou conversar diretamente com seu posto de atendimento.</p>',
   2,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   0);

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
   25,
   'CONSÓRCIO - Assembléia de consórcio',
   5180,
   '<br/>#nmprimtl - Nome do cooperado',
   1,
   1,
   '1,2,3,4,5,6,7',
   '1,2,3,4,5,6',
   NULL,
   NULL,
   30000,
   'CNSO0001.fn_busca_contas_assembleia',
   NULL);

-- Contemplado por sorteio
INSERT INTO tbgen_notif_msg_cadastro
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
  (5181,
   8,
   'Parabéns consorciado!',
   'Você foi contemplado em seu consórcio.',
   '<p>Parabéns <b>#nmprimtl</b>!</p>

<p>Você foi contemplado através de sorteio em sua assembleia de consórcio! Para iniciar o processo de contemplação, basta comparecer em seu posto de atendimento e conversar com um atendente :).</p>',
   2,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   0);

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
   26,
   'CONSÓRCIO - Contemplados por Sorteio',
   5181,
   '<br/>#nmprimtl - Nome do cooperado',
   1,
   1,
   '1,2,3,4,5,6,7',
   '1,2,3,4,5,6',
   NULL,
   NULL,
   30000,
   'CNSO0001.fn_busca_contemplado_sorteio',
   NULL);

-- Contemplado por lance
INSERT INTO tbgen_notif_msg_cadastro
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
  (5182,
   8,
   'Parabéns consorciado!',
   'Você foi contemplado em seu consórcio.',
   '<p>Parabéns <b>#nmprimtl</b>!</p>

<p>Você foi contemplado através de lance em sua assembleia de consórcio! Para realizar o pagamento do lance e iniciar o processo de contemplação, basta comparecer em seu posto de atendimento e conversar com um atendente :).</p>',
   2,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   0);

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
   27,
   'CONSÓRCIO - Contemplados por Lance',
   5182,
   '<br/>#nmprimtl - Nome do cooperado',
   1,
   1,
   '1,2,3,4,5,6,7',
   '1,2,3,4,5,6',
   NULL,
   NULL,
   30000,
   'CNSO0001.fn_busca_contemplado_lance',
   NULL);

-- Parcela de consorcio
INSERT INTO tbgen_notif_msg_cadastro
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
  (5183,
   8,
   'Parcela de consórcio.',
   'Sua parcela de consórcio está programada.',
   '<p>Olá <b>#nmprimtl</b>!</p>

<p>Sua parcela de consórcio vencerá no dia #dtvencpv. Não perca está data, ela lhe dará direito a participar da assembleia deste mês.</p>

<p>Caso tenha alguma dúvida, converse conosco :)!</p>',
   2,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   0);

-- Falta pagamento
INSERT INTO tbgen_notif_msg_cadastro
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
  (5184,
   8,
   'Atenção Consorciado.',
   'Não identificamos o pagamento de sua parcela.',
   '<p>Olá <b>#nmprimtl</b>!</p>

<p>Não identificamos o pagamento de sua parcela de consórcio. Para regularizá-la, basta gerar o boleto no canal do consorciado, no seu posto de atendimento ou até mesmo pelo SAC (0800 647 22 00). Caso você já tenha realizado o pagamento favor desconsiderar esta mensagem.</p>',
   2,
   0,
   NULL,
   0,
   NULL,
   NULL,
   NULL,
   NULL,
   NULL,
   0);

COMMIT;
