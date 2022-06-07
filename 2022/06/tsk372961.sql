DECLARE
BEGIN

update tbgen_notif_msg_cadastro
set DSHTML_MENSAGEM = '#nomeCooperado, <br><br>O aumento de limite m�ximo do Pix que voc� solicitou foi realizado com sucesso. <br><br>Novo limite m�ximo: R$#novoLimite. <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.' 
where cdorigem_mensagem = 13
and CDMENSAGEM = 8550
and dstitulo_mensagem = 'Aumento de limite m�ximo do Pix';

update tbgen_notif_msg_cadastro
set DSHTML_MENSAGEM = '#nomeCooperado, <br><br>A altera��o de hor�rio do per�odo noturno que voc� solicitou foi realizada com sucesso. <br><br>Novo hor�rio do per�odo noturno: <br><br>In�cio: #horarioInicio <br>Fim: #horarioFim <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.' 
where cdorigem_mensagem = 13
and CDMENSAGEM = 8552
and dstitulo_mensagem = 'Efetiva��o de novo hor�rio noturno';

update tbgen_notif_msg_cadastro
set DSHTML_MENSAGEM = '#nomeCooperado, <br><br>O cadastro da conta que voc� solicitou foi realizado com sucesso. Voc� j� pode gerenciar de forma personalizada os limites Pix dessa conta. <br><br>Dados da Conta: <br><br>Nome: #nomeContaCadastrada <br>Banco: #bancoContaCadastrada <br>Ag�ncia: #agenciaContaCadastrada <br>Conta: #numeroContaCadastrada <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.' 
where cdorigem_mensagem = 13
and CDMENSAGEM = 8551
and dstitulo_mensagem = 'Efetiva��o de uma conta cadastrada';

commit;
end;
