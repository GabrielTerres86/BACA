--Ativar monitoramento JD Express
DECLARE
BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = 1
   WHERE p.progress_recid = 777003;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
