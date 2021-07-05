declare 
  -- Local variables here
  V_CODIGO TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  
begin
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
    ,'Seu agendamento Pix está próximo'
    ,'Você tem agendamentos Pix programados para o dia #dataagendamento, mediante saldo em conta corrente'
    ,'<br>Você tem agendamentos Pix programados para o dia #dataagendamento.<br><br> Lembre-se que o pagamento só será realizado mediante saldo em sua conta corrente.' 
    ,16
    ,0
    ,1
    ,1024 --Ver agendamentos
    ,1
    ,'Ver agendamentos'
    ,'Ver agendamentos');

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
    ,24
    ,'PIX - Seu agendamento Pix está próximo'
    ,(V_CODIGO + 1)
    ,'<br>Você tem agendamentos Pix programados para o dia #dataagendamento.<br><br> Lembre-se que o pagamento só será realizado mediante saldo em sua conta corrente.' 
    ,1
    ,0);

COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;