--Parametro do diretorio onde estara o arquivo retorno da sincronica
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'IMP_ARQ_SINC_DIR', 'Diretorio de retorno arquivo controle de segurança sincronica ', '/usr/sistemas/Sincronica/recebe');
--Parametro do diretorio do conect para envio sincronica
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'IMP_ARQ_ENV_SINC_DIR', 'Diretorio do riversoft para envio sincronica ', '/usr/sistemas/Sincronica/envia');
--Parametro do Nome do servidor FTP ABBC
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'TRAN_BBC_SERV_FTP_CS', 'Nome do servidor FTP da ABBC codigo seguranca', '10.201.53.23');
--Parametro do diretorio de armazenamento dos arquivos logicos e de imagem ABBC 
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_ABBC_FTP_CS', 'Diretorio para recebimento de arquivo ABBC ', 'cecred/salvar');
--Parametro do diretorio do conect para envio sincronica
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'DIR_ABBC_ENV_FTP_CS', 'Diretorio do riversoft para envio de arquivo ABBC ', '/usr/sistemas/Sincronica/envia');
--Parametro Senha do servidor FTP 
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'TRAN_BBC_PASS_FTP_CS', 'Senha do servidor FTP da ABBC codigo seguranca', 'R721!P18');
--Parametro do diretorio de captura do arquivos logico e de imagem ABBC
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'TRAN_BBC_DIR_CS', 'Diretorio do FTP da ABBC codigo seguranca', '/085PSR');
--Parametro para script shell para downloud de arquivo SFTP ABBC'
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'BAIXA_ARQ_SFTP_ABBC', 'Script para download de arquivo SFTP ABBC', '/usr/local/cecred/bin/sftp-conecta.sh');
--Parametro Usuario do servidor FTP  
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'TRAN_BBC_USER_FTP_CS', 'Usuario do servidor FTP da ABBC IMAGEM CHEQUE', '085PSR');
--Parametro Email retorno arquivo sincronica
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'EMAIL_RET_VALID_SINC', 'Email retorno arquivo sincronica com situação de inconsistencia. ', 'compe@ailos.coop.br');
--Parametro diretorio para Backup de arquivos enviados sincronica 
insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'BKP_ARQ_SINC_ENV', 'Diretorio para Backup de arquivos enviados sincronica', 'cecred/salvar');

COMMIT;