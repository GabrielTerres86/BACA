DECLARE
  pr_cdcooper crapcop.cdcooper%TYPE := 8;
  pr_dtmvtolt crapdat.dtmvtolt%TYPE := to_date('17/08/2021');
BEGIN
  DELETE FROM crapris t
   WHERE t.cdcooper = pr_cdcooper
     AND t.dtrefere >= pr_dtmvtolt;
     
  DELETE FROM crapvri t
   WHERE t.cdcooper = pr_cdcooper
     AND t.dtrefere >= pr_dtmvtolt;
     
  DELETE FROM crapsda t
   WHERE t.cdcooper = pr_cdcooper
     AND t.dtmvtolt >= pr_dtmvtolt;
     
  DELETE FROM tbgen_batch_controle t
   WHERE t.cdcooper = pr_cdcooper
     AND t.dtmvtolt >= pr_dtmvtolt;
     
  COMMIT;
END;