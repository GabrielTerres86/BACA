BEGIN
  DELETE FROM credito.tbcred_peac_operacao_retorno;
  DELETE FROM credito.tbcred_peac_operacao;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
