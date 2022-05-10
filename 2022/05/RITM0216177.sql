DECLARE
BEGIN
UPDATE CECRED.crapprm
   SET DSVLRPRM = 85
 WHERE nmsistem = 'CRED'
   AND cdcooper = 0
   AND cdacesso = 'PERC_ALTO_FRAUDE_ADM_P';
COMMIT;
END;
/