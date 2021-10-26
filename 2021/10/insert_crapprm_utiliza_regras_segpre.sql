BEGIN
  INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'UTILIZA_REGRAS_SEGPRE', 'Utiliza novas regras prestamista SEGPRE S (SIM) e N (NÃO)', 'N');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
