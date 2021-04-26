BEGIN
  UPDATE crapmot
  SET crapmot.Dsmotivo = 'Solicitacao cancelamento Protesto (Carta de Anuencia Eletronica)'
  WHERE crapmot.cddbanco = 85
  AND   crapmot.cdocorre = 98
  AND   crapmot.cdmotivo = 'F1';

  COMMIT;
END;
