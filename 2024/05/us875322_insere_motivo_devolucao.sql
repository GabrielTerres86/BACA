BEGIN

  INSERT INTO pagamento.tbpagto_motivo_cancelamento_baixa
    (CDMOTIVO_CANCELAMENTO_BAIXA
    ,DSMOTIVO_CANCELAMENTO_BAIXA)
  VALUES
    (87
    ,'Recurso financeiro não enviado pela IF Recebedora via STR');
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'US875322');
    RAISE;
  
END;
