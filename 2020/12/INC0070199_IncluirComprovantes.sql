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
  vr_dsprotoc_est := '2AC1.F998.DE33.09A5.D488.4A22.D377.6B0C';
  vr_dsprotoc     := '2AC1.F998.DE33.09A5.D488.4A22.D377.6B0C';
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE0OjA5OjQyICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKQUcuIEFSUkVDQURBRE9SOkNOQyA3NTYgQkFOQ08gQ09PUEVSQVRJVk8gQlJBU0lMCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU4NjAwMDAwMDMgOTEzMjAzMjgyMDMKICAgICAgICAgICAgICAgICAgICAgICAgIDU2MDcyMDIwMTg4IDAzMjA2ODc5Mjk5CgoNREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wMy8xMi8yMDIwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjM5MSwzMgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQoKQVVURU5USUNBQ0FPOgpCQU5DT09CMDAwMTAwOCAwMzEyMjAgMDU4IDAwMDAuLi4uLi4zOTEsMzIgMDUwMQoNQ0k6MzIzOTIwMiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg0wMjRBMkFBOS1EQTlDLTQyNTYtQjJEQS0zRDVCQjNDQkRFQzcKDQogICAgICAgICBPVVZJRE9SSUEgQkFOQ09PQjogMDgwMDY0NjQwMDEgICAgICAgICAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0=';
  vr_rowid        := null;
  vr_idsicredi    := 2460369;
  vr_nsu          := 'Aceito para processamento - NSU: 203380163658';
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
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE0OjE4OjA4ICAgCiAgICAgICBBUlJFQ0FEQUNBTyBERSBEQVJGIC8gREFSRiBTSU1QTEVTICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICAgICAgICBDQU5BTCBERSBQQUdBTUVOVE8gQ0FJWEEgICAgICAgICAgICAKCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU2MDAwMDAwMDIgNTAwMDAxNTMwMzUKICAgICAgICAgICAgICAgICAgICAgICAgIDExODM4NjY1ODIwIDAwMTEzNDUwMjA0CkRBVEEgUEFHQU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMDMvMTIvMjAyMApQRVJJT0RPIERFIEFQVVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KTlVNRVJPIERPIENQRiBPVSBDTlBKOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uCkNPRElHTyBSRUNFSVRBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpOVU1FUk8gREUgUkVGRVJFTkNJQTouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KREFUQSBWRU5DSU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uClJFQ0VJVEEgQlJVVEEgQUNVTVVMQURBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpQRVJDRU5UVUFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KVkFMT1IgUFJJTkNJUEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uClZBTE9SIERBIE1VTFRBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpWQUxPUiBET1MgSlVST1MgRS9PVSBFTkNBUkdPUzouLi4uLi4uLi4uLi4uLi4uLi4KVkFMT1IgVE9UQUw6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMjUwLDAwCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCgpBVVRFTlRJQ0FDQU86CkJBTkNPT0IwMDAxMDA4IDAzMTIyMCAwNTggMDAwMC4uLi4uLjI1MCwwMCAwNTAxCg1DSTo0NDQ0MDYgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKDTMwNzFDMjdELUI1NUUtNDc4Ny05N0U2LUQ4REQ3RjI3M0UwOAotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogICAgTW9kZWxvIGFwcm92YWRvIHBlbGEgU1JGIC0gQURFIENvbmp1bnRvICAgIAogICAgICAgICAgQ29yYXQvQ290ZWMgbm8gMDAxLCBkZSAyMDA2LiAgICAgICAgICAKCiAgICAgICAgIE9VVklET1JJQSBCQU5DT09COiAwODAwNjQ2NDAwMSAgICAgICAgIAotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ==';
  vr_rowid        := null;  
  vr_idsicredi    := 2460378;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380163658';
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
  -- Atualizar terceiro comprovante
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE0OjI2OjAxICAgCiAgICAgICBBUlJFQ0FEQUNBTyBERSBEQVJGIC8gREFSRiBTSU1QTEVTICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICAgICAgICBDQU5BTCBERSBQQUdBTUVOVE8gQ0FJWEEgICAgICAgICAgICAKCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU2NzAwMDAwMDIgNTAwMDAxNTMwMzUKICAgICAgICAgICAgICAgICAgICAgICAgIDExODM4NjY1ODIwIDAwMTEzNDUwMjY3CkRBVEEgUEFHQU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMDMvMTIvMjAyMApQRVJJT0RPIERFIEFQVVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KTlVNRVJPIERPIENQRiBPVSBDTlBKOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uCkNPRElHTyBSRUNFSVRBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpOVU1FUk8gREUgUkVGRVJFTkNJQTouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KREFUQSBWRU5DSU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uClJFQ0VJVEEgQlJVVEEgQUNVTVVMQURBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpQRVJDRU5UVUFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4KVkFMT1IgUFJJTkNJUEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uClZBTE9SIERBIE1VTFRBOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLgpWQUxPUiBET1MgSlVST1MgRS9PVSBFTkNBUkdPUzouLi4uLi4uLi4uLi4uLi4uLi4KVkFMT1IgVE9UQUw6Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMjUwLDAwCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCgpBVVRFTlRJQ0FDQU86CkJBTkNPT0IwMDAxMDA4IDAzMTIyMCAwNTggMDAwMC4uLi4uLjI1MCwwMCAwNTAxCg1DSTo0NDQ0MDYgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKDTU1NjVBNjdBLTU2NkItNDQwMC1BNTI2LUFBNUI1RURENzY5MwotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogICAgTW9kZWxvIGFwcm92YWRvIHBlbGEgU1JGIC0gQURFIENvbmp1bnRvICAgIAogICAgICAgICAgQ29yYXQvQ290ZWMgbm8gMDAxLCBkZSAyMDA2LiAgICAgICAgICAKCiAgICAgICAgIE9VVklET1JJQSBCQU5DT09COiAwODAwNjQ2NDAwMSAgICAgICAgIAotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ==';
  vr_rowid        := null;  
  vr_idsicredi    := 2460380;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380163698';
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
  -- Atualizar quarto comprovante
  vr_cdcooper     := 1;
  vr_dsprotoc_est := '916B.5B0B.B056.C0BF.9E6F.D5C5.ED27.9B71';
  vr_dsprotoc     := '916B.5B0B.B056.C0BF.9E6F.D5C5.ED27.9B71';
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE1OjE3OjMwICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKQUcuIEFSUkVDQURBRE9SOkNOQyA3NTYgQkFOQ08gQ09PUEVSQVRJVk8gQlJBU0lMCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU4MjAwMDAwMDAgNTgyNTAzMjgyMTAKICAgICAgICAgICAgICAgICAgICAgICAgIDIwMDcwODIwMTAxIDk4OTYxMDkzOTEwCgoNREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wMy8xMi8yMDIwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi41OCwyNQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQoKQVVURU5USUNBQ0FPOgpCQU5DT09CMDAwMTAwOCAwMzEyMjAgMDU4IDAwMDAuLi4uLi4uNTgsMjUgMDUwMQoNQ0k6MzIzOTI4ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg0xOThDN0QzNC1EOUU2LTRGRjgtOUREOC1FRkZFMDU5REE4NzUKDQogICAgICAgICBPVVZJRE9SSUEgQkFOQ09PQjogMDgwMDY0NjQwMDEgICAgICAgICAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0=';
  vr_rowid        := null;  
  vr_idsicredi    := 2460990;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380238085';
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
  -- Atualizar quinto comprovante
  vr_cdcooper     := 1;
  vr_dsprotoc_est := 'B603.4577.6DF9.4314.C74D.53A5.F43C.74C9';
  vr_dsprotoc     := 'B603.4577.6DF9.4314.C74D.53A5.F43C.74C9';
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE1OjIyOjAwICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKQUcuIEFSUkVDQURBRE9SOkNOQyA3NTYgQkFOQ08gQ09PUEVSQVRJVk8gQlJBU0lMCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU4MjAwMDAwMDAgNTcyNTAzMjgyMTAKICAgICAgICAgICAgICAgICAgICAgICAgIDIwMDcwODIwMDk1IDAxMjQzNjkwMDI1CgoNREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wMy8xMi8yMDIwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi41NywyNQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQoKQVVURU5USUNBQ0FPOgpCQU5DT09CMDAwMTAwOCAwMzEyMjAgMDU4IDAwMDAuLi4uLi4uNTcsMjUgMDUwMQoNQ0k6MzIzOTAxICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg05MDFBNkQ5My02MDY5LTQzMUItQjMxMS00NzQ1Q0EyRjA1M0MKDQogICAgICAgICBPVVZJRE9SSUEgQkFOQ09PQjogMDgwMDY0NjQwMDEgICAgICAgICAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0=';
  vr_rowid        := null;  
  vr_idsicredi    := 2460993;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380238091';
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
  -- Atualizar sexto comprovante
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE1OjI0OjI2ICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICAgICAgICBDQU5BTCBERSBQQUdBTUVOVE8gQ0FJWEEgICAgICAgICAgICAKCkFHLiBBUlJFQ0FEQURPUjpDTkMgNzU2IEJBTkNPIENPT1BFUkFUSVZPIEJSQVNJTApPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLi4uMDUvMDEgLSBDT05WRU5JT1MKTkFUVVJFWkEgREEgT1BFUkFDQU86Li4uLi4uLi4uLi4uLi4uLi4uLi5DUkVESVRPCk4uIERBIEFVVEVOVElDQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wMDAwMQoNQ09ESUdPIERFIEJBUlJBUzogICAgICAgIDg1ODcwMDAwMDA3IDA5ODIwMzI4MjAzCiAgICAgICAgICAgICAgICAgICAgICAgICA1NjA3MjAyMDMzNyA3OTA2ODUwOTIxMwoKDURBVEEgUEFHQU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMDMvMTIvMjAyMApWQUxPUiBUT1RBTDouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi43MDksODIKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KCkFVVEVOVElDQUNBTzoKQkFOQ09PQjAwMDEwMDggMDMxMjIwIDA1OCAwMDAwLi4uLi4uNzA5LDgyIDA1MDEKDUNJOjMyMzk0MCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAoNQ0MwRTc4N0YtNjRCRC00OTBFLUI3QzItMDg5RkRCQkQ5MjQ4Cg0KICAgICAgICAgT1VWSURPUklBIEJBTkNPT0I6IDA4MDA2NDY0MDAxICAgICAgICAgCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t';
  vr_rowid        := null;  
  vr_idsicredi    := 2460994;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380238089';
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
  -- Atualizar sétimo comprovante
  vr_cdcooper     := 1;
  vr_dsprotoc_est := 'AF8F.3E25.011F.2807.8EA1.DC2A.E642.AA08';
  vr_dsprotoc     := 'AF8F.3E25.011F.2807.8EA1.DC2A.E642.AA08';
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE1OjQ1OjQ1ICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKQUcuIEFSUkVDQURBRE9SOkNOQyA3NTYgQkFOQ08gQ09PUEVSQVRJVk8gQlJBU0lMCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU4ODAwMDAwMDAgNjQ1OTAzMjgyMDMKICAgICAgICAgICAgICAgICAgICAgICAgIDY1MDcwODIwMzM4IDg3NjE0MDk3MjE1CgoNREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wMy8xMi8yMDIwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi42NCw1OQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQoKQVVURU5USUNBQ0FPOgpCQU5DT09CMDAwMTAwOCAwMzEyMjAgMDU4IDAwMDAuLi4uLi4uNjQsNTkgMDUwMQoNQ0k6MzIzOTYxICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg1EQkJBQTc3Mi1BQTZCLTQzOTgtOUMyRi0zODcyMDBGMzlDMjgKDQogICAgICAgICBPVVZJRE9SSUEgQkFOQ09PQjogMDgwMDY0NjQwMDEgICAgICAgICAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0=';
  vr_rowid        := null;  
  vr_idsicredi    := 2460998;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380238100';
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
  -- Atualizar oitavo comprovante
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE1OjU5OjI4ICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICAgICAgICBDQU5BTCBERSBQQUdBTUVOVE8gQ0FJWEEgICAgICAgICAgICAKCkFHLiBBUlJFQ0FEQURPUjpDTkMgNzU2IEJBTkNPIENPT1BFUkFUSVZPIEJSQVNJTApPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLi4uMDUvMDEgLSBDT05WRU5JT1MKTkFUVVJFWkEgREEgT1BFUkFDQU86Li4uLi4uLi4uLi4uLi4uLi4uLi5DUkVESVRPCk4uIERBIEFVVEVOVElDQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wMDAwMQoNQ09ESUdPIERFIEJBUlJBUzogICAgICAgIDg1ODgwMDAwMDA2IDAwMDAwMzI4MjAzCiAgICAgICAgICAgICAgICAgICAgICAgICA1NjA3MjAyMDMzNyA3Njk0ODIwNjQ2MQoKDURBVEEgUEFHQU1FTlRPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uMDMvMTIvMjAyMApWQUxPUiBUT1RBTDouLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi42MDAsMDAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KCkFVVEVOVElDQUNBTzoKQkFOQ09PQjAwMDEwMDggMDMxMjIwIDA1OCAwMDAwLi4uLi4uNjAwLDAwIDA1MDEKDUNJOjMyMzkxOTkgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAoNRjNBMkEzQjUtNTdBRS00RjE2LTlBMzItNzAyQUMxMDIzNDMxCg0KICAgICAgICAgT1VWSURPUklBIEJBTkNPT0I6IDA4MDA2NDY0MDAxICAgICAgICAgCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t';
  vr_rowid        := null;  
  vr_idsicredi    := 2461001;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380238098';
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
  -- Atualizar nono comprovante
  vr_cdcooper     := 16;
  vr_dsprotoc_est := 'B9A7.C4B8.CF41.6433.B9A8.0FDE.76DD.701A';
  vr_dsprotoc     := 'B9A7.C4B8.CF41.6433.B9A8.0FDE.76DD.701A';
  vr_base64       := 'LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICAgICBTSVNCUi1TSVNURU1BIERFIElORk9STUFUSUNBIERPIFNJQ09PQiAgICAgCiAgIDAzLzEyLzIwMjAgLSAyIFZJQSBDT01QUk9WQU5URSAtIDE2OjQxOjE4ICAgCiAgICAgICAgREUgUEFHQU1FTlRPIERFIFNJTVBMRVMgTkFDSU9OQUwgICAgICAgIAoKICAgICAgICAgICAgICAgT1JJR0VNIERBIE9QRVJBQ0FPICAgICAgICAgICAgICAgCkJBTkNPOiA3NTYgLSBBRzogMDAwMSAtIEJBTkNPT0IgUEFCIC0gQUdFTkNJQSBCUgogICAgICBDQU5BTCBERSBQQUdBTUVOVE8gSU5URVJORVQgQkFOS0lORyAgICAgIAoKQUcuIEFSUkVDQURBRE9SOkNOQyA3NTYgQkFOQ08gQ09PUEVSQVRJVk8gQlJBU0lMCk9QRVJBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wNS8wMSAtIENPTlZFTklPUwpOQVRVUkVaQSBEQSBPUEVSQUNBTzouLi4uLi4uLi4uLi4uLi4uLi4uLkNSRURJVE8KTi4gREEgQVVURU5USUNBQ0FPOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLjAwMDAxCg1DT0RJR08gREUgQkFSUkFTOiAgICAgICAgODU4MzAwMDAwMDAgNjk0NTAzMjgyMDMKICAgICAgICAgICAgICAgICAgICAgICAgIDY1MDcwODIwMzM4IDg3ODg5NDAxMTAzCgoNREFUQSBQQUdBTUVOVE86Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4wMy8xMi8yMDIwClZBTE9SIFRPVEFMOi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi42OSw0NQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQoKQVVURU5USUNBQ0FPOgpCQU5DT09CMDAwMTAwOCAwMzEyMjAgMDU4IDAwMDAuLi4uLi4uNjksNDUgMDUwMQoNQ0k6NDQyMDEwICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCg0wNTI3Qzg4My00MTVELTREOTgtQkJEOS1EMkM5MjgyMDU0MzQKDQogICAgICAgICBPVVZJRE9SSUEgQkFOQ09PQjogMDgwMDY0NjQwMDEgICAgICAgICAKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0=';
  vr_rowid        := null;  
  vr_idsicredi    := 2461012;  
  vr_nsu          := 'Aceito para processamento - NSU: 203380238097';
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
