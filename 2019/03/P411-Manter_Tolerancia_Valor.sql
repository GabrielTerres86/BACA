-- Script para manter parametro de tolerancia de valor
BEGIN
  FOR idx IN 0..16 LOOP
    INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
      VALUES('CRED', idx, 'CD_TOLERANCIA_DIF_VALOR', '% Tolerancia na diferença de valor', 0.05);
  END LOOP;
END;
