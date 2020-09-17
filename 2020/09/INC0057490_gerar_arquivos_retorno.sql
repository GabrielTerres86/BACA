declare
  
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  
begin
  
  PGTA0001.pc_gera_retorno_tit_pago(pr_cdcooper => 1
                                  , pr_dtmvtolt => to_date('03082020','ddmmyyyy')
                                  , pr_idorigem => 3 -- Ayllos
                                  , pr_cdoperad => '1'
                                  , pr_cdcritic => vr_cdcritic
                                  , pr_dscritic => vr_dscritic );
  
  commit;

end;