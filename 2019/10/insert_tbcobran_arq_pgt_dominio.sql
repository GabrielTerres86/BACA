-- Created on 25/09/2019 by Rafael Ferreira (Mouts) - T0032702 
-- Este bloco PL Insere o novo Dominio de Cobrança BI
-- RITM0038130
BEGIN
  -- Insere o Dominio de Cobrança BI
  INSERT INTO tbcobran_arq_pgt_dominio
    (CDCAMPO, CDDOMINIO, DSDOMINIO)
  VALUES
    ('G059', 'BI', 'Beneficiário Divergente');

  COMMIT;
END;
