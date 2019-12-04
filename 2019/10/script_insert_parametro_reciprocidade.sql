-- Created on 23/10/2019 by Rafael Ferreira - Mouts (T0032702)
-- RITM0044881
DECLARE
  -- Local variables here

BEGIN
  -- Loop nas Cooperativas definidas pela area de negócio
  FOR rw_coop IN (SELECT cop.cdcooper, cop.nmrescop
                    FROM crapcop cop
                   WHERE cop.cdcooper IN (2, 7, 8, 10, 14, 5, 6, 11, 12, 13)) LOOP
  
    -- Insere o Parametro que ativa da nova reciprocidade
    INSERT INTO crapprm
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
       rw_coop.cdcooper,
       'RECIPROCIDADE_PILOTO',
       'Ativar/Desativar nova reciprocidade para cooperativa. (0 - desativada e 1 - ativada)',
       '1');
  
    -- Insere o Parametro indicando a data de ativação da nova reciprocidade
    INSERT INTO crapprm
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    VALUES
      ('CRED',
       rw_coop.cdcooper,
       'DT_VIG_RECECIPR_V2',
       'Data de vigencia do novo modelo de reciprocidade.',
       '24/10/2019');
  END LOOP;

  COMMIT;
END;
