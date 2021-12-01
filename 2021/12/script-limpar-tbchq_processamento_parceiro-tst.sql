BEGIN
  DELETE FROM tbchq_processamento_parceiro t WHERE t.nmarquivoimportacao LIKE 'CC291101.CSV';
COMMIT;
END;  
