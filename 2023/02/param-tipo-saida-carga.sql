DECLARE
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', rw_crapcop.cdcooper, 'TPEXEC_SAIDAS_CENTRAL', 'Tipo de execucao das saidas geradas na carga da central (1-saidas diarias / 2-saidas mensais)', '2');
  END LOOP;
  
  UPDATE crapprm SET dsvlrprm = '2' WHERE nmsistem = 'CRED' AND cdcooper IN (8, 10, 12) AND cdacesso = 'EXECUTAR_CARGA_CENTRAL';
  
  UPDATE gestaoderisco.tbrisco_central_carga c SET c.cdstatus = 7 where cdcooper IN (8, 10, 12);
  
  COMMIT;
END;
