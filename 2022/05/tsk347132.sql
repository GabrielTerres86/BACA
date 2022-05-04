DECLARE
BEGIN
UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
set DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que voc� solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Per�odo: R$#LimiteDiurno <br>Transa��o: R$#PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Per�odo: R$#LimiteNoturno <br>Transa��o: R$#PorTransacaoLimiteNoturno <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.'
WHERE CDMENSAGEM = 8547 AND CDORIGEM_MENSAGEM = 13;

UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
set DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix Saque e Pix Troco que voc� solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Per�odo: R$#LimiteDiurno <br>Transa��o: R$#PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Per�odo: R$#limiteNoturno <br>Transa��o: R$#PorTransacaoLimiteNoturno <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.'
WHERE CDMENSAGEM = 8548 AND CDORIGEM_MENSAGEM = 13;

UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
set DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que voc� solicitou foi realizado com sucesso. <br><br>Dados da Conta: <br><br>Nome: #NomeContaCadastrada <br>Banco: #BancoContaCadastrada <br>Ag�ncia: #AgenciaContaCadastrada <br>Conta: #NumeroContaCadastrada <br>Novos limites: <br><br>DIURNO <br>Per�odo: R$#LimiteDiurno <br>Transa��o: R$#PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Per�odo: R$#LimiteNoturno <br>Transa��o: R$#PorTransacaoLimiteNoturno <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.'
WHERE CDMENSAGEM = 8549 AND CDORIGEM_MENSAGEM = 13;

COMMIT;
END;