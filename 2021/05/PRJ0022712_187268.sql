--project/PRJ0022712_187268 - Liberar linhas craplrt
BEGIN
  UPDATE craplrt lrt
     SET lrt.flgstlcr = 1
   WHERE lrt.cddlinha IN (30,31,32,40,41,42);
   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20001,'Erro ao atualizar tabela craplrt. Erro: '||sqlerrm);
END;
 
 
 
 
 
