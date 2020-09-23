PL/SQL Developer Test script 3.0
157
-- Created on 27/08/2020 by E0030208 
declare 
  -- Local variables here
  V_CODIGO TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
  
begin
  -- Test statements here  
  
--1º -> Inserir novo icone
  INSERT INTO tbgen_notif_icone
    (CDICONE
    ,NMICONE
    ,NMIMAGEM_LIDA
    ,NMIMAGEM_NAOLIDA
    ,NMIMAGEM_IBANK)
  VALUES
    (16
    ,'Pix'
    ,'pix_72_w.png'  
    ,'pix_72.png'   
    ,'mdi-coin');   

--2º > Realiza a inclusão da origem:  Pix - Pagamento Instantâneo   
  INSERT INTO TBGEN_NOTIF_MSG_ORIGEM
    (CDORIGEM_MENSAGEM
    ,DSORIGEM_MENSAGEM
    ,CDTIPO_MENSAGEM
    ,HRINICIO_PUSH
    ,HRFIM_PUSH
    ,HRTEMPO_VALIDADE_PUSH)
  VALUES
    (13
    ,'Pix - Pagamento Instantâneo'
    ,1 --Serviços
    ,0 
    ,86399
    ,86400); 
    
    
--3º > Criar menu no mobile
--Os insert na tabela menumobile foram feitos pelo vinicius, não será necessário eu criar.
 
--1009  Transações -> PIX
--1010  Transações -> PIX -> Cadastramento de chaves
--1011  Transações -> PIX -> Pagamento Pix
--1012  Transações -> PIX -> Recebimento Pix
--1013  Transações -> PIX -> Sobre o Pix
                        
--xxx4.10 > Realiza a Inclus�o de Mensagem 
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
    ,'Sua chave Pix foi cadastrada'
    ,'Sucesso no processo de inclusão. Saiba mais!'
    ,'#nomeresumido,</br></br>Sua chave do Pix #chaveenderecamento foi cadastrada e vinculada à sua conta com sucesso.</br></br>' 
    ,16
    ,0
    ,1
    ,1009 --gerenciamento de chaves
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
    ,10
    ,'PIX - Sucesso no cadastro de chave fora do horário da DICT'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
                                            
--xxx4.11 > Realiza a Inclus�o de Mensagem 
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
    ,'Sua chave Pix não foi cadastrada'
    ,'Ocorreu um erro durante o processo de inclusão. Saiba mais!'
    ,'#nomeresumido,</br></br>A tentativa de inclusão da chave #chaveenderecamento não foi efetivada por estar em processo de #motivo.</br></br>Tente novamente!</br></br>' 
    ,16
    ,0
    ,1
    ,1010 --cadastramento de chaves
    ,1
    ,'Cadastrar chave'
    ,'Cadastrar chave');

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
    ,11
    ,'PIX - Erro no cadastro de chave fora do horário da DICT'
    ,(V_CODIGO + 1)
    ,'</br>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' || 
     '</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)' ||
     '</br>#motivo - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'     
    ,1
    ,0);
               
COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;
0
0
