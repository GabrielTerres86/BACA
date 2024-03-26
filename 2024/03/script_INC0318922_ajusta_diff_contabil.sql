DECLARE
  rw_crapdat datasCooperativa;   
BEGIN
   rw_crapdat := datasCooperativa(pr_cdcooper => 5);
  
   update gestaoderisco.tbcc_historico_juros_adp his
      set his.vlcorte = 191.10
    where his.cdcooper = 5
      and his.nrdconta = 147265
      and his.dtmvtolt = rw_crapdat.dtmvtoan;
      
   COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    ROLLBACK;
END;
