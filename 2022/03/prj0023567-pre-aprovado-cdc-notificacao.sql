DECLARE
  vr_max_prod NUMBER(5);
  vr_max_orig_mensagem NUMBER(5);
  vr_max_cdmensagem NUMBER := 0; 
    
  vr_dstitulo_mensagem VARCHAR2(100):= 'Crédito Aprovado para você!';
  vr_dstexto_mensagem VARCHAR2(100):= 'Disponível para você contratar agora mesmo.';
  vr_dshtml_mensagem VARCHAR2(1000):= '<p>Olá #nomeresumido,</p>
<p>Temos disponível um crédito de R$ <strong>#valordisponivelcdc</strong> para você utilizar em lojas parceiras do Sistema Ailos.</p>
<p>A contratação do crédito é feita diretamente na loja e há diversas oportunidades esperando por você.</p>'; 

BEGIN
  INSERT INTO tbgen_notif_msg_origem
    (cdorigem_mensagem,
     dsorigem_mensagem,
     cdtipo_mensagem,
     hrinicio_push,
     hrfim_push,
     hrtempo_validade_push)
    SELECT (SELECT MAX(notf.cdorigem_mensagem)
              FROM tbgen_notif_msg_origem notf) + 1 cdori,
           'Limite de Crédito Pré-aprovado CDC',
           ori.cdtipo_mensagem,
           ori.hrinicio_push,
           ori.hrfim_push,
           ori.hrtempo_validade_push
      FROM tbgen_notif_msg_origem ori
     WHERE ori.cdorigem_mensagem = 2;

  SELECT MAX(cdmensagem) + 1 INTO vr_max_cdmensagem FROM tbgen_notif_msg_cadastro;
  SELECT MAX(cdorigem_mensagem) + 1 INTO vr_max_orig_mensagem FROM tbgen_notif_automatica_prm;
  
  insert into tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, nmimagem_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dslink_acao_mobile, dsmensagem_acao_mobile, dsparam_acao_mobile, inenviar_push)
  values (vr_max_cdmensagem, vr_max_orig_mensagem, vr_dstitulo_mensagem, vr_dstexto_mensagem, vr_dshtml_mensagem, 7, 0, null, 0, null, 0, null, null, null, 1);
  

  SELECT MAX(cdproduto) + 1 INTO vr_max_prod FROM tbcc_produto;
  INSERT INTO tbcc_produto (cdproduto, dsproduto, idfaixa_valor) VALUES (vr_max_prod, 'LIMITE CREDITO PRE-APROVADO CDC', 0);

  INSERT INTO tbcc_operacoes_produto (CDPRODUTO, CDOPERAC_PRODUTO, DSOPERAC_PRODUTO, TPCONTROLE)
  VALUES (vr_max_prod, 1, 'Limite Credito Pre-Aprovado Liberado CDC', '2');
  
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
    (vr_max_orig_mensagem,
     28,
     'Oferta de Limite de Crédito Pré-aprovado CDC',
     7070,
     '<br/>#valordisponivelcdc - Valor disponível ao cooperado (Ex.: 3.500,00)',
     1,
     2,
     NULL,
     NULL,
     15,
     '1,2,3,4,5,6,7,8,9,10,11,12',
     32400,
     'credito.obterConsultaContasPreAprvCdc',
     SYSDATE);    

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
