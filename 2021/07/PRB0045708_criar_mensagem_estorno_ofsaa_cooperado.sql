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
    ,INENVIAR_PUSH )
  VALUES
    ((V_CODIGO + 1)
    ,13
    ,'PIX - Pagamento Pix: OFSAA (cancelado cooperado)'
    ,'O valor foi estornado para a sua conta. Saiba Mais.'
    ,'Abortamos o processo de análise da sua operação realizada via Pix.</br></br>A sua solicitação de cancelamento foi atendida.</br></br>Valor: #valorpix </br>Beneficiário: #beneficiario </br>Instituição: #instituicao </br></br><b>O valor foi estornado e está disponível em sua conta corrente.</b></br></br>Em caso de dúvidas, entre em contato com a Cooperativa.</br></br>'
    ,16
    ,0
    ,0
    ,1);

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
    ,19
    ,'PIX - Pagamento Pix: OFSAA (cancelamento cooperado)'
    ,(V_CODIGO + 1)
    ,'</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#instituicao - PSP do beneficiário</br>#beneficiario - Nome do beneficiário.'
    ,1
    ,0);
  
               
COMMIT;

  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;