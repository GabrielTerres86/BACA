DECLARE
BEGIN
UPDATE CECRED.crapprm
   SET DSVLRPRM = 85
 WHERE nmsistem = 'CRED'
   AND cdcooper = 0
   AND cdacesso = 'PERC_ALTO_FRAUDE_ADM_P';

UPDATE CECRED.crapprm
   SET DSVLRPRM = 't0033471@ailos.coop.br'
 WHERE nmsistem = 'CRED'
   AND cdcooper = 0
   AND cdacesso = 'EMAIL_RISCOFRAUDE_ADM';

COMMIT;
END;
/