begin
  update crapprg  p set p.nrsolici = 9999, 
                        p.inlibprg = 2 /* 2 - bloqueado */
  /* Programas a serem descontinuados*/                                         
  where upper(p.cdprogra) in ('CRPS430'
                             ,'CRPS082'
                             ,'CRPS088'
                             ,'CRPS661'
                             ,'CRPS615'
                             ,'CRPS405');
                             
  commit;
  
end;
