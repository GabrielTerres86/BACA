-- Atualizar a folha de cheque para compensado
update crapfdc a
   set a.incheque = 5
 where a.cdcooper = 9
   and a.nrdconta = 132977
   and a.nrcheque = 467;

COMMIT;

