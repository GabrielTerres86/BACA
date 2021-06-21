declare 
  -- Local variables here
  V_CODIGO TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  V_CODIGOMENSAGEM TBGEN_NOTIF_AUTOMATICA_PRM.CDMOTIVO_MENSAGEM%TYPE;
  
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
    ,'Seu recebimento Pix foi tarifado.'
    ,'Seu recebimento Pix no valor de #valorPix teve uma tarifa. saiba mais'
    ,'#nomeresumido,</br></br>O Pix que você recebeu hoje no valor de #valorPix teve uma tarifa no valor de #valorTarifa. </br> Para saber mais sobre a tarifa do Pix. clique aqui ou acesse o site da sua cooperativa </br> Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200)</br></br>' 
    ,16
    ,0
    ,1
    ,1009
    ,0
    ,''
    ,'');
  

  SELECT MAX(CDMOTIVO_MENSAGEM)
    INTO V_CODIGOMENSAGEM
    FROM TBGEN_NOTIF_AUTOMATICA_PRM;

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
    ,(V_CODIGOMENSAGEM + 1)
    ,'PIX - Recebimento de tarifa Pix'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)'
    ,1
    ,0);
                                           
               
COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;
