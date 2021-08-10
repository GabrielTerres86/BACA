begin
  update crapprg
     set inlibprg = 1, nrsolici = 23
   where cdprogra = 'CRPS036'
     and cdcooper = 1;
  commit;
end;
