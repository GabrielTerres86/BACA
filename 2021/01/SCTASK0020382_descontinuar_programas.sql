begin
  update crapprg  p set p.nrsolici = 9999, 
                      p.inlibprg = 2 /*2 - bloqueado*/
  /* Programas a serem descontinuados*/                                         
  where upper(p.cdprogra) in ('CRPS215',
                             'CRPS464',
                             'CRPS383',
                             'CRPS479',
                             'CRPS520',
                             'CRPS507',
                             'CRPS488',
                             'CRPS277',
                             'CRPS167',
                             'CRPS492',
                             'CRPS496',
                             'CRPS196',
                             'CRPS384');
                             
  commit;
  
end;
