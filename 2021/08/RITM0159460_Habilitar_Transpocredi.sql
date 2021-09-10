-- Created on 25/08/2021 by Jose Dill - Mouts (T0032120)
-- RITM0159460 - Habilitar nova reciprocidade para Transpocredi
-- 
DECLARE
  -- Local variables here

BEGIN
  -- Loop nas Cooperativas definidas pela area de negócio
  FOR rw_coop IN (SELECT cop.cdcooper, cop.nmrescop
                    FROM crapcop cop
                   WHERE cop.cdcooper IN (9)) LOOP
  
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
       '31/08/2021');
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaoInterna(pr_compleme => 'RITM0159460');  
END;
