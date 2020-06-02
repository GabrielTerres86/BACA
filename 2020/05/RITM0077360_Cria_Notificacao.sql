/*
RITM0077360
Criação de registros de notificação para atender ao projeto PRJTASK0039640 - Acompanhar status das propostas de crédito presenciais nos canais digitais
Edmar Soares de Oliveira - 28/05/2020
*/


DECLARE

  vr_cdmsgpag NUMBER := 0; 
  pr_CDMOTIVO_MENSAGEM NUMBER:= 0;
  pr_CDORIGEM_MENSAGEM NUMBER:= 8; 

    
  pr_DSTITULO_MENSAGEM VARCHAR2(100):= 'NOVA SITUAÇÃO DE PROPOSTA - ANÁLISE FINALIZADA';
  pr_DSTEXTO_MENSAGEM VARCHAR2(100):= 'Sua solicitação teve a análise de crédito finalizada.';
  pr_DSHTML_MENSAGEM VARCHAR2(1000):= '<p><b>#nomecompleto</b></p>
  <p>A análise de crédito da sua proposta no valor de <b>R$ #valor</b> foi finalizada.</p>
  <p>Compareça ao posto de atendimento para maiores informações.</p>'; 

BEGIN

  -- PROPOSTA COM ANÁLISE FINALIZADA

  SELECT MAX(CDMENSAGEM)+1 INTO vr_cdmsgpag FROM tbgen_notif_msg_cadastro;
  select max(CDMOTIVO_MENSAGEM) +1 INTO pr_CDMOTIVO_MENSAGEM from tbgen_notif_automatica_prm where CDORIGEM_MENSAGEM = pr_CDORIGEM_MENSAGEM;

  insert into tbgen_notif_msg_cadastro (CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, NMIMAGEM_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, DSTEXTO_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, DSLINK_ACAO_MOBILE, DSMENSAGEM_ACAO_MOBILE, DSPARAM_ACAO_MOBILE, INENVIAR_PUSH)
  values (vr_cdmsgpag, pr_CDORIGEM_MENSAGEM, pr_DSTITULO_MENSAGEM, pr_DSTEXTO_MENSAGEM, pr_DSHTML_MENSAGEM, 7, 0, null, 0, null, 0, null, null, null, 1);
  
  insert into tbgen_notif_automatica_prm (CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO, NRDIAS_SEMANA, NRSEMANAS_REPETICAO, NRDIAS_MES, NRMESES_REPETICAO, HRENVIO_MENSAGEM, NMFUNCAO_CONTAS, DHULTIMA_EXECUCAO)
  values (pr_CDORIGEM_MENSAGEM, pr_CDMOTIVO_MENSAGEM, pr_DSTITULO_MENSAGEM, vr_cdmsgpag, 'Notificação de Análise Finalizada', 1, 0, null, null, null, null, null, null, null);

  COMMIT;

END;
