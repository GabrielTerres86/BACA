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
    ,'Sua chave Pix foi cancelada'
    ,'Sua chave pix #chave foi cancelada por falta de uso'
    ,'#nomeresumido, <br><br> Sua chave Pix que estava sem utilização foi cancelada.<br><br> Chave: #chave <br><br>Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).' 
    ,16
    ,0
    ,1
    ,1009
    ,1
    ,'Minhas chaves'
    ,'Minhas chaves');

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
    ,31
    ,'PIX - Sua chave Pix foi cancelada'
    ,(V_CODIGO + 1)
    ,'Sua chave pix #chave foi cancelada por falta de uso' 
    ,1
    ,0);

COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;