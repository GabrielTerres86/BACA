BEGIN
  INSERT INTO pagamento.tbpagto_motivo_cancelamento_baixa
    (cdmotivo_cancelamento_baixa
    ,dsmotivo_cancelamento_baixa)
  VALUES
    (88
    ,'Devolucao de recurso financeiro sem reativacao do boleto');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'US931127');
    RAISE;
END;