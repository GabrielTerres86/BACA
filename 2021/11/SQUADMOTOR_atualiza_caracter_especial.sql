begin

  UPDATE tbgen_analise_credito t SET t.xmlanalise = REPLACE(t.xmlanalise,'CONCRESERV CONCRETO & SERVICOS','CONCRESERV CONCRETO e SERVICOS')
   WHERE t.cdcooper = 6
     AND t.nrdconta = 169676
     AND t.nrcontrato = 252232
     ;
  commit;

  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(sqlerrm);
    ROLLBACK;
end;




