BEGIN
  BEGIN
    UPDATE crapenc
       SET tpendass = 13
     WHERE cdcooper = 1
       AND nrdconta = 11063556
       AND nrcepend = 89120000;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro na alteração => '||SQLERRM(SQLCODE));
  END;
  
  COMMIT;
  
END;






   
