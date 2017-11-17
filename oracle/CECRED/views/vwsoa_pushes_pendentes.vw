CREATE OR REPLACE VIEW cecred.vwsoa_pushes_pendentes AS
SELECT psh.cdlote_push
      ,psh.cdnotificacao
      ,psh.iddispositivo_mobile
      ,dsp.tokendispositivofcm
      ,msg.dstitulo_mensagem
      ,NOTI0001.fn_substitui_variaveis(ntf.cdcooper, ntf.nrdconta,ntf.idseqttl,msg.dstexto_mensagem,ntf.dsvariaveis) dsmensagem
      ,ntf.dhenvio
      ,1 qtmensagem --Fixo 1, pq o bagde do ícone do Cecred Mobile vai acumular o contador de 1 em 1
      ,24*60*60 tempodevida
      ,1 prioridade
      ,'{"CodigoNotificacao":'|| psh.cdnotificacao ||',' ||
       '"CooperativaId":'|| ntf.cdcooper ||',' ||
       '"NumeroConta":'|| ntf.nrdconta ||',' ||
       '"TitularId":'|| ntf.idseqttl ||'}' parametros
  FROM tbgen_notif_push  psh
      ,dispositivomobile dsp
      ,tbgen_notificacao ntf
      ,tbgen_notif_msg_cadastro msg
 WHERE psh.iddispositivo_mobile = dsp.dispositivomobileid
   AND psh.cdnotificacao = ntf.cdnotificacao
   AND ntf.cdmensagem = msg.cdmensagem
   
   AND psh.insituacao = 1 -- Processando no Aymaru
   
   -- Valida se o dispositivo pode receber o push
   AND dsp.habilitado = 1
   AND dsp.autorizado = 1
   AND dsp.pushhabilitado = 1
   AND dsp.tokendispositivofcm IS NOT NULL
