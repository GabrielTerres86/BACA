/***** Atualização SFTP para empresa IGB *****/

UPDATE crapprm
   SET dsvlrprm = 'igb.com.br'
 WHERE cdacesso = 'RRD_SERV_SFTP';

UPDATE crapprm
   SET dsvlrprm = 'ailos-sftp'
 WHERE cdacesso = 'RRD_USER_FTP';

UPDATE crapprm
   SET dsvlrprm = 'omInUHlc4spYedy'
 WHERE cdacesso = 'RRD_PASS_FTP';

UPDATE crapprm
   SET dsvlrprm = '/ailos-sftp'
 WHERE cdacesso = 'RRD_DIR_UPLOAD';

UPDATE crapprm
   SET dsvlrprm = '/usr/local/cecred/bin/sftp_envia_recebe_115.pl'
 WHERE cdacesso = 'RRD_SCRIPT';


COMMIT;


