BEGIN

  INSERT INTO pagamento.tbpagto_motivo_cancelamento_baixa
    (CDMOTIVO_CANCELAMENTO_BAIXA
    ,DSMOTIVO_CANCELAMENTO_BAIXA)
  VALUES
    (86
    ,'Correção de saldo parcial de pagamento');
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0280144');
    RAISE;
  
END;
