DECLARE
BEGIN
UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
set DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que você solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Período: R$#LimiteDiurno <br>Transação: R$#PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Período: R$#LimiteNoturno <br>Transação: R$#PorTransacaoLimiteNoturno <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.'
WHERE CDMENSAGEM = 8547 AND CDORIGEM_MENSAGEM = 13;

UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
set DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix Saque e Pix Troco que você solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Período: R$#LimiteDiurno <br>Transação: R$#PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Período: R$#LimiteNoturno <br>Transação: R$#PorTransacaoLimiteNoturno <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.'
WHERE CDMENSAGEM = 8548 AND CDORIGEM_MENSAGEM = 13;

UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
set DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que você solicitou foi realizado com sucesso. <br><br>Dados da Conta: <br><br>Nome: #NomeContaCadastrada <br>Banco: #BancoContaCadastrada <br>Agência: #AgenciaContaCadastrada <br>Conta: #NumeroContaCadastrada <br>Novos limites: <br><br>DIURNO <br>Período: R$#LimiteDiurno <br>Transação: R$#PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Período: R$#LimiteNoturno <br>Transação: R$#PorTransacaoLimiteNoturno <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.'
WHERE CDMENSAGEM = 8549 AND CDORIGEM_MENSAGEM = 13;

COMMIT;
END;