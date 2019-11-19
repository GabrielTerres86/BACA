-- Valor que será passado ao parametro pr_tpreme nas chamadas de envio de SMS.
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMS_TPREME_EMPRESTIMO', 'Identificação do centro de custo para SMSs enviadas oriundas de Emprestimos e Financiamentos.', 'SMSCRDEPR');

-- Agregate ID das cooperativas
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_ACENTRA', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58776');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_ACREDICOOP', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58775');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_VIACREDI AV', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58786');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_CIVIA', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58785');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_CREDCREA', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58779');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_CREDELESC', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58780');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_CREDICOMIN', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58782');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_CREDIFOZ', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58783');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_CREVISC', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58784');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_EVOLUA', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58777');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_TRANSPOCRED', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58781');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_UNILOS', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58778');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SMSCRDEPR_VIACREDI', 'Chave do aggregateId para envio de SMS usando SOA e ZENVIA.', '58753');

COMMIT;
