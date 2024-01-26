DECLARE
    V_CODIGO TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
BEGIN
    SELECT MAX(CDMENSAGEM) INTO V_CODIGO FROM CECRED.TBGEN_NOTIF_MSG_CADASTRO;
  
    INSERT INTO CECRED.TBGEN_NOTIF_MSG_CADASTRO (
    CDMENSAGEM, 
    CDORIGEM_MENSAGEM, 
    DSTITULO_MENSAGEM, 
    DSTEXTO_MENSAGEM, 
    DSHTML_MENSAGEM, 
    CDICONE, 
    INEXIBIR_BANNER, 
    NMIMAGEM_BANNER, 
    INEXIBE_BOTAO_ACAO_MOBILE, 
    DSTEXTO_BOTAO_ACAO_MOBILE, 
    CDMENU_ACAO_MOBILE, 
    DSLINK_ACAO_MOBILE, 
    DSMENSAGEM_ACAO_MOBILE, 
    DSPARAM_ACAO_MOBILE, 
    INENVIAR_PUSH)
    VALUES (
    (V_CODIGO + 1), 
    13, 
    'Seu Pix não foi concluído', 
    'Você tentou enviar um Pix de R$ #ValorPix mas a transação não foi concluída.', 
    'Cooperado, <br><br>Você tentou enviar um Pix, mas a transação não foi concluída.<br><br>Recebedor: #NomeRecebedor <br>CPF/CNPJ: #DocumentoRecebedor<br>Valor do pagamento: #ValorPix <br>Instituição: #Instituicao <br> Identificação: #Identificacao <br>Data/Hora Transacão: #datahoratransacao <br>Descrição: #Descricao <br><br>Confira o extrato da sua conta e refaça a transação se desejar.', 
    16, 
    0, 
    null, 
    1, 
    'Fazer um novo Pix',
    1011, 
    null, 
    'Fazer um novo Pix',
    null, 
    1);

    INSERT INTO CECRED.TBGEN_NOTIF_AUTOMATICA_PRM (
    CDORIGEM_MENSAGEM, 
    CDMOTIVO_MENSAGEM, 
    DSMOTIVO_MENSAGEM, 
    CDMENSAGEM, 
    DSVARIAVEIS_MENSAGEM, 
    INMENSAGEM_ATIVA, 
    INTIPO_REPETICAO, 
    NRDIAS_SEMANA, 
    NRSEMANAS_REPETICAO, 
    NRDIAS_MES, 
    NRMESES_REPETICAO, 
    HRENVIO_MENSAGEM, 
    NMFUNCAO_CONTAS, 
    DHULTIMA_EXECUCAO)
    VALUES (
    13, 
    62, 
    'PIX - Seu Pix não foi concluído', 
    (V_CODIGO + 1), 
    '<br>#NomeRecebedor - Nome do Recebedor<br>#DocumentoRecebedor - CPF/CNPJ<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#Instituicao - Nome da Instituição<br>#Identificacao - Identificação do Pix<br>#datahoratransacao - Data/Hora Transacão<br>#Descricao - Descrição do Pagamento', 
    1, 
    0, 
    null, 
    null, 
    null, 
    null, 
    null, 
    null, 
    null);
  
    COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN 
       dbms_output.put_line('Erro: ' || SQLERRM);
       
end;