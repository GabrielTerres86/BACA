BEGIN
  UPDATE credito.tbcred_pronampe_contrato
     SET vlsaldocontrato = NULL
   WHERE vlsaldocontrato IS NOT NULL;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
     RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao limpar dados da tabela tbcred_pronampe_contrato. Erro: '|| SQLERRM);
END;
