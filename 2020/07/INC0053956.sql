BEGIN
  BEGIN
    UPDATE crawcrd
       SET nrcrcard = 0
          ,nrcctitg = 0
          ,insitcrd = 6
     WHERE cdcooper = 1
       AND nrdconta = 11381990;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro na alteração => '||SQLERRM(SQLCODE));
  END;
  
  COMMIT;
  
END;
