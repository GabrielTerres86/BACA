begin
  update crapprg
     set inlibprg = 1, nrsoloci = 23
   where cdprogra = 'CRPS036'
     and cdcooper = 1;
  commit;
end;
