begin

  update crapprg p set p.nrsolici = 9999, p.inlibprg = 2 
   where p.cdprogra = 'CRPS128';
  
  commit;
  
end;  






   
