//INC0057421
//NOTIFICA��O P�S FIXADO
//Daniel Filomena (AMcom) 11/08/2020
//Realizado altera��es de mensagem, pois as mesmas estavam conflitrando com outrao Squad.


UPDATE 
       TBGEN_NOTIF_MSG_CADASTRO 
SET 
       DSTITULO_MENSAGEM = 'NOVA SITUA��O DE PROPOSTA - AN�LISE FINALIZADA',
       DSTEXTO_MENSAGEM = 'Sua solicita��o teve a an�lise de cr�dito finalizada.',
       DSHTML_MENSAGEM = '<p><b>#nomecompleto</b></p>
<p>A an�lise de cr�dito da sua proposta no valor de <b>R$ #valor</b> foi finalizada.</p>
<p>Compare�a ao posto de atendimento para maiores informa��es.</p>'
WHERE
       CDORIGEM_MENSAGEM = 8
       AND CDMENSAGEM = 1408;                                      
    
COMMIT;

UPDATE 
       TBGEN_NOTIF_AUTOMATICA_PRM
SET
       CDMENSAGEM = 1408,
       DSMOTIVO_MENSAGEM = 'NOVA SITUA��O DE PROPOSTA - AN�LISE FINALIZADA',
       DSVARIAVEIS_MENSAGEM = 'Notifica��o de An�lise Finalizada',
       INMENSAGEM_ATIVA = 1,
       INTIPO_REPETICAO = 0,
       NRDIAS_MES = NULL,
       NRMESES_REPETICAO = NULL                 
 WHERE 
       CDORIGEM_MENSAGEM = 8
       AND CDMOTIVO_MENSAGEM = 22
       
COMMIT;
