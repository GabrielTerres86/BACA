DELETE crapris ris
 WHERE ris.cdcooper = 1
   AND ris.inddocto = 2
   AND ris.dtrefere = '28/02/2019'
;
UPDATE crapris ris
   SET ris.flgindiv = 0
 WHERE ris.cdcooper = 1
   AND ris.dtrefere = '28/02/2019'

COMMIT;

UPDATE crapprm prm
   SET prm.dsvlrprm = prm.dsvlrprm || ';1402;2162;2425;2648'
 WHERE nmsistem = 'CRED' 
   AND cdcooper = 0 
   AND cdacesso = 'HISTOR_PREJ_N_SALDO';

COMMIT;