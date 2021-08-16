BEGIN  
  UPDATE tbseg_historico_relatorio r
     SET r.dtfim = TO_DATE('31/07/2021','DD/MM/RRRR')
   WHERE r.idhistorico_relatorio = 1;
   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Sucesso 1');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Erro 1: ' || SQLERRM);
  ROLLBACK;
END;
/
BEGIN   
  UPDATE tbseg_historico_relatorio r
     SET r.dtinicio = TO_DATE('01/08/2021','DD/MM/RRRR'), 
         r.dtfim = NULL
   WHERE r.idhistorico_relatorio = 2;   
   DBMS_OUTPUT.PUT_LINE('Sucesso 2');
   COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Erro 2: ' || SQLERRM);  
  ROLLBACK;
END;
/
