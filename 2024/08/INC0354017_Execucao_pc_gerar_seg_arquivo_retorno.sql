DECLARE
  vr_cdcritic number;
  vr_dscritic varchar2(10000);  
  vr_dtretorn date;
  
BEGIN
  vr_dtretorn := to_date('23/08/2024', 'dd/mm/yyyy');
  cecred.pgta0001.pc_gerar_seg_arquivo_retorno(pr_dtretorno => vr_dtretorn
                                              ,pr_cdcritic  => vr_cdcritic
                                              ,pr_dscritic  => vr_dscritic); 
  if vr_dscritic is not null then
    RAISE_application_error(-20500,'Erro rotina pc_gerar_seg_arquivo_retorno: '||vr_dscritic);
  end if;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEn
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;