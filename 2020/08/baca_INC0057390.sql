declare
  vr_dscritic varchar2(1000) := NULL;
begin
  
  UPDATE tbcobran_log_arquivo_ieptb t SET t.qtregistro_arquivo = 0, t.cdsituacao = 1
  WHERE t.nmarquivo_ieptb = 'R0853107.201';
  
  UPDATE tbcobran_log_arquivo_ieptb t SET t.qtregistro_arquivo = 0, t.cdsituacao = 1
  WHERE t.nmarquivo_ieptb = 'C0853107.201';
  
  UPDATE tbcobran_log_arquivo_ieptb t SET t.qtregistro_arquivo = 0, t.cdsituacao = 1
  WHERE t.nmarquivo_ieptb = 'R0850308.201';
  
  UPDATE tbcobran_log_arquivo_ieptb t SET t.qtregistro_arquivo = 0, t.cdsituacao = 1
  WHERE t.nmarquivo_ieptb = 'C0850308.201';
  
  COMMIT;   
  
  begin
    
    pc_crps730(pr_dscritic => vr_dscritic);
    
    IF trim(vr_dscritic) IS NOT NULL THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_cdprograma   => 'INC0057390'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||	
                                                    ' - BACA_INC0057390 --> Erro: ' || vr_dscritic);  
			ROLLBACK;      
    ELSE	
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_cdprograma   => 'INC0057390'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||	
                                                    ' - BACA_INC0057390 --> OK');                                                    
      COMMIT;
    END IF;
	
  exception
    when others then
	  rollback;
	  btch0001.pc_gera_log_batch(pr_cdcooper     => 3
							                ,pr_ind_tipo_log => 1 -- Mensagem
							                ,pr_cdprograma   => 'INC0057390'
							                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
								  				                        ' - BACA_INC0057390 --> '||
												                          'Erro: '|| SQLERRM);	
  
  end;
  
end;
