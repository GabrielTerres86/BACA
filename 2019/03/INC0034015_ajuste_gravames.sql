begin 

/*

INC0034015 - Baixa de gravame

Cooperativa Viacredi baixou gravame na cetip, mas não está conseguindo baixar na GRAVAM porque não sai do processamento. Já estão acompanhando a alguns dias. Em anexo algumas evidencias do caso.

*/

  /* 274.240.3      295.037       Baixado */
  update crapbpr c
     set c.cdsitgrv = 4
       , c.flginclu = 0
       , c.flgbaixa = 0
       , c.flgalter = 0
       , c.flcancel = 0
   where c.cdcooper = 1
     and c.progress_recid IN (1996891, 1996891);
  
  commit;

exception
  
  when others then
  
    rollback;

end;