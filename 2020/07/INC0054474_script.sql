--INC0054474
--Alguns cooperados est�o recebendo o push de aprova��o da proposta do CDC com a mensagem incorreta, conforme anexo.
--Exemplo proposta 15233137 Viacredi.

DECLARE
      V_CODIGO NUMBER;
BEGIN

-- Realiza Altera��o de mensagem, pois a mesma est� incorreta em produ��o;      
UPDATE
  TBGEN_NOTIF_AUTOMATICA_PRM 
SET 
  DSMOTIVO_MENSAGEM = 'PROPOSTA AGUARDANDO ASSINATURA DIGITAL', 
  DSVARIAVEIS_MENSAGEM = 'Notifica��o de Proposta Aguardando assinatura digital'
WHERE 
  CDORIGEM_MENSAGEM = 8 
  AND CDMOTIVO_MENSAGEM = 22 
  AND CDMENSAGEM = 1408;
COMMIT;

-- Realiza Altera��o de mensagem, pois a mesma est� incorreta em produ��o;      
UPDATE 
      TBGEN_NOTIF_MSG_CADASTRO 
SET 
      DSTITULO_MENSAGEM = 'PROPOSTA AGUARDANDO ASSINATURA DIGITAL',
      DSTEXTO_MENSAGEM = 'Proposta est� dispon�vel para sua confer�ncia, contrate digitando a sua senha.',
      DSHTML_MENSAGEM = 'Cooperado,</br></br>Proposta est� dispon�vel para sua confer�ncia, contrate digitando a sua senha.  </br></br>'
WHERE
      CDORIGEM_MENSAGEM = 8
      AND CDMENSAGEM = 1408;    

COMMIT;

-- Realiza a Inclus�o de Mensagem 23 - Proposta Pendente que n�o existe em produ��o;
SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
   
INSERT INTO TBGEN_NOTIF_MSG_CADASTRO(CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, INENVIAR_PUSH)
VALUES((V_CODIGO + 1), 8, 'PROPOSTA PENDENTE', 'Existe alguma pend�ncia que precisa ser ajustada para concluir o processo. Verifique com a loja ou com seu Posto de Atendimento.', 'Cooperado,</br></br>Existe alguma pend�ncia que precisa ser ajustada para concluir o processo. Verifique com a loja ou com seu Posto de Atendimento. </br></br>', 7, 0, 0, 0, 1); 
     
INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM(CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO)
VALUES(8, 23, 'PROPOSTA PENDENTE', (V_CODIGO + 1), 'Notifica��o de Proposta Pendente' ,1, 0);

COMMIT;

-- Realiza a Inclus�o de Mensagem 24 - CONTRATO IMPRESSO Que n�o existe em produ��o;
  
SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM TBGEN_NOTIF_MSG_CADASTRO;
   
INSERT INTO TBGEN_NOTIF_MSG_CADASTRO(CDMENSAGEM, CDORIGEM_MENSAGEM, DSTITULO_MENSAGEM, DSTEXTO_MENSAGEM, DSHTML_MENSAGEM, CDICONE, INEXIBIR_BANNER, INEXIBE_BOTAO_ACAO_MOBILE, CDMENU_ACAO_MOBILE, INENVIAR_PUSH)
VALUES((V_CODIGO + 1), 8, 'CONTRATO IMPRESSO', 'Falta Pouco! V� at� a loja para assinar o contrato.', 'Cooperado,</br></br>Falta Pouco! V� at� a loja para assinar o contrato. </br></br>', 7, 0, 0, 0, 1); 
     
INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM(CDORIGEM_MENSAGEM, CDMOTIVO_MENSAGEM, DSMOTIVO_MENSAGEM, CDMENSAGEM, DSVARIAVEIS_MENSAGEM, INMENSAGEM_ATIVA, INTIPO_REPETICAO)
VALUES(8, 24, 'CONTRATO IMPRESSO', (V_CODIGO + 1), 'Notifica��o de Proposta Contrato impresso' ,1, 0);

COMMIT;
END;
