begin
  update crapprg
   set crapprg.inlibprg = 2, --Indicador de liberacao do programa (1=lib, 2=bloq e 3=em teste)
    crapprg.nrsolici = 70
  where crapprg.cdprogra = 'CRPS431';
  
  COMMIT;
end;

