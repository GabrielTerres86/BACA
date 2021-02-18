begin
  update crapprg  p set p.inlibprg = 2 /* 2 - bloqueado */
  /* Programas a serem descontinuados*/                                         
  where upper(p.cdprogra) = 'CRPS524';
                             
  commit;
  
end;
