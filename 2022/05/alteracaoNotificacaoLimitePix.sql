DECLARE
BEGIN
    UPDATE TBGEN_NOTIF_AUTOMATICA_PRM
    SET DSVARIAVEIS_MENSAGEM='<br>#nomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite por transação do período diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do período noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteNoturno - Valor do novo limite por transação do período noturno (Ex.: 1000,00)'
    WHERE CDORIGEM_MENSAGEM=13 AND CDMOTIVO_MENSAGEM=44;
    UPDATE TBGEN_NOTIF_AUTOMATICA_PRM
    SET DSVARIAVEIS_MENSAGEM='<br>#nomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite por transação do período diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do período noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteNoturno - Valor do novo limite por transação do período noturno (Ex.: 1000,00)'
    WHERE CDORIGEM_MENSAGEM=13 AND CDMOTIVO_MENSAGEM=45;
    UPDATE TBGEN_NOTIF_AUTOMATICA_PRM
    SET DSVARIAVEIS_MENSAGEM='<br>#nomeCooperado - Nome do cooperado<br>#NomeContaCadastrada - Nome do beneficiario da conta cadastrada<br>#BancoContaCadastrada - Código e descrição do banco da conta cadastrada<br>#AgenciaContaCadastrada - Agencia da conta cadastrada<br>#NumeroContaCadastrada - Número da conta cadastrada<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite por transação do período diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do período noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteNoturno - Valor do novo limite por transação do período noturno (Ex.: 1000,00)'
    WHERE CDORIGEM_MENSAGEM=13 AND CDMOTIVO_MENSAGEM=46;
COMMIT;
END;