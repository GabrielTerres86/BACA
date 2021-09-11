declare 
  -- Local variables here
  V_CODIGO TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  
begin

SELECT MAX(CDMENSAGEM)
    INTO V_CODIGO
    FROM TBGEN_NOTIF_MSG_CADASTRO;
	
INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,INEXIBE_BOTAO_ACAO_MOBILE  
    ,CDMENU_ACAO_MOBILE 
    ,INENVIAR_PUSH
    ,DSMENSAGEM_ACAO_MOBILE
    ,Dstexto_Botao_Acao_Mobile )
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'Pagamento agendado Pix não realizado'
    ,'O pagamento no valor de #valorpix que estava agendado para hoje não foi realizado'
    ,'#nomeresumido, <br><br> Infelizmente, seu pagamento Pix que estava agendado para hoje não foi realizado. <br><br> Valor: #valorpix <br> Beneficiário: #beneficiario <br> Motivo: #motivo <br><br> Para mais informações, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).'
    ,16
    ,0
    ,1
    ,1024 --agendamentos Pix
    ,1
    ,'Ver agendamentos Pix'
    ,'Ver agendamentos Pix');

  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO)
  VALUES
    (13
    ,25
    ,'PIX - Pagamento agendado Pix não realizado'
    ,(V_CODIGO + 1)
    ,'#nomeresumido, <br><br> Infelizmente, seu pagamento Pix que estava agendado para hoje não foi realizado. <br><br> Valor: #valorpix <br> Beneficiário: #beneficiario <br> Motivo: #motivo <br><br>  Para mais informações, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).'
    ,1
    ,0);

COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;