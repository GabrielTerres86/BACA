DECLARE

  pr_CDMENSAGEM NUMBER;  
  pr_CDMOTIVO_MENSAGEM NUMBER;
  pr_CDORIGEM_MENSAGEM NUMBER:= 12; 
  
  pr_DSTITULO_MENSAGEM VARCHAR2(32767);
  pr_DSTEXTO_MENSAGEM VARCHAR2(32767);
  pr_DSHTML_MENSAGEM VARCHAR2(32767);

BEGIN
  
  select max(cdmensagem) into pr_CDMENSAGEM from TBGEN_NOTIF_MSG_CADASTRO;

	INSERT INTO TBGEN_NOTIF_MSG_ORIGEM (CDORIGEM_MENSAGEM, DSORIGEM_MENSAGEM, CDTIPO_MENSAGEM, HRINICIO_PUSH, HRFIM_PUSH, HRTEMPO_VALIDADE_PUSH)
	values (pr_CDORIGEM_MENSAGEM, 'Depósito de cheque mobile', 3, 32400, 79200, 86400);

  -- 1 - Funcionalidade de cheque liberada
  pr_CDMOTIVO_MENSAGEM := 1;

  pr_CDMENSAGEM := pr_CDMENSAGEM + 1;
  pr_DSTITULO_MENSAGEM := 'Funcionalidade de cheque liberada';
  pr_DSTEXTO_MENSAGEM := 'Temos novidades sobre o depósito de cheques. Acesse o seu aplicativo e saiba mais!';
  pr_DSHTML_MENSAGEM := '<p>Cooperado</p>
  <p>A partir de agora você poderá realizar o depósito de cheque direto pelo seu aplicativo. </p>
  <p>Deposite, faça a gestão e acompanhamento de todos os cheques pela palma da sua mão. </p>
  <p>Acesse o menu de serviços, veja o tutorial e comece agora mesmo!</p>';	
  		
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INENVIAR_PUSH)
  VALUES (pr_CDMENSAGEM, pr_CDORIGEM_MENSAGEM, pr_DSTITULO_MENSAGEM, pr_DSTEXTO_MENSAGEM, pr_DSHTML_MENSAGEM, 1, 'VERIFICAR', 500, null, null, null, 11, 0, null, 1);

  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, CDMENSAGEM, DSMOTIVO_MENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, INTIPO_REPETICAO, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (pr_CDORIGEM_MENSAGEM, pr_CDMOTIVO_MENSAGEM, pr_CDMENSAGEM, 'Funcionalidade cheque liberada', '', 1, '4', '1,3', null, null, 68400, 1, 'EMPR0002.fn_sql_contas_com_preaprovado', null);

  -- 2 - Funcionalidade de cheque reprovada
  pr_CDMOTIVO_MENSAGEM := 2;

  pr_CDMENSAGEM := pr_CDMENSAGEM + 1;
  pr_DSTITULO_MENSAGEM := 'Funcionalidade de cheque reprovada';
  pr_DSTEXTO_MENSAGEM := 'Depósito de cheque: acesse o aplicativo e saiba mais sobre a funcionalidade.';
  pr_DSHTML_MENSAGEM := '<p>Cooperado,</p>
  <p>Neste momento esta funcionalidade não está disponível para você utilizar.</p>
  <p>Entre em contato com a nossa equipe de SAC (0800 647 2200) ou dirija-se até um Posto de Atendimento para que nossa equipe possa auxiliá-lo.</p>';	
  		
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INENVIAR_PUSH)
  VALUES (pr_CDMENSAGEM,  pr_CDORIGEM_MENSAGEM, pr_DSTITULO_MENSAGEM, pr_DSTEXTO_MENSAGEM, pr_DSHTML_MENSAGEM, 1, 'VERIFICAR', 500, null, null, null, 2, 0, null, 1);

  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, CDMENSAGEM, DSMOTIVO_MENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, INTIPO_REPETICAO, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (pr_CDORIGEM_MENSAGEM, pr_CDMOTIVO_MENSAGEM, pr_CDMENSAGEM, 'Funcionalidade cheque reprovada', '', 1, '4', '1,3', null, null, 68400, 1, 'EMPR0002.fn_sql_contas_com_preaprovado', null);
  		
  -- 3 - Cheque Aprovado
  pr_CDMOTIVO_MENSAGEM := 3;
  
  pr_CDMENSAGEM := pr_CDMENSAGEM + 1;
  pr_DSTITULO_MENSAGEM := 'Cheque Aprovado';
  pr_DSTEXTO_MENSAGEM := 'O seu cheque no valor de <b>R$ #valorcheque</b> foi compensado. Acesse o seu aplicativo e saiba mais.';
  pr_DSHTML_MENSAGEM := '<p>Cooperado,</p>
  <p>O seu cheque no valor de <b>R$ #valorcheque</b> foi compensado com sucesso.</p>
  <p>Acesse o Menu de Depósito de Cheques para visualizar todos os detalhes.</p>';	
  		
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INENVIAR_PUSH)
  VALUES (pr_CDMENSAGEM, pr_CDORIGEM_MENSAGEM, pr_DSTITULO_MENSAGEM, pr_DSTEXTO_MENSAGEM, pr_DSHTML_MENSAGEM, 1, 'VERIFICAR', 500, null, null, null, 7, 0, null, 1);
  	
  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, CDMENSAGEM, DSMOTIVO_MENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, INTIPO_REPETICAO, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (pr_CDORIGEM_MENSAGEM, pr_CDMOTIVO_MENSAGEM, pr_CDMENSAGEM, 'Cheque Aprovado', '<br/>#valorcheque - Valor do Cheque (Ex.: 5.000,00)', 1, '4', '1,3', null, null, 68400, 1, 'EMPR0002.fn_sql_contas_com_preaprovado', null);
    
  -- 4 - Cheque Reprovado
  pr_CDMOTIVO_MENSAGEM := 4;

  pr_CDMENSAGEM := pr_CDMENSAGEM + 1;
  pr_DSTITULO_MENSAGEM := 'Cheque Reprovado';
  pr_DSTEXTO_MENSAGEM := 'O seu cheque no valor de <b>R$ #valorcheque</b> foi reprovado. Acesse o seu aplicativo e saiba mais.';
  pr_DSHTML_MENSAGEM := '<p>Cooperado,</p>
  <p>O seu cheque no valor de <b>R$ #valorcheque</b> foi reprovado no processo de conferência.</p>
  <p>Acesse o Menu de Depósito de Cheques para visualizar todos os detalhes.</p>';	
  		
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INENVIAR_PUSH)
  VALUES (pr_CDMENSAGEM, pr_CDORIGEM_MENSAGEM, pr_DSTITULO_MENSAGEM, pr_DSTEXTO_MENSAGEM, pr_DSHTML_MENSAGEM, 1, 'VERIFICAR', 500, null, null, null, 2, 0, null, 1);

  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, CDMENSAGEM, DSMOTIVO_MENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, INTIPO_REPETICAO, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (pr_CDORIGEM_MENSAGEM, pr_CDMOTIVO_MENSAGEM, pr_CDMENSAGEM, 'Cheque Reprovado', '<br/>#valorcheque - Valor do Cheque (Ex.: 5.000,00)', 1, '4', '1,3', null, null, 68400, 1, 'EMPR0002.fn_sql_contas_com_preaprovado', null);

  -- 5 - Cheque Estornado
  pr_CDMOTIVO_MENSAGEM := 5;
  
  pr_CDMENSAGEM := pr_CDMENSAGEM + 1;
  pr_DSTITULO_MENSAGEM := 'Cheque Estornado';
  pr_DSTEXTO_MENSAGEM := 'O seu cheque no valor de <b>R$ #valorcheque</b> foi estornado. Acesse o seu aplicativo e saiba mais.';
  pr_DSHTML_MENSAGEM := '<p>Cooperado,</p>
  <p>O seu cheque no valor de <b>R$ #valorcheque</b> foi estornado com sucesso.</p>
  <p>Acesse o Menu de Depósito de Cheques para visualizar todos os detalhes.</p>';	
  		
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INENVIAR_PUSH)
  VALUES (pr_CDMENSAGEM, pr_CDORIGEM_MENSAGEM, pr_DSTITULO_MENSAGEM, pr_DSTEXTO_MENSAGEM, pr_DSHTML_MENSAGEM, 1, 'VERIFICAR', 500, null, null, null, 2, 0, null, 1);

  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, CDMENSAGEM, DSMOTIVO_MENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, INTIPO_REPETICAO, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (pr_CDORIGEM_MENSAGEM, pr_CDMOTIVO_MENSAGEM, pr_CDMENSAGEM, 'Cheque Estornado', '<br/>#valorcheque - Valor do Cheque (Ex.: 5.000,00)', 1, '4', '1,3', null, null, 68400, 1, 'EMPR0002.fn_sql_contas_com_preaprovado', null);

  -- 6 - Descarte de Cheque
  pr_CDMOTIVO_MENSAGEM := 6;
  
  pr_CDMENSAGEM := pr_CDMENSAGEM + 1;
  pr_DSTITULO_MENSAGEM := 'Descarte de Cheque';
  pr_DSTEXTO_MENSAGEM := 'Chegou a hora de descartar o seu cheque já compensado. Acesse o seu aplicativo e saiba mais.';
  pr_DSHTML_MENSAGEM := '<p>Cooperado,</p>
  <p>Lembra daquele cheque de R$ <b>R$ #valorcheque</b> depositado pelo aplicativo?</p>
  <p>Chegou a hora de descartá-lo. E por motivos de segurança, recomendamos que você rasgue o documento.</p>';	
  		
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INENVIAR_PUSH)
  VALUES (pr_CDMENSAGEM, pr_CDORIGEM_MENSAGEM, pr_DSTITULO_MENSAGEM, pr_DSTEXTO_MENSAGEM, pr_DSHTML_MENSAGEM, 1, 'VERIFICAR', 500, null, null, null, 9, 0, null, 1);

  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, CDMENSAGEM, DSMOTIVO_MENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, INTIPO_REPETICAO, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (pr_CDORIGEM_MENSAGEM, pr_CDMOTIVO_MENSAGEM, pr_CDMENSAGEM, 'Cheque Descartado', '<br/>#valorcheque - Valor do Cheque (Ex.: 5.000,00)', 1, '4', '1,3', null, null, 68400, 1, 'EMPR0002.fn_sql_contas_com_preaprovado', null);

END;
