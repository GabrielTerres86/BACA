begin 

/*

Boa tarde,

 Por uma migra��o e erro da CETIP(B3) perdemos o aceso para envios de lote de todas as cooperativas, estamos em contato com 
 o parceiro por�m n�o temos expectativa de corre��o. Como medida paliativa, vamos solicitar as cooperativas que alienem 
 manualmente os ve�culos, a fim de n�o estagnar os cr�ditos. Para tanto, gostaria de verificar com a sustenta��o se existe 
 a possibilidade de alterar todas os ve�culos que est�o como "Em processamento" na tela GRAVAM e alterar para "N�o Enviado" para que seja poss�vel aliena��o manual da cooperativa. A altera��o � necess�ria, pois o status "Em processamento" n�o permite qualquer altera��o. Pe�o por gentileza ser tratado urgente, as cooperativas que precisamos ajustar s�o a Alto Vale e a Acentra, conforme script executado sexta-feira pelo chamado INC0012824 

Atenciosamente, Eduardo Gon�alves dos Santos

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
