BEGIN
  UPDATE crawcrd
     SET nrcrcard = 0
        ,nrcctitg = 0
        ,insitcrd = 6
   WHERE cdcooper = 1
     AND nrdconta = 11387181;
  COMMIT;   
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro na alteração => '||SQLERRM(SQLCODE));
END;