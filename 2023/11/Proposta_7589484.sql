begin

  UPDATE CECRED.tbgen_analise_credito t SET t.xmlanalise = REPLACE(t.xmlanalise,'<=3','menor ou igual a 3')
   WHERE t.cdcooper = 1
     AND t.nrdconta = 7301200
     AND t.nrcontrato = 7589484
     ;
  commit;

  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(sqlerrm);
    ROLLBACK;
end;