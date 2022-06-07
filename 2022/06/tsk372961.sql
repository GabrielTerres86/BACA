DECLARE
BEGIN

update tbgen_notif_msg_cadastro
set DSHTML_MENSAGEM = '#nomeCooperado, <br><br>O aumento de limite máximo do Pix que você solicitou foi realizado com sucesso. <br><br>Novo limite máximo: R$#novoLimite. <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.' 
where cdorigem_mensagem = 13
and CDMENSAGEM = 8550
and dstitulo_mensagem = 'Aumento de limite máximo do Pix';

update tbgen_notif_msg_cadastro
set DSHTML_MENSAGEM = '#nomeCooperado, <br><br>A alteração de horário do período noturno que você solicitou foi realizada com sucesso. <br><br>Novo horário do período noturno: <br><br>Início: #horarioInicio <br>Fim: #horarioFim <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.' 
where cdorigem_mensagem = 13
and CDMENSAGEM = 8552
and dstitulo_mensagem = 'Efetivação de novo horário noturno';

update tbgen_notif_msg_cadastro
set DSHTML_MENSAGEM = '#nomeCooperado, <br><br>O cadastro da conta que você solicitou foi realizado com sucesso. Você já pode gerenciar de forma personalizada os limites Pix dessa conta. <br><br>Dados da Conta: <br><br>Nome: #nomeContaCadastrada <br>Banco: #bancoContaCadastrada <br>Agência: #agenciaContaCadastrada <br>Conta: #numeroContaCadastrada <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.' 
where cdorigem_mensagem = 13
and CDMENSAGEM = 8551
and dstitulo_mensagem = 'Efetivação de uma conta cadastrada';

commit;
end;
