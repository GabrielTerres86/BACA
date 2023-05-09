BEGIN
  
  UPDATE crapass a 
  set a.nrcpfcgc = 77904720000106,
      a.nrcpfcnpj_base = 77904720
  where a.progress_recid = 814011;
  
  UPDATE crapass a 
  set a.nrcpfcgc = 10533320000160,
      a.nrcpfcnpj_base = 10533320
  where a.progress_recid = 1016399;
  
  UPDATE crapass a 
  set a.nrcpfcgc = 7863677000100,
      a.nrcpfcnpj_base = 7863677
  where a.progress_recid = 1149158;
  
  UPDATE crapass a 
  set a.nrcpfcgc = 7449767000141,
      a.nrcpfcnpj_base = 7449767
  where a.progress_recid = 1204587;
  
  UPDATE crapass a 
  set a.nrcpfcgc = 8044008000161,
      a.nrcpfcnpj_base = 8044008
  where a.progress_recid = 1569957;        
        
COMMIT;
END;
