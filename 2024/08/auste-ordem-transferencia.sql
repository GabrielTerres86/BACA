begin

UPDATE tbblqj_ordem_online a
   SET a.dhrequisicao = SYSDATE-1
 WHERE a.tpordem = 4 
   AND a.instatus = 1
   AND a.idordem in (5828178,5828180,5828183,5828188)
   ;
commit;
end;
