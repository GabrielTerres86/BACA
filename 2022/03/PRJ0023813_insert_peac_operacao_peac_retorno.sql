BEGIN
insert into credito.tbcred_peac_operacao (IDPEAC_OPERACAO, IDPEAC_CONTRATO, IDSOLICITACAO, DHOPERACAO, TPOPERACAO, CDSTATUS, VLRECUPERACAO, VLAMORTIZACAO)
values (4, 1779, 1, to_date('08-03-2022', 'dd-mm-yyyy'), 1, 'APROVADA', 300.00, 120.00);

insert into credito.tbcred_peac_operacao (IDPEAC_OPERACAO, IDPEAC_CONTRATO, IDSOLICITACAO, DHOPERACAO, TPOPERACAO, CDSTATUS, VLRECUPERACAO, VLAMORTIZACAO)
values (5, 1783, 1, to_date('07-03-2022', 'dd-mm-yyyy'), 2, 'PENDENTE', 350.00, 430.00);

insert into credito.tbcred_peac_operacao (IDPEAC_OPERACAO, IDPEAC_CONTRATO, IDSOLICITACAO, DHOPERACAO, TPOPERACAO, CDSTATUS, VLRECUPERACAO, VLAMORTIZACAO)
values (6, 1796, 1, to_date('20-02-2022', 'dd-mm-yyyy'), 1, 'REJEITADA', 289.00, 703.00);

insert into credito.tbcred_peac_operacao (IDPEAC_OPERACAO, IDPEAC_CONTRATO, IDSOLICITACAO, DHOPERACAO, TPOPERACAO, CDSTATUS, VLRECUPERACAO, VLAMORTIZACAO)
values (7, 1932, 1, to_date('06-03-2022', 'dd-mm-yyyy'), 2, 'APROVADA', 888.00, 968.00);

insert into credito.tbcred_peac_operacao (IDPEAC_OPERACAO, IDPEAC_CONTRATO, IDSOLICITACAO, DHOPERACAO, TPOPERACAO, CDSTATUS, VLRECUPERACAO, VLAMORTIZACAO)
values (8, 1999, 1, to_date('09-03-2022', 'dd-mm-yyyy'), 1, 'PENDENTE', 760.00, 900.00);

insert into credito.tbcred_peac_operacao_retorno (IDPEAC_OPERACAO_RETORNO, IDPEAC_OPERACAO, DSMENSAGEM, DHRETORNO)
values (21, 4, 'teste de erro', to_date('08-03-2022', 'dd-mm-yyyy'));

insert into credito.tbcred_peac_operacao_retorno (IDPEAC_OPERACAO_RETORNO, IDPEAC_OPERACAO, DSMENSAGEM, DHRETORNO)
values (22, 5, 'operacao com erro', to_date('08-03-2022', 'dd-mm-yyyy'));

insert into credito.tbcred_peac_operacao_retorno (IDPEAC_OPERACAO_RETORNO, IDPEAC_OPERACAO, DSMENSAGEM, DHRETORNO)
values (23, 6, 'erro de requisicao', to_date('08-03-2022', 'dd-mm-yyyy'));

insert into credito.tbcred_peac_operacao_retorno (IDPEAC_OPERACAO_RETORNO, IDPEAC_OPERACAO, DSMENSAGEM, DHRETORNO)
values (24, 7, 'falhou', to_date('08-03-2022', 'dd-mm-yyyy'));
COMMIT;
END;
