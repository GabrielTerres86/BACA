BEGIN
  
  -- Excluir o registro do programa, pois n�o � necess�rio para rodar via JOB.
  DELETE crapprg t
   WHERE t.cdprogra = 'CRPS690';
   
  -- 
  COMMIT;
  
END;
