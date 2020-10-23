insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_TIVIT_CONNECT_ENV', 'Diret�rio onde arquivos de remessa ser�o postados para enviar para TIVIT via Connect Direct', '/usr/connect/tivit/envia/');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_TIVIT_CONNECT_REC', 'Diret�rio onde arquivos de retorno ser�o postados pela TIVIT via Connect Direct', '/usr/connect/tivit/recebe/');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_TIVIT_CONNECT_RECBS', 'Diret�rio onde arquivos de retorno postados pela TIVIT via Connect Direct ser�o salvos', '/usr/connect/tivit/recebidos/');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SITUACAO_TIVIT', 'Indicador da situa��o da integra��o com TIVIT (0-Inativo / 1-Ativo)', '1');
commit;
