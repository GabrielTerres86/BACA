

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'AUTBUR_SCRIPT_SFTP_PORTA', 'Script para envio e recebimento dos arquivos via SFTP informando porta', '/usr/local/bin/exec_comando_oracle.sh perl_remoto /usr/local/cecred/bin/sftp_envia_recebe_porta.pl');

insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
values ('CRED', 0, 'SFTP_PORTA_BOAVISTA', 'Porta do ftp do BOA VISTA', '9022');

COMMIT;

insert into crappbc (IDTPREME, FLGATIVO, DSFNCHRM, FLREMSEQ, IDTPENVI, DSDIRENV, DSFNBURM, DSSITFTP, DSUSRFTP, DSPWDFTP, DSDREFTP, DSDRENCD, DSDREVCD, DSFNRNEN, IDTPRETO, IDOPRETO, QTHORRET, DSDRRFTP, DSDRRECD, DSDRRTCD, DSDIRRET, DSFNBURT, DSFNRNDV, DSFNCHRT, QTINTERR, IDTPSOLI, IDENVSEG)
values ('BOAVISTA', 1, 'cybe0002.fn_chvrem_serasa', 1, 'F', '/micros/cecred/cyber/boavista/envia', 'cybe0002.fn_chbusca_ppware', 'ts.bvsnet.com.br', 'ailos', 'Central2020.', 'negativacao/remessa', null, null, null, null, 'M', 1, 'negativacao/retorno', null, null, '/micros/cecred/cyber/boavista/recebe', 'cybe0002.fn_nmarquiv_ret', null, null, null, 'A', 'S');

COMMIT;


