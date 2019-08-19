begin 

/*

Prezados, bom dia!

O gravame do CTR 1.407.263 da CC 854.589-8 da cooperativa VIACREDI entrou no lote 3435 (10:00h de 12/02), porém, ocorreu algum problema onde a CETIP não alienou esse bem, e também não deu retorno no lote, sendo possível ver que o veículo ficou travado "em processamento" e que no retorno do lote esse gravame consta "Sem Retorno".

Precisamos por gentileza que seja tirada esse status, ele pode ser alterado para "Não enviado" ou então "Processado com Crítica", para que ele entre nos próximos lotes e aliene normalmente.

Peço que o ajuste seja efetuado o quanto antes por favor, o cooperado está aguardando a alienação para que o contrato seja efetuado, podendo desistir do contrato em virtude da demora.

Qualquer dúvida estou à disposição,
Eduardo Gonçalves dos Santos

*/

  /* Processado com Critica */
  update crapbpr c
     set c.cdsitgrv = 3
   where c.cdcooper = 1
     and c.progress_recid = 5574386;
 
   
  update crapgrv c
   set c.dtretgrv = trunc(sysdate)
   where c.cdcooper = 1
   and (c.nrdconta, c.nrctrpro) in ((8545898, 1407263))
   and c.dtretgrv is null;   

  commit;

exception
  
  when others then
  
    rollback;

end;