BEGIN

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (1
    ,0.31000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (2
    ,0.31000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (3
    ,0.31000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (41
    ,0.31000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (4
    ,1.74000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (5
    ,0.31000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (6
    ,0.31000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (7
    ,0.31000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));

  INSERT INTO PAGAMENTO.TA_TARIFA_RCO
    (IDCANAL_PAGAMENTO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA)
  VALUES
    (21
    ,0.72000
    ,to_date('01-01-2023', 'dd-mm-yyyy'));
  COMMIT;

END;