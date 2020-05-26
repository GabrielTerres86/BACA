DECLARE

  /*******************************/
  /*******************************/
  /****Executar em test window****/
  /*******************************/
  /*******************************/

  -- Gravar execucao
  vr_cdprogra VARCHAR(40) := 'PRJ0015801';
  vr_idprglog TBGEN_PRGLOG.IDPRGLOG%TYPE := 0;
  -- Default id
  vr_cdproduto number := 25;                          // Validar !
  -- Codigo da mensagem
  vr_cdmensagem number;

BEGIN

  -- Gera log no início da execução
  cecred.pc_log_programa(pr_dstiplog   => 'I'         
                        ,pr_cdprograma => vr_cdprogra 
                        ,pr_cdcooper   => 0
                        ,pr_tpexecucao => 0     
                        ,pr_idprglog   => vr_idprglog);

  /* Dados da tela cadfra */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados da tela cadfra', pr_idprglog => vr_idprglog);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (13, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Intra para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Intra do sistema antifraude.', null, 0, 1);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (13, 2, 24900, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Intra para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Intra do sistema antifraude.', null, 0, 2);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (14, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Inter para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Inter do sistema antifraude.', null, 0, 1);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (14, 2, 24900, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Inter para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Inter do sistema antifraude.', null, 0, 2);
  --
  insert into tbgen_analise_fraude_param (CDOPERACAO, TPOPERACAO, HRRETENCAO, FLGEMAIL_ENTREGA, DSEMAIL_ENTREGA, DSASSUNTO_ENTREGA, DSCORPO_ENTREGA, FLGEMAIL_RETORNO, DSEMAIL_RETORNO, DSASSUNTO_RETORNO, DSCORPO_RETORNO, FLGATIVO, TPRETENCAO)
  values (15, 1, null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha na entrega da Transferência Ailos Pag para a análise do sistema antifraude.', null, 1, 'monitoracaodefraudes@ailos.coop.br', 'Falha no retorno da análise de Transferência Ailos Pag do sistema antifraude.', null, 0, 1);

  /* Dados de transf. internas */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de transf. internas', pr_idprglog => vr_idprglog);
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '13', 'Transferências Internas');
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (13, 1, 21600, 57600, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (13, 1, 57660, 60000, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (13, 1, 60060, 61200, 10);
  --
  insert into tbcc_produto (CDPRODUTO, DSPRODUTO, FLGITEM_SOA, FLGUTILIZA_INTERFACE_PADRAO, FLGENVIA_SMS, FLGCOBRA_TARIFA, IDFAIXA_VALOR, FLGPRODUTO_API)
  values (50, 'TRI', 0, 0, 0, 0, 0, 0);

  /* Dados de transf. intercooperativas */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de transf. intercooperativas', pr_idprglog => vr_idprglog);
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '14', 'Intercooperativas');
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (14, 1, 21600, 57600, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (14, 1, 57660, 60000, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (14, 1, 60060, 61200, 10);
  --
  insert into tbcc_produto (CDPRODUTO, DSPRODUTO, FLGITEM_SOA, FLGUTILIZA_INTERFACE_PADRAO, FLGENVIA_SMS, FLGCOBRA_TARIFA, IDFAIXA_VALOR, FLGPRODUTO_API)
  values (51, 'ICO', 0, 0, 0, 0, 0, 0);

  /* Dados de transf. ailos pag */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de transf. ailos pag', pr_idprglog => vr_idprglog);
  --
  insert into tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
  values ('CDOPERAC_ANALISE_FRAUDE', '15', 'Ailos Pag');
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (15, 1, 21600, 57600, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (15, 1, 57660, 60000, 20);
  --
  insert into tbgen_analise_fraude_interv (CDOPERACAO, TPOPERACAO, HRINICIO, HRFIM, QTDMINUTOS_RETENCAO)
  values (15, 1, 60060, 61200, 10);
  --
  insert into tbcc_produto (CDPRODUTO, DSPRODUTO, FLGITEM_SOA, FLGUTILIZA_INTERFACE_PADRAO, FLGENVIA_SMS, FLGCOBRA_TARIFA, IDFAIXA_VALOR, FLGPRODUTO_API)
  values (52, 'AIP', 0, 0, 0, 0, 0, 0);

  /* Dados das notificacoes_1 */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados das notificacoes_1', pr_idprglog => vr_idprglog);
  --
  FOR i IN 50 .. 52 LOOP
    -- 25,29,33
    vr_cdproduto := vr_cdproduto + 1;
    insert into tbgen_tipo_mensagem (CDTIPO_MENSAGEM, DSTIPO_MENSAGEM, CDPRODUTO, DSOBSERVACAO, DSAGRUPADOR)
    values (vr_cdproduto,'Texto Minhas Mensagens Estorno - PF', i, null, null);
    -- 26,30,34
    vr_cdproduto := vr_cdproduto + 1;
    insert into tbgen_tipo_mensagem (CDTIPO_MENSAGEM, DSTIPO_MENSAGEM, CDPRODUTO, DSOBSERVACAO, DSAGRUPADOR)
    values (vr_cdproduto,'Texto Minhas Mensagens Estorno - PJ', i, null, null);
    -- 27,31,35
    vr_cdproduto := vr_cdproduto + 1;
    insert into tbgen_tipo_mensagem (CDTIPO_MENSAGEM, DSTIPO_MENSAGEM, CDPRODUTO, DSOBSERVACAO, DSAGRUPADOR)
    values (vr_cdproduto,'Texto Minhas Mensagens Cancela Agendamento - PF', i, null, null);
    -- 28,32,36
    vr_cdproduto := vr_cdproduto + 1;
    insert into tbgen_tipo_mensagem (CDTIPO_MENSAGEM, DSTIPO_MENSAGEM, CDPRODUTO, DSOBSERVACAO, DSAGRUPADOR)
    values (vr_cdproduto,'Texto Minhas Mensagens Cancela Agendamento - PJ', i, null, null);
  END LOOP;

  /* Dados das notificacoes_2 */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados das notificacoes_2', pr_idprglog => vr_idprglog);
  --
  FOR crapcop IN (SELECT cdcooper FROM crapcop ORDER BY cdcooper) LOOP

    -- Reset do id
    vr_cdproduto := 25;
    --
    FOR i IN 50 .. 52 LOOP

      -- Texto Minhas Mensagens Estorno - PF
      vr_cdproduto := vr_cdproduto + 1;
      insert into tbgen_mensagem (CDCOOPER, CDPRODUTO, CDTIPO_MENSAGEM, DSMENSAGEM) -- 21
      values (crapcop.cdcooper, i, vr_cdproduto, 'Caro(a), #NOME#

Por motivos de Segurança, a Transferência no valor de R$#VALOR# não foi efetivada, os valores serão restituídos a sua conta.

Nossa equipe de segurança entrará em contato com você.
Agradecemos a compreensão.');

      -- Texto Minhas Mensagens Estorno - PJ
      vr_cdproduto := vr_cdproduto + 1;
      insert into tbgen_mensagem (CDCOOPER, CDPRODUTO, CDTIPO_MENSAGEM, DSMENSAGEM)
      values (crapcop.cdcooper, i, vr_cdproduto, '#NOME#

Por motivos de segurança, a Transferência no valor R$#VALOR# não foi efetivada, os valores serão restitídos na conta.

Nossa equipe de segurança entrará em contato!
Agradecemos a compreensão');

      -- Texto Minhas Mensagens Cancela Agendamento - PF
      vr_cdproduto := vr_cdproduto + 1;
      insert into tbgen_mensagem (CDCOOPER, CDPRODUTO, CDTIPO_MENSAGEM, DSMENSAGEM) -- 19
      values (crapcop.cdcooper, i, vr_cdproduto, 'Caro(a), #NOME#

Por motivos de Segurança, a Transferência no valor R$#VALOR# com débito em #DTDEBITO# não foi efetivada.

Nossa equipe de segurança entrará em contato com você.
Agradecemos a compreensão.');

      -- Texto Minhas Mensagens Cancela Agendamento - PJ
      vr_cdproduto := vr_cdproduto + 1;
  insert into tbgen_mensagem (CDCOOPER, CDPRODUTO, CDTIPO_MENSAGEM, DSMENSAGEM)
  values (crapcop.cdcooper, i, vr_cdproduto, '#NOME#

Por motivos de segurança, a Transferência no valor R$#VALOR# com débito em #DTDEBITO# não será efetivada.

Nossa equipe de segurança entrará em contato!
Agradecemos a compreensão');

    END LOOP;

  END LOOP;

  /* Dados das mensagens */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados das mensagens', pr_idprglog => vr_idprglog);
  --
  insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
  values ((select max(cdmensagem) +1 from tbgen_notif_msg_cadastro), 3, 'Agendamento de Transferencia Estornado', 'A transferência agendada para data #dtdebito não foi efetivada. Clique e saiba mais.',
'<p>#nomeresumido </p>

<p>Por motivos de Seguran&ccedil;a, a Transfer&ecirc;ncia no valor R$#valor  com d&eacute;bito em #dtdebito  n&atilde;o foi efetivada.</p>

<p>Nossa equipe de seguran&ccedil;a entrar&aacute; em contato com voc&ecirc;.</p>

<p>Agradecemos a compreens&atilde;o.</p>',
1, 0, null, 0, null, 0, null, null, null, 1) returning cdmensagem into vr_cdmensagem;
  --
  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (3, 14, 'Transferência - Agendamento não efetivado 1', vr_cdmensagem, '<br/>#valor  - Valor da Transferência (Ex: 2.000,00) <br/>#dtdebito - Data de débito da Transferência (Ex: 01/01/2018) ', 1, 0, null, null, null, null, null, null, null);
  --
  insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
  values ((select max(cdmensagem) +1 from tbgen_notif_msg_cadastro), 3, 'Agendamento de Transferencia Estornado', 'A transferência agendada para data #dtdebito não foi efetivada. Clique e saiba mais.',
'<p>#nomeresumido </p>

<p>Por motivos de Seguran&ccedil;a, a Transfer&ecirc;ncia no valor R$#valor  com d&eacute;bito em #dtdebito  n&atilde;o foi efetivada.</p>

<p>Nossa equipe de seguran&ccedil;a entrar&aacute; em contato com voc&ecirc;.</p>

<p>Agradecemos a compreens&atilde;o.</p>',
1, 0, null, 0, null, 0, null, null, null, 1) returning cdmensagem into vr_cdmensagem;
  --
  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (3, 15, 'Transferência - Agendamento não efetivado 2', vr_cdmensagem, '<br/>#valor  - Valor da Transferência (Ex: 2.000,00) <br/>#dtdebito - Data de débito da Transferência (Ex: 01/01/2018)  ', 1, 0, null, null, null, null, null, null, null);

  /* Dados dos historicos */ /*-- Nao executar em producao
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados dos historicos', pr_idprglog => vr_idprglog);
  --
  if instr(upper(GENE0001.fn_database_name),'P',1) = 0 then 

    for rw_crapcop in (select cdcooper from crapcop) loop
  
      insert into craphis (CDHISTOR, DSHISTOR, INHISTOR, INDEBCRE, TPLOTMOV, INDOIPMF, TXDOIPMF, INAUTORI, INAVISAR, INDEBCTA, INDEBFOL, INCLASSE, DSEXTHST, CDHSTCTB, NRCTADEB, NRCTACRD, TPCTBCCU, TPCTBCXA, NMESTRUT, INCREMES, NRCTATRD, NRCTATRC, INDCOMPL, INGERDEB, INGERCRE, CDCOOPER, FLGSENHA, CDPRODUT, CDAGRUPA, DSEXTRAT, CDHISEST, INDCALEM, INDCALCC, CDTRSCYB, INMONPLD, CDGRPHIS, INESTOURA_CONTA, IDMONPLD, INDUTBLQ, INPERDES, INDEBPRJ, INTRANSF_CRED_PREJUIZO, INDCALDS, CDHISREC, CDESTSIG, INDLCMEP)
      values (3242, 'EST.TRANSF', 1, 'C', 0, 2, 0.0000, 0, 0, 0, 0, 20, 'ESTORNO DE TRANSFERENCIA INTERNET TAA', 5210, 4957, 4112, 0, 0, 'CRAPLCM', 0, 0, 0, 0, 1, 2, rw_crapcop.cdcooper, 0, 0, 0, 'ESTORNO TRANSFERENCIA', 0, 'N', 'N', ' ', 0, 0, 0, 0, 'S', 0, 0, 1, 'N', null, null, 0);
  
      insert into craphis (CDHISTOR, DSHISTOR, INHISTOR, INDEBCRE, TPLOTMOV, INDOIPMF, TXDOIPMF, INAUTORI, INAVISAR, INDEBCTA, INDEBFOL, INCLASSE, DSEXTHST, CDHSTCTB, NRCTADEB, NRCTACRD, TPCTBCCU, TPCTBCXA, NMESTRUT, INCREMES, NRCTATRD, NRCTATRC, INDCOMPL, INGERDEB, INGERCRE, CDCOOPER, FLGSENHA, CDPRODUT, CDAGRUPA, DSEXTRAT, CDHISEST, INDCALEM, INDCALCC, CDTRSCYB, INMONPLD, CDGRPHIS, INESTOURA_CONTA, IDMONPLD, INDUTBLQ, INPERDES, INDEBPRJ, INTRANSF_CRED_PREJUIZO, INDCALDS, CDHISREC, CDESTSIG, INDLCMEP)
      values (3244, 'EST.TRF INTER', 1, 'C', 0, 2, 0.0000, 0, 0, 1, 0, 20, 'ESTORNO DE TRANSFERENCIA INTERCOOPERATIVA', 5210, 1111, 4112, 0, 2, 'CRAPLCM', 0, 0, 0, 0, 1, 2, rw_crapcop.cdcooper, 0, 0, 0, 'ESTORNO TRANSF INTER', 0, 'N', 'N', ' ', 0, 0, 0, 0, 'S', 0, 0, 1, 'N', null, null, 0);
  
      insert into craphis (CDHISTOR, DSHISTOR, INHISTOR, INDEBCRE, TPLOTMOV, INDOIPMF, TXDOIPMF, INAUTORI, INAVISAR, INDEBCTA, INDEBFOL, INCLASSE, DSEXTHST, CDHSTCTB, NRCTADEB, NRCTACRD, TPCTBCCU, TPCTBCXA, NMESTRUT, INCREMES, NRCTATRD, NRCTATRC, INDCOMPL, INGERDEB, INGERCRE, CDCOOPER, FLGSENHA, CDPRODUT, CDAGRUPA, DSEXTRAT, CDHISEST, INDCALEM, INDCALCC, CDTRSCYB, INMONPLD, CDGRPHIS, INESTOURA_CONTA, IDMONPLD, INDUTBLQ, INPERDES, INDEBPRJ, INTRANSF_CRED_PREJUIZO, INDCALDS, CDHISREC, CDESTSIG, INDLCMEP)
      values (3245, 'EST AILOS PAG', 1, 'C', 0, 2, 0.0000, 0, 0, 0, 0, 20, 'ESTORNO PAGAMENTO AILOS PAG', 5210, 4957, 4112, 0, 0, 'CRAPLCM', 0, 0, 0, 0, 1, 2, rw_crapcop.cdcooper, 0, 0, 0, 'ESTORNO AILOS PAG', 0, 'N', 'N', ' ', 0, 0, 0, 0, 'S', 0, 0, 1, 'N', null, null, 0);
  
      insert into craphis (CDHISTOR, DSHISTOR, INHISTOR, INDEBCRE, TPLOTMOV, INDOIPMF, TXDOIPMF, INAUTORI, INAVISAR, INDEBCTA, INDEBFOL, INCLASSE, DSEXTHST, CDHSTCTB, NRCTADEB, NRCTACRD, TPCTBCCU, TPCTBCXA, NMESTRUT, INCREMES, NRCTATRD, NRCTATRC, INDCOMPL, INGERDEB, INGERCRE, CDCOOPER, FLGSENHA, CDPRODUT, CDAGRUPA, DSEXTRAT, CDHISEST, INDCALEM, INDCALCC, CDTRSCYB, INMONPLD, CDGRPHIS, INESTOURA_CONTA, IDMONPLD, INDUTBLQ, INPERDES, INDEBPRJ, INTRANSF_CRED_PREJUIZO, INDCALDS, CDHISREC, CDESTSIG, INDLCMEP)
      values (3247, 'EST AILOS PAG', 1, 'C', 0, 2, 0.0000, 0, 0, 1, 0, 20, 'ESTORNO PAGAMENTO AILOS PAG INTERCOOPERATIVA', 5210, 1111, 4112, 0, 2, 'CRAPLCM', 0, 0, 0, 0, 1, 2, rw_crapcop.cdcooper, 0, 0, 0, 'EST. AILOS PAG INTER', 0, 'N', 'N', ' ', 0, 0, 0, 0, 'S', 0, 0, 1, 'N', null, null, 0);
  
    end loop;

  end if;*/

  /* Dados da automatizacao de msgs */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados da automatizacao de msgs', pr_idprglog => vr_idprglog);
  --
  insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
  values ((select max(cdmensagem) +1 from tbgen_notif_msg_cadastro), 5, 'Transferência não efetivada', 'Transferência: Sua transfêrencia não foi efetivada. Clique e saiba mais.', 
'<p>#nomecompleto</p>

<p>Por motivos de seguran&ccedil;a, a Transfer&ecirc;ncia no valor R$#valor n&atilde;o foi efetivada, os valores ser&atilde;o restitu&iacute;dos em sua conta.</p>

<p>Nossa equipe de seguran&ccedil;a entrar&aacute; em contato com voc&ecirc;.</p>

<p>Agradecemos a compreens&atilde;o.</p>', 
  
  14, 0, null, 0, null, 0, null, null, null, 1) returning cdmensagem into vr_cdmensagem;
  --
  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (5, 8, 'Transferência - Transferência Estornada 1', vr_cdmensagem, '<br/>#valor - Valor da Transferência (Ex: 2.000,00) ', 1, 0, null, null, null, null, null, null, null);
  --
  insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
  values ((select max(cdmensagem) +1 from tbgen_notif_msg_cadastro), 5, 'Transferência não efetivada', 'Transferência: Sua transfêrencia não foi efetivada. Clique e saiba mais.', 

'<p>#nomecompleto</p>

<p>Por motivos de seguran&ccedil;a, a Transfer&ecirc;ncia no valor R$#valor n&atilde;o foi efetivada, os valores ser&atilde;o restitu&iacute;dos em sua conta.</p>

<p>Nossa equipe de seguran&ccedil;a entrar&aacute; em contato com voc&ecirc;.</p>

<p>Agradecemos a compreens&atilde;o.</p>', 
  
  14, 0, null, 0, null, 0, null, null, null, 1) returning cdmensagem into vr_cdmensagem;
  -- 
  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (5, 9, 'Transferência - Transferência Estornada 2', vr_cdmensagem, '<br/>#valor - Valor da TED (Ex: 2.000,00)', 1, 0, null, null, null, null, null, null, null);

  /* Dados de parametrizacao */
  cecred.pc_log_programa(pr_dstiplog => 'O', pr_cdprograma => vr_cdprogra, pr_cdcooper => 0, pr_dsmensagem => 'Dados de parametrizacao', pr_idprglog => vr_idprglog);
  --
  update tbgen_analise_fraude_param set vlcorte_envio_ofsaa = 1000 where cdoperacao > 12;
  --
  update crapaca c
     set c.lstparam = c.lstparam||',pr_vlcorteofs'
   where c.nmdeacao = 'CADFRA_GRAVA';
  --
  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ((SELECT MAX(NRSEQACA)+1 FROM CRAPACA), 'CONSULTA_PARMON_OFS', 'TELA_PARMON', 'pc_consultar_parmon_ofs', 'pr_cdcoptel', 1024);
  --
  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ((SELECT MAX(NRSEQACA)+1 FROM CRAPACA), 'ALTERA_PARMON_OFS', 'TELA_PARMON', 'pc_alterar_parmon_ofs', 'pr_cdcoptel,pr_vlflgtri,pr_vlflgico,pr_vlflgaip,pr_inflgtri,pr_inflgico,pr_inflgaip', 1024); 

  -- Gera log no início da execução
  cecred.pc_log_programa(pr_dstiplog   => 'F'         
                        ,pr_cdprograma => vr_cdprogra 
                        ,pr_cdcooper   => 0
                        ,pr_tpexecucao => 0     
                        ,pr_flgsucesso => 1     
                        ,pr_idprglog   => vr_idprglog);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN

    ROLLBACK;

    -- Gera ocorrencia
    cecred.pc_log_programa(pr_dstiplog   => 'O'
                          ,pr_cdprograma => vr_cdprogra
                          ,pr_cdcooper   => 0
                          ,pr_dsmensagem => 'Erro nao tratado: '||SQLERRM
                          ,pr_idprglog   => vr_idprglog);

    -- Gera log no início da execução
    cecred.pc_log_programa(pr_dstiplog   => 'F'         
                          ,pr_cdprograma => vr_cdprogra 
                          ,pr_cdcooper   => 0
                          ,pr_tpexecucao => 0     
                          ,pr_flgsucesso => 0     
                          ,pr_idprglog   => vr_idprglog);

END;