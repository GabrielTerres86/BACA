BEGIN
  UPDATE CECRED.tbepr_portabilidade
     SET nrunico_portabilidade = '202305220000261263578'
   WHERE cdcooper = 11
         AND nrdconta = 16742974
         AND nrctremp = 344393;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
