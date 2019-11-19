-- Created on 25/09/2019 by Rafael Ferreira (Mouts) - T0032702 
-- Este bloco PL Insere o novo motivo de Rejeição de boleto informado pela àrea de negócio Ailos
-- RITM0038130
DECLARE

BEGIN
  -- Loop por todas as cooperativas
  FOR rw_coop IN (SELECT cdcooper FROM crapcop) LOOP
  
    BEGIN
      -- Insere os registros na tabela de motivos de rejeição
      INSERT INTO crapmot
        (CDCOOPER, CDDBANCO, CDOCORRE, TPOCORRE, CDMOTIVO, DSMOTIVO, DSABREVI, CDOPERAD, DTALTERA, HRTRANSA)
      VALUES
        (rw_coop.cdcooper, 85, 3, 2, 'BI', 'Beneficiário Divergente', ' ', '1', to_date('23-09-2019', 'dd-mm-yyyy'), 0);
    
    EXCEPTION
      WHEN OTHERS THEN
        pc_internal_exception;
    END;
  
  END LOOP;

  COMMIT;
END;
