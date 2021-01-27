insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_TIVIT_CONNECT_ENV', 'Diretório onde arquivos de remessa serão postados para enviar para TIVIT via Connect Direct', '/usr/connect/tivit/envia/');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_TIVIT_CONNECT_REC', 'Diretório onde arquivos de retorno serão postados pela TIVIT via Connect Direct', '/usr/connect/tivit/recebe/');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_TIVIT_CONNECT_RECBS', 'Diretório onde arquivos de retorno postados pela TIVIT via Connect Direct serão salvos', '/usr/connect/tivit/recebidos/');
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SITUACAO_TIVIT', 'Indicador da situação da integração com TIVIT (0-Inativo / 1-Ativo)', '1');
commit;
