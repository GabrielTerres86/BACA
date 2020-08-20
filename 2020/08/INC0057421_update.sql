//INC0057421
//NOTIFICAÇÃO PÓS FIXADO
//Daniel Filomena (AMcom) 11/08/2020
//Realizado alterações de mensagem, pois as mesmas estavam conflitrando com outrao Squad.


UPDATE 
       TBGEN_NOTIF_MSG_CADASTRO 
SET 
       DSTITULO_MENSAGEM = 'NOVA SITUAÇÃO DE PROPOSTA - ANÁLISE FINALIZADA',
       DSTEXTO_MENSAGEM = 'Sua solicitação teve a análise de crédito finalizada.',
       DSHTML_MENSAGEM = '<p><b>#nomecompleto</b></p>
<p>A análise de crédito da sua proposta no valor de <b>R$ #valor</b> foi finalizada.</p>
<p>Compareça ao posto de atendimento para maiores informações.</p>'
WHERE
       CDORIGEM_MENSAGEM = 8
       AND CDMENSAGEM = 1408;                                      
    
COMMIT;

UPDATE 
       TBGEN_NOTIF_AUTOMATICA_PRM
SET
       CDMENSAGEM = 1408,
       DSMOTIVO_MENSAGEM = 'NOVA SITUAÇÃO DE PROPOSTA - ANÁLISE FINALIZADA',
       DSVARIAVEIS_MENSAGEM = 'Notificação de Análise Finalizada',
       INMENSAGEM_ATIVA = 1,
       INTIPO_REPETICAO = 0,
       NRDIAS_MES = NULL,
       NRMESES_REPETICAO = NULL                 
 WHERE 
       CDORIGEM_MENSAGEM = 8
       AND CDMOTIVO_MENSAGEM = 22
       
COMMIT;
