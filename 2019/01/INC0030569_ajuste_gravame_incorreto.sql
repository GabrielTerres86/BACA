begin 

/*

Boa tarde,

Identificamos um problema no retorno do lote de inclusão 3363 da Viacredi, onde todos os veículos do lote tiveram retorno de alienação ou crítica, menos um deles.

Já tivemos um problema semelhante no caso do incidente INC0029950 e foi necessário ajuste via script.

Anexo evidencia de retorno do lote, com exceção do caso mencionado.

Anexo também enviarei o print dentro da CETIP, onde mostra que o bem foi alienado.

Atenciosamente,
Eduardo
*/

  /* Alienado */
  update crapbpr c
     set c.cdsitgrv = 2
       , c.flginclu = 0
       , c.flgbaixa = 0
       , c.flgalter = 0
       , c.flcancel = 0
   where c.cdcooper = 1
     and c.progress_recid = 5533724;
 
   
  update crapgrv c
   set c.dtretgrv = trunc(sysdate)
   where c.cdcooper = 1
   and (c.nrdconta, c.nrctrpro) in ((3768198, 1387450))
   and c.dtretgrv is null;   

  commit;

exception
  
  when others then
  
    rollback;

end;