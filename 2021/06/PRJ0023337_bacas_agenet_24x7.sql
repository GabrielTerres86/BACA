begin 
  
  /* Criar cada cddopcao como nmrotina */
  insert into craptel (nmdatela,nrmodulo,cdopptel,tldatela,tlrestel,flgteldf,flgtelbl,nmrotina,lsopptel,inacesso,cdcooper,idsistem,idevento,nrordrot,nrdnivel,nmrotpai,idambtel)
  select nmdatela,nrmodulo,'@',tldatela,tlrestel,flgteldf,flgtelbl,'IMPRESSAO','IMPRESSAO',2,cdcooper,idsistem,idevento,nrordrot,nrdnivel,nmrotpai,idambtel
    from craptel
   where nmdatela = 'AGENET'
   and nmrotina = ' ';

  insert into craptel (nmdatela,nrmodulo,cdopptel,tldatela,tlrestel,flgteldf,flgtelbl,nmrotina,lsopptel,inacesso,cdcooper,idsistem,idevento,nrordrot,nrdnivel,nmrotpai,idambtel)
  select nmdatela,nrmodulo,'@',tldatela,tlrestel,flgteldf,flgtelbl,'VISUALIZAR','VISUALIZAR',2,cdcooper,idsistem,idevento,nrordrot,nrdnivel,nmrotpai,idambtel
    from craptel
   where nmdatela = 'AGENET'
   and nmrotina = ' ';
   
  insert into craptel (nmdatela,nrmodulo,cdopptel,tldatela,tlrestel,flgteldf,flgtelbl,nmrotina,lsopptel,inacesso,cdcooper,idsistem,idevento,nrordrot,nrdnivel,nmrotpai,idambtel)
  select nmdatela,nrmodulo,'@',tldatela,tlrestel,flgteldf,flgtelbl,'CANCELAR','CANCELAR',0,cdcooper,idsistem,idevento,nrordrot,nrdnivel,nmrotpai,idambtel
    from craptel
   where nmdatela = 'AGENET'
   and nmrotina = ' '; 

  /* Manter na AGENET somente o "acesso"  */
  update craptel set cdopptel = '@', lsopptel = 'ACESSO', inacesso = 2
  where nmdatela = 'AGENET'
  and nmrotina = ' ';
  
  /* Migrar acessos como cddopcao para nmrotina */
  update crapace 
     set cddopcao = '@'
        ,nmrotina = DECODE(CDDOPCAO,'C','CANCELAR','I','IMPRESSAO','T','VISUALIZAR',CDDOPCAO)
   where upper(nmdatela) = 'AGENET' 
     and cddopcao <> '@';     
  
  /* Ajustar crapaca */
  update crapaca aca
     set aca.lstparam = 'pr_nmrotina, pr_nrdconta, pr_dtiniper, pr_dtfimper, pr_cdagesel, pr_insitlau, pr_cdtiptra, pr_nrregist, pr_nriniseq, pr_tipsaida, pr_nmarquiv'
   where aca.nmdeacao = 'BUSCA_AGENDAMENTOS';
  
  commit;
  
end;  

