begin

UPDATE tbblqj_ordem_online a
   SET a.dhrequisicao = SYSDATE-1
 WHERE a.tpordem = 4 
   AND a.instatus = 1
   AND a.idordem in (5828101,5828104,5828109,5828111,5828115,5828117,5828119,5828121,5828123)
   ;
commit;
end;
