-- Valor que ser� passado ao parametro pr_tpreme nas chamadas de envio de SMS.
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMS_TPREME_EMPRESTIMO', 'Identifica��o do centro de custo para SMSs enviadas oriundas de Emprestimos e Financiamentos.', 'PRTPREME');

COMMIT;
