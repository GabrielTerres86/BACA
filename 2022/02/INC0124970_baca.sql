--INC0124970 
begin 
  update CREDITO.TBEPR_TRANSF_ARQUIVO_IMOB_LINHAS
     set nrctremp = 4924277
   where nrctremp = 924277;
   
  update CREDITO.TBEPR_TRANSF_ARQUIVO_IMOB_LINHAS
     set nrctremp = 4997509
   where nrctremp = 997509;

  commit;

exception
  when others then
    rollback;
end;
