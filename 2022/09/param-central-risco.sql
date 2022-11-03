DECLARE
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', rw_crapcop.cdcooper, 'EXECUTAR_CARGA_CENTRAL', 'Executar carga da central de risco (0-processo normal/1-nova carga/2-executar ambos)', '0');
  END LOOP;
  COMMIT;
END;
