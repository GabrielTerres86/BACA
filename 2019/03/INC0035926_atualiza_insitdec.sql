update tbcrd_limite_atualiza a
   set a.insitdec = 7 -- Expirada
 where a.cdcooper = 1
   and a.nrdconta = 9265821
   and a.idatualizacao = 356936;
   
commit;
