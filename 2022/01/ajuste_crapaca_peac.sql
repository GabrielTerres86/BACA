BEGIN
  UPDATE crapaca a
     SET a.nmproced = 'pc_consultar_limites_web'
   WHERE a.nmdeacao = 'CONSULTA_LIMITES_PEAC';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
