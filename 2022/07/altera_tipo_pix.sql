begin
  update credito.tbcred_preaprov a
     set a.tppreapr = 2
   where a.idcarga  = 122; 
commit;
end;
