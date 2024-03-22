DECLARE
  rw_crapdat     datasCooperativa;
  rw_crapdat_2   datasCooperativa;
    
BEGIN
   rw_crapdat := datasCooperativa(pr_cdcooper => 14);
       
   update gestaoderisco.tbcc_historico_juros_adp his
      set his.vlcorte = 2018.98
    where his.cdcooper = 14
      and his.nrdconta = 14995921
      and his.dtmvtolt = rw_crapdat.dtmvtoan;           

   update gestaoderisco.tbcc_historico_juros_adp his
      set his.vlcorte = 697.66
    where his.cdcooper = 14
      and his.nrdconta = 16047109
      and his.dtmvtolt = rw_crapdat.dtmvtoan;
  
  rw_crapdat_2 := datasCooperativa(pr_cdcooper => 5);
  
   update gestaoderisco.tbcc_historico_juros_adp his
      set his.vlcorte = 11260.20
    where his.cdcooper = 5
      and his.nrdconta = 147265
      and his.dtmvtolt = rw_crapdat_2.dtmvtoan;
      
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    ROLLBACK;
END;
