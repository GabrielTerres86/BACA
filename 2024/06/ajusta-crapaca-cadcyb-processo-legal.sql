BEGIN
  UPDATE CRAPACA
     SET CRAPACA.LSTPARAM = CRAPACA.LSTPARAM||',pr_cdproleg'
   WHERE CRAPACA.NMDEACAO = 'ALTERA_DADOS_CADCYB';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
    ROLLBACK;
END;
