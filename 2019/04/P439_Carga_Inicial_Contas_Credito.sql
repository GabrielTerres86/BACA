UPDATE tbepr_cdc_emprestimo
   SET cdcooper_cred = cdcooper,
       nrdconta_cred = nrdconta
 WHERE cdcooper_cred = 0
   AND nrdconta_cred = 0;

COMMIT;