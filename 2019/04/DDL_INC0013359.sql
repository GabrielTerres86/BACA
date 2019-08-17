begin 

/*

Boa tarde,

 Por uma migração e erro da CETIP(B3) perdemos o aceso para envios de lote de todas as cooperativas, estamos em contato com 
 o parceiro porém não temos expectativa de correção. Como medida paliativa, vamos solicitar as cooperativas que alienem 
 manualmente os veículos, a fim de não estagnar os créditos. Para tanto, gostaria de verificar com a sustentação se existe 
 a possibilidade de alterar todas os veículos que estão como "Em processamento" na tela GRAVAM e alterar para "Não Enviado" para que seja possível alienação manual da cooperativa. A alteração é necessária, pois o status "Em processamento" não permite qualquer alteração. Peço por gentileza ser tratado urgente, as cooperativas que precisamos ajustar são a Alto Vale e a Acentra, conforme script executado sexta-feira pelo chamado INC0012824 

Atenciosamente, Eduardo Gonçalves dos Santos

*/

  /* Processado com Critica */
--ACENTRA
  update crapbpr c
     set c.cdsitgrv = 3
   where c.cdcooper = 5 
     and c.progress_recid in (select c.progress_recid     from crapbpr c
                              where c.cdcooper = 5 and c.cdsitgrv = 1);
 
   
  update crapgrv c
   set c.dtretgrv = trunc(sysdate)
   where c.cdcooper = 5
   and c.dtretgrv is null;   

  commit;

--ALTO VALE
  update crapbpr c
     set c.cdsitgrv = 3
   where c.cdcooper = 16
     and c.progress_recid in (select c.progress_recid     from crapbpr c
                              where c.cdcooper = 16 and c.cdsitgrv = 1);

  update crapgrv c
   set c.dtretgrv = trunc(sysdate)
   where c.cdcooper = 16
   and c.dtretgrv is null;   

  commit;
  
exception
  
  when others then
  
    rollback;

end;
