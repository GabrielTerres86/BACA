-- Created on 25/09/2019 by Rafael Ferreira (Mouts) - T0032702 
-- Este bloco PL Insere o novo Parametro de Data limite de aceite para o J52
-- RITM0038130
BEGIN
  -- Insere o Parametro Geral
  INSERT INTO crapprm
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED', 0, 'DT_LIM_CNAB240_SEM_J52', 'Data limite para aceite de arquivos CNAB240 sem o J52.', '27/11/2019');

  COMMIT;
END;
