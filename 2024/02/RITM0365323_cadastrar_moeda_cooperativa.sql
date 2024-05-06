DECLARE 
  pr_cdcooper PLS_INTEGER := 9; 
  pr_dtmaxima DATE := to_date('31/12/2024','dd/mm/yyyy'); 

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  vr_data DATE;
  vr_erro PLS_INTEGER := 0;
  vr_correto PLS_INTEGER := 0;
  
  CURSOR cr_crapmfx IS
    SELECT DISTINCT crapmfx.tpmoefix
      FROM CECRED.crapmfx
     WHERE cdcooper = pr_cdcooper;

  CURSOR cr_crapmfx_2(pr_tpmoefix PLS_INTEGER) IS
      SELECT crapmfx.vlmoefix 
        FROM CECRED.crapmfx 
       WHERE cdcooper = pr_cdcooper 
         AND tpmoefix = pr_tpmoefix
       ORDER BY dtmvtolt DESC;  
  rw_crapmfx_2 cr_crapmfx_2%ROWTYPE;
  
  cursor cr_coop is
   select cdcooper from crapcop where flgativo = 1 and cdcooper = pr_cdcooper;
  
begin
  for rw_coop in cr_coop loop
    pr_cdcooper := rw_coop.cdcooper;
    dbms_output.put_line(pr_cdcooper);

  OPEN btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  FOR rw_crapmfx IN cr_crapmfx LOOP
    
    OPEN cr_crapmfx_2(rw_crapmfx.tpmoefix);
    FETCH cr_crapmfx_2 INTO rw_crapmfx_2;
    CLOSE cr_crapmfx_2;
    
    vr_data := rw_crapdat.dtmvtolt - 60;
    
    LOOP
      vr_data := vr_data + 1;
      BEGIN
        INSERT INTO CECRED.crapmfx
          (dtmvtolt,
           tpmoefix,
           vlmoefix,
           cdcooper)
        VALUES 
          (vr_data,
           rw_crapmfx.tpmoefix,
           rw_crapmfx_2.vlmoefix,
           pr_cdcooper);
      EXCEPTION
        WHEN dup_val_on_index THEN
          vr_erro := vr_erro + 1;
          vr_correto := vr_correto - 1;
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
          vr_erro := vr_erro + 1;
          vr_correto := vr_correto - 1;
      END;
      vr_correto := vr_correto + 1;
      EXIT WHEN vr_data >= pr_dtmaxima;
    END LOOP;
           
  END LOOP;
  dbms_output.put_line('Erro: '||vr_erro);
  dbms_output.put_line('Correto: '||vr_correto);
  END LOOP;
  COMMIT;
end;