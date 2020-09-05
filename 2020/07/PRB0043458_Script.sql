Begin
  update tbcobran_log_arquivo_ieptb 
  set CDSITUACAO = 1 
  where IDLOG_ARQUIVO = 17452;
  Commit;
End;  
