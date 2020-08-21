-- Deletar notificacao que nao possui consorcio, foram criadas indevidamente
-- Projeto 595, são 2621 notificações
BEGIN
  DELETE
    FROM tbgen_notificacao o
   WHERE o.cdmensagem = 5183
     AND NOT EXISTS (SELECT 1
            FROM crapcns s
           WHERE s.cdcooper = o.cdcooper
             AND s.nrdconta = o.nrdconta);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro: '|| sqlerrm);
END;
