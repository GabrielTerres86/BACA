DECLARE
  CURSOR cr_crapcop IS
    SELECT cdcooper FROM cecred.crapcop WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    UPDATE cecred.crapprm
       SET dsvlrprm = dsvlrprm || ';0'
     WHERE cdcooper = rw_crapcop.cdcooper
       AND UPPER(nmsistem) = 'CRED' 
       AND UPPER(cdacesso) = 'RISCO_CARTAO_BACEN';
  END LOOP;
  COMMIT;
END;
