-- Created on 18/10/2019 by Rafael Ferreira (Mouts) - T0032702 
-- Este bloco PL Insere o novo Parametro de Boletos Pendentes na CIP
-- RITM0035298
BEGIN
  -- Insere o Parametro Geral
  INSERT INTO crapprm
    (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED', 0, 'EMAIL_BOL_PEND_CIP', 'Email para envio do arquivo de boletos pendentes na CIP.', 'cobranca@ailos.coop.br');

  COMMIT;
END;