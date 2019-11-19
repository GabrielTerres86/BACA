BEGIN
  
  -- Excluir o registro do programa, pois não é necessário para rodar via JOB.
  DELETE crapprg t
   WHERE t.cdprogra = 'CRPS690';
   
  -- 
  COMMIT;
  
END;
