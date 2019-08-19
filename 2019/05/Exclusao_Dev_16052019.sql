-- exclusão de devolução para conta inexistente
delete
   from crapdev aa
   where aa.progress_recid IN (2429122,2429123);
   
commit;
   