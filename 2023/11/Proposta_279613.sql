begin

  UPDATE CECRED.tbgen_analise_credito t SET t.xmlanalise = REPLACE(t.xmlanalise,'<=3','menor ou igual a 3')
   WHERE t.cdcooper = 6
     AND t.nrdconta = 16482069
     AND t.nrcontrato = 279613
     ;
  commit;

  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(sqlerrm);
    ROLLBACK;
end;