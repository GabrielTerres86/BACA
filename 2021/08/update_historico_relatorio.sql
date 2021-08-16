BEGIN  
  UPDATE tbseg_historico_relatorio r
     SET r.dtfim = '31/07/2021'
   WHERE r.idhistorico_relatorio = 1;
   
  UPDATE tbseg_historico_relatorio r
     SET r.dtinicio = '01/08/2021', 
         r.dtfim = NULL
   WHERE r.idhistorico_relatorio = 2;   
   COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
