begin
  update CRAPPRG set INLIBPRG = 1, NRSOLICI = 23 where cdprogra = 'CRPS036' and cdcooper = 1;
 
  commit;
end;

--select NMSISTEM, CDPROGRA, DSPROGRA##1, INLIBPRG from CRAPPRG where cdprogra = 'CRPS036' and cdcooper = 1;
