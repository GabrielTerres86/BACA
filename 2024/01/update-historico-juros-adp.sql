DECLARE
  vr_cdcooper    crapcop.cdcooper%TYPE := 14;
  vr_nrdconta    crapass.nrdconta%TYPE := 99967600;
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  vr_exc_saida   EXCEPTION;
  rw_crapdat     datasCooperativa;
    
BEGIN
  rw_crapdat := datasCooperativa(pr_cdcooper => vr_cdcooper);
  
  begin       
    update gestaoderisco.tbcc_historico_juros_adp his
            set his.vlcorte = 2245.36
          where his.cdcooper = vr_cdcooper
            and his.nrdconta = vr_nrdconta
            and his.dtmvtolt = rw_crapdat.dtmvtoan;
            
    if sql%rowcount = 0 then
      raise vr_exc_saida;
    end if;
      
  exception
    when others then
      raise vr_exc_saida;
  end;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line(sqlerrm);
    ROLLBACK;
END;
