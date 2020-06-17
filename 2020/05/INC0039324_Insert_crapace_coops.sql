begin          
  /* Acesso para cooperativa => 1 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 1, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 1
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 2 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 2, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 2
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 5 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 5, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 5
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;


  /* Acesso para cooperativa => 5 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 6, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 6
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 7 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 7, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 7
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 8 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 8, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 8
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 9 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 9, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 9
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 10 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 10, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 10
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 11 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 11, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 11
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;
                
  /* Acesso para cooperativa => 12 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 12, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 12
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 13 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 13, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 13
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 14 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 14, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 14
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;

  /* Acesso para cooperativa => 16 */ 
  Insert  into crapace (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace) 
  Select ace.nmdatela, ace.cddopcao, ace.cdoperad, ace.nmrotina, 16, ace.nrmodulo, ace.idevento, ace.idambace
  From crapace ace
  where upper(ace.nmdatela) = 'MANPRT'
  and ace.cddopcao   = '@'
  and ace.cdcooper   = 3
  and not exists (select 1
                from crapace a
                where CDCOOPER = 16
                and   UPPER(NMDATELA) = 'MANPRT'
                and   UPPER(NMROTINA) =  UPPER(ACE.NMROTINA)                          
                and   UPPER(CDDOPCAO) =  UPPER(ACE.CDDOPCAO)
                and   UPPER(CDOPERAD) =  UPPER(ACE.CDOPERAD)
                and   IDAMBACE        =  ACE.IDAMBACE) ;


  COMMIT;
                  
end;
  
