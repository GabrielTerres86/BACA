declare

  vr_error exception;
  vr_rowid rowid;
  
  vr_cdcooper     crappro.cdcooper%type;
  vr_dsprotoc_est crappro.dsprotoc%type;
  vr_dsprotoc     crappro.dsprotoc%type;
  vr_base64       crappro.dscomprovante_parceiro%type;
  vr_idsicredi    tbconv_registro_remessa_pagfor.idsicredi%type;
  vr_nsu          tbconv_registro_remessa_pagfor.dsprocessamento%type;
  
  cursor cr_crappro (pr_cdcooper crappro.cdcooper%type
                    ,pr_dsprotoc crappro.dsprotoc%type) is
    select p.rowid
      from crappro p
     where p.cdcooper        = pr_cdcooper
       and upper(p.dsprotoc) = pr_dsprotoc;       
       
begin 
  
  -- Atualizar primeiro comprovante
  vr_cdcooper     := 1;
  vr_dsprotoc_est := '3879.FADB.0891.D66A.FE0F.ADBB.66EC.FFFF **ESTORNADO(21/10/20-16:19:51)';
  vr_dsprotoc     := '3879.FADB.0891.D66A.FE0F.ADBB.66EC.FFFF';
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDA1LzExLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE0OjQxOjM2ICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKQUcuIEFSUkVDQURBRE9SOkNOQyA3NTYgQkFOQ08gQ09PUEVSQVRJVk8gQlJBU0lMCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU4MDAwMDAwMTEgNDE3OTAzMjgyMDIKICAgICAgICAgICAgICAgICAgICAgICAgIDk1MDcyMDIwMjk1IDc3ODQ1ODc1NDYzCgoNREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4yMS8xMC8yMDIwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4xLjE0MSw3OQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQoKQVVURU5USUNBQ0FPOgpCQU5DT09CMDAwMTAwOCAyMTEwMjAgMDU4IDAwMDAuLi4uMS4xNDEsNzkgMDUwMQoNQ0k6MzIzOTM3ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg04MkFDRjZFNS0wM0YyLTQ2RUItOTY4RC1GMThDOTVFRUZFMDEKDQogICAgICAgICBPVVZJRE9SSUEgQkFOQ09PQjogMDgwMDY0NjQwMDEgICAgICAgICAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0=';
  vr_rowid        := null;
  vr_idsicredi    := 2248936;
  vr_nsu          := 'Aceito para processamento - NSU: 202950218904';
  
  open cr_crappro (pr_cdcooper => vr_cdcooper
                  ,pr_dsprotoc => vr_dsprotoc_est);
  fetch cr_crappro into vr_rowid;
  if vr_rowid is null then
    close cr_crappro;
    dbms_output.put_line('Falha na consulta da crappro: ' || vr_dsprotoc_est);    
    raise vr_error;    
  end if;
  close cr_crappro;
  
  begin 
    update crappro c
       set c.dsprotoc               = vr_dsprotoc
          ,c.dscomprovante_parceiro = vr_base64
     where c.rowid = vr_rowid;
  exception
    when others then
      dbms_output.put_line('Falha na atualização da crappro: ' || vr_dsprotoc_est || ' - ' || SQLERRM);    
      raise vr_error;        
  end;
  
  begin
    update tbconv_registro_remessa_pagfor r
       set r.dsprocessamento        = vr_nsu
          ,r.cdstatus_processamento = 3
     where r.idsicredi = vr_idsicredi;
  exception
    when others then
      dbms_output.put_line('Falha na atualização da tbconv_registro_remessa_pagfor: ' || vr_idsicredi || ' - ' || SQLERRM);    
      raise vr_error;        
  end;  
  
  -- Atualizar segundo comprovante
  vr_cdcooper     := 11;
  vr_dsprotoc_est := 'ABF5.918C.4691.F6D0.0BAB.7CB3.AC04.B06C **ESTORNADO(21/10/20-16:21:44)';
  vr_dsprotoc     := 'ABF5.918C.4691.F6D0.0BAB.7CB3.AC04.B06C';
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDA1LzExLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE0OjQ0OjIwICAgCiAgICAgICBBUlJFQ0FEQUNBTyBERSBEQVJGIC8gREFSRiBTSU1QTEVTICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKT1BFUkFDQU86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLjA1LzAxIC0gQ09OVkVOSU9TCk5BVFVSRVpBIERBIE9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uQ1JFRElUTwpOLiBEQSBBVVRFTlRJQ0FDQU86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMDAwMDEKDUNPRElHTyBERSBCQVJSQVM6ICAgICAgICA4NTg1MDAwMDAwMCAyNTAwMDM4NTIwMwogICAgICAgICAgICAgICAgICAgICAgICAgMjQwNzAxMjAyOTQgNTYwMDM1MzY3NjAKREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4yMS8xMC8yMDIwClBFUklPRE8gREUgQVBVUkFDQU86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpOVU1FUk8gRE8gQ1BGIE9VIENOUEo6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KQ09ESUdPIFJFQ0VJVEE6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uCk5VTUVSTyBERSBSRUZFUkVOQ0lBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpEQVRBIFZFTkNJTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KUkVDRUlUQSBCUlVUQSBBQ1VNVUxBREE6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uClBFUkNFTlRVQUw6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpWQUxPUiBQUklOQ0lQQUw6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KVkFMT1IgREEgTVVMVEE6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uClZBTE9SIERPUyBKVVJPUyBFL09VIEVOQ0FSR09TOi4uLi4uLi4uLi4uLi4uLi4uLgpWQUxPUiBUT1RBTDouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMjUsMDAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KCkFVVEVOVElDQUNBTzoKQkFOQ09PQjAwMDEwMDggMjExMDIwIDA1OCAwMDAwLi4uLi4uLjI1LDAwIDA1MDEKDUNJOjQ0MzgwNiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAoNNzY0RkJERjMtNDMyOS00NzAyLUE5NzUtQzEzNTUwQjFGNDVBCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCiAgICBNb2RlbG8gYXByb3ZhZG8gcGVsYSBTUkYgLSBBREUgQ29uanVudG8gICAgCiAgICAgICAgICBDb3JhdC9Db3RlYyBubyAwMDEsIGRlIDIwMDYuICAgICAgICAgIAoKICAgICAgICAgT1VWSURPUklBIEJBTkNPT0I6IDA4MDA2NDY0MDAxICAgICAgICAgCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t';
  vr_rowid        := null;  
  vr_idsicredi    := 2248954;  
  vr_nsu          := 'Aceito para processamento - NSU: 202950218893';
  
  open cr_crappro (pr_cdcooper => vr_cdcooper
                  ,pr_dsprotoc => vr_dsprotoc_est);
  fetch cr_crappro into vr_rowid;
  if vr_rowid is null then
    close cr_crappro;
    dbms_output.put_line('Falha na consulta da crappro: ' || vr_dsprotoc_est);    
    raise vr_error;    
  end if;
  close cr_crappro;
  
  begin 
    update crappro c
       set c.dsprotoc               = vr_dsprotoc
          ,c.dscomprovante_parceiro = vr_base64
     where c.rowid = vr_rowid;
  exception
    when others then
      dbms_output.put_line('Falha na atualização da crappro: ' || vr_dsprotoc_est || ' - ' || SQLERRM);    
      raise vr_error;        
  end;  
  
  begin
    update tbconv_registro_remessa_pagfor r
       set r.dsprocessamento        = vr_nsu
          ,r.cdstatus_processamento = 3
     where r.idsicredi = vr_idsicredi;
  exception
    when others then
      dbms_output.put_line('Falha na atualização da tbconv_registro_remessa_pagfor: ' || vr_idsicredi || ' - ' || SQLERRM);    
      raise vr_error;        
  end;    
  
  -- Commit dos updates acima
  commit;
  
exception    
  when vr_error then
    rollback;
  when others then
    dbms_output.put_line('Falha na atualização da crappro: ' || SQLERRM);
    rollback;
    
end;
