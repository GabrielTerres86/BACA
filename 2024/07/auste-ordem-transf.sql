begin

UPDATE tbblqj_ordem_online a
   SET a.dhrequisicao = SYSDATE-1
 WHERE a.tpordem = 4 
    AND a.instatus = 1
   ;
commit;
end;
