BEGIN
  UPDATE tbblqj_ordem_online e
     SET e.instatus = 1
   WHERE trunc(e.dhrequisicao) = '26/08/2020'
     AND e.instatus = 4;
     
  COMMIT;     
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao atualizar tbblqj_ordem_online - '||Sqlerrm);
END;
