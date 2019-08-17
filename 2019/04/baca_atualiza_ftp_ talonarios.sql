UPDATE crapprm
   SET dsvlrprm = 'ftp.igb.com.br'
 WHERE cdacesso = 'RRD_SERV_SFTP';
UPDATE crapprm
   SET dsvlrprm = 'ailos'
 WHERE cdacesso = 'RRD_USER_FTP';
UPDATE crapprm
   SET dsvlrprm = 'TrA4Uka!=Sp@!I#rAfrl'
 WHERE cdacesso = 'RRD_PASS_FTP';

UPDATE crapprm
   SET dsvlrprm = '/usr/local/cecred/bin/ftp_envia_recebe.pl'
 WHERE cdacesso = 'RRD_SCRIPT';


COMMIT;
